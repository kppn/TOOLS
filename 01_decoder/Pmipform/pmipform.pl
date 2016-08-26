#!/usr/bin/perl

#############################################################
# Change History
# 	
# 	2011/2/15	T.Kondoh
# 		* add output item : status-code
# 	
#	2011/4/19	T.Kondoh
# 		* add PCO decode function.
#		* add output item : Vendor-Specific Error Code
#		* add msglog smon format correspondence
# 	
# 	2011/5/11	T.Kondoh
#		* bug fix. Tool fail for clean character without hex string,
#		  when data has only hex number string that upper case.
# 	
#############################################################


# Define PMIPv6 option codes.

%ies = (
	0x00	=> {"iename" => "Pad 0"},			
	0x01	=> {"iename" => "Pad N"},			
	0x08	=> {"iename" => "Mobile Node Identifier",	"decfunc" => \&decfunc_mobile_node_identifier},	
	0x14	=> {"iename" => "Service Selection",		"decfunc" => \&decfunc_service_selection},
	0x16	=> {"iename" => "IPv6 Home Network Prefix"},	
	0x17	=> {"iename" => "Handoff Indicator"},		
	0x18	=> {"iename" => "Access Technology Type"},	
	0x1a	=> {"iename" => "Link-Local Address"},		
	0x1b	=> {"iename" => "Timestamp"},			
	0x1d	=> {"iename" => "IPv4 Home Address"},		
	0x1e	=> {"iename" => "IPv4 Home Address Ack"},	
	0x13	=> {"iename" => "3GPP Vendor-Specific",		"decfunc" => \&decfunc_vendor_specific},
	0x21	=> {"iename" => "GRE Key"},			
);

%tgpp_ies = (
	0x01	 => {"iename" => "PCO.",	"decfunc" => \&decfunc_pco},
	0x02	 => {"iename" => "3GPP Specific PMIPv6 Error Code.",	"decfunc" => \&decfunc_vendor_specific_error_code},
	0x03	 => {"iename" => "PMIPv6 PDN GW IP Address."},
	0x04	 => {"iename" => "PMIPv6 DHCPv4 Address Allocation Procedure Indication."},
	0x05	 => {"iename" => "PMIPv6 Fully Qualified PDN Connection Set Identifier "},
	0x06	 => {"iename" => "PMIPv6 PDN type indication."},
	0x07	 => {"iename" => "Charging ID"},
	0x08	 => {"iename" => "Selection Mode"},
	0x09	 => {"iename" => "I-WLAN Mobility Access Point Name (APN)."},
	0x0a	 => {"iename" => "Charging Characteristics"},
	0x0b	 => {"iename" => "Mobile Equipment Identity (MEI)"},
	0x0c	 => {"iename" => "MSISDN"},
	0x0d	 => {"iename" => "Serving Network"},
	0x0e	 => {"iename" => "APN Restriction"},
	0x0f	 => {"iename" => "Maximum APN Restriction"},
);

%status_codes = (
	0	=> "Binding Update accepted",
	1	=> "Accepted but prefix discovery necessary ",
	2	=> "GRE_KEY_OPTION_NOT_REQUIRED ",
	3	=> "GRE_TUNNELING_BUT_TLV_HEADER_NOT_SUPPORTED ",
	4	=> "MCOA NOTCOMPLETE ",
	5	=> "MCOA RETURNHOME WO/NDP ",
	6	=> "PBU_ACCEPTED_TB_IGNORED_SETTINGSMISMATCH ",
	128	=> "Reason unspecified ",
	129	=> "Administratively prohibited ",
	130	=> "Insufficient resources ",
	131	=> "Home registration not supported ",
	132	=> "Not home subnet ",
	133	=> "Not home agent for this mobile node ",
	134	=> "Duplicate Address Detection failed ",
	135	=> "Sequence number out of window ",
	136	=> "Expired home nonce index ",
	137	=> "Expired care-of nonce index ",
	138	=> "Expired nonces ",
	139	=> "Registration type change disallowed ",
	140	=> "Mobile Router Operation not permitted ",
	141	=> "Invalid Prefix ",
	142	=> "Not Authorized for Prefix ",
	143	=> "Forwarding Setup failed ",
	144	=> "MIPV6-ID-MISMATCH ",
	145	=> "MIPV6-MESG-ID-REQD ",
	146	=> "MIPV6-AUTH-FAIL ",
	147	=> "Permanent home keygen token unavailable ",
	148	=> "CGA and signature verification failed ",
	149	=> "Permanent home keygen token exists ",
	150	=> "Non-null home nonce index expected ",
	151	=> "SERVICE_AUTHORIZATION_FAILED ",
	152	=> "PROXY_REG_NOT_ENABLED ",
	153	=> "NOT_LMA_FOR_THIS_MOBILE_NODE ",
	154	=> "MAG_NOT_AUTHORIZED_FOR_PROXY_REG ",
	155	=> "NOT_AUTHORIZED_FOR_HOME_NETWORK_PREFIX ",
	156	=> "TIMESTAMP_MISMATCH ",
	157	=> "TIMESTAMP_LOWER_THAN_PREV_ACCEPTED ",
	158	=> "MISSING_HOME_NETWORK_PREFIX_OPTION ",
	159	=> "BCE_PBU_PREFIX_SET_DO_NOT_MATCH ",
	160	=> "MISSING_MN_IDENTIFIER_OPTION ",
	161	=> "MISSING_HANDOFF_INDICATOR_OPTION ",
	162	=> "MISSING_ACCESS_TECH_TYPE_OPTION ",
	163	=> "GRE_KEY_OPTION_REQUIRED ",
	164	=> "MCOA MALFORMED ",
	165	=> "MCOA NON-MCOA BINDING EXISTS ",
	166	=> "MCOA PROHIBITED ",
	167	=> "MCOA UNKNOWN COA ",
	168	=> "MCOA BULK REGISTRATION PROHIBITED ",
	169	=> "MCOA SIMULTANEOUS HOME AND FOREIGN PROHIBITED ",
	170	=> "NOT_AUTHORIZED_FOR_IPV4_MOBILITY_SERVICE ",
	171	=> "NOT_AUTHORIZED_FOR_IPV4_HOME_ADDRESS ",
	172	=> "NOT_AUTHORIZED_FOR_IPV6_MOBILITY_SERVICE ",
	173	=> "MULTIPLE_IPV4_HOME_ADDRESS_ASSIGNMENT_NOT_SUPPORTED ",
);



%vendor_specific_error_codes = (
	69	=> "Mandatory IE incorrect",
	70	=> "Mandatory IE missing",
	71	=> "Optional IE incorrect",
	78	=> "Missing or unknown APN",
	80	=> "GRE key not found",
	91	=> "No memory is available",
	93	=> "APN access denied no subscription",
	220	=> "MISSING_TIMESTAMP_OPTION",
	221	=> "MULTIPLE_HNP_NOT_ALLOWED",
);



sub decfunc_service_selection {
	my $depth = shift;
	my $len = shift;
	my @array = @_;
	
	print "\t" x $depth;
	print @array;
	print "\t# ", pack("H*", join('', @array)) if $disp_ie_comment;
	print "\n";
}

sub decfunc_mobile_node_identifier {
	my $depth = shift;
	my $len = shift;
	my @array = @_;
	
	print "\t" x $depth;
	print shift @array, @array;
	print "\t# ", pack("H*", join('', @array)) if $disp_ie_comment;
	print "\n";
}



sub decfunc_vendor_specific_error_code {
	my $depth = shift;
	my $len = shift;
	my @array = @_;
	
	print "\t" x $depth, $array[0];
	print $vendor_specific_error_codes{hex $array[0]} if $disp_ie_comment;
	print "\n";
}





%pco_protocols = (
	0xC023 => "PAP",
	0xC223 => "CHAP",
	0x8021 => "IPCP",
	0x0001 => "P-CSCF IPv6 Address Request",
	0x0002 => "IM CN Subsystem Signaling Flag",
	0x0003 => "DNS Server IPv6 Address Request", 
	0x0004 => "Not Supported",
	0x0005 => "MS Support of Network Requested Bearer Control indicator",
	0x0006 => "Reserved", 
	0x0007 => "DSMIPv6 Home Agent Address Request",
	0x0008 => "DSMIPv6 Home Network Prefix Request",
	0x0009 => "DSMIPv6 IPv4 Home Agent Address Request",
	0x000A => "IP address allocation via NAS signalling",
	0x000B => "IPv4 address allocation via DHCPv4",
	0x000C => "P-CSCF IPv4 Address Request",
	0x000D => "DNS Server IPv4 Address Request",
	0x000E => "MSISDN Request"
);


sub decfunc_chap {
	my $depth = shift;
	my @array = @_;
	my $chaplen;

	print "\t" x $depth, shift(@array), " ", shift(@array), " ";
	$chaplen .= shift(@array);
	$chaplen .= shift(@array);
	print $chaplen;
	$chaplen = hex($chaplen);
	print "\n";

	$depth++;
	print "\t" x $depth, $array[0], " ";
	$peer_len = hex(shift(@array));
	for ($i = 0; $i < $peer_len; $i++) {
		print shift(@array);
	}
	print "\n";
	print "\t" x $depth, @array;
	print "\t# ", pack("H*", join('', @array)) if $disp_value_decode;
	#print "\t" x $depth, @array[0 .. ($chaplen - $peer_len + 1)];
	#print "\t# ", pack("H*", join('', @array[0 .. ($chaplen - $peer_len + 1)]));
	print "\n";

#	if (@array) {
#		print "\t" x $depth;
#
#		print "\t" x $depth, @array[0 .. ($chaplen - $peer_len + 1)];
#		print 
#
#		for ($i = 0; $i < ($chaplen - $peer_len + 1); $i++) {
#			print shift(@array);
#		}
#		print "\n";
#	}
}


sub decfunc_pap {
	my $depth = shift;
	my @array = @_;

	print "\t" x $depth, shift(@array), " ", shift(@array), " ", shift(@array), shift(@array);
	print "\n";

	$depth++;
	while (@array) {
		$peer_len = hex($array[0]);
		print "\t" x $depth, @array[0], " ", @array[1 .. $peer_len];
		print "\t# ", pack("H*", join('', @array[1 .. $peer_len])) if $disp_value_decode;
		@array = @array[$peer_len+1 .. $#array];
		print "\n";
	}
}


sub decfunc_ipcp {
	my $depth = shift;
	my @array = @_;

	print "\t" x $depth, shift(@array), " ", shift(@array), " ", shift(@array), shift(@array);
	print "\n";

	$depth++;
	while (@array) {
		$peer_len = hex($array[1]) - 2;
		print "\t" x $depth, shift(@array), " ", shift(@array), " ";
		for ($i = 0; $i < $peer_len; $i++) {
			print shift(@array);
		}
		print "\n";
	}
}


sub decfunc_pco {
	my $depth = shift;
	my $len = shift;
	my @array = @_;

	my $protocol_id;
	my $sublen;

	print "\t" x $depth, shift(@array);
	print "\t# ext" if $disp_ie_comment;
	print "\n";

	while (@array) {
		$protocol_id =  shift @array;
		$protocol_id .= shift @array;
		$sublen = shift @array;
		print "\t" x $depth, $protocol_id, " ", $sublen;
		print "\t# ", $pco_protocols{hex($protocol_id)} if $disp_ie_comment;
		print "\n";

		$sublen = hex($sublen);
		if ($pco_protocols{hex($protocol_id)} eq "CHAP") {
			decfunc_chap($depth+1, @array[0 .. $sublen-1]);
			@array = @array[$sublen .. $#array];
		}
		elsif ($pco_protocols{hex($protocol_id)} eq "PAP") {
			decfunc_pap($depth+1, @array[0 .. $sublen-1]);
			@array = @array[$sublen .. $#array];
		}
		elsif ($pco_protocols{hex($protocol_id)} eq "IPCP") {
			decfunc_ipcp($depth+1, @array[0 .. $sublen-1]);
			@array = @array[$sublen .. $#array];
		}
		else {
			print "\t" x ($depth+1), @array[0 .. $sublen-1];
			print "\n";
			@array = @array[$sublen .. $#array];
		}
	}
}




sub decfunc_vendor_specific {
	my $depth = shift;
	my $len = shift;
	my @array = @_;
	
	$tgpp_ie = $array[4];
	$ie_num = hex $tgpp_ie;
	
	print "\t" x $depth, "### $tgpp_ies{$ie_num}->{iename}\n" if $disp_ie_comment;
	
	print "\t" x $depth;
	for ($i = 0; $i < 4; $i++) {
		print shift @array;
	}
	$len -= 4;
	print "\n";
	
	print "\t" x $depth;
	for ($i = 0; $i < 2; $i++) {
		print shift @array;
	}
	$len -= 2;
	print "\n";
	
	if ($tgpp_ies{$ie_num}->{decfunc} == undef) {
		print "\t" x ($depth + 1);
		while (@array) {
			print shift @array;
		}
	}
	else {
		$tgpp_ies{$ie_num}->{decfunc}($depth+1, $len, @array[0 .. $len-1]);
		@array = @array[$len .. $#array];
	}
	
	print "\n";
}



sub disp_ie {
	my $depth = shift @_;
	my @array = @_;
	my $len;

	while (@array) {
		$ie = shift @array;
		$ie_num = hex $ie;

		print "\t" x $depth, "### $ies{$ie_num}->{iename}\n" if $disp_ie_comment;
		print "\t" x $depth, $ie, " ";

		print "\n" and next if ($ie_num == 0x00);

		$len = shift @array;
		print "$len \n";
		$len = hex $len;
		
		if ($ies{$ie_num}->{decfunc} == undef) {
			print "\t" x ($depth + 1);
			for ($i = 0; $i < $len; $i++) {
				print shift @array;
			}
			print "\n";
			$len = "";
		}
		else {
			$ies{$ie_num}->{decfunc}($depth+1, $len, @array[0 .. $len-1]);
			@array = @array[$len .. $#array];
		}
		
		
	}
}


$disp_ie_comment = 1 and $ARGV[0] = "" if ($ARGV[0] eq "-c");

while (<STDIN>) {
	chomp;
	
	s/^C[CED].... //;
	s/data=//;
	s/#.*//;
	s/\s+//g;
	
	next if /[^0-9a-fA-F]/;
	
	$msg .= $_;
}


@array = $msg =~ /../g;

$status_code = hex($array[6]) if $array[2] eq "06";
for ($i = 0; $i < 12; $i++) {
	print shift @array;
	print " " if $i % 2;
}
print "\t# Status: $status_codes{$status_code}";
print "\n";

disp_ie(0, @array);
print "\n";


