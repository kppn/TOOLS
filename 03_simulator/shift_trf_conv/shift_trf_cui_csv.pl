#!/usr/bin/perl


if ( $#ARGV < 0 ) {
        print "usage: shift_trf_cui_csv.pl CUI_TRAFFIC_FILE.log\n";
        print "\n";
        exit(1);
}


my $first = 1;	# only first time, print title line 

$scenario_name = $ARGV[0];

while ($line = <STDIN>) {
	if ($line =~ /^#.*$scenario_name /) {
		push(@block, $line);
		while ($line = <STDIN>) {
			push(@block, $line);
			last if ($line =~ /^$/);
		}


		# 計測時刻         : 20121212_133342372
		$block[2] =~ /: ([0-9_]+)/;
		$daytime = $1;

		# 経過時間         : 5.029 [秒]
		$block[3] =~ /: ([0-9\.]+)/;
		$whiletime = $1;

		# シナリオ状態     : ACTIVE
		$block[4] =~ /: ([A-Z]+)/;
		$scenariostate = $1;

		# 負荷制御状態     : GENERATING
		$block[5] =~ /: ([A-Z]+)/;
		$loadstate = $1;

		# 発信数           : 0 [回]
		$block[6] =~ /: ([0-9]+)/;
		$attempt_count = $1;

		# 全体負荷レベル   : 0 [BHCA]
		$block[7] =~ /: ([0-9]+)/;
		$bhca = $1;

		# 加入者数         : 2000 / 10000 [生存数/登録数]
		$block[8] =~ m{: ([0-9]+) / ([0-9]+)};
		$sub_num_registered = $2;
		$sub_num_survive    = $1;

		if ($first) {
			print "計測時刻", 		",";
			print "開始後経過時間",		",";
			print "発信数",			",";
			print "負荷レベル",		",";
			print "シナリオ状態",		",";
			print "負荷制御状態",		",";
			print "加入者登録数",		",";
			print "加入者生存数",		",";
		}
		else {
			print "$daytime", 		',';
			print "$whiletime",		',';
			print "$attempt_count",		',';
			print "$bhca",			',';
			print "$scenariostate",		',';
			print "$loadstate",		',';
			print "$sub_num_registered",	',';
			print "$sub_num_survive",	',';
		}
	

		# through while '-- シナリオ変数 --' 
		$i = 10;
		while (1) {
			last if ($block[$i] =~ /-- /);
			$i++;
		}
		$i++;
		
		# scenario variables
		while ($block[$i] !~ /^$/) {
			$block[$i] =~ /([a-zA-Z0-9_]+)\s+: ([0-9]+)/;
			if ($first) {
				print $1, ",";
			}
			else {
				print $2, ",";
			}
			$i++;
		}
		$first = 0;
		print "\n";
	}

	@block = ();
}



