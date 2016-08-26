#!/usr/bin/perl


if (length @ARGV != 1) {
	print "seq_numbering.pl file";
	exit(1);
}

open(FILE, "<$ARGV[0]") or die "file open fail\n";


$n = 1;
while($line = <FILE>) {
	if ($line =~ /^     .   ?([0-9]{1,2}) ,/) {
		#print $line;
		$old_num = $1;

		$line =~ s/^     .   ?[0-9]{1,2} ,//;
		$sep = $n == 1 ? ' ' : ',';
		$old_num_print = sprintf("OLD : %2d   |", $old_num);
		print STDERR $old_num_print;
		printf("     %s  %2d ,", $sep, $n);
		print $line;

		$n++;
	}
	else {
		print $line;
	}
}



