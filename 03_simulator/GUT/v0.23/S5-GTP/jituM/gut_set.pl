#!/usr/bin/perl

if( ! open ( GUT_CONF, "<gut.conf")) {
    print "gut.conf File not found.\n";
    exit(-1);
}

if( ! open ( SGBTRC, "<sgbtrc.txt")) {
    print "sgbtrc.txt File not found.\n";
    exit(-1);
}

while (<SGBTRC>) {
	chomp;

	if ( /ipadr_own_u_s5=(.*)/ ) {
		$sgw_ip = $1;
	}
	if ( /gre_key_s5=\d{4}(\d{4})/ ) {
		$sgw_teid_u = "4040" . $1;
	}
	if ( /ipadr_v4_pdn=(.*)/ ) {
        	$euip = $1;
	}
}

while(<GUT_CONF>){
    s/SERVER_NW_v4           =.*/SERVER_NW_v4           =$euip\/32/;
    s/GTP-U_DST_IP           =.*/GTP-U_DST_IP           =$sgw_ip/;
    s/GWP-U_TEID             =.*/GWP-U_TEID             =$sgw_teid_u/;
    print
}


close(SGBTRC);
close(GUT_CONF);
