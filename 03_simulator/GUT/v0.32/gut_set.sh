#!/usr/bin/perl

$GW  = '172.30.33.37';        #GWのIPアドレスを設定
$IMSI= '440101540040304';    #試験で使用するIMSIを設定

$RSH = '/usr/bin/rsh';


#==================================================================
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

gut_set.xx [-n s1|s5] [-m P|R] [-c n] [(config file)]

  command line options

     node setting
	-n s1: perform S1-u GTP for S-GW
	-n s4: perform S4-u GTP for S-GW
	-n s5: perform S5-GTP(P-GW) for S-GW

	    default: s1

     mode setting
	-m P : Parmanent mode. static IPv6 address configuration
	-m R : RA mode. retreive IPv6 from RA

	    default: R at s1 node
	             P at s5 node (In S5 node, RA mode is ignored) 

     connection selection

	-c n: select connection number when Multi-PDN connected;
	    default: 1

EOL
}


%options = ("mode"	=> "R",
	    "node"	=> "s1",
	    "connection" => 1,
	    "route4"	=> "",
	    "route6"	=> "",
	    "config_file"      => "gut.conf",
	    "config_file_base" => "gut.conf.base"
	    );

for ($i = 0; $i <= $#ARGV; $i++) {
	if ($ARGV[$i] eq '-n') {
		if (($ARGV[$i+1] eq 's1') or 
		    ($ARGV[$i+1] eq 's4') or
		    ($ARGV[$i+1] eq 's5')   ) {
			$options{"node"} = $ARGV[$i+1];
		}
		else {
			usage();
			exit;
		}
	}
	if ($ARGV[$i] eq '-m') {
		if (($ARGV[$i+1] eq 'P') or 
		    ($ARGV[$i+1] eq 'R')   ) {
			$options{"mode"} = $ARGV[$i+1];
			$i += 2;
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
	if ($ARGV[$i] =~ /gut.*conf/) {
		$options{"config_file"} = $ARGV[$i];
		$options{"config_file_base"} = $ARGV[$i] . '.base';
	}
	if ($ARGV[$i] eq '-h') {
		usage();
		exit;
	}
} 
if ( $options{"node"} eq 's5' ) {
	$options{"mode"} = 'P';
}





if ( (! open ( GUT_CONF_BASE, "< $options{'config_file_base'}")) or 
      ! open ( GUT_CONF, "> $options{'config_file'}")         ) {
	print STDERR "File not found.\n";
	exit(-1);
}

@sgbtrc = `$RSH $GW str_sgbtrc imsi $IMSI`;
if ($sgbtrc[0] =~ /str_sgbtrc err/) {
	print STDERR "ERROR: str_sgbtrc err\n";
	exit(1);
}
print "@sgbtrc";


# through while target connection
while ($line = shift @sgbtrc) {
	print "DEGUG: $line";
	last if $line =~ /## pdn information \($options{'connection'}/;
}
if ( $#sgbtrc == 0) {
	print STDERR "Can't find connection number\n";
	exit;
}

while ($line = shift @sgbtrc) {
	chomp($line);
	$ipadr_pgw_u   = $1 if $line =~ /ipadr_pgw_u=([0-9a-z:\.]+)/;
	$enb_addr      = $1 if $line =~ /ipadr_enb_u=([0-9a-z:\.]+)/;
	$sgsn_addr     = $1 if $line =~ /ipadr_sgsn_u=([0-9a-z:\.]+)/;
	$gwp_u_teid    = $1 if $line =~ /teid_u_s1_s4=([0-9a-z:\.]+)/;
	$gwp_u_teid_s8 = $1 if $line =~ /sgw_teid_u_s8=([0-9a-z:\.]+)/;
	$euipv4	       = $1 if $line =~ /ipadr_v4_pdn=([0-9a-z:\.]+)/;
	$euipv6	       = $1 if $line =~ /ipadr_v6_pdn=([0-9a-z:\.]+)/;
	$ipadr_sgw_us8 = $1 if $line =~ /ipadr_own_u_s8=([0-9a-z:\.]+)/;
	last if $line =~ /gbr_for_downlink/;
}


if ( $options{"mode"} eq 'R' and $euipv6 ne "") {
	$euipv6 = "fe80::" . &get_iid($euipv6);
}
$euipv6 .= "/64";


@lines = <GUT_CONF_BASE>;

$fmt = "%-23s=%s\n";

if ($options{"node"} eq 's1' ) {
	foreach $line (@lines) {
		chomp($line);
		if ( $line =~ /^GTP-U_OWN_IP.*=(.*)/ ) {
			printf(GUT_CONF $fmt, "GTP-U_OWN_IP", $enb_addr);
		}
		elsif ( $line =~ /^GWP-U_TEID.*=(.*)/ ) {
			printf(GUT_CONF $fmt, "GWP-U_TEID", $gwp_u_teid);
		}
		elsif ( $line =~ /^EUIPv4.*=(.*)/ ) {
			printf(GUT_CONF $fmt, "EUIPv4"    , $euipv4    );
		}
		elsif ( $line =~ /^EUIPv6.*=(.*)/ ) {
			printf(GUT_CONF $fmt, "EUIPv6"    , $euipv6    );
		} 
		elsif ( ($line =~ /^SERVER_NW_v4.*=(.*)/ ) and 
			($options{'route4'} ne "")      ) {
			printf(GUT_CONF $fmt, "SERVER_NW_v4"    , $options{'route4'} );
		}
		elsif ( ($line =~ /^SERVER_NW_v6.*=(.*)/ ) and 
			($options{'route6'} ne "")      ) {
			printf(GUT_CONF $fmt, "SERVER_NW_v6"    , $options{'route6'} );
		}
		else {
			print GUT_CONF "$line\n";
		}
	}
}
if ($options{"node"} eq 's4' ) {
	foreach $line (@lines) {
		chomp($line);
		if ( $line =~ /^GTP-U_OWN_IP.*=(.*)/ ) {
			printf(GUT_CONF $fmt, "GTP-U_OWN_IP", $sgsn_addr);
		}
		elsif ( $line =~ /^GWP-U_TEID.*=(.*)/ ) {
			printf(GUT_CONF $fmt, "GWP-U_TEID", $gwp_u_teid);
		}
		elsif ( $line =~ /^EUIPv4.*=(.*)/ ) {
			printf(GUT_CONF $fmt, "EUIPv4"    , $euipv4    );
		}
		elsif ( $line =~ /^EUIPv6.*=(.*)/ ) {
			printf(GUT_CONF $fmt, "EUIPv6"    , $euipv6    );
		} 
		elsif ( ($line =~ /^SERVER_NW_v4.*=(.*)/ ) and 
			($options{'route4'} ne "")      ) {
			printf(GUT_CONF $fmt, "SERVER_NW_v4"    , $options{'route4'} );
		}
		elsif ( ($line =~ /^SERVER_NW_v6.*=(.*)/ ) and 
			($options{'route6'} ne "")      ) {
			printf(GUT_CONF $fmt, "SERVER_NW_v6"    , $options{'route6'} );
		}
		else {
			print GUT_CONF "$line\n";
		}
	}
}
if ($options{"node"} eq 's5' ) {
	foreach $line (@lines) {
		chomp($line);
		if ( $line =~ /^GTP-U_OWN_IP.*=(.*)/ ) {
			printf(GUT_CONF $fmt, "GTP-U_OWN_IP", $ipadr_pgw_u);
		}
		elsif ( $line =~ /^GWP-U_TEID.*=(.*)/ ) {
			printf(GUT_CONF $fmt, "GWP-U_TEID", $gwp_u_teid_s8);
		}
		elsif ( $line =~ /^SERVER_NW_v4.*=(.*)/ ) {
			printf(GUT_CONF "%-23s=%s/32\n", "SERVER_NW_v4"    , $euipv4    );
		}
		elsif ( $line =~ /^SERVER_NW_v6.*=(.*)/ ) {
			printf(GUT_CONF "%-23s=%s/128\n", "SERVER_NW_v6"    , $euipv6    );
		} 
		else {
			print GUT_CONF "$line\n";
		}
	}
}

close(GUT_CONF);
close(GUT_CONF_BASE);

exec( "./gut $options{'config_file'} ");


