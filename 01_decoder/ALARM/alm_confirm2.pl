

while (<>) {
	next if /^C/;
	
	if (/^M..... (20\d\d\/..\/.. ..:..:..) (.*)/) {
		$time = $1;
		$serv = $2;

		$nextline = <STDIN>;
		$nextline =~ / (\d{7}) /;
		$alm_num = $1;

		$almmsg = <STDIN>;
		chomp($almmsg);

		print "$alm_num $time $serv\t$almmsg\n";
	}
}


