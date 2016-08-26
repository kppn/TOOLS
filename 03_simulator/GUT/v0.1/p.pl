$i = 0;

while(<>) {
	chomp;
	print "\t\tdata[$i] = 0x$_;\n";
	$i++;
}


