#!/usr/bin/perl

if ($#ARGV == 0) {
	$start_time = $ARGV[0];
}
else {
	$start_time = "0000";
}


while ($line = <STDIN>) {
	if ($line =~ /^C/) {
		next;
	}

	if ($line =~ m{ [0-9]{4}/[0-9]{2}/[0-9]{2} ([0-9]{2}):([0-9]{2}):[0-9]{2} } ) {
		$retrieve_time = $1 . $2;
		next if $retrieve_time <= $start_time;

		chomp($line);
		$line =~ s/^M..... //;

		$message_num = <STDIN>;
		chomp($message_num);
		$message_num =~ s/[0-9]{24}//;
		$message_num =~ s/^M..... //;

		$message = <STDIN>;
		$message =~ s/^M..... //;
		chomp($message);

		print "$message_num  $line  $message\n";
		
		$msghash{$message_num}->[0] = $message;
		$msghash{$message_num}->[1] += 1;
	}
}

print "\n\n";
print "---- message output statistics ---------------------------------------------------------\n";

foreach $key (sort keys %msghash) {
	printf("%7d  ", $msghash{$key}->[1]);
	print "$key  ";
	print "$msghash{$key}->[0]", "\n";
}


