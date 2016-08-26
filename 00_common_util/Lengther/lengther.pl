

while (<>) {
	chomp();
	s/#.*//;
	s/[ \t]+//g;
	#print;
	$total += length($_);
}

$bytes = $total / 2;

printf("Length :  %d,  0x%x\n", $bytes, $bytes);

