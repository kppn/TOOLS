$ethpath = "C:\\Program Files\\Wireshark\\";


while (chomp($line = <>)) {
	$line =~ s/^CD[0-9]{4} //;
	push @lines, $line;
}


$port = 1812;
$outnum = 0;

while ($line = shift @lines) {
	# port番号判断
	if ($line =~ /gtp signal/) {
		$port = 2123;
		next;
	}
	if ($line =~ /sig=access/) {
		$port = 1812;
		next;
	}
	if ($line =~ /sig=accounting_/) {
		$port = 1813;
		next;
	}
	
	# キャプチャ時間抜き出し
	if ($line =~ /tm=([0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3})/) {
		$time = $1;
		next;
	}
	
	if ($line =~ /data=/) {
		print "hoge\n";
		$line =~ s/data=//;
		unshift @lines, $line;
		while ($line = shift @lines) {
			last if $line eq "";
			$allline .= $line;
		}
		
		$allline =~ s/ //g;
		$allline =~ s/(..)/$1 /g;
		@allhex = split(/ /, $allline);
		
		$outnum++;
		$outfile = $outnum. ".txt";
		$pcapfile = $outnum . ".pcap";
		
		open OUTFILE, (">${outfile}"); 
		# print OUTFILE "$time " if $time;
		print OUTFILE "00000000 ";
		print OUTFILE "@allhex";
		print OUTFILE " \n";
		close(OUTFILE);
		
		print "$outfile $pcapfile\n";
		
		`"${ethpath}text2pcap.exe" -u $port,$port $outfile $pcapfile`;
		
		$time = 0;
		$allline = "";
		@allhex = ();
	}
}

for ($i = $outnum; $outnum > 0; $outnum--){
	$allpcap .= $outnum. ".pcap ";
}

$outpcapname = time() . ".pcap";

`"${ethpath}mergecap.exe" -w $outpcapname  $allpcap`;
exec( " \"${ethpath}ethereal.exe\" $outpcapname  " );


