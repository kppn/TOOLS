use Socket;



sub dump_data {
	my ($val) = @_;
	my ($j, @nums);
	
	@nums = unpack("C*", $val);
	$j = 0;
	
	foreach $num (@nums) {
		printf("%02x", $num);
		if ($j % 2 == 1) {
			print " ";
		}
		if ($j == 15) {
			print "\n";
			$j = 0;
		}
		else {
			$j++;
		}
	}
	print "\n";
}


sub decap_gtp_header {
	my ($buf) = @_;
	my ($tmp, $ret);
	
	@nums = unpack("C*", $buf);
	$tmp = pack("C*", @nums[8 .. $#nums]);
}


sub is_icmpv6{
	my ($buf) = @_;
	my (@nums);
	
	@nums = unpack("C*", $buf);
	
	if ($nums[6] == 0x3a) {
		1;
	}
	else {
		0;
	}
}


sub is_rs{
	my ($buf) = @_;
	my (@nums);

	@nums = unpack("C*", $buf);
	
	if ($nums[40] == 0x85) {
		1;
	}
	else {
		0;
	}
}



socket(OSOCKET, PF_INET, SOCK_DGRAM, 0);
bind(OSOCKET, pack_sockaddr_in(2152, inet_aton("172.16.1.1")));
$dsock_addr = pack_sockaddr_in(2152, inet_aton("172.16.1.10"));

$gtp_h_str = "30ff0058deadbeaf";


$icmpv4_echo_req_str = $gtp_h_str . $ipv4_str . $icmpv4_str;
$icmpv4_echo_req = pack("H*", $icmpv4_echo_req_str);

# TCP SYN from 10.0.0.1 to 192.168.1.10
$ipv4_str = "4510003c2462400040064a970a000001c0a8010a";
$tcp_syn_str = "eb9400172f217d0c00000000a00216d07f540000020405b40402080af4e1596e0000000001030306";
$tcp_syn_packet_str = $gtp_h_str . $ipv4_str . $tcp_syn_str;

$tcp_syn = pack("H*", $tcp_syn_packet_str);

for ($i = 0; $i < 3; $i++) {
	print "===!!!!!!  TCP SYN Send !!!===\n";
	dump_data($tcp_syn);
	print "\n";
	send(OSOCKET, $tcp_syn, 0, $dsock_addr);
	
	recv(OSOCKET, $tcp_syn_ack, 65536, 0);
	print "===!!!!!!  TCP SYN-ACK Recieve !!!===\n";
	dump_data($tcp_syn_ack);
	print "\n";
	
	sleep(3);
}


