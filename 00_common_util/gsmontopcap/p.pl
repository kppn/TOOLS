
while (chomp($line = <>)) {
	$line =~ s/^CD[0-9]{4} //;
	push @lines, $line;
}


while ($line = shift @lines) {
	print $line;
}
