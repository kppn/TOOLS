#!/usr/bin/perl

while (<>) {
	if (m{^CS.*([0-9]{2}/[0-9]{2}/[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2}.*)}) {
		$filename = "${1}_${2}";
		$filename =~ s{ }{_}g;
		$filename =~ s{/}{}g;
		$filename =~ s{:}{}g;
		open(FILE, ">$filename");

		$_ =~ s{^......}{};
		print FILE $_;
		while (<>) {
			last if $_ =~ /^CE/;
			$_ =~ s{^......}{};
			print FILE $_;
		}

		close(FILE);
	}
}


