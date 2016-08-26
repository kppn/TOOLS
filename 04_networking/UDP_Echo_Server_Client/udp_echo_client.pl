#!/usr/bin/perl

use Socket;
use Time::HiRes qw/usleep/;

$src_addr = $ARGV[0];
$dst_addr = $ARGV[1];
$size = $ARGV[2];
$count = $ARGV[3];

$dst_port = 7;
if ($dst_addr =~ /([0-9\.]+):([0-9]+)/) {
	$dst_addr = $1;
	$dst_port = $2;
	print "$dst_addr $dst_port\n";
}

socket(OSOCKET, PF_INET, SOCK_DGRAM, 0);
bind(OSOCKET, pack_sockaddr_in(55555, inet_aton($src_addr)));
$dsock_addr = pack_sockaddr_in($dst_port, inet_aton($dst_addr));

$msg = 'a' x ($size - 8 - 20); # 8:UDP Header, 20: IP Header
for ($i = 0; $i < $count; $i++) {
	send(OSOCKET, $msg, 0, $dsock_addr);
	usleep(10);
}



