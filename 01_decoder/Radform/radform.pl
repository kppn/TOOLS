#!/usr/bin/perl


############################################################################
# Change History
# 	
# 	2012/1/31	T.Kondoh
# 		* first release
#
# 	
############################################################################



%ies = (
1	 => ['User-Name',		"UTF8String"],
2	 => ['User-Password'],
3	 => ['CHAP-Password'],
4	 => ['NAS-IP-Address',		"IPAddress"],
5	 => ['NAS-Port'],
6	 => ['Service-Type',		"Enumerated",
					{1 =>	'Login',
					2 =>	'Framed',
					3 =>	'Callback Login',
					4 =>	'Callback Framed',
					5 =>	'Outbound',
					6 =>	'Administrative',
					7 =>	'NAS Prompt',
					8 =>	'Authenticate Only',
					9 =>	'Callback NAS Prompt',
					10 =>	'Call Check'},
	    ],
7	 => ['Framed-Protocol',		"Enumerated",
					{1	 => 'PPP',
					2	 => 'SLIP',
					3	 => 'AppleTalk Remote Access Protocol (ARAP)',
					4	 => 'Gandalf proprietary SingleLink/MultiLink protocol',
					5	 => 'Xylogics proprietary IPX/SLIP',
					6	 => 'X.75 Synchronous',
					7	 => 'GPRS PDP Context',},
	    ],
8	 => ['Framed-IP-Address',		"IPAddress"],
9	 => ['Framed-IP-Netmask'],
10	 => ['Framed-Routing'],
11	 => ['Filter-Id'],
12	 => ['Framed-MTU'],
13	 => ['Framed-Compression'],
14	 => ['Login-IP-Host'],
15	 => ['Login-Service'],
16	 => ['Login-TCP-Port'],
17	 => ['Unassigned'],
18	 => ['Reply-Message'],
19	 => ['Callback-Number'],
20	 => ['Callback-Id'],
21	 => ['Unassigned'],
22	 => ['Framed-Route'],
23	 => ['Framed-IPX-Network'],
24	 => ['State'],
25	 => ['Class'],
26	 => ['Vendor-Specific'],
27	 => ['Session-Timeout'],
28	 => ['Idle-Timeout'],
29	 => ['Termination-Action'],
30	 => ['Called-Station-Id',	"UTF8String"],
31	 => ['Calling-Station-Id'],
32	 => ['NAS-Identifier'],
33	 => ['Proxy-State'],
34	 => ['Login-LAT-Service'],
35	 => ['Login-LAT-Node'],
36	 => ['Login-LAT-Group'],
37	 => ['Framed-AppleTalk-Link'],
38	 => ['Framed-AppleTalk-Network'],
39	 => ['Framed-AppleTalk-Zone'],
40	 => ['Acct-Status-Type',	"Enumerated",
					{1 => 'Start',
					 2 => 'Stop',
					 3 => 'Interim-Update',
					 7 => 'Accounting-On',
					 8 => 'Accounting-Off'},
	    ],
41	 => ['Acct-Delay-Time'],
42	 => ['Acct-Input-Octets'],
43	 => ['Acct-Output-Octets'],
44	 => ['Acct-Session-Id',		"UTF8String"],
45	 => ['Acct-Authentic'],
46	 => ['Acct-Session-Time'],
47	 => ['Acct-Input-Packets'],
48	 => ['Acct-Output-Packets'],
49	 => ['Acct-Terminate-Cause'],
50	 => ['Acct-Multi-Session-Id'],
51	 => ['Acct-Link-Count'],
52	 => ['Acct-Input-Gigawords'],
53	 => ['Acct-Output-Gigawords'],
54	 => ['Unassigned'],
55	 => ['Event-Timestamp'],
56	 => ['Egress-VLANID'],
57	 => ['Ingress-Filters'],
58	 => ['Egress-VLAN-Name'],
59	 => ['User-Priority-Table'],
60	 => ['CHAP-Challenge'],
61	 => ['NAS-Port-Type'],
62	 => ['Port-Limit'],
63	 => ['Login-LAT-Port'],
64	 => ['Tunnel-Type'],
65	 => ['Tunnel-Medium-Type'],
66	 => ['Tunnel-Client-Endpoint'],
67	 => ['Tunnel-Server-Endpoint'],
68	 => ['Acct-Tunnel-Connection'],
69	 => ['Tunnel-Password'],
70	 => ['ARAP-Password'],
71	 => ['ARAP-Features'],
72	 => ['ARAP-Zone-Access'],
73	 => ['ARAP-Security'],
74	 => ['ARAP-Security-Data'],
75	 => ['Password-Retry'],
76	 => ['Prompt'],
77	 => ['Connect-Info'],
78	 => ['Configuration-Token'],
79	 => ['EAP-Message'],
80	 => ['Message-Authenticator'],
81	 => ['Tunnel-Private-Group-ID'],
82	 => ['Tunnel-Assignment-ID'],
83	 => ['Tunnel-Preference'],
84	 => ['ARAP-Challenge-Response'],
85	 => ['Acct-Interim-Interval'],
86	 => ['Acct-Tunnel-Packets-Lost'],
87	 => ['NAS-Port-Id'],
88	 => ['Framed-Pool'],
89	 => ['CUI'],
90	 => ['Tunnel-Client-Auth-ID'],
91	 => ['Tunnel-Server-Auth-ID'],
92	 => ['NAS-Filter-Rule'],
93	 => ['Unassigned'],
94	 => ['Originating-Line-Info'],
95	 => ['NAS-IPv6-Address'],
96	 => ['Framed-Interface-Id'],
97	 => ['Framed-IPv6-Prefix'],
98	 => ['Login-IPv6-Host'],
99	 => ['Framed-IPv6-Route'],
100	 => ['Framed-IPv6-Pool'],
101	 => ['Error-Cause'],
102	 => ['EAP-Key-Name'],
103	 => ['Digest-Response'],
104	 => ['Digest-Realm'],
105	 => ['Digest-Nonce'],
106	 => ['Digest-Response-Auth'],
107	 => ['Digest-Nextnonce'],
108	 => ['Digest-Method'],
109	 => ['Digest-URI'],
110	 => ['Digest-Qop'],
111	 => ['Digest-Algorithm'],
112	 => ['Digest-Entity-Body-Hash'],
113	 => ['Digest-CNonce'],
114	 => ['Digest-Nonce-Count'],
115	 => ['Digest-Username'],
116	 => ['Digest-Opaque'],
117	 => ['Digest-Auth-Param'],
118	 => ['Digest-AKA-Auts'],
119	 => ['Digest-Domain'],
120	 => ['Digest-Stale'],
121	 => ['Digest-HA1'],
122	 => ['SIP-AOR'],
123	 => ['Delegated-IPv6-Prefix'],
124	 => ['MIP6-Feature-Vector'],
125	 => ['MIP6-Home-Link-Prefix'],
126	 => ['Operator-Name'],
127	 => ['Location-Information'],
128	 => ['Location-Data'],
129	 => ['Basic-Location-Policy-Rules'],
130	 => ['Extended-Location-Policy-Rules'],
131	 => ['Location-Capable'],
132	 => ['Requested-Location-Info'],
133	 => ['Framed-Management-Protocol'],
134	 => ['Management-Transport-Protection'],
135	 => ['Management-Policy-Id'],
136	 => ['Management-Privilege-Level'],
137	 => ['PKM-SS-Cert'],
138	 => ['PKM-CA-Cert'],
139	 => ['PKM-Config-Settings'],
140	 => ['PKM-Cryptosuite-List'],
141	 => ['PKM-SAID'],
142	 => ['PKM-SA-Descriptor'],
143	 => ['PKM-Auth-Key'],
144	 => ['DS-Lite-Tunnel-Name'],
);





sub disp_ie {
	my $depth = shift @_;
	my $len = shift @_;
	my @array = @_;
	my $ie;
	my $avp_len_str;
	my $value_len;

	while (@array) {
		$ie =    join('', @array[0]);
		$avp_len_str = join('', @array[1]);

		@array = @array[2 .. $#array];
		$len -= 2;

		print "\t" x $depth, "### ", $ies{hex $ie}->[0], "\n" if $disp_ie_comment;
		print "\t" x $depth, $ie, " ", $avp_len_str, " " ;
		print "\n";
		
		$value_len = (hex $avp_len_str) - 2;

		if ($ies{hex $ie}->[1] eq "Grouped") {
			disp_ie($depth + 1, $value_len, @array[0..$value_len-1]);
		}
		else {
			print "\t" x $depth, "\t", @array[0..$value_len-1];
			if ($disp_value_decode) {
				print "\t# ", pack("H*", join('', @array[0..$value_len-1])) if $ies{hex $ie}->[1] eq "UTF8String";
				print "\t# ", pack("H*", join('', @array[0..$value_len-1])) if $ies{hex $ie}->[1] eq "DiamIdent";
				if ($ies{hex $ie}->[1] eq "IPAddress") {
					printf("\t# %d.%d.%d.%d", hex $array[0], hex $array[1], hex $array[2], hex $array[3]);
				}
				
				if ( $ies{hex $ie}->[1] eq "Enumerated") {
					print "\t# ";
					$value = hex join('', @array[0..$value_len-1]);
					$value_name = $ies{hex $ie}->[2]->{$value};
					print $value_name;
				}
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

print "##### Access-Request"		if $array[0] == 0x01;
print "##### Access-Accept"		if $array[0] == 0x02;
print "##### Access-Reject"		if $array[0] == 0x03;
print "##### Accounting-Request"	if $array[0] == 0x04;
print "##### Accounting-Response"	if $array[0] == 0x05;
print "\n\n";
print shift @array;
print "\t# code\n";
print shift @array;
print "\t# identifier\n";
print shift @array;
print shift @array;
print "\t# length\n";


$total_len = hex join('', @array[1..3]);
for ($i = 0; $i < 16; $i++) {
	print shift @array;
	print " " if (($i % 4) == 3);
}
print "# authenticator\n";
print "\n";

$disp_ie_comment = 1 and $ARGV[0] = "" if ($ARGV[0] eq "-c");
$disp_value_decode = 1 and $ARGV[1] = "" if ($ARGV[1] eq "-v");
disp_ie(0, $total_len - 20, @array);


