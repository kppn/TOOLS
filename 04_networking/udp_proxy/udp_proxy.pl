#!/usr/bin/perl -w

use IO::Socket;
use IO::Select;

if ($#ARGV < 2) {
	print_usage();
	exit(1);
}




($addrport0, $addrport1) = split(/[-]/, $ARGV[0]);
($address{dst_0}->{addr}, $address{dst_0}->{port}) = split(/[:]/, $addrport0);
($address{own_0}->{addr}, $address{own_0}->{port}) = split(/[:]/, $addrport1);

($addrport0, $addrport1) = split(/[-]/, $ARGV[1]);
($address{own_1}->{addr}, $address{own_1}->{port}) = split(/[:]/, $addrport0);
($address{dst_1}->{addr}, $address{dst_1}->{port}) = split(/[:]/, $addrport1);

print "socket 0\n";
print "  $address{own_0}->{addr}\n";
print "  $address{own_0}->{port}\n";
print "  $address{dst_0}->{addr}\n";
print "  $address{dst_0}->{port}\n";
print "socket 1\n";
print "  $address{own_1}->{addr}\n";
print "  $address{own_1}->{port}\n";
print "  $address{dst_1}->{addr}\n";
print "  $address{dst_1}->{port}\n";


$socket0 = IO::Socket::INET->new(
	LocalAddr => $address{own_0}->{addr},
	LocalPort => $address{own_0}->{port},
	PeerAddr  => $address{dst_0}->{addr},
	PeerPort  => $address{dst_0}->{port},
	Proto     => "udp"
) or die "socket0 open error $!\n" ;

$socket1 = IO::Socket::INET->new(
	LocalAddr => $address{own_1}->{addr},
	LocalPort => $address{own_1}->{port},
	PeerAddr  => $address{dst_1}->{addr},
	PeerPort  => $address{dst_1}->{port},
	Proto     => "udp"
) or die "socket1 open error $!\n" ;


$readset = IO::Select->new();
$readset->add($socket0);
$readset->add($socket1);


while(1) {
	@ready = $readset->can_read;
	foreach $fh (@ready) {
		if ($fh == $socket0) {
			# print "socket 0 recv\n";
			$socket0->recv($data, 65535);
			$socket1->send($data);
		}
		elsif ($fh == $socket1) {
			# print "socket 1 recv\n";
			$socket1->recv($data, 65535);
			$socket0->send($data);
		}
		else {
			print "unknown host\n";
			exit(1);
		}
	}
}




sub print_usage {
print <<EOL;

    usage
      ./udp_proxy peer0addr:port-own0addr:port own1addr:port-peer1addr:port

      e.g) 
          (1) Proxy 2 hosts.
                
                On proxy machine
                    ./udp_proxy 172.16.0.100:2123-172.16.0.1:2123 192.168.0.1:2123-192.168.0.100:2123
                    
                      +-------------------+
                      | host1             |
                      +-------------------+
                              | 172.16.0.100:2123
                              | 
                              | 172.16.0.1:2123
                      +-------------------+
                      | proxy machine     |
                      | (udp_proxy)       |
                      +-------------------+
                              | 192.168.0.1:2123
                              |
                              | 192.168.0.100:2123
                      +-------------------+
                      | host2             |
                      +-------------------+

          (2) Proxy Internal

                On host2
                    ./udp_proxy 172.16.0.100:2123-172.16.0.1:2123 202.0.0.1:2123-192.168.0.100:2123
                    
                      +-------------------+
                      | host1             |
                      +-------------------+
                              | 172.16.0.100:2123
                              |  
                              | 172.16.0.1:2123
                      +-------|--------------------+
                      |    +-----------+           |
                      |    |udp_proxy  |           |
                      |    +-----------+           |
                      |       | 202.0.0.1:2123     |
                      |       |                    |
                      |       | 192.168.0.100:2123 |
                      |    +-----------+           |
                      |    |Orig App   |           |
                      |    +-----------+           |
                      | host2                      |
                      +----------------------------+
EOL
}
