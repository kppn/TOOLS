#!/usr/bin/perl

for ($i = 5; $i <= 15; $i++) {
	`./p.pl $i > tmp.txt`;
	@reply  = `./udpsend.pl -s 172.30.32.153:50000 -d 172.30.32.153:50001 tmp.txt`;
	print @reply;
	print "------------------------------\n";
}



