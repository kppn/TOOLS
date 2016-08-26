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

$gtp_h_str = "30010002deadbeaf0000";
$gtp_echo = pack("H*", $gtp_h_str);

for ($i = 0; $i < 3; $i++) {
	print "===!!!!!! GTP Echo Send !!!===\n";
	dump_data($gtp_echo);
	print "\n";
	send(OSOCKET, $gtp_echo, 0, $dsock_addr);
	
	recv(OSOCKET, $gtp_echo_resp, 65536, 0);
	print "===!!!!!! GTP Echo Resp Recieve !!!===\n";
	dump_data($gtp_echo_resp);
	print "\n";
	
	sleep(3);
}


