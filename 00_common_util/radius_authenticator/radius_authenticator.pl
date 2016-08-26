#!/usr/bin/perl

use Digest::MD5 'md5_hex';


$data_str = 
# Response Code/Id/Len
"021e001a" . 
# Request Authenticator
"c61c5237 8c32cc61 f56dd33c ad156915" . 
# Response Attributes
"08060ae0 1bdf" . 
# Secret Key
"6465627567";


$data_str =~ s/ //g;

$data = pack('H*', $data_str);
print md5_hex($data);

