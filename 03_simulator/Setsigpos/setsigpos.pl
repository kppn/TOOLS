#!/usr/bin/perl 

$debug = 1;

if ($ARGV[0] eq "") {
	print "usage : setsigpos.pl (filename)\n";
	print "\n";
	exit;
}

open(SCENARIO, "<$ARGV[0]") or die "file open failure\n";

while (<SCENARIO>) {
	push @alllines, $_;
	if ( /^\s*pdu\s+([a-zA-Z_0-9]+)/ ) {
		$signame = $1;
		print STDERR "DEGUG: pdu found: $signame\n" if $debug;

		while ($line = <SCENARIO>) { 
			$line =~ s/\r\n/\n/;
			push @alllines, $line;
			chomp($line);
			last if $line =~ /}/;
			if ( $line =~ /#\[(POS_[A-Z1-9_]+)\]/ ) {
				$posname = $1;
				print STDERR "DEBUG: pos found: $posname : $offset \n" if $debug;
				$positions{$signame}->{$posname} = $offset;
			}
			$line =~ s/#.*//;
			$line =~ s/ //g;
			$line =~ s/\t//g;
			$line =~ s/[\{\}]//g;
			$offset += length($line) / 2;
			print STDERR "DEBUG: line   : $line  \n" if $debug;
			print STDERR "DEBUG: offset : $offset\n" if $debug;
		}
	}
	$offset = 0;
}


print STDERR "DEBUG: POSITION DATA ======================== \n" if $debug;
foreach $signame (keys %positions) {
	foreach $posname ( keys %{$positions{$signame}}) {
		$offset = $positions{$signame}->{$posname};
		print STDERR "DEBUG: ${signame}_$posname : $offset\n" if $debug;
		push @position_vals, "\tprivate ${signame}_${posname}\t= $offset;";
	}
}

close(SCENARIO);

open(TMPFILE, ">$ARGV[0].tmp");
$do = 1;
foreach $line (@alllines) {
	$tmpline = $line;

	$tmpline =~ s/#.*//;
	next if $tmpline =~ /private.*_POS_/;

	if ( ($tmpline =~ /^\s*transit/) and $do ) {
		foreach $val (sort @position_vals) {
			print TMPFILE "$val\n";
		}
		print TMPFILE "\n";
		$do = 0;
	}
	print TMPFILE "$line";
}

close(TMPFILE);


