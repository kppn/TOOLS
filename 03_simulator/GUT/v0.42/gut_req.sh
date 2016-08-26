#!/usr/bin/perl 


##################################################################3
#
# Environment difinition
#

#
# basic configuration
# 
%basic = (

GW    => '172.30.33.41',		# IP of ESPGW FS.
IMSI  => '440101540040304',		# IMSI of test target. it is used for 'sgbtrc imsi $IMSI'.
RSH   => '/usr/bin/rsh',		# don't touch this. 
TRC   => 'str_sgbtrc',

);

#
# Command socket
#
%command_socket = (

OWN => {
IP      => '172.30.32.153',	# command ip   of gut_req.sh. 
PORT    => 50000,		# command port of gut_req.sh. select one of some.
},

DST => {
IP      => '172.30.32.153',	# command ip   of GUT. see gut.conf
PORT    => 50001,		# command port of GUT. see gut.conf
},
);


#
# Permanent routes
#   If no '-r4', '-r6' option's not specified, gut_req.sh use these value.
#
%perm_routes = (

'kopera.ne.jp' => {
   route4 => '192.171.61.0/24',
   route6 => '',
},

'y-mode.docomo.ne.jp' => {
   route4 => '192.168.0.2',
   route6 => '2001:1::1/128',
},

);

#
# End Environment difinition
##################################################################3

use Socket;



#
# print usage
#
sub usage() {
print <<END;

gut_req.sh command ([-e ebi] | [-c n] | [-a apn]) 
             [-n s5] [-m P|R] 
             [-a4 xxx.xxx.xxx.xxx/xx] [-a6 xxxx::xxxx/xxx]
             [-r4 xxx.xxx.xxx.xxx/xx] [-r6 xxxx::xxxx/xxx]
             [-s xxx.xxx.xxx.xxx:xx] [-d xxx.xxx.xxx.xxx:xx] 
  
  
  command kind is follow. Any information is retrieved from sgbtrc.
  
      add      add session request to GUT. speficed by -e, -a, -c .
                  -e : EBI
                  -a : APN. substring matching at first character.
                  -c : connection number of sgbtrc.
               default: '-e 5'.
               
      addall   add all session on sgbtrc.
      
      del      delete session, speficed by -c or -a or -e
               default: '-e 5'.
               
      #replace  delete & add session, speficed by -c or -a or -e
      #         default: '-e 5'.
      #
      # not implemented yet
               
      flush    delete all session from GUT.
  
      disp     display all session from GUT.
  
      #raw      specify REQUEST message file. gut_req.sh send thorough to GUT.
      #
      # not implemented yet
  
      (nothin) means 'add -e 5 '
  
  
  command source and destination  
  
      -s xxx.xxx.xxx.xxx:xx
            gut_req.sh own IP/Port. used to receive reply message from GUT.
            
      -d xxx.xxx.xxx.xxx:xx
            IP/Port of GUT.
  
  
  additional options

     node setting
        -n s1: perform S1-GTP-U(eNB) for S-GW
        -n s4: perform S4-GTP-U(eNB) for S-GW
	-n s5: perform S5-GTP(P-GW) for S-GW
	    default: s1

     IPv6 address setting mode
	-m P : Parmanent mode. static IPv6 address configuration
	-m R : RA mode. retreive IPv6 from RA

	    default: R at s1 node
	             P at s5 node (In S5 node, RA mode is ignored) 

     pdn address
        -a4 "xxx.xxx.xxx.xxx/xx"
        -a6 "xxxx::xxxx/xxx"
        
        in -n s5, address setting is Mandarory.

     routing
        -r4 "xxx.xxx.xxx.xxx/xx"
        -r6 "xxxx::xxxx/xxx"
        
        Don't use this with "addall".

     imsi
	-i "xxxxxxxxxxxxxxx"
		If imsi option specified, ignore "IMSI" variable, and
		use option value. This situation, append bottom 6 digit 
		of imsi to ebi. 
			e.g. 1)
				$ ./gut_req.sh add -i 440101540040304 -e 12

				  -> EBI or ADD REQUEST : 12040304

END
}


sub get_iid() {
	my $original = $_[0];
	my @address;
	my $interfaceId;
	my $exp;

	if ($original =~ /::/) {
		# ’ZkŒ`Ž®‚ð“WŠJ‚·‚é
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




sub split_sgbtrc_block {
	my @sgbtrc = @_;
	my $line;

	while ($line = shift @sgbtrc) {
		push @form_sgbtrc, "blockend" if $line =~ /pdn information/;
		push @form_sgbtrc, $line;
	}
	while ($line = shift @form_sgbtrc)  {
		last if $line =~ /pdn information/;
	}
	unshift(@form_sgbtrc, $line);
	

	for ($i = 0; @form_sgbtrc; $i++) {
		while ($line = shift @form_sgbtrc) {
			if ($line =~ /blockend/) {
				last;
			}
			push @array, $line;
		}
		push @arrayref, [ @array ];
		@array = ();
	}

	return @arrayref;
}


sub is_target {
	my $target_elem = shift @_;
	my $target_value  = shift @_;
	my @sgbtrc = @_;

	foreach $line (@sgbtrc) {
		$line =~ /((pdn ){0,1}[A-Za-z_]+)[ =(]+([0-9a-z\-\.]+)/;
		#print "line   : $line";
		#print "target : $target_elem \t $target_value \n";
		#print "result : $1 \t $3 \n";
		#print "\n";
		return 1 if $target_elem eq $1 and $target_value eq $3;
	}
	return 0;
}


sub construct_add_message {
	my $node = shift;
	my $options_ref = shift;
	my $perm_routes_ref = shift;
	my @sgbtrc = @_;
	
	my $message;
	my $connection;
	my $eps_bearer_id;
	my $apnni;
	my $pdn_type;
	my $ipadr_v4_pdn;
	my $ipadr_v6_pdn;
	my $ipadr_enb_u;
	my $teid_enb_u;
	my $ipadr_sgsn_u;
	my $teid_sgsn_u;
	my $ipadr_own_u_s1_s4;
	my $teid_u_s1_s4;
	my $ipadr_pgw_u;
	my $pgw_teid_u;
	my $ipadr_own_u_s8;
	my $sgw_teid_u_s8;
	my $route4 = "";
	my $route6 = "";
	my %options = %$options_ref;
	my %perm_routes = %$perm_routes_ref;

	#mark
	foreach $line (@sgbtrc) {
		chomp($line);

		$connection		= $1 if $line =~ /pdn information \($options{"connection"}/;
		$eps_bearer_id  	= $1 if $line =~ /eps_bearer_id=([0-9a-z:\.]+)/;
		$apnni			= $1 if $line =~ /apnni=([0-9a-z_:\-\.]+)/;
		$pdn_type		= $1 if $line =~ /pdn_type=([0-9a-z:\.]+)/;
		
		# PDN Address
		$ipadr_v4_pdn		= $1 if $line =~ /ipadr_v4_pdn=([0-9a-z:\.]+)/;
		$ipadr_v6_pdn		= $1 if $line =~ /ipadr_v6_pdn=([0-9a-z:\.]+)/;
		
		# eNB S1
		$ipadr_enb_u		= $1 if $line =~ /ipadr_enb_u=([0-9a-z:\.]+)/;
		$teid_enb_u		= $1 if $line =~ /teid_enb_u=([0-9a-z:\.]+)/;
		
		# SGSN S4
		$ipadr_sgsn_u		= $1 if $line =~ /ipadr_sgsn_u=([0-9a-z:\.]+)/;
		$teid_sgsn_u		= $1 if $line =~ /teid_sgsn_u=([0-9a-z:\.]+)/;
		
		# S-GW S1/S4
		$ipadr_own_u_s1_s4	= $1 if $line =~ /ipadr_own_u_s1_s4=([0-9a-z:\.]+)/;
		$teid_u_s1_s4		= $1 if $line =~ /teid_u_s1_s4=([0-9a-z:\.]+)/;
		
		
		# P-GW S5
		$ipadr_pgw_u		= $1 if $line =~ /ipadr_pgw_u=([0-9a-z:\.]+)/;
		$pgw_teid_u		= $1 if $line =~ /pgw_teid_u=([0-9a-z:\.]+)/;
		
		# S-GW S5
		$ipadr_own_u_s8		= $1 if $line =~ /ipadr_own_u_s8=([0-9a-z:\.]+)/;
		$sgw_teid_u_s8		= $1 if $line =~ /sgw_teid_u_s8=([0-9a-z:\.]+)/;
	}
	
	
	
	# equivalent check
	#
	if ($options{node} eq "s1") {
		# mark
		print "S1 SGW  IP   not found from sgbtrc.\n"   and exit if $ipadr_own_u_s1_s4   eq "";
		print "S1 SGW  TEID not found from sgbtrc.\n"   and exit if $teid_u_s1_s4        eq "";
		print "S4 eNB  TEID not found from sgbtrc.\n"   and exit if $ipadr_enb_u    eq "";
	}
	if ($options{node} eq "s4") {
		# mark
		print "S4 SGW  IP   not found from sgbtrc.\n"   and exit if $ipadr_own_u_s1_s4   eq "";
		print "S4 SGW  TEID not found from sgbtrc.\n"   and exit if $teid_u_s1_s4    eq "";
		print "S4 SGSN TEID not found from sgbtrc.\n"   and exit if $teid_sgsn_u   eq "";
	}
	if ($options{node} eq "s5") {
		# mark
		print "S5 SGW  IP   not found from sgbtrc.\n"   and exit if $ipadr_own_u_s8   eq "";
		print "S5 SGW  TEID not found from sgbtrc.\n"   and exit if $sgw_teid_u_s8    eq "";
		print "S5 PGW  TEID not found from sgbtrc.\n"   and exit if $pgw_teid_u    eq "";
	}

	# IPv6 permanemt mode / ra mode
	#
	if ( $options{"mode"} eq 'R' and $ipadr_v6_pdn ne "") {
		$ipadr_v6_pdn = "fe80::" . &get_iid($ipadr_v6_pdn);
	}
	if ( $options{"mode"} eq 'P' and $ipadr_v6_pdn ne "") {
		$ipadr_v6_pdn .= "/64";
	}
	
	#
	# route setting 
	# mark
	#
	$route4 = $options{route4};
	$route6 = $options{route6};
	if ($options{route4} eq "" and $perm_routes{$apnni}->{route4} ne "") {
		$route4 = $perm_routes{$apnni}->{route4};
	}
	if ($options{route6} eq "" and $perm_routes{$apnni}->{route6} ne "") {
		$route6 = $perm_routes{$apnni}->{route6};
	}
	if ($ipadr_v4_pdn eq "") {
		$route4 = "";
	}
	if ($ipadr_v6_pdn eq "") {
		$route6 = "";
	}

	#
	# S5mode, up side down EUIP/routing 
	#
	if ($options{"node"} eq "s5") {
		if ($options{addr4} eq "" and $options{addr6} eq "") {
			print "-n s5 must specified -a4 or -a6 \n";
			exit(1);
		}
		$route4 = $ipadr_v4_pdn . "/32"  if $ipadr_v4_pdn ne "";
		$route6 = $ipadr_v6_pdn . "/128" if $ipadr_v6_pdn ne "";
		$ipadr_v4_pdn = $options{addr4};
		$ipadr_v6_pdn = $options{addr6};
	}


	# mark
	$message .= "ADD REQUEST\n";
	if ($options{node} eq "s1") {
		$message .= "EBI=${eps_bearer_id}\n";

		$message .= "GTP-U_OWN_TEID=${teid_enb_u}\n";
		$message .= "GTP-U_DST_IP=${ipadr_own_u_s1_s4}\n";
		$message .= "GTP-U_DST_TEID=${teid_u_s1_s4}\n";
		
		$message .= "EUIPV4=${ipadr_v4_pdn}\n"		if $ipadr_v4_pdn ne "";
		$message .= "SERVER_NW_V4=${route4}\n"		if $route4 ne "";
		$message .= "EUIPV6=${ipadr_v6_pdn}\n"		if $ipadr_v6_pdn ne "";
		$message .= "SERVER_NW_V6=${route6}\n"		if $route6 ne "";
	}
	if ($options{node} eq "s4") {
		$message .= "EBI=${eps_bearer_id}\n";

		$message .= "GTP-U_OWN_TEID=${teid_sgsn_u}\n";
		$message .= "GTP-U_DST_IP=${ipadr_own_u_s1_s4}\n";
		$message .= "GTP-U_DST_TEID=${teid_u_s1_s4}\n";
		
		$message .= "EUIPV4=${ipadr_v4_pdn}\n"		if $ipadr_v4_pdn ne "";
		$message .= "SERVER_NW_V4=${route4}\n"	if $route4 ne "";
		$message .= "EUIPV6=${ipadr_v6_pdn}\n"		if $ipadr_v6_pdn ne "";
		$message .= "SERVER_NW_V6=${route6}\n"		if $route6 ne "";
	}
	if ($options{node} eq "s5") {
		$message .= "EBI=${eps_bearer_id}\n";

		$message .= "GTP-U_OWN_TEID=${pgw_teid_u}\n";
		$message .= "GTP-U_DST_IP=${ipadr_own_u_s8}\n";
		$message .= "GTP-U_DST_TEID=${sgw_teid_u_s8}\n";
		
		$message .= "EUIPV4=${ipadr_v4_pdn}\n"		if $ipadr_v4_pdn ne "";
		$message .= "SERVER_NW_V4=${route4}\n"		if $route4 ne "";
		$message .= "EUIPV6=${ipadr_v6_pdn}\n"		if $ipadr_v6_pdn ne "";
		$message .= "SERVER_NW_V6=${route6}\n"		if $route6 ne "";
	}
	$message .= ".\n"; 

	return $message;
}


sub construct_del_message {
	my $options_ref = shift;

	my $message;
	my %options = %$options_ref;

	if ($options{ebi} eq "") {
		print "del command must EBI\n";
		exit(1);
	}

	$message .= "DELETE REQUEST\n";
	$message .= "EBI=$options{ebi}\n";
	$message .= ".\n";

	return $message;
}

sub construct_flush_message {
	my $message;

	$message .= "FLUSH REQUEST\n";
	$message .= ".\n";

	return $message;
}

sub construct_disp_message {
	my $message;

	$message .= "DISPLAY REQUEST\n";
	$message .= ".\n";

	return $message;
}




#######################################################################
#
# main
#
#######################################################################




%options = ("command"	=> "add",
	    "mode"	=> "R",
	    "node"	=> "s1",
	    "ebi"	=> "",
	    "apn"	=> "",
	    "connection"=> "",
	    "addr4"	=> "",
	    "addr6"	=> "",
	    "route4"	=> "",
	    "route6"	=> "",
	    "src"       => "",
	    "dst"       => "",
	    "imsi"	=> "",
	    );


# option decode


@defined_commands = (
	"add", 
	"addall", 
	"del", 
	"replace", 
	"flush", 
	"disp", 
);

while ($arg = shift @ARGV) {
	if ($arg eq "raw") {
		$rawfile = shift @ARGV;
	}
	
	if ($arg =~ /^[a-z]+$/) {
		foreach $def (@defined_commands) {
			if ($arg eq $def) {
				$options{"command"} = $arg;
				$valid_command = 1;
			}
		}
		if ($valid_command != 1) {
			print "unknown command\n";
			exit(1);
		}
	}

	if ($arg eq '-n') {
		$arg = shift @ARGV;
		if (($arg eq 's1') or 
		    ($arg eq 's4') or
		    ($arg eq 's5')   ) {
			$options{"node"} = $arg;
		}
		else {
			usage() and exit;
		}
	}
	if ($arg eq '-m') {
		$arg = shift @ARGV;
		if (($arg eq 'P') or  ($arg eq 'R')) {
			$options{"mode"} = $arg;
		}
		else {
			usage() and exit;
		}
	}
	if ($arg eq '-e') {
		$arg = shift @ARGV;
		$options{ebi} = $arg;
	}
	if ($arg eq '-a') {
		$arg = shift @ARGV;
		$options{apn} = $arg;
	}
	if ($arg eq '-c') {
		if ($arg < 0 or 11 < $arg) {
			usage() and exit;
		}
		$arg = shift @ARGV;
		$options{"connection"} = $arg
	}
	if ($arg eq '-r4') {
		$arg = shift @ARGV;
		if ($arg eq "") {
			usage() and exit;
		}
		$options{"route4"} = $arg;
	}
	if ($arg eq '-r6') {
		$arg = shift @ARGV;
		if ($arg eq "") {
			usage() and exit;
		}
		$options{"route6"} = $arg;
	}
	if ($arg eq '-a4') {
		$arg = shift @ARGV;
		if ($arg eq "") {
			usage() and exit;
		}
		$options{"addr4"} = $arg;
	}
	if ($arg eq '-a6') {
		$arg = shift @ARGV;
		if ($arg eq "") {
			usage() and exit;
		}
		$options{"addr6"} = $arg;
	}
	
	if ($arg eq '-s') {
		$arg = shift @ARGV;
		if ($arg eq "") {
			usage() and exit;
		}
		($command_socket{OWN}->{IP}, $command_socket{OWN}->{PORT}) = split(/:/, $arg);
	}
	if ($arg eq '-d') {
		$arg = shift @ARGV;
		if ($arg eq "") {
			usage() and exit;
		}
		($command_socket{DST}->{IP}, $command_socket{DST}->{PORT}) = split(/:/, $arg);
	}
	if ($arg eq '-i') {
		$arg = shift @ARGV;
		if ($arg eq "") {
			usage() and exit;
		}
		$IMSI = $arg;
	}
	if ($arg eq '-h') {
		usage();
		exit;
	}
} 
if ( $options{"node"} eq 's5' ) {
	$options{"mode"} = 'P';
}


#
# open command socket. (dgram)
#

socket(SOCKET, PF_INET, SOCK_DGRAM, 0) or die "command socket open failure\n";

if ($command_socket{ONW}->{IP} ne "") {
        $srcaddr_in = inet_aton($command_socket{ONW}->{IP});
        bind(SOCKET, sockaddr_in($command_socket{ONW}->{PORT}, $srcaddr_in));
}

$dstaddr_in = inet_aton($command_socket{DST}->{IP});
$sock_addr = sockaddr_in($command_socket{DST}->{PORT}, $dstaddr_in);



#
# execute sgbtrc for FS.
#

if ($options{command} eq 'add' or $options{command} eq 'addall') {
	$basic{IMSI} = $options{imsi} if $options{imsi} ne "";

	@sgbtrc = `$basic{RSH} $basic{GW} $basic{TRC} imsi $basic{IMSI}`;
	if ($sgbtrc[0] =~ /str_sgbtrc err/) {
		print STDERR "ERROR: str_sgbtrc err\n";
		print STDERR "Please check IMSI\n";
		exit(1);
	}
	if ($sgbtrc[0] =~ /Permission/) {
		print STDERR "ERROR: str_sgbtrc err\n";
		print STDERR "Please check FS /root/.rhosts. Add this machine's IP.\n";
		exit(1);
	}
	
	@arrayref = split_sgbtrc_block @sgbtrc;
}



#
# send request message to GUT
#

if ($options{command} eq 'add') {
	my $found = 0;
	my @array;
	my $target_elem;
	my $target_value;

	if ($options{ebi} ne "") {
		$target_elem  = "eps_bearer_id";
		$target_value = $options{ebi};
	}
	elsif ($options{connection} ne "") {
		$target_elem  = "pdn information";
		$target_value = $options{connection};
	}
	elsif ($options{apn} ne "") {
		$target_elem  = "apnni";
		$target_value = $options{apn};
	}
	if ($target_elem eq "") {
		$target_elem = "eps_bearer_id";
		$target_value = "5";
	}
	

	foreach $ref (@arrayref) {
		@array = @$ref;
		if (is_target($target_elem, $target_value, @array)) {
			$found = 1;
			last;
		}
	}
	if ($found == 0) {
		print "requested connection not found from sgbtrc. $target_elem:$target_value\n";
		exit;
	}

	$request_message = construct_add_message $options{node}, \%options, \%perm_routes, @array;
	print $request_message;
	send(SOCKET, $request_message, 0, $sock_addr);
	recv(SOCKET, $reply_message, 16536, 0);
	print $reply_message;
}
elsif ($options{command} eq 'addall') {
	foreach $ref (@arrayref) {
		my @array = @$ref;
		$request_message = construct_add_message $options{node}, \%options, \%perm_routes, @array;
		print $request_message;
		send(SOCKET, $request_message, 0, $sock_addr);
		recv(SOCKET, $reply_message, 16536, 0);
		print $reply_message;
	}
}
elsif ($options{command} eq 'del') {
	$request_message = construct_del_message \%options;
	print $request_message;
	send(SOCKET, $request_message, 0, $sock_addr);
	recv(SOCKET, $reply_message, 16536, 0);
	print $reply_message;
}
elsif ($options{command} eq 'flush') {
	$request_message = construct_flush_message;
	print $request_message;
	send(SOCKET, $request_message, 0, $sock_addr);
	recv(SOCKET, $reply_message, 16536, 0);
	print $reply_message;
}
elsif ($options{command} eq 'disp') {
	$request_message = construct_disp_message;
	print $request_message;
	send(SOCKET, $request_message, 0, $sock_addr);
	recv(SOCKET, $reply_message, 16536, 0);
	print $reply_message;
}
else {
	print "unknown command.\n";
	exit(1);
}


##################################################################3
#
#	Change History
#
#	2011/4/18	T.Kondoh
#		* v0.40 first Release
#			Is there some bug's ?  don't be care!
#
#	2011/4/18	T.Kondoh
#		* bug fix
#			don't execute sgbtrc without add command.
#
#
##################################################################3

