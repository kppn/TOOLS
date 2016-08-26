#!/usr/bin/perl

$device = "tun";
$GWU = '192.168.1.161';        #GWUのIPアドレスを設定
$IMSI= '440101540040304';    #試験で使用するIMSIを設定
$RSH = '/usr/bin/rsh';

$AFPDEBUG = '/usr/local/6bin/afpdebug';

#
# Command socket
#
%command_socket = (

OWN => {
IP      => '127.0.0.1',		# command ip   of gut_req.sh. 
PORT    => 50010,		# command port of gut_req.sh. select one of some.
},

DST => {
IP      => '127.0.0.1',		# command ip   of GUT. see gut.conf
PORT    => 50000,		# command port of GUT. see gut.conf
},
);



use Socket;

$dstaddr_in = inet_aton($command_socket{DST}->{IP});
$sock_addr = sockaddr_in($command_socket{DST}->{PORT}, $dstaddr_in);
socket(SOCKET, PF_INET, SOCK_DGRAM, 0) or die "command socket open failure\n";

if ($command_socket{ONW}->{IP} ne "") {
        $srcaddr_in = inet_aton($command_socket{ONW}->{IP});
        bind(SOCKET, sockaddr_in($command_socket{ONW}->{PORT}, $srcaddr_in));
}




sub get_iid() {
	my $original = $_[0];
	my @address;
	my $interfaceId;

	if ($original =~ /::/) {
		# 短縮形式を展開する
		my ($adr_a, $adr_b) = split /::/, $original;
		my @adr_a = split /:/, $adr_a;
		my @adr_b = split /:/, $adr_b;
		for (scalar @adr_a .. 7 - scalar @adr_b) {
		    push @adr_a, 0
		};
		@address = (@adr_a, @adr_b);
	} else {
		@address = split /:/, $original;
	}

	foreach $i (@address) {
		$exp .= sprintf("%04s:", $i)
	}
	chop($exp);

	@tmp = split(/:/, $exp);
	$interfaceId = join(':', @tmp[4..7]);
}


#
# print usage
#
sub usage() {
print <<EOL;

gut_set.sh [-n gwp|pgw] [-c n] [-r4 (ipv4_route/mask)] [-r6 (ipv6_route/pref_len)]

  command line options

     delete all exisit gtp tunnel
	-d

     display all exisit gtp tunnel
	-p

     node setting
	-n sgw: perform S-GW side for P-GW
	-n pgw: perform P-GW side for S-GW

	    default: sgw

     connection selection

	-c n: select connection number when Multi connected;
	    default: first idx of 'echo find | afpdebug'.

     address setting

        -a4 xxx.xxx.xxx.xxx  : set IPv4 addr
	-a6 xxxx:xxxx::xxxx  : set IPv6 addr

     route setting

	-r4 xxx.xxx.xxx.xxx/xx  : set IPv4 route
	-r6 xxxx:xxxx::xxxx/xxx : set IPv6 route

EOL
}

if ( @ARGV == 1 and
     $ARGV[0] eq "-d") {
	$message .= "FLUSH REQUEST\n";
	$message .= "." .					"\n";
	$message .= 						"\n";

	send(SOCKET, $message, 0, $sock_addr);
	recv(SOCKET, $reply_message, 16536, 0);

	@iprules = `ip rule show | grep for_gut`;
	foreach $rule (@iprules) {
		$rule =~ s/.*://;
		$rule =~ s{all}{/0};
		$commad_del_rule = 'ip rule del ' . $rule . "\n";
		`$commad_del_rule`;
	}

	exit(1);
}


if ( @ARGV == 1 and
     $ARGV[0] eq "-p") {
	$message .= "DISPLAY REQUEST\n";
	$message .= "." .					"\n";
	$message .= 						"\n";

	send(SOCKET, $message, 0, $sock_addr);
	recv(SOCKET, $reply_message, 16536, 0);
	exit(1);
}


%options = ("node"	=> "sgw",
	    "connection" => "",
	    "addr4"	=> "",
	    "addr6"	=> "",
	    "route4"	=> "",
	    "route6"	=> ""
	    );

for ($i = 0; $i <= $#ARGV; $i++) {
	if ($ARGV[$i] eq '-n') {
		if (($ARGV[$i+1] eq 'sgw') or 
		    ($ARGV[$i+1] eq 'pgw')   ) {
			$options{"node"} = $ARGV[$i+1];
		}
		else {
			usage();
			exit;
		}
	}
	if ($ARGV[$i] eq '-c') {
		$options{"connection"} = $ARGV[$i+1];
		$i++;
	}
	if ($ARGV[$i] eq '-a4') {
		if ($ARGV[$i+1] eq "") {
			usage();
			exit;
		}
		$options{"addr4"} = $ARGV[$i+1];
		$i++;
	}
	if ($ARGV[$i] eq '-a6') {
		if ($ARGV[$i+1] eq "") {
			usage();
			exit;
		}
		$options{"addr6"} = $ARGV[$i+1];
		$i++;
	}
	if ($ARGV[$i] eq '-r4') {
		if ($ARGV[$i+1] eq "") {
			usage();
			exit;
		}
		$options{"route4"} = $ARGV[$i+1];
		$i++;
	}
	if ($ARGV[$i] eq '-r6') {
		if ($ARGV[$i+1] eq "") {
			usage();
			exit;
		}
		$options{"route6"} = $ARGV[$i+1];
		$i++;
	}
	if ($ARGV[$i] eq '-h') {
		usage();
		exit;
	}
} 








# End User Address. from afpdebug find

$afpdebug_cmd = "'echo find | $AFPDEBUG'";
$cmd_gbtrc = "./exec_command_gwu.sh $GWU $afpdebug_cmd";
@afpdebug_find = `$cmd_gbtrc`;

FIND_SESSION: foreach $line (@afpdebug_find) {
	if ($line =~ /^([0-9]{6}) /) {
		if ($options{"connection"} eq "") {
			$connection = $1;
			last FIND_SESSION;
		}
		else {
			if ($1 == $options{"connection"}) {
				$line_found = $line;
				$connection = $1;
				last FIND_SESSION;
			}
		}
	}
}
if ($connection eq "") {
	print "connection $options{'connection'} not exist.\n";
	print "\n";
	print @afpdebug_find;
	print "\n";
	exit;
}

$line_found =~ /^([0-9a-z]+).* ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})[ \t]+([0-9a-z:]+)/;
$idx = $1;
$euipv4 = $2;
$euipv6 = $3;


# Node IP Address and GRE Key. from afpdebug dump

$afpdebug_cmd = "'echo dump $connection | $AFPDEBUG'";
$cmd_gbtrc = "./exec_command_gwu.sh $GWU $afpdebug_cmd | grep 'if1 info' -A 14";
@afpdebug_dump = `$cmd_gbtrc`;


# determine device number. e.g.) tungre0, tungre1 ..

$max_exist_tunnel_num = -1;

@exist_tunnels = `iptunnel | grep tungre | perl -pe 's/:.*//'`;
foreach $exist_tunnel (@exist_tunnels) {
	$tunnel_usage{$exist_tunnel} = 1;

	$exist_tunnel =~ /$device([0-9]+)/;
	$tunnel_num = $1;
	$max_exist_tunnel_num = $tunnel_num;
}

if ($max_exist_tunnel_num == -1) {
	$tunnel_num = 0;
}
elsif ($max_exist_tunnel_num < 19) {
	$tunnel_num = $max_exist_tunnel_num + 1;
}
else {
	FIND_FREE_TUNNEL_NUM: for ($i = 0; $i < 19; $i++) {
		$tmp_device = $device . $i;
		if ($tunnel_usage{$tmp_device} == undef) {
			$tunnel_num = $i;
			last FIND_FREE_TUNNEL_NUM;
		}
	}
}


$device = $device . $tunnel_num;




if ($options{"node"} eq "sgw" or $options{"node"} eq "pgw") {
	foreach $line (@afpdebug_dump) {
		$teid_remote   = $1 if $line =~ /own_teid += ([0-9a-zx]+)/;
		$teid_own      = $1 if $line =~ /gtp.teid += ([0-9a-zx]+)/;

		$ipadr_remote  = $1 if $line =~ /ip.src_v4 += ([0-9a-z:\.]+)/;
		$ipadr_own     = $1 if $line =~ /ip.dst_v4 += ([0-9a-z:\.]+)/;
	}

	$teid_remote =~ s/^0x//;
	$teid_own    =~ s/^0x//;
}


$euipv4 = $options{"addr4"} if $options{"addr4"} ne "";
$euipv6 = $options{"addr6"} if $options{"addr6"} ne "";

$message .= "ADD REQUEST\n";
$message .= "EBI=" .		"5" .			"\n";
$message .= "GTP-U_OWN_TEID=" .	$teid_own .		"\n";
$message .= "GTP-U_DST_IP=" .	$ipadr_remote .		"\n";
$message .= "GTP-U_DST_TEID=" .	$teid_remote .		"\n";
$message .= "EUIPV4=" .		$euipv4 .		"\n"	if $euipv4 		ne "";
$message .= "SERVER_NW_V4=" .	$options{"route4"} .	"\n"	if $options{"route4"} 	ne "";
$message .= "EUIPV6=" .		$euipv6 .		"\n"	if $euipv6		ne "";
$message .= "SERVER_NW_V6=" .	$options{"route6"} . 	"\n"	if $options{"route6"} 	ne "";
$message .= "." .					"\n";
$message .= 						"\n";



send(SOCKET, $message, 0, $sock_addr);
recv(SOCKET, $reply_message, 16536, 0);



