#!/usr/bin/perl

print <<EOL;
ADD REQUEST
EBI=$ARGV[0]
GTP-U_OWN_TEID=00000001
GTP-U_DST_IP=172.30.63.228
GTP-U_DST_TEID=0000000f
EUIPV4=192.168.228.75/32
EUIPV6=fe80::4410:1045:0004:0304/64
SERVER_NW_V4=192.171.61.0/24
SERVER_NW_V6=2001:0001::1/128
.

EOL


