#!/usr/bin/perl

use Socket;

$srcaddr = "";
$srcport = "";
$dstaddr = "";
$dstport = "";


while ($arg = shift @ARGV) {
	if ($arg eq "-s") {
		$tmp = shift @ARGV;
		$tmp =~ /(.*):(.*)/;
		$srcaddr = $1;
		$srcport = $2;
		next;
	}
	if ($arg eq "-d") {
		$tmp = shift @ARGV;
		$tmp =~ /(.*):(.*)/;
		$dstaddr = $1;
		$dstport = $2;
		next;
	}
	$file = $arg and last;
}


open(INFILE, "<$file") or die "file open failure\n";
@packet_str_array = <INFILE>;
close(INFILE);
foreach $line (@packet_str_array) {
	chomp;
	$line =~ s/#.*//;
	$line =~ s/\s+//g;
	$packet_str .= $line;
}
$packet = pack("H*", $packet_str);


if ($srcport eq "") {
	$srcport = 0;
}


socket(SOCKET, PF_INET, SOCK_DGRAM, 0);

if ($srcaddr ne "") {
	$srcaddr_in = inet_aton($srcaddr);
	bind(SOCKET, sockaddr_in($srcport, $srcaddr_in));
}

$dstaddr_in = inet_aton($dstaddr);
$sock_addr = sockaddr_in($dstport, $dstaddr_in);

send(SOCKET, $packet, 0, $sock_addr);




