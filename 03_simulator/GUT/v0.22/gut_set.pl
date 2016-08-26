#!/usr/bin/perl

if( ! open ( GUT_CONF, "<gut.conf")) {
    print "File not found.\n";
    exit(-1);
}

$a = `grep teid_u_s1_s4 sgbtrc.txt | cut -c 24-`;
$a =~ s/\n//;
$b = `grep ipadr_v4_pdn sgbtrc.txt | cut -c 20-`;
$b =~ s/\n//;
$c = `grep ipadr_v6_pdn sgbtrc.txt | cut -c 20-`;
$c =~ s/\n//;
while(<GUT_CONF>){
    s/GWP-U_TEID             =.*/GWP-U_TEID             =$a/g;
    s/EUIPv4                 =.*\//EUIPv4                 =$b\//g;
    s/EUIPv6                 =.*\//EUIPv6                 =$c\//g;
    print
}

close(GUT_CONF);
