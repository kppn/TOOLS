#!/usr/bin/perl


if ( $#ARGV < 0 ) {
	print "usage: shift_trf.pl CUI_TRAFFIC_FILE.log\n";
	print "\n";
	exit(1);
}

$ARGV[0] =~ /([A-Z0-9_]+)/;
$node_name = $1;

# retrieve scenario names in file
open(FILE, "< $ARGV[0]");
while ($line = <FILE>) {
	if ($line =~ /^#.* ([0-9a-zA-Z_\-]+) /) {
		next if ($1 =~ /Node/);
		$scenario_names{$1}++;
	}
}
close(FILE);


foreach $scenario_name (keys %scenario_names) {
	$output_file_name_base = "${node_name}_${scenario_name}_stat_";
	for ($i = 1; i < 10; $i++) {
		$output_file_name_tmp = $output_file_name_base . $i . ".csv";
		unless (-e output_file_name_tmp) {
			last;
		}
	}
	$output_file_name = $output_file_name_tmp;
	`cat $ARGV[0] | perl shift_trf_cui_csv.pl $scenario_name > $output_file_name`;
}

