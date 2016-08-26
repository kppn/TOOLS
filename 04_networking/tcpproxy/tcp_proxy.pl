#!/usr/bin/perl

use IO::Socket;
use IO::Select;


$sock_base = IO::Socket::INET->new(
	Listen     => 1,
	LocalAddr  => "192.168.200.1:61500",
	#PeerAddr   => "192.168.200.37",
	Proto      => "tcp",
	Reuse      => 1
) or die "sock_base open fail. $!\n";

$sock_client = $sock_base->accept();

$sock_target = IO::Socket::INET->new(
	# LocalAddr  => "192.168.1.2:61500",
	PeerAddr   => "172.21.64.1:61500",
	Proto      => "tcp",
	Reuse      => 1
) or die "sock_target connect fail. $!\n";

$readset = IO::Select->new();
$readset->add($sock_client);
$readset->add($sock_target);

while (1) {
	@ready = $readset->can_read;
	foreach $fh (@ready) {
		if ($fh == $sock_client) {
			$sock_client->recv($data, 65535);
			$sock_target->send($data);
			$sock_target->flush;
		}
		if ($fh == $sock_target) {
			$sock_target->recv($data, 65535);
			$sock_client->send($data);
			$sock_client->flush;
		}
	}
}



