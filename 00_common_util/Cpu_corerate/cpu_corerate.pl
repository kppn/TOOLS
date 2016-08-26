#!/usr/bin/perl

#==============================================================================
# cpu_corerate.pl
#    
#    CPU使用率をコア毎に表示する
#    収集元は/proc/stat
#    
#      2013/4/1  T.Kondoh
#           初版作成 
#==============================================================================

$sleep_time = 5;


sub percentage
{
	my $user     = $_[0];
	my $user_old = $_[1];
	my $nice     = $_[2];
	my $nice_old = $_[3];
	my $sys      = $_[4];
	my $sys_old  = $_[5];
	my $idle     = $_[6];
	my $idle_old = $_[7];

	my $user_diff = $user_old - $user;
	my $nice_diff = $nice_old - $nice;
	my $sys_diff  = $sys_old  - $sys;
	my $idle_diff = $idle_old - $idle;
	
	$total_diff    = $user_diff + $nice_diff + $sys_diff + $idle_diff;

	if ($total_diff == 0) {
		$total_diff = 1;
	}

	my $user_per = (0.0 + $user_diff) / $total_diff * 100;
	my $nice_per = (0.0 + $nice_diff) / $total_diff * 100;
	my $sys_per  = (0.0 + $sys_diff)  / $total_diff * 100;
	my $idle_per = (0.0 + $idle_diff) / $total_diff * 100;

	$nice_per = 0.0 if $nice_per == -0.0;

	return ($user_per, $nice_per, $sys_per, $idle_per);
}


while ( 1 ) {
	print `date`;
	@statlines = `cat /proc/stat`;

	printf("      user  nice  sys  total  idle\n");
	foreach $line (@statlines) {
		last if $line !~ /cpu/;
		
		@nums = split(/ +/, $line);
		
		$cpustat{$nums[0]}->{cur}->[0] = $nums[1];
		$cpustat{$nums[0]}->{cur}->[1] = $nums[2];
		$cpustat{$nums[0]}->{cur}->[2] = $nums[3];
		$cpustat{$nums[0]}->{cur}->[3] = $nums[4];
		
		($user_per, $nice_per, $sys_per, $idle_per) = 
			percentage(
					$cpustat{$nums[0]}->{cur}->[0],
					$cpustat{$nums[0]}->{old}->[0],
					$cpustat{$nums[0]}->{cur}->[1],
					$cpustat{$nums[0]}->{old}->[1],
					$cpustat{$nums[0]}->{cur}->[2],
					$cpustat{$nums[0]}->{old}->[2],
					$cpustat{$nums[0]}->{cur}->[3],
					$cpustat{$nums[0]}->{old}->[3]);
		
                $cpustat{$nums[0]}->{old}->[0] = $cpustat{$nums[0]}->{cur}->[0];
                $cpustat{$nums[0]}->{old}->[1] = $cpustat{$nums[0]}->{cur}->[1];
                $cpustat{$nums[0]}->{old}->[2] = $cpustat{$nums[0]}->{cur}->[2];
                $cpustat{$nums[0]}->{old}->[3] = $cpustat{$nums[0]}->{cur}->[3];
		
		
		$total = $user_per + $nice_per + $sys_per;
		printf("%4s : %4.1f  %4.1f  %4.1f  %4.1f  %4.1f", $nums[0], $user_per, $nice_per, $sys_per, $total, $idle_per);
		print "\n";
	
	}
	print "\n";

	sleep $sleep_time;
}
	
