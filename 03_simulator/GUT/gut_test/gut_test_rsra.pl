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
#$ipv6_str = "6000000000303afffe80000000000000b1cff2562a13016efe800000000000000000000000000002";
$ipv6_str = "6000000000303afffe80000000000000b1cff2562a13016eff020000000000000000000000000002";
$icmpv6_str = "860070b840180e100000000000000000030440c000015180000038400000000020010000000000000000000000000000";
$ra_str = $gtp_h_str . $ipv6_str . $icmpv6_str;

$ra = pack("H*", $ra_str);


while (1) {
	recv(OSOCKET, $buf, 10000, 0);
	
	print "=== UDP Data Recieve ===\n";
	dump_data($buf);
	print "\n";
	
	print "=== User Packet ===\n";
	$user_packet = decap_gtp_header($buf);
	dump_data($user_packet);
	
	if (is_icmpv6($user_packet) and is_rs($user_packet)) {
		print "===!!!!!!  RA Send !!!===\n";
		dump_data($ra);
		print "\n";
		send(OSOCKET, $ra, 0, $dsock_addr);
	}
	
	print "\n";
}


