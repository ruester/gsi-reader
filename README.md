GSI Reader
==========

Simple reader for GSI files.

Example
-------

The content of the GSI file:
~~~
*11....+0000000000004009 81...0+0000004515858615 82...0+0000005745692643 83...0+0000000000060449
*11....+0000000000004010 81...0+0000004515883911 82...0+0000005745652625 83...0+0000000000060326
*11....+0000000000004001 81...0+0000004515734360 82...0+0000005745641326 83...0+0000000000060856
~~~

Running the script returns following output:

~~~
$ ./gsireader.pl example.GSI
example.GSI:
Punktnr.  Ost E        Nord N       Grnd.hoehe
    4009  4515858,615  5745692,643      60,449
    4010  4515883,911  5745652,625      60,326
    4001  4515734,360  5745641,326      60,856
~~~

Therefore we needed following configuration within the perl script:

~~~
$fieldname{'11'} = 'Punktnr.';
$fieldname{'81'} = 'Ost E';
$fieldname{'82'} = 'Nord N';
$fieldname{'83'} = 'Grnd.hoehe';

$insertat{'81'} = 3;
$insertat{'82'} = 3;
$insertat{'83'} = 3;

$thechar{'81'} = ",";
$thechar{'82'} = ",";
$thechar{'83'} = ",";
~~~
