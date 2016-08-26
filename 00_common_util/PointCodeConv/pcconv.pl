#!/usr/bin/perl

#===============================================================================
# TTC JT-Q704 format
# 
#   i.e. 16bit (M=5bit / S=4bit / U=7bit)
# 
#   e.g. M-S-U = 01-14-024
#        Binary= 0011000 1110 00001
#        Hex   = 31C1
#===============================================================================

$raw = $ARGV[0];

# input format : dd-dd-ddd
if ($raw =~ /(\d{2})\-(\d{2})\-(\d{2,3})/) {
	$d1 = $1;
	$d2 = $2;
	$d3 = $3;
	
	$hex = $d1 | ($d2 << 5) | ($d3 << 9);
	
	printf("%04x \n", $hex);
}
# input format : xxxx
elsif ($raw =~ /^[0-9a-fA-F]{4}$/) {
	$hex = hex($raw);
	
	$d1 = $hex      & 0b_0000_0000_0001_1111;
	$d2 = $hex >> 5 & 0b_0000_0000_0000_1111;
	$d3 = $hex >> 9 & 0b_0000_0000_0111_1111;
	
	printf("%02d-%02d-%03d \n", $d1, $d2, $d3);
}
# illegal format
else{
	print "Illegal format! \n";
}


