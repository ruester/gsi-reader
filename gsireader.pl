#!/usr/bin/perl

use warnings;
use Data::Dumper;

%fieldname = ();

# Generell
$fieldname{'11'} = 'Punktnr.';
$fieldname{'12'} = 'Seriennr.';
$fieldname{'13'} = 'Ident.nr.';
$fieldname{'18'} = 'Zeit';
$fieldname{'19'} = 'Zeit';

# Winkel
$fieldname{'20'} = 'Reserviert';
$fieldname{'21'} = 'Hz-Winkel';
$fieldname{'22'} = 'V-Winkel';
$fieldname{'24'} = 'Hz0';
$fieldname{'25'} = 'Hz0 - Hz';
$fieldname{'26'} = 'Offset';
$fieldname{'27'} = 'V0';
$fieldname{'28'} = 'V0 - V';

# Strecken
$fieldname{'30'} = 'Reserviert';
$fieldname{'31'} = 'Schraegstr.';
$fieldname{'32'} = 'Horiz.str.';
$fieldname{'33'} = 'Hoehendiff.';
$fieldname{'34'} = 'S0';
$fieldname{'35'} = 'S0 - S';
$fieldname{'36'} = 'H0';
$fieldname{'37'} = 'H0 - H';
$fieldname{'38'} = 'Horiz. Schraegdist.';

# Codes
$fieldname{'41'} = 'Code';
$fieldname{'42'} = 'Info 1';
$fieldname{'43'} = 'Info 2';
$fieldname{'44'} = 'Info 3';
$fieldname{'45'} = 'Info 4';
$fieldname{'46'} = 'Info 5';
$fieldname{'47'} = 'Info 6';
$fieldname{'48'} = 'Info 7';
$fieldname{'49'} = 'Info 8';

# EDM
$fieldname{'50'} = 'Reserviert';
$fieldname{'51'} = 'Konst.';
$fieldname{'52'} = 'Anz.Mess./St.abw.';
$fieldname{'53'} = 'Signalst.';
$fieldname{'54'} = 'Refr.koeff.';
$fieldname{'55'} = 'rel. Luftf.';
$fieldname{'56'} = 'SIG, DIST';
$fieldname{'57'} = 'Messinfo.';
$fieldname{'58'} = 'Add.konst.';
$fieldname{'59'} = 'PPM';

# Informationen fuer das EDM
$fieldname{'60'} = 'Reserviert';
$fieldname{'61'} = 'Laengsneig.';
$fieldname{'62'} = 'Querneig.';
$fieldname{'63'} = 'Stehachsschiefe';
$fieldname{'64'} = 'Azimut Stehachssch.';

# Bemerkungen
$fieldname{'70'} = 'Reserviert';
$fieldname{'71'} = 'Bemerkung 1';
$fieldname{'72'} = 'Bemerkung 1';
$fieldname{'73'} = 'Bemerkung 1';
$fieldname{'74'} = 'Bemerkung 1';
$fieldname{'75'} = 'Bemerkung 1';
$fieldname{'76'} = 'Bemerkung 1';
$fieldname{'77'} = 'Bemerkung 1';
$fieldname{'78'} = 'Bemerkung 1';
$fieldname{'79'} = 'Bemerkung 1';

# Koordinaten
$fieldname{'80'} = 'Reserviert';
$fieldname{'81'} = 'Ost E';
$fieldname{'82'} = 'Nord N';
$fieldname{'83'} = 'Grnd.hoehe';
$fieldname{'84'} = 'E0';
$fieldname{'85'} = 'N0';
$fieldname{'86'} = 'H0';
$fieldname{'87'} = 'Zielpkt.hoehe';
$fieldname{'88'} = 'Instr.hoehe';

# Nivellier-Informationen
$fieldname{'95'}  = 'Innentemp.';
$fieldname{'330'} = 'Lattenabl.';
$fieldname{'331'} = 'Lattenabl. R';
$fieldname{'332'} = 'Lattenabl. V';
$fieldname{'333'} = 'Lattenabl. S';
$fieldname{'334'} = 'Lattenabl. Abst.';
$fieldname{'335'} = 'Lattenabl. R2';
$fieldname{'336'} = 'Lattenabl. V2';
$fieldname{'374'} = 'Absteckdiff.';
$fieldname{'571'} = 'St.sdiff.';
$fieldname{'572'} = 'St.diff. Summe';
$fieldname{'573'} = 'Zielw.untersch.';
$fieldname{'574'} = 'Str.summe';

# 21.022+0000000023936860 <-- at 5 places from the end put a ','
#               239,36860
$insertat{'21'} = 5;
$insertat{'22'} = 5;

# 31...0+0000000000041712 <-- at 3 places:
#                  41,712
$insertat{'31'} = 3;
$insertat{'32'} = 5;
$insertat{'33'} = 5;
$insertat{'57'} = 5;
$insertat{'81'} = 3;
$insertat{'82'} = 3;
$insertat{'83'} = 3;
$insertat{'87'} = 3;

# decimal seperator
$sep = ",";

# which character should be placed
$thechar{'21'} = $sep;
$thechar{'22'} = $sep;
$thechar{'31'} = $sep;
$thechar{'32'} = $sep;
$thechar{'33'} = $sep;
$thechar{'57'} = $sep;
$thechar{'81'} = $sep;
$thechar{'82'} = $sep;
$thechar{'83'} = $sep;
$thechar{'87'} = $sep;

sub usage {
    print "$0: <GSI file...>\n";
}

sub errmsg {
    print STDERR "$0: " . shift . "\n";
}

sub numchar {
    return $a cmp $b if ($a =~ /[a-zA-Z\.]/ || $b =~ /[a-zA-Z\.]/);
    return $a <=> $b;
}

sub trim {
    $s = shift;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}

sub remove_leading_zeros {
    $s = shift;
    $s =~ s/^0+//;
    return "0" . $s if (substr($s, 0, 1) =~ /[,.]/);
    return $s;
}

sub remove_trailing_dots {
    $s = shift;
    $s =~ s/\.+$//;
    return $s;
}

if ($#ARGV < 0) {
    usage();
    exit(1);
}

# $numfiles = $#ARGV + 1;

foreach $fname (@ARGV) {
    open(FH, "<", $fname)
        or errmsg("could not open file '$fname'");

    # support \r, \n and \r\n line endings
    local $/ = undef;
    @lines = split /\r\n|\n|\r/, <FH>;

    $count = 0;
    %table = ();

    foreach $line (@lines) {
        $count++;

        @s    = ();
        $line = trim($line);

        next if (length($line) == 0);

        @s = split / +/, $line;

        next if ($#s == 0);

        if (substr($s[0], 0, 1) ne '*') {
            errmsg("$fname: no starting character * at line #$count, continuing anyway");
        } else {
            $s[0] =~ s/.//; # remove '*'
        }

        $count_f = 0;

        foreach $i (@s) {
            $count_f++;

            # 410001+0000000000000003

            $i  = trim($i);
            @fv = split /\+|-/, $i, 2;

            # 410001 0000000000000003

            if ($#fv != 1) {
                errmsg("$fname: line #$count: unable to handle field #$count_f");
                next;
            }

            $known = 0;
            $index = substr($fv[0], 0, 2);

            # 410001 or 22.022 or 333.28
            foreach $p (keys %fieldname) {
                next if ($p ne $index);
                
                $known = 1;
                last;
            }

            if (not $known) {
                # try extended index
                $index = substr($fv[0], 0, 3);

                foreach $p (keys %fieldname) {
                    next if ($p ne $index);

                    $known = 1;
                    last;
                }
            }

            if (not $known) {
                errmsg("$fname: unknown index at line #$count and field #$count_f: '$fv[0]'");
                $index = $fv[0]; # take complete sequence
            }

            # ...{41} = 0000000000000003
            $table{$count}{$index} = $fv[1];
        }
    }

    %allkeys = ();
    %max     = ();

    # strip zeros and insert desired delimiters
    # and collect all used indexes
    foreach $row (sort numchar keys %table) {
        foreach $field (sort numchar keys $table{$row}) {
            if (defined $insertat{$field}) {
                substr($table{$row}{$field}, -$insertat{$field}, 0) = $thechar{$field}
            }

            $table{$row}{$field} = remove_leading_zeros($table{$row}{$field});
            $allkeys{$field}     = not undef;
        }
    }

    # get maximum string length for each column
    foreach $field (sort numchar keys %allkeys) {
        $fieldname{$field} = "unknown" if (not defined $fieldname{$field});

        if (not defined $max{$field} or length($fieldname{$field}) > $max{$field}) {
            $max{$field} = length $fieldname{$field};
        }

        foreach $row (sort numchar keys %table) {
            next if (not defined $table{$row}{$field});

            if (length($table{$row}{$field}) > $max{$field}) {
                $max{$field} = length($table{$row}{$field});
            }
        }
    }

    $first = 1;

    print "$fname:\n";

    # print table header
    foreach $field (sort numchar keys %allkeys) {
        print "  " if (not $first);

        printf "% -*s", $max{$field}, $fieldname{$field};

        $first = 0;
    }

    print "\n";

    foreach $row (sort numchar keys %table) {
        $first = 1;

        foreach $field (sort numchar keys %allkeys) {
            if (not defined $table{$row}{$field}) {
                $table{$row}{$field} = '';
            }

            print "  " if (not $first);

            printf "% *s", $max{$field}, $table{$row}{$field};

            $first = 0;
        }

        print "\n";
    }

    close(FH)
        or errmsg("could not close file '$fname'");
}
