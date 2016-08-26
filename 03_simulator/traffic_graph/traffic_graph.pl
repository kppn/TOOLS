#!/usr/bin/perl


$graph = 1;
if ($ARGV[0] eq '-G') {
	$dummy = shift(@ARGV);
	$graph = 0;
}

$file   = $ARGV[0];
$nline  = $ARGV[1];
$target = $ARGV[2];

if (scalar(@ARGV) == 0) {
	print_usage();
	exit(1);
}


$readline = $nline + 1;
@lines = `tail -n $readline $file`;

$title = `head -n 1 $file`;
@params = split(/,/, $title);

if (scalar(@ARGV) == 1) {
	$line = `tail -n 1 $file`;
	@numbers = split(/,/, $line);
	for ($i = 0; $i <= $#params; $i++) {
		printf("%3d %s %4d\n", $i+1, $params[$i], $numbers[$i]);
	} 
	exit;
}


for ($i = 0; $i <= $#params; $i++) {
	if ($params[$i] eq $target) {
		$target_num = $i;
		last;
	}
}


@numbers_1st = split(/,/, $lines[0]);
@numbers_2nd = split(/,/, $lines[1]);
$num_diff = $numbers_2nd[$target_num] - $numbers_1st[$target_num];

if ($num_diff < 50) {
	$scale = 1.0
}
elsif ($num_diff < 100) {
	$scale = 0.5;
}
else {
	$scale = 0.1;
}

$num_old = $numbers_1st[$target_num];
foreach $line (@lines) {
	@numbers = split(/,/, $line);
	$time = $numbers[0];
	$num = $numbers[$target_num];

	$num_diff = $num - $num_old;

	$num_scaled = int($num_diff * $scale);
	$num_scaled = 1 if ($num_scaled == 0 and $num_diff != 0);

	if ($graph == 1) {
		$bar = '*' x $num_scaled;
	}
	else {
		$bar = '';
	}
	
	printf("%s   %4d   %s\n", $time, $num_diff, $bar);

	$num_old = $num;
}


sub print_usage
{
print <<EOL; 
    usage

        print items 
            traffic_graph.pl csvfile

        print graph
            traffic_graph.pl csvfile nline elemname

              e.g.) traffic_graph.pl 131127_010_RAU_intra_RNC_stat_1.csv 10 SND_RA_UPDATE_REQUEST

                    20131127_195608000      0
                    20131127_195618000    390   ***************************************
                    20131127_195628000    390   ***************************************
                    20131127_195638000    390   ***************************************
                    20131127_195648000    390   ***************************************
                    20131127_195658000    390   ***************************************
                    20131127_195708000    390   ***************************************
                    20131127_195718000    390   ***************************************
                    20131127_195728000    390   ***************************************
                    20131127_195738000    389   **************************************
                    20131127_195748000    390   ***************************************
            
EOL
}

