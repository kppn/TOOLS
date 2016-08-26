#!/usr/bin/perl
#
# Transport Layer Addres 抽出位置確認ツール
#
# 2013/09/04  NEC  version0 Release
#
#

$IN_IMSI = $ARGV[0];
if ( $ARGV[0] eq "" ){
  print "\n";
  print " IMSIを指定してください\n";
  print "\n";
  exit;
}

@RES_SPTRC = `str_sptrc imsi $IN_IMSI`;

if ( index( @RES_SPTRC[0], "search number" ) eq -1 ){
  print "\n";
  print " 通信中ではありません\n";
  print "\n";
  exit;
}  

print "\n";
$DATE_ORG = substr(@RES_SPTRC[26], index( @RES_SPTRC[26], "=") + 1, 17);
$DATE_ORG =~  s/://g;
$DATE_ORG =~  s/\///g;
$DATE_ORG = substr($DATE_ORG, 0, 11);
print "接続完了時間 $DATE_ORG\n";

#print "\n";
$IPADR_OUN_C = substr(@RES_SPTRC[6], index( @RES_SPTRC[6], "=") + 1, 15);
chomp ( $IPADR_OUN_C );
$IPADR_OUN_C =~  s/ //g;

print "IPアドレス   $IPADR_OUN_C\n";
  my $WK_INT = 0;
  $IPADR_OUN_C_HEX = "";
  while ( $WK_INT < 3 ) {
    $IPADR_OUN_C_HEX = $IPADR_OUN_C_HEX . sprintf "%x", substr($IPADR_OUN_C, 0,index( $IPADR_OUN_C, "."));
    $IPADR_OUN_C = substr($IPADR_OUN_C, index( $IPADR_OUN_C, ".") + 1, length( $IPADR_OUN_C ));
    $WK_INT ++;
  }
  $IPADR_OUN_C_HEX = $IPADR_OUN_C_HEX . sprintf "%x", $IPADR_OUN_C;

print "             $IPADR_OUN_C_HEX\n";

&RAB_REQ_GET();
$RAB_SET_POS = index( $RAB_REQ_DATA, $IPADR_OUN_C_HEX) / 2;
print "擬似呼設定値 $RAB_SET_POS\n";
print "\n";
exit;

##########################################################
# 
sub RAB_REQ_GET {

  @RES_SSMON = `view_ssmon file $DATE_ORG imsi $IN_IMSI`;

  my $WK_INT = 0;
  my $WK_FLG = 0;
  $RAB_REQ_DATA = "";

  while ( $WK_INT <= $#RES_SSMON ) {

    @RES_SSMON[$WK_INT] =~ s/ //g;
    if ( index( @RES_SSMON[$WK_INT], "rab_assignment_request") ne -1 ){
      $WK_FLG = 1;
    }
    if ( $WK_FLG eq 1 ) {
      if ( length( @RES_SSMON[$WK_INT] ) eq 1 ) {
        last;
      }
      if ( index( @RES_SSMON[$WK_INT], "data") ne -1 ){
        chomp ( @RES_SSMON[$WK_INT] );
        $RAB_REQ_DATA = $RAB_REQ_DATA . @RES_SSMON[$WK_INT];
      }
    }
    $WK_INT ++;
  }
  $RAB_REQ_DATA =~ s/data=//g;
  print "\n";
}
