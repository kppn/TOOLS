#!/usr/bin/perl


############################################################################
# Change History
# 	
# 	2011/2/24	T.Kondoh
# 		* add PCO decode function.
# 	
# 	2011/3/7	T.Kondoh
# 		* add Cause decode function.
# 		* add F-TEID decode function.
#
#	2011/3/23	T.Kondoh
#		* bug fix. PCO protocol comment displayed without -c option
#
#	2011/3/29	T.Kondoh
#		* add APN and string value in PCO decode function.
#		* add -v option. 
#	
#	2011/4/19	T.Kondoh
#		* add msglog smon format correspondence
#
#	2011/4/26	T.Kondoh
#		* bug fix. APN octets not printed.
# 	
# 	2011/5/11	T.Kondoh
#		* bug fix. Tool fail for clean character without hex string,
#		  when data has only hex number string that upper case.
#	
# 	2013/12/10	T.Kondoh
# 		* add 6D (PDN Connection) to nest;
# 		* add MM Context(GSM Key and Triplets) decode function.
#		* add MM Context(UMTS Key and Quintuplets) decoce function.
#		* add detection that a decfunc are left over the hex data.
#
############################################################################




# 構造体IEを定義しておく。16進文字は大文字で
@nest = ("5D", "6D");

%ies = (
	1	=> {"iename" => "IMSI"},
	2	=> {"iename" => "Cause", "decfunc" => \&decfunc_cause},
	3	=> {"iename" => "Recovery"},
	71	=> {"iename" => "APN", "decfunc" => \&decfunc_apn},
	72	=> {"iename" => "AMBR"},
	73	=> {"iename" => "EBI"},
	74	=> {"iename" => "IP Address"},
	75	=> {"iename" => "MEI"},
	76	=> {"iename" => "MSISDN"},
	77	=> {"iename" => "Indication"},
	78	=> {"iename" => "PCO", "decfunc" => \&decfunc_pco},
	79	=> {"iename" => "PAA"},
	80	=> {"iename" => "Bearer QoS"},
	81	=> {"iename" => "Flow QoS"},
	82	=> {"iename" => "RAT Type"},
	83	=> {"iename" => "Serving Network"},
	84	=> {"iename" => "Bearer TFT"},
	85	=> {"iename" => "TAD"},
	86	=> {"iename" => "ULI"},
	87	=> {"iename" => "F-TEID", "decfunc" => \&decfunc_fteid},
	88	=> {"iename" => "TMSI"},
	89	=> {"iename" => "Global CN-Id"},
	92	=> {"iename" => "Delay Value"},
	93	=> {"iename" => "Bearer Context "},
	94	=> {"iename" => "Charging ID"},
	95	=> {"iename" => "Charging Characteristics"},
	96	=> {"iename" => "Trace Information"},
	97	=> {"iename" => "Bearer Flags"},
	98	=> {"iename" => "Reserved"},
	99	=> {"iename" => "PDN Type"},
	100	=> {"iename" => "Procedure Transaction ID"},
	101	=> {"iename" => "DRX Parameter"},
	102	=> {"iename" => "UE Network Capability"},
	103	=> {"iename" => "MM Context (GSM Key and Triplets)", 					"decfunc" => \&decfunc_mm_context_gsm_key_and_triplets},
	104	=> {"iename" => "MM Context (UMTS Key, Used Cipher and Quintuplets)"},
	105	=> {"iename" => "MM Context (GSM Key, Used Cipher and Quintuplets)"},
	106	=> {"iename" => "MM Context (UMTS Key and Quintuplets)", 				"decfunc" => \&decfunc_mm_context_umts_key_and_quintuplets},
	107	=> {"iename" => "MM Context (EPS Security Context, Quadruplets and Quintuplets)"},
	108	=> {"iename" => "MM Context (UMTS Key, Quadruplets and Quintuplets)",			"decfunc" => \&decfunc_umts_key_quadruplets_and_quintuplets},
	109	=> {"iename" => "PDN Connection"},
	110	=> {"iename" => "PDU Numbers"},
	111	=> {"iename" => "P-TMSI"},
	112	=> {"iename" => "P-TMSI Signature"},
	113	=> {"iename" => "Hop Counter"},
	114	=> {"iename" => "UE Time Zone"},
	115	=> {"iename" => "Trace Reference"},
	116	=> {"iename" => "Complete Request Message"},
	117	=> {"iename" => "GUTI"},
	118	=> {"iename" => "F-Container"},
	119	=> {"iename" => "F-Cause"},
	120	=> {"iename" => "Selected PLMN ID"},
	121	=> {"iename" => "Target Identification"},
	122	=> {"iename" => "NSAPIReserved   "},
	123	=> {"iename" => "Packet Flow ID "},
	124	=> {"iename" => "RAB Context "},
	125	=> {"iename" => "Source RNC PDCP Context Info"},
	126	=> {"iename" => "UDP Source Port Number"},
	127	=> {"iename" => "APN Restriction"},
	128	=> {"iename" => "Selection Mode"},
	129	=> {"iename" => "Source Identification"},
	130	=> {"iename" => "Reserved"},
	131	=> {"iename" => "Change Reporting Action"},
	132	=> {"iename" => "FQ-CSID"},
	133	=> {"iename" => "Channel needed"},
	134	=> {"iename" => "eMLPP Priority"},
	135	=> {"iename" => "Node Type"},
	136	=> {"iename" => "FQDN", "decfunc" => \&decfunc_apn},
	137	=> {"iename" => "TI"},
	144	=> {"iename" => "RFSP Index"},
	149	=> {"iename" => "Service indicator"},
	255	=> {"iename" => "Private Extension"}
);


%ievalue_cause = (
	2	=> "Local Detach",
	3	=> "Complete Detach",
	4	=> "RAT changed from 3GPP to Non-3GPP",
	5	=> "ISR deactivation",
	6	=> "Error Indication received from RNC/eNodeB",
	7	=> "IMSI Detach Only ",
	16	=> "Request accepted",
	17	=> "Request accepted partially",
	18	=> "New PDN type due to network preference",
	19	=> "New PDN type due to single address bearer only",
	64	=> "Context Not Found",
	65	=> "Invalid Message Format",
	66	=> "Version not supported by next peer",
	67	=> "Invalid length",
	68	=> "Service not supported",
	69	=> "Mandatory IE incorrect",
	70	=> "Mandatory IE missing",
	71	=> "Reserved",
	72	=> "System failure",
	73	=> "No resources available",
	74	=> "Semantic error in the TFT operation",
	75	=> "Syntactic error in the TFT operation",
	76	=> "Semantic errors in packet filter(s)",
	77	=> "Syntactic errors in packet filter(s)",
	78	=> "Missing or unknown APN",
	80	=> "GRE key not found",
	81	=> "Relocation failure",
	82	=> "Denied in RAT",
	83	=> "Preferred PDN type not supported",
	84	=> "All dynamic addresses are occupied",
	85	=> "UE context without TFT already activated",
	86	=> "Protocol type not supported",
	87	=> "UE not responding",
	88	=> "UE refuses",
	89	=> "Service denied",
	90	=> "Unable to page UE",
	91	=> "No memory available",
	92	=> "User authentication failed",
	93	=> "APN access denied - no subscription",
	94	=> "Request rejected",
	95	=> "P-TMSI Signature mismatch",
	96	=> "IMSI not known",
	97	=> "Semantic error in the TAD operation",
	98	=> "Syntactic error in the TAD operation",
	99	=> "Reserved Message Value Received",
	100	=> "Remote peer not responding",
	101	=> "Collision with network initiated request",
	102	=> "Unable to page UE due to Suspension",
	103	=> "Conditional IE missing",
	104	=> "APN Restriction type Incompatible with currently active PDN connection",
	105	=> "Invalid overall length of the triggered response message and a piggybacked initial message",
	106	=> "Data forwarding not supported"
);




sub decfunc_cause {
	my $depth = shift;
	my $len = shift;
	my @array = @_;
	my $offending;
	
	$offending = 1 if $len > 2;
	
	print "\t" x $depth, @array[0..1];
	my $cause = hex($array[0]);
	@array = @array[2 .. $#array];
	if ($offending) {
		print " ", @array[0 .. $#array]
	}
	print "\t# ", $ievalue_cause{$cause} if $disp_value_decode;
	print "\n";
	
	return @array;
}




sub decfunc_apn {
	my $depth = shift;
	my $len = shift;
	my @array = @_;

	my $apn_string;
	my $label_hex;
	my $label;
	my $label_len_hex;
	my $label_len;

	print "\t" x $depth;
	while (@array) {
		$label_len_hex = shift(@array);
		$label_len = hex($label_len_hex);
		@label_hex = @array[0 .. $label_len-1];
			
		print $label_len_hex, ' ', join('', @label_hex), ' ';

		@array = @array[$label_len .. $#array];

		$label = pack("H*", join('', @label_hex));
		$apn_string .= $label . '.';
	}
	chop($apn_string);

	print "\t# $apn_string" if $disp_value_decode;

	print "\n";

	return @array;
}




sub shift_disp {
	my $depth = shift;
	my $len = shift;
	my $array_ref = shift;
	my $comment = shift;
	
	my $array_endp = $#{$array_ref};
	
	print "\t" x $depth, @{$array_ref}[0 .. ($len - 1)];
	@{$array_ref} = @{$array_ref}[ $len .. $array_endp ];
	print "\t# $comment" if $disp_ie_comment;
	print "\n";
}




sub decfunc_mm_context_gsm_key_and_triplets {
	my $depth = shift;
	my $len = shift;
	my @array = @_;
	
	$security_mode	= (hex($array[0]) & 0b11100000) >> 5;
	$drxi		= (hex($array[0]) & 0b00001000) >> 3;
	
	$n_xxplet	= (hex($array[1]) & 0b11100000) >> 5;
	$uambri		= (hex($array[1]) & 0b00000010) >> 1;
	$sambri		= (hex($array[1]) & 0b00000001) >> 0;
	
	shift_disp($depth, 1, \@array, 'Spare(4bit) / Instance(4bit)');
	shift_disp($depth, 1, \@array, 'Security Mode(4bit) / Spare(1bit) / DRXI(1bit) / CKSN(3bit)');
	shift_disp($depth, 1, \@array, 'Number of Triplet(3bits) / Spare(3bit) / UAMBRI(1bit) / SAMBRI(1bit)');
	
	shift_disp($depth, 1, \@array, 'Spare(4bit) / Used Cipher(4bit)');
	shift_disp($depth, 8, \@array, 'Kc');
	
	for ($i = 0; $i < $n_xxplet; $i++) {
		shift_disp($depth, 28, \@array, 'Triplet RAND(16oct)/SRES(4oct)/Kc(8oct)');
	}
	
	if ($drxi) {
		shift_disp($depth, 2, \@array, 'DRX parameter');
	}
	if ($sambri) {
		shift_disp($depth, 4, \@array, 'Uplink   Subscribed UE AMBR');
		shift_disp($depth, 4, \@array, 'Downlink Subscribed UE AMBR');
	}
	
	if ($uambri) {
		shift_disp($depth, 4, \@array, 'Uplink   Used UE AMBR');
		shift_disp($depth, 4, \@array, 'Downlink Used UE AMBR');
	}
	
	$len_ue_net_capa  = hex($array[0]);
	shift_disp($depth, 1, \@array, 'Length of UE Network Capability');
	if ($len_ue_net_capa > 0) {
		shift_disp($depth + 1, $len_ue_net_capa, \@array, 'UE Network Capability');
	}
	
	$len_ms_net_capa  = hex($array[0]);
	shift_disp($depth, 1, \@array, 'Length of MS Network Capability');
	if ($len_ms_net_capa > 0) {
		shift_disp($depth + 1, $len_ms_net_capa, \@array, 'MS Network Capability');
	}
	
	$len_mei  = hex($array[0]);
	shift_disp($depth, 1, \@array, 'Length of MEI');
	if ($len_mei > 0) {
		shift_disp($depth + 1, $len_mei, \@array, 'MEI');
	}
	
	shift_disp($depth, 1, \@array, 'Spare / HNNA / ENA / INA / GANA / GENA / UNA');
	
	$len_voice_prefe  = hex($array[0]);
	shift_disp($depth, 1, \@array, 'Length of Voice Domain Preference and UEs Usage Setting');
	if ($len_voice_prefe > 0) {
		shift_disp($depth + 1, $len_voice_prefe, \@array, 'Voice Domain Preference and UEs Usage Setting');
	}

	return @array;
}




sub decfunc_mm_context_umts_key_and_quintuplets {
	my $depth = shift;
	my $len = shift;
	my @array = @_;
	
	$security_mode	= (hex($array[0]) & 0b_1110_0000) >> 5;
	$drxi		= (hex($array[0]) & 0b_0000_1000) >> 3;
	
	$n_xxplet	= (hex($array[1]) & 0b11100000) >> 5;
	$uambri		= (hex($array[1]) & 0b00000010) >> 1;
	$sambri		= (hex($array[1]) & 0b00000001) >> 0;
	
	shift_disp($depth, 1, \@array, 'Security Mode(4bit) / Spare(1bit) / DRXI(1bit) / KSI(3bit)');
	shift_disp($depth, 1, \@array, 'Number of Quintuplets(3bits) / Spare(3bit) / UAMBRI(1bit) / SAMBRI(1bit)');
	shift_disp($depth, 1, \@array, 'Spare(8bit)');
	
	shift_disp($depth, 16, \@array, 'CK');
	shift_disp($depth, 16, \@array, 'IK');
	
	if ($n_xxplet > 0) {
		for ($i = 0; $i < $n_xxplet; $i++) {
			print "\t" x $depth, "# Quintuplet\n";
			
			shift_disp($depth + 0, 16, \@array, 'RAND');
			
			$len_xres = hex($array[0]);
			shift_disp($depth + 0, 1, \@array, 'XRES Length');
			shift_disp($depth + 1, $len_xres, \@array, 'XRES');
			
			shift_disp($depth + 0, 16, \@array, 'CK');
			
			shift_disp($depth + 0, 16, \@array, 'IK');
			
			$len_autn = hex($array[0]);
			shift_disp($depth + 0, 1, \@array, 'AUTN Length');
			shift_disp($depth + 1, $len_autn, \@array, 'AUTN');
			
		}
	}
	
	if ($drxi) {
		shift_disp($depth, 2, \@array, 'DRX parameter');
	}
	
	if ($sambri) {
		shift_disp($depth, 4, \@array, 'Uplink   Subscribed UE AMBR');
		shift_disp($depth, 4, \@array, 'Downlink Subscribed UE AMBR');
	}
	
	if ($uambri) {
		shift_disp($depth, 4, \@array, 'Uplink   Used UE AMBR');
		shift_disp($depth, 4, \@array, 'Downlink Used UE AMBR');
	}
	
	$len_ue_net_capa  = hex($array[0]);
	shift_disp($depth, 1, \@array, 'Length of UE Network Capability');
	if ($len_ue_net_capa > 0) {
		shift_disp($depth + 1, $len_ue_net_capa, \@array, 'UE Network Capability');
	}
	
	$len_ms_net_capa  = hex($array[0]);
	shift_disp($depth, 1, \@array, 'Length of MS Network Capability');
	if ($len_ms_net_capa) {
		shift_disp($depth + 1, $len_ms_net_capa, \@array, 'MS Network Capability');
	}
	
	$len_mei  = hex($array[0]);
	shift_disp($depth, 1, \@array, 'Length of MEI');
	if ($len_mei > 0) {
		shift_disp($depth + 1, $len_mei, \@array, 'MEI');
	}
	
	shift_disp($depth, 1, \@array, 'Spare(2bit) / HNNA(1bit) / ENA(1bit) / INA(1bit) / GANA(1bit) / GENA(1bit) / UNA(1bit)');
	
	$len_voice_prefe  = hex($array[0]);
	shift_disp($depth, 1, \@array, 'Length of Voice Domain Preference and UEs Usage Setting');
	if ($len_voice_prefe > 0) {
		shift_disp($depth + 1, $len_voice_prefe, \@array, 'Voice Domain Preference and UEs Usage Setting');
	}

	return @array;
}




sub decfunc_umts_key_quadruplets_and_quintuplets {
	my $depth = shift;
	my $len = shift;
	my @array = @_;
	
	$security_mode	= (hex($array[0]) & 0b_1110_0000) >> 5;
	$drxi		= (hex($array[0]) & 0b_0000_1000) >> 3;
	
	$n_quintuplet	= (hex($array[1]) & 0b11100000) >> 5;
	$n_quadruplet	= (hex($array[1]) & 0b00011100) >> 2;
	$uambri		= (hex($array[1]) & 0b00000010) >> 1;
	$sambri		= (hex($array[1]) & 0b00000001) >> 0;
	
	shift_disp($depth, 1, \@array, 'Security Mode(4bit) / Spare(1bit) / DRXI(1bit) / KSI(3bit)');
	shift_disp($depth, 1, \@array, 'Number of Quintuplets(3bits) / Number of Quindruplets(3bit) / UAMBRI(1bit) / SAMBRI(1bit)');
	shift_disp($depth, 1, \@array, 'Spare(8bit)');
	
	shift_disp($depth, 16, \@array, 'CK');
	shift_disp($depth, 16, \@array, 'IK');
	
	if ($n_quadruplet > 0) {
		for ($i = 0; $i < $n_quadruplet; $i++) {
			print "\t" x $depth, "# Quadruplet\n";
			
			shift_disp($depth, 16, \@array, 'RAND');
			$len_xres = hex($array[0]);
			shift_disp($depth, 1, \@array, 'XRES Length');
			shift_disp($depth + 1, $len_xres, \@array, 'XRES');
			$len_autn = hex($array[0]);
			shift_disp($depth, 1, \@array, 'AUTN Length');
			shift_disp($depth + 1, $len_autn, \@array, 'AUTN');
			shift_disp($depth, 32, \@array, 'Kasme');
		}
	}
	if ($n_quintuplet > 0) {
		for ($i = 0; $i < $n_quintuplet; $i++) {
			print "\t" x $depth, "# Quintuplet\n";
			
			shift_disp($depth + 0, 16, \@array, 'RAND');
			
			$len_xres = hex($array[0]);
			shift_disp($depth + 0, 1, \@array, 'XRES Length');
			shift_disp($depth + 1, $len_xres, \@array, 'XRES');
			
			shift_disp($depth + 0, 16, \@array, 'CK');
			
			shift_disp($depth + 0, 16, \@array, 'IK');
			
			$len_autn = hex($array[0]);
			shift_disp($depth + 0, 1, \@array, 'AUTN Length');
			shift_disp($depth + 1, $len_autn, \@array, 'AUTN');
		}
	}
	
	if ($drxi) {
		shift_disp($depth, 2, \@array, 'DRX parameter');
	}
	
	if ($sambri) {
		shift_disp($depth, 4, \@array, 'Uplink   Subscribed UE AMBR');
		shift_disp($depth, 4, \@array, 'Downlink Subscribed UE AMBR');
	}
	
	if ($uambri) {
		shift_disp($depth, 4, \@array, 'Uplink   Used UE AMBR');
		shift_disp($depth, 4, \@array, 'Downlink Used UE AMBR');
	}
	
	$len_ue_net_capa  = hex($array[0]);
	shift_disp($depth, 1, \@array, 'Length of UE Network Capability');
	if ($len_ue_net_capa > 0) {
		shift_disp($depth + 1, $len_ue_net_capa, \@array, 'UE Network Capability');
	}
	
	$len_ms_net_capa  = hex($array[0]);
	shift_disp($depth, 1, \@array, 'Length of MS Network Capability');
	if ($len_ms_net_capa) {
		shift_disp($depth + 1, $len_ms_net_capa, \@array, 'MS Network Capability');
	}
	
	$len_mei  = hex($array[0]);
	shift_disp($depth, 1, \@array, 'Length of MEI');
	if ($len_mei > 0) {
		shift_disp($depth + 1, $len_mei, \@array, 'MEI');
	}
	
	shift_disp($depth, 1, \@array, 'Spare(2bit) / HNNA(1bit) / ENA(1bit) / INA(1bit) / GANA(1bit) / GENA(1bit) / UNA(1bit)');
	
	$len_voice_prefe  = hex($array[0]);
	shift_disp($depth, 1, \@array, 'Length of Voice Domain Preference and UEs Usage Setting');
	if ($len_voice_prefe > 0) {
		shift_disp($depth + 1, $len_voice_prefe, \@array, 'Voice Domain Preference and UEs Usage Setting');
	}
	
	return @array;
}




%ievalue_fteid_iftype = (
	0	=> "S1-U eNB GTP-U",
	1	=> "S1-U SGW GTP-U",
	2	=> "S12 RNC GTP-U",
	3	=> "S12 SGW GTP-U",
	4	=> "S5/S8 SGW GTP-U",
	5	=> "S5/S8 PGW GTP-U",
	6	=> "S5/S8 SGW GTP-C",
	7	=> "S5/S8 PGW GTP-C",
	8	=> "S5/S8 SGW PMIPv6",
	9	=> "S5/S8 PGW PMIPv6",
	10	=> "S11 MME GTP-C",
	11	=> "S11/S4 SGW GTP-C",
	12	=> "S10 MME GTP-C",
	13	=> "S3 MME GTP-C",
	14	=> "S3 SGSN GTP-C",
	15	=> "S4 SGSN GTP-U",
	16	=> "S4 SGW GTP-U",
	17	=> "S4 SGSN GTP-C",
	18	=> "S16 SGSN GTP-C",
	19	=> "eNB GTP-U DL forward",
	20	=> "eNB GTP-U UL forward",
	21	=> "RNC GTP-U forward",
	22	=> "SGSN GTP-U forward",
	23	=> "SGW GTP-U DL forward",
	24	=> "Sm MBMS GW GTP-C",
	25	=> "Sn MBMS GW GTP-C",
	26	=> "Sm MME GTP-C",
	27	=> "Sn SGSN GTP-C",
	28	=> "SGW GTP-U for UL data forwarding",
	29	=> "Sn SGSN GTP-U ",
	30	=> "S2b ePDG GTP-C",
	31	=> "S2b-U ePDG GTP-U",
	32	=> "S2b PGW GTP-C",
	33	=> "S2b-U PGW GTP-U",
);


sub hextoipstr {
	my @hexstr = @_;
	my $ipstr;
	
	$ipstr = sprintf("%d.%d.%d.%d", hex($hexstr[0]), hex($hexstr[1]), hex($hexstr[2]), hex($hexstr[3]),);
}



sub decfunc_fteid {
	my $depth = shift;
	my $len = shift;
	my @array = @_;
	my $iftype;

	$iftype = hex($array[0]) & 0x1f;
	print "\t" x $depth, $array[0], " ", @array[1..4], " ", @array[5..8];
	if ($disp_value_decode) {
		print "\t# ", $ievalue_fteid_iftype{$iftype}, ", ";
		print hextoipstr(@array[5..8]);
	}
	print "\n";
	
	@array = @array[9 .. $#array];

	return @array;
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
	@array = @array[0 .. $#array];
	print "\t# ", pack("H*", join('', @array)) if $disp_value_decode;
	print "\n";
	
	return @array;
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

	return @array;
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

	return @array;
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

	return @array;
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
		$len .= shift @array;
		$len .= shift @array;
		print "$len ";
		$len = hex $len;
		print shift @array, "\n"; 

		$ie = uc $ie;
		$nests = join ' ', @nest;
		if ($nests =~ /$ie/) {
			my @tmp;
			for ($i = 0; $i < $len; $i++) {
				$byte = shift @array;
				push @tmp, $byte;
			}
			disp_ie($depth + 1, @tmp);
		}
		else {
			if ($ies{$ie_num}->{decfunc} == undef) {
				print "\t" x ($depth + 1);
				for ($i = 0; $i < $len; $i++) {
					print shift @array;
				}
				print "\n";
			}
			else {
				@left = $ies{$ie_num}->{decfunc}($depth+1, $len, @array[0 .. $len-1]);

				if (@left and (join('', @left)) =~ /[0-9a-fA-F]/) {
					print "\n";
					print "WARNING!! the following data left over, unused !! signal format is evel?\n\n";
					print "'@left'";
					print "\n\n";
					exit(1);
				}

				@array = @array[$len .. $#array];
			}
		}
		$len = "";
	}

}


while (<STDIN>) {
	chomp;
	
	s/^C[CED].... //;
	s/data=//;
	
	s/#.*//;
	s/\s+//g;
	s/ //g;
	s/\t//g;
	
	next if /^$/;
	next if /[^0-9a-fA-F]/;
	
	$msg .= $_;
}


@array = $msg =~ /../g;

if ($array[0] eq "48") {
	for ($i = 0; $i < 12; $i++) {
		print shift @array;
		print " " if $i % 2;
	}
}
print "\n";

$disp_ie_comment = 1 and $ARGV[0] = "" if ($ARGV[0] eq "-c");
$disp_value_decode = 1 and $ARGV[1] = "" if ($ARGV[1] eq "-v");
disp_ie(0, @array);


