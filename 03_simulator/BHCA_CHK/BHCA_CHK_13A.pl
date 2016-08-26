#!/usr/bin/perl

use strict;
use Time::Local;
use threads;
use threads::shared;

#print "Debug Exit" and exit if ( 1 == 1);

my $unit  = $ARGV[0];
my $model = $ARGV[1];

if ($#ARGV < 1) {
print <<EOL;
error: few args

  usage
    BHCA_CHK_13A.pl unit (PKT|CPU|ITI)

  example
    BHCA_CHK_13A.pl NxGSN_D PKT
EOL
}


my $TrafficFile_Dir = "../Traffic_CHOUAN_" . $unit;
my @PRINT_DATA  : shared;
my @PRINT_CHECK : shared;



# import traffic definition file
push(@INC, '/home/shift/ShareDir/CHOUAN/Chk_CHOUAN_COMMON');
my $package_name = "BHCA_CHK_Traffic_Def_" . $unit . "_" . $model;
my $require_cmd = "require " . $package_name;
eval ($require_cmd);

my @Procedure = $package_name->get_procedure;



my $n = @Procedure / 10;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);

my @GET_Thread;
my $x = 1;
  while( $x <= $n ){
    my $TMP_Thread = threads->new(\&GETFnc,  $Procedure[$x * 10 - 10], 
                                             $Procedure[$x * 10 - 9], 
                                             $Procedure[$x * 10 - 8], 
                                             $Procedure[$x * 10 - 7], 
                                             $Procedure[$x * 10 - 6],
                                             $Procedure[$x * 10 - 5],
                                             $Procedure[$x * 10 - 4],
                                             $Procedure[$x * 10 - 3],
                                             $Procedure[$x * 10 - 2],
                                             $Procedure[$x * 10 - 1]     );
    push(@GET_Thread, $TMP_Thread);
    $x++;
  }

sleep 5;

my $Print_Thread = threads->new(\&PrintFnc, "CHK");

#################################################
$Print_Thread->join;
foreach(@GET_Thread){
  $_->join;
}

#################################################
sub PrintFnc {
   while(1){
     #system("clear");

     foreach(@PRINT_CHECK){
       print "$_\n";  
     }
     print "====== CHECK ===========================================\n";
     print "\n";

     $x = 1;
     while( $x <= $n ){
       print "$PRINT_DATA[$x]\n";
       $x++;
     }
     
     print "====== END =============================================\n";
     print "========================================================\n";
     threads->yield();
     sleep 5;
   }
}
#################################################

sub GETFnc {
   my $SET_TUBAN;
   my $SET_KOSYU;
   my $SET_NodeName;
   my $SET_SceName;
   my $SET_100PreBHCA;
   my $SET_ChkTraffic;
   my $SET_ChkTraffic_OK;
   my $SET_KEISUU;
    
   my @TrafficFile_Tmp;
   my $TrafficFile_Cnt;
   my $TrafficFile;
    
   my @Get_Time     = ( 0, 0 ) ;
   my @Get_Value    = ( 0, 0 ) ;
   my @Get_Value_OK = ( 0, 0 ) ;
   my $OldCnt       = @Get_Time;  
 
   my $BHCA_Value = 0;
   my $BHCA_Gage  = "";
    
   my $CHK_Num   = 0;
   my $CHK_NumOK = 0;;

   my $InitF = 0;
   
   while($InitF == 0){
       $SET_TUBAN          = $_[0];
       $SET_KOSYU          = $_[1];
       $SET_SceName        = $_[2];
       $SET_100PreBHCA     = $_[3];
       $SET_ChkTraffic     = $_[4];
       $SET_ChkTraffic_OK  = $_[5];
       $SET_KEISUU         = $_[6];
    
       $PRINT_DATA[$SET_TUBAN] = "$SET_KOSYU : NON DATA ";
   
       @TrafficFile_Tmp = `ls -1tr $TrafficFile_Dir/\*$SET_SceName\_stat\*`; 
       $TrafficFile_Cnt = @TrafficFile_Tmp;
       $TrafficFile     = @TrafficFile_Tmp[$TrafficFile_Cnt - 1];
    
       my $CHK_Num_Tmp = `head -n 1 $TrafficFile`;
       my @Tmp = split(/,/, $CHK_Num_Tmp);
    
       my $T1 = 0;
       foreach my $Value (@Tmp){
         if( $Value eq $SET_ChkTraffic ){
           $CHK_Num = $T1;
           $T1++;
         }elsif( $Value eq $SET_ChkTraffic_OK ){
           $CHK_NumOK = $T1;
           $T1++;
         }else{
           $T1++;
         }
       }

       $InitF = $CHK_Num;
       if($InitF == 0) { sleep 1; }
   }

   my @GetDATA;
   while(1){
     my $T_Sleep = 10;
     @GetDATA = `tail -n 4 $TrafficFile`;
     my $GetDATA_cnt = @GetDATA;
     my @GetData_Point = split(/,/, $GetDATA[$GetDATA_cnt - 1]);
    
     my $NEW_Time = $GetData_Point[0];
     my $T_Year  = substr($NEW_Time,  0, 4);
     my $T_Mouth = substr($NEW_Time,  4, 2);
     my $T_Day   = substr($NEW_Time,  6, 2);
     my $T_Hour  = substr($NEW_Time,  9, 2);
     my $T_Min   = substr($NEW_Time, 11, 2);
     my $T_Sec   = substr($NEW_Time, 13, 2);
     my $T_Msec  = substr($NEW_Time, 15, 3) / 1000;
     $T_Year -= 1900;
     $T_Mouth--;

     my $TimeF = 1;
     
     #if($T_Year  < 0                  ){ $TimeF = 0; }
     if($T_Mouth < 0 || 12 < $T_Mouth ){ $TimeF = 0; }
     if($T_Hour  < 0 || 23 < $T_Hour  ){ $TimeF = 0; }
     if($T_Min   < 0 || 59 < $T_Min   ){ $TimeF = 0; }
     if($T_Sec   < 0 || 59 < $T_Sec   ){ $TimeF = 0; }

     if($TimeF == 1){
       my $fura = sprintf("%.3f", timelocal($T_Sec, $T_Min, $T_Hour, $T_Day, $T_Mouth, $T_Year) + $T_Msec);
       if($Get_Time[$OldCnt] != $fura){
         my $hoge = shift(@Get_Time);
            $hoge = shift(@Get_Value);
            $hoge = shift(@Get_Value_OK);

         $Get_Time[$OldCnt]     = sprintf("%.3f", timelocal($T_Sec, $T_Min, $T_Hour, $T_Day, $T_Mouth, $T_Year) + $T_Msec);
         $Get_Value[$OldCnt]    = $GetData_Point[$CHK_Num];
         $Get_Value_OK[$OldCnt] = $GetData_Point[$CHK_NumOK];

           my $NowSetBHCA = $GetData_Point[3] / $SET_KEISUU;
           my $fuga = ( 3600 / $NowSetBHCA);
           if($fuga <= 0.1 ){
              $T_Sleep = 10;
           }elsif($fuga < 1){
              $T_Sleep = 20;
           }elsif($fuga < 2){
              #$T_Sleep = $fuga * 3 + 1;
              $T_Sleep = 50;
           }else{
              $T_Sleep = ($fuga * 2) + 2;
           }
   
           if($NowSetBHCA == 1){
              $T_Sleep = 10;
           }
 
           my $NowSetBHCA_Pre = sprintf("%.2f" , $NowSetBHCA / $SET_100PreBHCA);
           $NowSetBHCA_Pre = $NowSetBHCA_Pre * 100;
           if( $NowSetBHCA_Pre > 999 ){ $NowSetBHCA_Pre = "999"; }
    
             my $TMP_Time  = $Get_Time[$OldCnt] - $Get_Time[0];
             my $TMP_Value = $Get_Value[$OldCnt] - $Get_Value[0];
             my $Send_Value    = sprintf("%.2f" ,$TMP_Value / $TMP_Time);
             my $OK = 0;
             if($Send_Value != 0){
               $OK = ((($Get_Value_OK[$OldCnt] - $Get_Value_OK[0]) / $TMP_Time) * 3600 ) / $NowSetBHCA * 100;
             }      
             $OK = sprintf("%.2f", $OK); 
    
             $BHCA_Value = $TMP_Value / $TMP_Time;
             $BHCA_Value = sprintf("%.6f", $BHCA_Value);
             $BHCA_Value = sprintf("%.2f", $BHCA_Value * 3600);

             
             if ($SET_100PreBHCA < 0) {
               my $OK_in_Hour = ((($Get_Value_OK[$OldCnt] + 1.0 - $Get_Value_OK[0]) / $TMP_Time) * 3600 );
               $BHCA_Value = 1 if $BHCA_Value == 0;
               $OK = ($OK_in_Hour / $BHCA_Value) * 100;
               $OK = sprintf("%.2f", $OK);
             }
             
             my $BHCA_Per = sprintf("%.2f", $BHCA_Value / $NowSetBHCA * 100);
             if( $BHCA_Per > 999 ){ $BHCA_Per = 999.99; }
             $BHCA_Gage = "\|";
             for( my $cnt = 70; $cnt <= 130; $cnt += 2){
               if($cnt <= $BHCA_Per){ 
                 if($cnt == 100){ 
                   $BHCA_Gage = $BHCA_Gage . "O"; 
                 }else{
                   $BHCA_Gage = $BHCA_Gage . ">"; 
                 }
               }else{
                 if($cnt == 100){
                   $BHCA_Gage = $BHCA_Gage . "X";
                 }else{
                   $BHCA_Gage = $BHCA_Gage . " ";
                 }
               }
             }
             $BHCA_Gage = $BHCA_Gage . "\|";
    
             my $Attempt_OK = 0;
            
             my $BHCA_Per_Print        = sprintf("%6s",  $BHCA_Per       );
             my $NowSetBHCA_Print      = sprintf("%7s",  $NowSetBHCA     );
             my $NowSetBHCA_Pre_Print  = sprintf("%3s",  $NowSetBHCA_Pre >= 0 ? $NowSetBHCA_Pre : -$NowSetBHCA_Pre);
             my $BHCA_Value_Print      = sprintf("%10s", $BHCA_Value     );
             my $Send_Value_Print      = sprintf("%7s",  $Send_Value     );
             my $OK_Print              = sprintf("%6s",  $OK             );
             my $SET_100PreBHCA_Print  = sprintf("%7s",  $SET_100PreBHCA >= 0 ? $SET_100PreBHCA : '--');
             $T_Sleep               = sprintf("%3d",  $T_Sleep        );
    
             $PRINT_DATA[$_[0]] = "$SET_KOSYU  $BHCA_Gage $BHCA_Per_Print\%"
                                . "    SET=$NowSetBHCA_Print\($NowSetBHCA_Pre_Print\%\)"
                                . "    BHCA=$BHCA_Value_Print"
                                . "    Send=$Send_Value_Print\/sec"
                                . "    OK=$OK_Print\%"
                                . "    100\%=$SET_100PreBHCA_Print"
                                . "    LastData=$T_Hour:$T_Min:$T_Sec"
                                . "    Sleep=$T_Sleep";

             if($T_Sleep != 1){
                 if($BHCA_Per <= 90){
                    #push(@PRINT_CHECK, $PRINT_DATA[$_[0]]);
                 }
             }
             $NowSetBHCA = 0;
             $NowSetBHCA_Pre = 0;
             $NowSetBHCA_Pre_Print = "";
       }
     } 

     threads->yield();
     sleep $T_Sleep;

   }
}
    
    
