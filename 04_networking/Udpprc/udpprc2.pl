#!/usr/bin/perl

use Socket;
use Time::HiRes qw/usleep/;

if( $ARGV[0] == "" || $ARGV[0] == "-h" ){
        printf("perl udpprc2.pl START_IPADR END_IPADR BHCA\n");
        exit;
}


sub ipstrtonum {
        my ($ipstr) = @_;
        my $num;

        unless ($ipstr =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) {
                return -1;
        }
        $num = ($1<<24) + ($2<<16) + ($3<<8) + ($4<<0);
}

sub numtoipstr{
        my ($ipnum) = @_;
        my $ipstr;

        $ipstr = ($ipnum>>24) . "." . (($ipnum>>16)&0xff) . "." . (($ipnum>>8)&0xff) . "." . ($ipnum&0xff);
}


$message = "waik up!";

$iprange_start = ipstrtonum($ARGV[0]);
$iprange_end   = ipstrtonum($ARGV[1]);
if ( $iprange_start == -1 or $iprange_end == -1 or
     $iprange_end < $iprange_start)  {
        print "ip address error: $ARGV[0] $ARGV[1]\n";
        print "perl udpprc2.pl START_IPADR END_IPADR BHCA\n";
        exit;
}

$target_ip = $iprange_start;
$bhca = $ARGV[2];
$sleep_nanotime = 1000000.0 / ($bhca / 3600.0) * 0.90; # 0.90 is script exec margin time;

print "$iprange_start\n";
print "$iprange_end\n";


socket(OSOCKET, PF_INET, SOCK_DGRAM, 0);

while (1) {
        $ipstr =  numtoipstr($target_ip);
        #print "$ipstr\n";

        $dsock_addr = pack_sockaddr_in(7, inet_aton($ipstr)) ||  die "pack ng\n";
        send(OSOCKET, $message, 0, $dsock_addr) || die "send ng\n";

        usleep $sleep_nanotime;

        $target_ip++;
        if ($target_ip > $iprange_end) {
                $target_ip = $iprange_start;
        }
}
