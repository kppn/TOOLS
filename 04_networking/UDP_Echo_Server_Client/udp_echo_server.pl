#!/usr/bin/perl

use Socket;
use Time::HiRes qw/usleep/;

$src_addr = $ARGV[0];
$src_port = 7;

socket(OSOCKET, PF_INET, SOCK_DGRAM, 0);
bind(OSOCKET, pack_sockaddr_in($src_port, inet_aton($src_addr)));

$msg = 'a' x ($size - 8 - 20); # 8:UDP Header, 20: IP Header

while(1) {
	$dsock_addr = recv(OSOCKET, $msg, 10000, 0);
	#print unpack("H*", $dst_addr), "\n";
	send(OSOCKET, $msg, 0, $dsock_addr);
}


