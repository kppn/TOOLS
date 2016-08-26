#!/usr/bin/perl

$device = "tungre";
$GW  = '172.30.33.37';        #GWのIPアドレスを設定
$IMSI= '440101540040304';    #試験で使用するIMSIを設定
$RSH = '/usr/bin/rsh';


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

tungre_set.sh [-n gwp|pgw] [-c n] [-r4 (ipv4_route/mask)] [-r6 (ipv6_route/pref_len)]

  command line options

     delete all exisit gre tunnel
	-d

     node setting
	-n sgw: perform S-GW side for P-GW
	-n pgw: perform P-GW side for S-GW

	    default: sgw

     connection selection

	-c n: select connection number when Multi-PDN connected;
	    default: 1

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
	@exist_tunnels = `iptunnel | grep tungre | perl -pe 's/:.*//'`;
	foreach $exist_tunnel (@exist_tunnels) {
		`iptunnel del $exist_tunnel`;
	}
	exit(1);
}


%options = ("node"	=> "sgw",
	    "connection" => 1,
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
		if ($ARGV[$i+1] == 0) {
			usage();
			exit;
		}
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

$cmd_gbtrc = "str_pgbtrc";
if ( $options{"node"} eq 'pgw' ) {
	$cmd_gbtrc = "str_sgbtrc";
}



@gbtrc = `$RSH $GW $cmd_gbtrc imsi $IMSI`;
if ($gbtrc[0] =~ /btrc err/) {
	print STDERR "ERROR: gbtrc err\n";
	exit(1);
}
print "@gbtrc";



# through while target connection
while ($line = shift @gbtrc) {
	last if $line =~ /## pdn information \($options{'connection'}/;
}
if ( $#gbtrc == 0) {
	print STDERR "Can't find connection number\n";
	exit;
}
$device_num = $options{'connection'} - 1;
$device = $device . $device_num;



if ($options{"node"} eq "sgw") {
	do {
		$line = shift @gbtrc;
		$euipv4  = $1 if $line =~ /ipadr_v4_pdn=([0-9a-z:\.]+)/;
		$euipv6  = $1 if $line =~ /ipadr_v6_pdn=([0-9a-z:\.]+)/;
	} until ( $line =~ /\-GW information ###/ );
	
	do {
		$line = shift @gbtrc;
		$ipadr_remote   = $1 if $line =~ /ipadr_own_u=([0-9a-z:\.]+)/;
		$grekey_remote  = $1 if $line =~ /gre_key=([0-9a-z:\.]+)/;
	} until ( $line =~ /\-GW information ###/ );
	do {
		$line = shift @gbtrc;
		$ipadr_own   = $1 if $line =~ /ipadr_sgw_u=([0-9a-z:\.]+)/;
		$grekey_own  = $1 if $line =~ /gre_key=([0-9a-z:\.]+)/;
	} until ( $line =~ /###/ );
}
else {
	do {
		$line = shift @gbtrc;
		$euipv4  = $1 if $line =~ /ipadr_v4_pdn=([0-9a-z:\.]+)/;
		$euipv6  = $1 if $line =~ /ipadr_v6_pdn=([0-9a-z:\.]+)/;
	} until ( $line =~ /-GW information ###/ );
	
	do {
		$line = shift @gbtrc;
		$ipadr_remote   = $1 if $line =~ /ipadr_own_u_s5=([0-9a-z:\.]+)/;
		$grekey_remote  = $1 if $line =~ /gre_key_s5=([0-9a-z:\.]+)/;
	} until ( $line =~ /-GW information ###/ );
	do {
		$line = shift @gbtrc;
		$ipadr_own   = $1 if $line =~ /ipadr_pgw_u=([0-9a-z:\.]+)/;
		$grekey_own  = $1 if $line =~ /gre_key=([0-9a-z:\.]+)/;
	} until ( $line =~ /###/ );
}

$euipv4 = $options{"addr4"} if $options{"addr4"} ne "";
$euipv6 = $options{"addr6"} if $options{"addr6"} ne "";


$ikey = hex $grekey_own;
$okey = hex $grekey_remote;

print "TUNNEL CREATE: $device \n";

system("iptunnel add $device mode gre local $ipadr_own remote $ipadr_remote ikey $ikey okey $okey ttl 255");
system("ip link set $device up");

system("ip addr add ${euipv4}/32  dev $device") if $euipv4 ne "";
system("ip addr add ${euipv6}/64 dev $device") if $euipv6 ne "";

system("ip route add $options{'route4'} dev $device") if $options{"route4"} ne "";
system("ip route add $options{'route6'} dev $device") if $options{"route6"} ne "";

