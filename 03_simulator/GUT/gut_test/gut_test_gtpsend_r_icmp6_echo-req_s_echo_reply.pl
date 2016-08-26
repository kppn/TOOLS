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


sub is_icmpv6_echo_req{
	my ($buf) = @_;
	my (@nums);
	
	@nums = unpack("C*", $buf);
	
	if ($nums[40] == 0x80) {
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


sub icmp_checksum
{
	my ($buf) = @_;
	my (@nums, $sum, $i, $len);
	
	@nums = unpack("S*", $buf);
	$len = $#nums + 1;
	
	$i = 0;
	while ($len > 0) {
		#printf("for: %04x\t", $nums[$i]);
		$sum += $nums[$i];
		$i++;
		$len -= 1;
		#printf("%08x\n", $sum);
	}
	if ($len == 1) {
		$sum += $nums[$i] * 0x100;
	}
	
	$sum = ($sum & 0xffff) + ($sum >> 16);
	$sum = ($sum & 0xffff) + ($sum >> 16);
	
	$sum_u = ~$sum & 0xff;
	$sum_l = (~$sum >> 8) & 0xff;
	
	($sum_u, $sum_l);
}


socket(OSOCKET, PF_INET, SOCK_DGRAM, 0);
bind(OSOCKET, pack_sockaddr_in(2152, inet_aton("172.16.1.1")));
$dsock_addr = pack_sockaddr_in(2152, inet_aton("172.16.1.10"));

$gtp_h_str = "30ff0058deadbeaf";
$ipv6_str = "6000000000403aff2003000000000000000000000000000120010000000000000000000000000001";

$pseudo_h_str =             "2003000000000000000000000000000120010000000000000000000000000001000000400000003a";
$icmpv6_str = "810000004e13001017f68f4b2727020008090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f3031323334353637";

$gtp_pack= pack("H*", $gtp_h_str);
$ipv6_pack = pack("H*", $ipv6_str);
$icmpv6_pack   = pack("H*", $icmpv6_str);

$sequence = 0;

while (1) {
	recv(OSOCKET, $buf, 10000, 0);
	
	print "=== UDP Data Recieve ===\n";
	dump_data($buf);
	print "\n";
	
	print "=== User Packet ===\n";
	$user_packet = decap_gtp_header($buf);
	dump_data($user_packet);
	
	if (is_icmpv6($user_packet) and is_icmpv6_echo_req($user_packet)){
		print "===!!!!!!  ICMPv6 Echo Reply !!!===\n";
		
		# Set ICMPv6 ID
		@nums = unpack("C*", $user_packet);
		printf("icmp_id %02x, %02x\n", $nums[44], $nums[45]);
		@icmpv6_unpack = unpack("C*", $icmpv6_pack);
		$icmpv6_unpack[4] = $nums[44];
		$icmpv6_unpack[5] = $nums[45];
		
		# Set Sequence Number
		$icmpv6_unpack[7] = $sequence++;
		if ($sequence > 255) {
			$sequence = 0;
		}
		
		# Checksum Calcuration
		$icmpv6_unpack[2] = 0x00;
		$icmpv6_unpack[3] = 0x00;
		$icmpv6_str = unpack("H*", pack("C*", @icmpv6_unpack));
		$pseudo_icmpv6_pack = pack("H*", $pseudo_h_str . $icmpv6_str);
		($sum_u, $sum_l) = icmp_checksum($pseudo_icmpv6_pack);
		printf("sum : %02x %02x\n", $sum_u, $sum_l);
		$icmpv6_unpack[2] = $sum_u;
		$icmpv6_unpack[3] = $sum_l;
		
		
		$icmpv6_pack = pack("C*", @icmpv6_unpack);
		
		$icmp_reply = $gtp_pack  . $ipv6_pack . $icmpv6_pack;
		dump_data($icmp_reply);
		print "\n";
		send(OSOCKET, $icmp_reply, 0, $dsock_addr);
	}
	
	print "\n";
}


