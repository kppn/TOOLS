#!/usr/bin/perl -w

use IO::Socket;

($addrport0, $addrport1) = split(/[-]/, $ARGV[0]);
($address{dst_0}->{addr}, $address{dst_0}->{port}) = split(/[:]/, $addrport0);
($address{own_0}->{addr}, $address{own_0}->{port}) = split(/[:]/, $addrport1);

print	"$address{own_0}->{addr}\n";
print	"$address{own_0}->{port}\n";
print	"$address{dst_0}->{addr}\n";
print	"$address{dst_0}->{port}\n";

$socket0 = IO::Socket::INET->new(
	LocalAddr => $address{own_0}->{addr},
	LocalPort => $address{own_0}->{port},
	PeerAddr  => $address{dst_0}->{addr},
	PeerPort  => $address{dst_0}->{port},
	Proto     => "udp"
) or die "socket0 open error $!\n" ;


$socket0->send("hoge");

