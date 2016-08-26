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

# ICMP Echo req from 192.168.1.1 to 192.168.1.10
# $ipv4_str = "4500003c50890000800166dc c0a80101 c0a8010a";
# $icmpv4_str = "08004d400001001b6162636465666768696a6b6c6d6e6f7071727374757677616263646566676869";

# ICMP Echo req from 10.0.0.1 to 192.168.1.10
$ipv4_str = "450000540000400040016ef60a000001c0a8010a";
$icmpv4_str = "080069c4a54600076670894b0b2f030008090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f3031323334353637";

$icmpv4_echo_req_str = $gtp_h_str . $ipv4_str . $icmpv4_str;
$icmpv4_echo_req = pack("H*", $icmpv4_echo_req_str);

for ($i = 0; $i < 3; $i++) {
	print "===!!!!!!  ICMP Echo Req Send !!!===\n";
	dump_data($icmpv4_echo_req);
	print "\n";
	send(OSOCKET, $icmpv4_echo_req, 0, $dsock_addr);
	
	recv(OSOCKET, $icmpv4_echo_res, 65536, 0);
	print "===!!!!!!  ICMP Echo Res Recieve !!!===\n";
	dump_data($icmpv4_echo_res);
	print "\n";
	
	sleep(3);
}


