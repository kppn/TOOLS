#!/usr/bin/perl


############################################################################
# Change History
# 	
# 	2011/3/24	T.Kondoh
# 		* add S6a AVP Codes (exclude docomo original message, 
#		  I'm lazy..)
#
# 	2011/3/30	T.Kondoh
#		* add Gx/Rx AVP Codes (PCC) from TS29.212, TS29.214
# 	
#	2011/4/19	T.Kondoh
#		* add msglog smon format correspondence
# 	
# 	2011/5/11	T.Kondoh
#		* bug fix. Tool fail for clean character without hex string,
#		  when data has only hex number string that upper case.
#
# 	2011/5/17	T.Kondoh
#		* change Redirect-Host data type from DiamURI to UTF8String.
# 	
# 	2012/2/2	T.Kondh
# 		* add part of NAS Application AVPs.
#			* Auth-Request-Type
# 		* add docomo original AVPs.
# 			* FGW-IP-Address
# 			* BTS-IP-Address
# 			* RNC-IP-Address
# 			* OPS-IP-Address
# 			* NTP-IP-Address
# 			* BTS-Location
# 			* Reset Timing
# 			* HeNB Information
# 			* DeBGW-IP Address
# 			* HeNB-IP Address
# 			* MME-IP Address
# 			* Action-Mode
# 	
############################################################################


%ies = (
1	=> ['User-Name',	'UTF8String'],
1000	=> ['Bearer-Usage',	'Enumerated'],
1001	=> ['Charging-Rule-Install',	'Grouped'],
1002	=> ['Charging-Rule-Remove',	'Grouped'],
1003	=> ['Charging-Rule-Definition',	'Grouped'],
1004	=> ['Charging-Rule-Base-Name',	'UTF8String'],
1005	=> ['Charging-Rule-Name',	'UTF8String'],
1006	=> ['Event-Trigger',	'Enumerated'],
1007	=> ['Metering-Method',	'Enumerated'],
1008	=> ['Offline',	'Enumerated'],
1009	=> ['Online',	'Enumerated'],
1010	=> ['Precedence',	'Unsigned32'],
1011	=> ['Reporting-Level',	'Enumerated'],
1013	=> ['TFT-Packet-Filter-Information',	'Grouped'],
1016	=> ['QoS-Information',	'Grouped'],
1018	=> ['Charging-Rule-Report',	'Grouped'],
1019	=> ['PCC-Rule-Status',	'Enumerated'],
1020	=> ['Bearer-Identifier',	'OctetString'],
1021	=> ['Bearer-Operation',	'Enumerated'],
1022	=> ['Access-Network-Charging-Identifier-Gx',	'Grouped'],
1023	=> ['Bearer-Control-Mode',	'Enumerated'],
1024	=> ['Network-Request-Support',	'Enumerated'],
1025	=> ['Guaranteed-Bitrate-DL',	'Unsigned32'],
1026	=> ['Guaranteed-Bitrate-UL',	'Unsigned32'],
1027	=> ['IP-CAN-Type',	'Enumerated'],
1028	=> ['QoS-Class-Identifier',	'Enumerated'],
1029	=> ['QoS-Negotiation',	'Enumerated'],
1030	=> ['QoS-Upgrade',	'Enumerated'],
1031	=> ['Rule-Failure-Code',	'Enumerated'],
1032	=> ['RAT-Type',	'Enumerated'],
1033	=> ['Event-Report-Indication',	'Grouped'],
1034	=> ['Allocation-Retention-Priority',	'Grouped'],
1035	=> ['CoA-IP-Address',	'Address'],
1036	=> ['Tunnel-Header-Filter',	'IPFilterRule'],
1037	=> ['Tunnel-Header-Length',	'Unsigned32'],
1038	=> ['Tunnel-Information',	'Grouped'],
1039	=> ['CoA-Information',	'Grouped'],
1040	=> ['APN-Aggregate-Max-Bitrate-DL',	'Unsigned32'],
1041	=> ['APN-Aggregate-Max-Bitrate-UL',	'Unsigned32'],
1042	=> ['Revalidation-Time',	'Time'],
1043	=> ['Rule-Activation-Time',	'Time'],
1044	=> ['Rule-Deactivation-Time',	'Time'],
1045	=> ['Session-Release-Cause',	'Enumerated'],
1046	=> ['Priority-Level',	'Unsigned32'],
1047	=> ['Pre-emption-Capability',	'Enumerated'],
1048	=> ['Pre-emption-Vulnerability',	'Enumerated'],
1049	=> ['Default-EPS-Bearer-QoS',	'Grouped'],
1050	=> ['AN-GW-Address',	'Address'],
1051	=> ['QoS-Rule-Install',	'Grouped'],
1052	=> ['QoS-Rule-Remove',	'Grouped'],
1053	=> ['QoS-Rule-Definition',	'Grouped'],
1054	=> ['QoS-Rule-Name',	'OctetString'],
1055	=> ['QoS-Rule-Report',	'Grouped'],
1058	=> ['Flow-Information',	'Grouped'],
1060	=> ['Packet-Filter-Identifier', 'OctetString'],
1061	=> ['Packet-Filter-Information',	'Grouped'],
1062	=> ['Packet-Filter-Operation',	'Enumerated'],
1063	=> ['Resource-Allocation-Notification',	'Enumerated'],
1064	=> ['Session-Linking-Indicator',	'Enumerated'],
12	=> ['3GPP-Selection-Mode',	'UTF8String'],
13	=> ['3GPP-Charging-Characteristics',	'UTF8String'],
1400	=> ['Subscription-Data',	'Grouped'],
1401	=> ['Terminal-Information',	'Grouped'],
1402	=> ['IMEI',	'UTF8String'],
1403	=> ['Software-Version',	'UTF8String'],
1405	=> ['ULR-Flags',	'Unsigned32'],
1406	=> ['ULA-Flags',	'Unsigned32'],
1407	=> ['Visited-PLMN-Id',	'OctetString'],
1408	=> ['Requested-EUTRAN-Authentication-Info',	'Grouped'],
1409	=> ['Requested-UTRAN-GERAN-Authentication-Info',	'Grouped'],
1410	=> ['Number-Of-Requested-Vectors',	'Unsigned32'],
1411	=> ['Re-synchronization-Info',	'OctetString'],
1412	=> ['Immediate-Response-Preferred',	'Unsigned32'],
1413	=> ['Authentication-Info',	'Grouped'],
1414	=> ['E-UTRAN-Vector',	'Grouped'],
1415	=> ['UTRAN-Vector',	'Grouped'],
1416	=> ['GERAN-Vector',	'Grouped'],
1417	=> ['Network-Access-Mode',	'Enumerated'],
1419	=> ['Item-Number',	'Unsigned32'],
1420	=> ['Cancellation-Type',	'Enumerated'],
1421	=> ['DSR-Flags',	'Unsigned32'],
1422	=> ['DSA-Flags',	'Unsigned32'],
1423	=> ['Context-Identifier',	'Unsigned32'],
1424	=> ['Subscriber-Status',	'Enumerated'],
1425	=> ['Operator-Determined-Barring',	'Unsigned32'],
1426	=> ['Access-Restriction-Data',	'Unsigned32'],
1427	=> ['APN-OI-Replacement',	'UTF8String'],
1428	=> ['All-APN-Configurations-Included-Indicator',	'Enumerated'],
1429	=> ['APN-Configuration-Profile',	'Grouped'],
1430	=> ['APN-Configuration',	'Grouped'],
1431	=> ['EPS-Subscribed-QoS-Profile',	'Grouped'],
1432	=> ['VPLMN-Dynamic-Address-Allowed',	'Enumerated'],
1433	=> ['STN-SR',	'OctetString'],
1434	=> ['Alert-Reason',	'Enumerated'],
1435	=> ['AMBR',	'Grouped'],
1436	=> ['CSG-Subscription-Data',	'Grouped'],
1438	=> ['PDN-GW-Allocation-Type',	'Enumerated'],
1440	=> ['RAT-Frequency-Selection-Priority-ID',	'Unsigned32'],
1441	=> ['IDA-Flags',	'Unsigned32'],
1442	=> ['PUA-Flags',	'Unsigned32'],
1443	=> ['NOR-Flags',	'Unsigned32'],
1444	=> ['User-Id',	'UTF8String'],
1446	=> ['Regional-Subscription-Zone-Code',	'OctetString'],
1447	=> ['RAND',	'OctetString'],
1448	=> ['SRES',	'OctetString'],
1448	=> ['XRES',	'OctetString'],
1449	=> ['AUTN',	'OctetString'],
1450	=> ['KASME',	'OctetString'],
1451	=> ['Confidentiality-Key',	'OctetString'],
1452	=> ['Integrity-Key',	'OctetString'],
1452	=> ['Trace-Collection-Entity',	'Address'],
1453	=> ['Kc',	'OctetString'],
1456	=> ['PDN-Type',	'Enumerated'],
1457	=> ['Roaming-Restricted-Due-To-Unsupported-Feature',	'Enumerated'],
1458	=> ['Trace-Data',	'Grouped'],
1459	=> ['Trace-Reference',	'OctetString'],
1462	=> ['Trace-Depth',	'Enumerated'],
1463	=> ['Trace-NE-Type-List',	'OctetString'],
1464	=> ['Trace-Interface-List',	'OctetString'],
1465	=> ['Trace-Event-List',	'OctetString'],
1466	=> ['OMC-Id',	'OctetString'],
1467	=> ['GPRS-Subscription-Data',	'Grouped'],
1471	=> ['3GPP2-MEID',	'OctetString'],
1472	=> ['Specific-APN-Info',	'Grouped'],
1473	=> ['LCS-Info',	'Grouped'],
1476	=> ['SS-Code',	'OctetString'],
1486	=> ['Teleservice-List',	'Grouped'],
1487	=> ['TS-Code',	'OctetString'],
1488	=> ['Call-Barring-Info-List',	'Grouped'],
1490	=> ['IDR-Flags',	'Unsigned32'],
15	=> ['3GPP-SGSN-IPv6-Address',	'OctetString'],
18	=> ['3GPP-SGSN-MCC-MNC',	'UTF8String'],
22	=> ['3GPP-User-Location-Info',	'OctetString'],
23	=> ['3GPP-MS-TimeZone',	'OctetString'],
258	=> ['Auth-Application-Id',	'Unsigned32'],
259	=> ['Acct-Application-Id',	'Unsigned32'],
260	=> ['Vendor-Specific-Application-Id',	'Grouped'],
261	=> ['Redirect-Host-Usage',	'Enumerated'],
262	=> ['Redirect-Max-Cache-Time',	'Unsigned32'],
263	=> ['Session-Id',	'UTF8String'],
264	=> ['Origin-Host',	'DiamIdent'],
266	=> ['Vendor-Id',	'Unsigned32'],
268	=> ['Result-Code',	'Unsigned32'],
274	=> ['Auth-Request-Type',	'Enumerated'],
277	=> ['Auth-Session-State',	'Enumerated'],
278	=> ['Origin-State-Id',	'Unsigned32'],
279	=> ['Failed-AVP',	'Grouped'],
280	=> ['Proxy-Host',	'DiamIdent'],
281	=> ['Error-Message',	'UTF8String'],
282	=> ['Route-Record',	'DiamIdent'],
283	=> ['Destination-Realm',	'DiamIdent'],
284	=> ['Proxy-Info',	'Grouped'],
285	=> ['Re-Auth-Request-Type',	'Enumerated'],
292	=> ['Redirect-Host',	'UTF8String'],
293	=> ['Destination-Host',	'DiamIdent'],
294	=> ['Error-Reporting-Host',	'DiamIdent'],
295	=> ['Termination-Cause',	'Enumerated'],
296	=> ['Origin-Realm',	'DiamIdent'],
297	=> ['Experimental-Result',	'Grouped'],
298	=> ['Experimental-Result-Code',	'Unsigned32'],
30	=> ['Called-Station-ID',	'UTF8String'],
33	=> ['Proxy-State',	'OctetString'],
334	=> ['MIP-Home-Agent-Address',	'Address'],
348	=> ['MIP-Home-Agent-Host',	'DiamIdent'],
415	=> ['CC-Request-Number',	'Unsigned32'],
416	=> ['CC-Request-Type',	'Enumerated'],
430	=> ['Final-Unit-Indication',	'Grouped'],
432	=> ['Rating-Group',	'Unsigned32'],
439	=> ['Service-Identifier',	'Unsigned32'],
443	=> ['Subscription-Id',	'Grouped'],
444	=> ['Subscription-Id-Data',	'UTF8String'],
450	=> ['Subscription-Id-Type',	'Enumerated'],
458	=> ['User-Equipment-Info',	'Grouped'],
459	=> ['User-Equipment-Info-Type',	'Enumerated'],
460	=> ['User-Equipment-Info-Value',	'OctetString'],
486	=> ['MIP6-Agent-Info',	'Grouped'],
4864	=> ['Subscribed-Carrier-Name',	'OctetString'],
4865	=> ['Subscriber-Class',	'Enumerated'],
4866	=> ['DCM-Service-Flags',	'Unsigned32'],
4867	=> ['Fomalimitplus-Information',	'Enumerated'],
4868	=> ['Fomalimitplus-Limitoverdate',	'OctetString'],
4869	=> ['LTE-Low-Class-Type',	'Enumerated'],
4870	=> ['MVNO-Identifier',	'Unsigned32'],
4871	=> ['MVNO-Plan',	'Unsigned32'],
4872	=> ['DCM-Service-WithdrawFlags',	'Unsigned32'],
4873	=> ['CA-Code',	'OctetString'],
4874	=> ['Data-Volume',	'Unsigned32'],
4875	=> ['Protocol-Configuration-Options',	'OctetString'],
4876	=> ['IP-Allocation',	'Enumerated'],
4878	=> ['Femto-ID',	'OctetString'],
4879	=> ['Femto-Status',	'Unsigned32'],
4880	=> ['Charging-Target-Flag',	'Unsigned32'],
4881	=> ['Dedicated-Line-Service-Flag',	'Unsigned32'],
4883	=> ['Volume-Threshold',	'Unsigned32'],
4885	=> ['Authentication-Protocol',	'Enumerated'],
4886	=> ['APN-Profile',	'Grouped'],
4887	=> ['UserID-Authentication',	'Enumerated'],
4888	=> ['UserID-Authentication-Password',	'OctetString'],
4889	=> ['ID-Notification',	'Enumerated'],
4891	=> ['APN-Service-Information',	'Unsigned32'],
4893	=> ['Preservation-Allowed-Time',	'Unsigned32'],
4894	=> ['Packet-Scheduling-Indicator',	'Enumerated'],
4895	=> ['TerminalState',	'Unsigned32'],
4897	=> ['S5-S8-Indicator',	'Enumerated'],
4898	=> ['Imode-Contract-Information',	'Enumerated'],
4899	=> ['DOCOMO-Container',	'OctetString'],
4900	=> ['DOCOMO-Container2',	'OctetString'],
4901	=> ['DOCOMO-Container3',	'OctetString'],
4902	=> ['Xsp-Roaming-Notification-Privacy',	'Enumerated'],
4903	=> ['Limited-APN-List',	'Grouped'],
4904	=> ['HPLMN-ODB',	'Unsigned32'],
493	=> ['Service-Selection',	'UTF8String'],
500	=> ['Abort-Cause',	'Enumerated'],
501	=> ['Access-Network-Charging-Address',	'Address'],
502	=> ['Access-Network-Charging-Identifier',	'Grouped'],
503	=> ['Access-Network-Charging-Identifier-Value',	'OctetString'],
504	=> ['AF-Application-Identifier',	'OctetString'],
505	=> ['AF-Charging-Identifier',	'OctetString'],
507	=> ['Flow-Description',	'UTF8String'],
509	=> ['Flow-Number',	'Unsigned32'],
510	=> ['Flows',	'Grouped'],
511	=> ['Flow-Status',	'Enumerated'],
512	=> ['Flow-Usage',	'Enumerated'],
513	=> ['Specific-Action',	'Enumerated'],
515	=> ['Max-Requested-Bandwidth-DL',	'Unsigned32'],
516	=> ['Max-Requested-Bandwidth-UL',	'Unsigned32'],
517	=> ['Media-Component-Description',	'Grouped'],
518	=> ['Media-Component-Number',	'Unsigned32'],
519	=> ['Media-Sub-Component AVP',	'Grouped'],
520	=> ['Media-Type',	'Enumerated'],
521	=> ['RR-Bandwidth',	'Unsigned32'],
522	=> ['RS-Bandwidth',	'Unsigned32'],
523	=> ['SIP-Forking-Indication',	'Enumerated'],
524	=> ['Codec-Data ',	'OctetString'],
525	=> ['Service-URN',	'OctetString'],
526	=> ['Acceptable-Service-Info',	'Grouped'],
527	=> ['Service-Info-Status',	'Enumerated'],
6	=> ['3GPP-SGSN-Address',	'OctetString'],
600	=> ['Visited-Network-Identifier',	'OctetString'],
618	=> ['Charging-Information',	'Grouped'],
628	=> ['Supported-Features',	'Grouped'],
629	=> ['Feature-List-ID',	'Unsigned32'],
630	=> ['Feature-List',	'Unsigned32'],
701	=> ['MSISDN',	'OctetString'],
8	=> ['Framed-IP-Address',	'OctetString'],
848	=> ['Served-Party-IP-Address',	'Address'],
909	=> ['RAI',	'UTF8String'],
97	=> ['Framed-IPv6-Prefix',	'OctetString'],


# PDG Docomo Original AVPs
4124	=> ['FGW-IP-Address',	'OctetString'],
4125	=> ['BTS-IP-Address',	'OctetString'],
4126	=> ['RNC-IP-Address',	'OctetString'],
4127	=> ['OPS-IP-Address',	'OctetString'],
4128	=> ['NTP-IP-Address',	'OctetString'],
4129	=> ['BTS-Location',	'OctetString'],
4130	=> ['Reset Timing',	'OctetString'],
16394	=> ['HeNB Information',	'OctetString'],
16391	=> ['DeBGW-IP Address',	'OctetString'],
16390	=> ['HeNB-IP Address',	'OctetString'],
16392	=> ['MME-IP Address',	'OctetString'],
16393	=> ['Action-Mode',	'OctetString'],
);



sub disp_ie {
	my $depth = shift @_;
	my $len = shift @_;
	my @array = @_;
	my $ie;
	my $avp_len_str;
	my $value_len;

	while (@array) {
		$ie =    join('', @array[0 .. 3]);
		$flags = $array[4];
		$avp_len_str = join('', @array[5..7]);

		@array = @array[8 .. $#array];
		$len -= 8;

		print "\t" x $depth, "### ", $ies{hex $ie}->[0], "\n" if $disp_ie_comment;
		print "\t" x $depth, $ie, " ", $flags, " ", $avp_len_str, " " ;

		$value_len = (hex $avp_len_str) - 8;
		$value_len = int(($value_len + 3) / 4) * 4;

		if (hex($flags) & 0x80) {
			print join('', @array[0..3]);
			@array = @array[4 .. $#array];
			$value_len -= 4;
			$len -= 4;
		}
		print "\n";

		if ($ies{hex $ie}->[1] eq "Grouped") {
			disp_ie($depth + 1, $value_len, @array[0..$value_len-1]);
		}
		else {
			print "\t" x $depth, "\t", @array[0..$value_len-1];
			if ($disp_value_decode) {
				print "\t# ", pack("H*", join('', @array[0..$value_len-1])) if $ies{hex $ie}->[1] eq "UTF8String";
				print "\t# ", pack("H*", join('', @array[0..$value_len-1])) if $ies{hex $ie}->[1] eq "DiamIdent";
			}
			print "\n";
		}

		@array = @array[$value_len .. $#array];
		print "\n" if $depth == 0;
	}
}


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

#print @array;
#exit;

$total_len = hex join('', @array[1..3]);
for ($i = 0; $i < 20; $i++) {
	print shift @array;
	print " " if (($i % 4) == 3);
}
print "\n";

$disp_ie_comment = 1 and $ARGV[0] = "" if ($ARGV[0] eq "-c");
$disp_value_decode = 1 and $ARGV[1] = "" if ($ARGV[1] eq "-v");
disp_ie(0, $total_len - 20, @array);


