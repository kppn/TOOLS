#!/usr/bin/perl

###########################################################
# Change History
#
#	2011/5/30
#		* first release
# 
#       2011/10/7
#               * add function. 
#                     Translate MAP operation code to signal(MAP service) name.
#               
#               * bug fix.
#                     imsi/msisdn/guti/ptmsi matching.
# 
#       2014/7/3
#               * bug fix.
#                     fix file size culculation.
# 
###########################################################

#use Time::HiRes qw/usleep/;	# not use.
use sort '_mergesort';
use sort 'stable';

print sort::current;

$| = 1;


# sequence seperation time (i.e. print '----')
$separate_time = 30;


# On ver 2011/5/30, disabled change signal name.
%change_table = (
	access_request => 'Auth-Req',
	access_accept => 'Auth-Ack',
	access_reject => 'Auth-Rej',
	accounting_request_start => 'Acct-reQ(START)',
	accounting_response_start => 'Acct-reS(START)',
	accounting_request_stop => 'Acct-reQ(STOP)',
	accounting_response_stop => 'Acct-reS(STOP)',
	accounting_request_interim_update => 'Acct-ReQ(INTERIM)',
	accounting_response_interim_update => 'Acct-ReS(INTERIM)',
	disconnect_request => 'Discon-ReQ',
	disconnect_response_ack => 'Discon-Ack',
	disconnect_response_nak => 'Discon-Nak',

	combined_location_update_request => 'combined_location_update_request',

	create_pdp_context_request    => 'CPCreQ',
	create_pdp_context_response   => 'CPCreS',

	GTPv2_create_session_request  => 'GTPv2_CSreQ',
	GTPv2_create_session_response => 'GTPv2_CSreS',
	GTPv2_modify_bearer_request   => 'GTPv2_MBreQ',
	GTPv2_modify_bearer_response  => 'GTPv2_MBreS',

	credit_control_request => 'CC-Req',
	credit_control_answer => 'CC-Ans',
	re_auth_request => 'RAR',
	re_auth_answer => 'RAA',
	initial_request => 'init',
	update_request => 'update',
	termination_request => 'term',

	proxy_binding_update => 'PBU',
	proxy_binding_acknowledgement => 'PBA',
	binding_revocation_indication => 'BR-Ind',
	binding_revocation_acknowledgement => 'BR-Ack',
	connection_creation => 'cre',
	connection_deletion => 'del',
);


%indent_def = (
        # LTE Protocol
	RANAP => 0,
	SM  => 0,
	GMM => 0,
	MAP => 4,
	'BSSAP+' => 4,
	GTP => 8,
	S5GTP => 4,
	PMIP => 4,
	DIAMETER => 8,
	NWMP   => 12,
	RADIUS => 12,
);


%s5gtp = (
	"s-gw-snd-create_session_request" => 1,
	"s-gw-rec-create_session_response" => 1,
	"s-gw-snd-modify_bearer_request" => 1,
	"s-gw-rec-modify_bearer_response" => 1,
);

sub is_s5gtp {
	my $req = join '-', @_;
	return 1 if $s5gtp{$req};
	return 0;
}



%ope_codes = (
	'02' => 'UpdateLocation',
	'03' => 'CancelLocation',
	'04' => 'ProvideRoamingNumber',
	'07' => 'InsertSubscriberData',
	'08' => 'DeleteSubscriberData',
	'0a' => 'RegisterSs',
	'0b' => 'EraseSs',
	'0c' => 'ActivateSs',
	'0d' => 'DeactivateSs',
	'0e' => 'InterrogateSs',
	'0f' => 'AuthenticationFailureReport',
	'11' => 'RegisterPassword',
	'12' => 'GetPassword',
	'16' => 'SendRoutingInformation',
	'17' => 'UpdateGprsLocation',
	'18' => 'SendRoutingInfoForGprs',
	'19' => 'FailureReport',
	'1a' => 'NoteMsPresentForGprs',
	'25' => 'Reset',
	'26' => 'ForwardCheckSsIndication',
	'2c' => 'MT-forwardSM',
	'2d' => 'SendRoutingInfoForSm',
	'2e' => 'MO-forwardSM',
	'2f' => 'ReportSmDeliveryStatus',
	'32' => 'ActivateTraceMode',
	'33' => 'DeactivateTraceMode',
	'38' => 'SendAutheticationInfo',
	'39' => 'RestoreData',
	'3a' => 'SendImsi',
	'3b' => 'ProcessUnstructuredSsRequest',
	'3c' => 'UnstructuredSsRequest',
	'3d' => 'UnstructuredSsNotify',
	'3f' => 'InformServiceCentre',
	'40' => 'AlertServiceCentre',
	'42' => 'ReadyForSm',
	'43' => 'PurgeMs',
	'46' => 'ProvideSubscriberInfo',
	'49' => 'SetReportingState',
	'4a' => 'StatusReport',
	'4b' => 'RemoteUserFree',
	'4c' => 'RegisterCcEntry',
	'4d' => 'EraseCcEntry',
	'55' => 'SendRoutingInfoForLCS',
	'57' => 'IstAlert',
	'58' => 'IstCommand',
	'0f01' => 'InquirySSStatus',
	'0f02' => 'InquiryUserInfo',
	'0f03' => 'UpdateUserInfo',
	'0f04' => 'ManagementEventDetection',
	'0f05' => 'RequestSMDelivery',
	'0f06' => 'SMForServiceLoading',
	'0f07' => 'PocUserInfo',
	'0f08' => 'SwitchphoneActivatingChange',
	'0f09' => 'MsSettingNotification',
	'0f0a' => 'Web Customer Control',
	'0f0b' => 'RequestOTADelivery',
	'0f0c' => 'ReportOTA-DeliveryStatus',
	'0f0d' => 'InquiryWLANInfo',
	'0f0e' => 'UpdateWLANInfo',
	'0f0f' => 'ServiceInfoUpdate',
	'0f10' => 'IncomingAddressResolution',
	'0f11' => 'inquiryIMSInfo',
	'0f12' => 'RequestSmNotification',
	'0f13' => 'NwStateNotification',
	'0f14' => 'TerminalStateUpdate',
	'0f15' => 'PacketMessageResend',
	'0f16' => 'UserConnectionControl',
	'0f40' => 'RepresentiveSwitchInterrogation',
	'0f41' => 'CheckSubscriberStatus',
	'0f42' => 'NmscpDBPDBPStatusReport',
	'0f43' => 'InquirySubscriberProfile',
	'0f44' => 'ModifyBearer',
	'0f45' => 'EarlyACMNotify',
	'0f46' => 'ReleaseResources',
	'0f47' => 'Disconnect Call Notify',
	'0f48' => 'ChargeInformationNotify',
	'0f49' => 'ChargeInformationRe-Notify',
	'0f50' => 'UserAuthentication',
	'0f51' => 'RequestRegistration',
	'0f52' => 'InquiryIMEIInfo',
	'0f53' => 'EmergencyLocationRequest',
	'0f54' => 'HuntInducementResource',
	'0f70' => 'CombinedUpdateLocation',
	'0f71' => 'updateIMEIInfo',
	'0f72' => 'cancelIMEIInfo',
	'0f73' => 'deviceManagemntoControl',
	'0f80' => 'InquiryDBPServiceStatus',
	'0f81' => 'NmscpChangeover',
	'0f82' => 'NmscpChangeback',
	'0f83' => 'NmscpSignalRestriction',
	'0f84' => 'AscpSignalRestriction',
	'0f85' => 'MMS Congestion Control',
	'0f86' => 'ReNotifyIMEIInfo',
	'0f92' => 'VisitorInformationNotify',
	'0f93' => 'ChargeAuditWrite2',
	'0f94' => 'ChargeAuditReWrite2',
	'0f95' => 'CallMonitorWrite',
	'0fa3' => 'CallCircuitSearch',
	'0fb0' => 'NmscpOMPStatusReport',
	'0fb1' => 'NmscpDBPStatusRepor',
	'0fc0' => 'McxAccessTest',
	'0fc1' => 'RemoteFileAccessTest',
	'0fc2' => 'EquippedSectorCollect',
	'0fc3' => 'HealthCheck',
	'0fd8' => 'NmscpTransmissionConfirm',
	'0fd9' => 'NmscpTransmissionClear',
	'0fda' => 'NmscpTransmissionChangeback',
	'0fdb' => 'NmscpTransmissionChangeover',
	'0fdc' => 'NmscpTransmissionReady'
);



$target = 'M';
$today = `date '+%y%m%d'`;
chomp($today);
$file = '/SYSTEM/LOG_COM/msglog/msg' . $today . '.log';
while (@ARGV) {
	$arg = pop @ARGV;
	
	#print "$arg\n";

	if ($arg eq "-h") {
		print_usage();
		exit();
	}
	if ($arg eq "-C") {
		$target = 'C';
		next;
	}
	if ($arg eq "-f") {
		$mode{tail} = 1;
		next;
	}
	if ($arg =~ /^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}$/) {
		next;
	}
	if ($arg =~ /^msisdn=([0-9]+)/) {
		push @target_subid, $1;
		next;
	}
	if ($arg =~ /^imsi=([0-9]+)/) {
		push @target_subid, $1;
		next;
	}
	if ($arg =~ /^guti=([a-z0-9]+)/) {
		push @target_subid, $1;
		next;
	}
	if ($arg =~ /^ptmsi=([a-z0-9]+)/) {
		push @target_subid, $1;
		next;
	}
	if ($arg =~ /^file=(.+)$/) {
		$file = $1;
		next;
	}
	$file = $arg;
}
print "file: $file\n";


sub istarget_subid {
	my $subid = shift;
	my @target = @_;
	my $target_exist;

	foreach $target_subid (@target) {
		$target_exist++ if $target_subid ne "";
	}
	return 1 if $target_exist == 0;

	foreach $target_subid (@target) {
		return 1 if $subid eq $target_subid;
	}
	return 0;
}


while(1) {
	$filesize = -s $file;
	sleep(1) and next if $filesize <= $filesize_old;

	sleep(1);
	open(FILE, "<${file}") or die "file open failure\n";
	seek FILE, $filereadsize, 0;

        SIGNAL_RETRIEVE:
	while(<FILE>) {
		$filereadsize += length($_);
		
		chomp();
		
		# ssmon
		if ( /^${target}.* signal_monitor_report (msisdn|imsi|guti|ptmsi)=([0-9a-z]+)/ ) {
			$subid = $2;
			next SIGNAL_RETRIEVE if ! istarget_subid($subid, @target_subid);
		
			while (<FILE>) {
				$filereadsize += length($_);
				
				chomp();
				
				$proto  = $1 if ( /([A-Z\+]+) 信号モニタ/ );
				$server = $1 if ( /(sgp..)/ );
				$time   = $1 if ( /tm=([0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3})/ );
				$dir    = $1 if ( /kind=(...)/ );
				
				$sig  = "";
				$sig  = $proto . ':' if $proto eq 'BSSAP+';
				$sig .= $1 and last if ( /sig=([^ ]+)/ );
				
				if ( /(id_dilog=[0-9a-z]+)/ ) {
					$sig = $1;
					if ( /(code_ope=([0-9a-z]+))/ ) {
						if ($ope_codes{$2} ne "") {
							$sig .= '  ' . $ope_codes{$2};
						}
						else{
							$sig .= $proto . ':' . $1;
						}
					}
					last;
				}
				
				#$sig = $proto . ':' . $1 and last if ( /(id_dilog.*)/ );
			}
			push @sigarray,	{proto   => $proto,
					 server  => $server,
					 time    => $time,
					 dir     => $dir,
					 sig     => $sig};
			$sig = "";
		}
		
		$server_tmp = $1 if (m|[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} (ggp..)|);
		# gsmon
		if ( /^${target}.* ([A-Z]+)信号モニタ情報/ ) {
			$proto = $1;
			$server = $server_tmp;
			
			while (<FILE>) {
				$filereadsize += length($_);
				
				chomp();
				
				$subid_gg_msisdn = $2 if /(msisdn)=([0-9a-z]+)/;
				$subid_gg_imsi   = $2 if /(imsi)=([0-9a-z]+)/;
				#$server         = $1 if ( /(ggp..)/ );
				$time            = $1 if ( /date=.......... ([0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3})/ );

				$subid_gg_msisdn = $1 if /MSISDN +: ([0-9]+)/;
				$subid_gg_imsi   = $1 if /IMSI +: ([0-9]+)/;
				$time            = $1 if /送受信時刻 *: [0-9]{4}\/[0-9]{1,2}\/[0-9]{1,2} (..:..:..\....)/;
				$server          = $1 if /GGSN-UP番号 +: (.....)/;
				$dir             = $1 if /送受信データ識別 +: (...)/;
				#$sig             = $1 and print "sig:$sig\n" if /信号.*: (.*)/;
				$sig             = $1 and print "sig:$sig\n" if /\信.*: (.*)/;
				
				if ( /kind=(...)/ ) {
					$dir    = $1;
					if ( (! istarget_subid($subid_gg_msisdn, @target_subid)) and
					     (! istarget_subid($subid_gg_imsi, @target_subid))      ) {
					     	$subid_gg_msisdn = "";
						$subid_gg_imsi   = "";
						next SIGNAL_RETRIEVE;
					}
				}
				$sig = $1 and last if /sig=([^ ]+)/;

				if ( /送受信データ/ ) {    
					if ( (! istarget_subid($subid_gg_msisdn, @target_subid)) and
					     (! istarget_subid($subid_gg_imsi, @target_subid))      ) {
					     	$subid_gg_msisdn = "";
						$subid_gg_imsi   = "";
						next SIGNAL_RETRIEVE;
					}
					last;
				}
			}
			push @sigarray,	{proto   => $proto,
					 server  => $server,
					 time    => $time,
					 dir     => $dir,
					 sig     => $sig};
			$sig = "";
			$kind = "";
			$time = "";
			$dir = "";
			$subid_gg_msisdn = "";
			$subid_gg_imsi   = "";
		}
		
	}
	
	
	
	foreach $sigref (@sigarray) {
		#foreach $change_name (keys %change_table ) {
		#	$sigref->{sig} =~ s/$change_name/$change_table{$change_name}/;
		#}
		$line = "$sigref->{time} $sigref->{server} $sigref->{dir}   ";
		$line .= " " x $indent_def{uc($sigref->{proto})};
		$line .= "$sigref->{sig}";
		
		push @displines, $line;
	}
	
	@displines = sort {substr($a,0,12) cmp substr($b,0,12)} @displines;
	foreach $line (@displines) {
		$line =~ /([0-9]{2}):([0-9]{2}):([0-9]{2}).*   (.*)/;
		$time_sec = $1 * 3600 + $2 * 60 + $3;
		$sig = $4;
	
		if (($time_sec - $old_time_sec) > $separate_time) {
			$sepa = 1;
		}
		print "$1:$2:$3 ---------------------------------------------\n" if $sepa == 1;
	
		print "$line\n";
		$line = "";
	
		$old_time_sec = $time_sec;
		$sepa = 0;
	}
	
	close(FILE);

	exit(0) if $mode{tail} != 1;

	@sigarray = ();
	@displines = ();
	$filesize_old = $filesize;
	sleep(1);
}





sub print_usage {
print <<EOL;

	./msgform3.pl [-f] [-C] [imsi=XXXX] [msisdn=XXXX] [guti=XXXX] [file=(file)] [(file)]

	options
		-f 
			output appended data as the file grows.

		-C
			From 'view_xxsmon file' command output.
			If this option is not presented, target is smon 
			asynchronous message.

		imsi/msisdn/guti/ptmsi
			print specific subscriber's smon only.
			Be set all options to match all signal.

		file=(file)
		(file)
			target file (explicit/implicit).
			if this option is not presented, target file is 
			Today's msglog at /SYSTEM/LOG_COM/msglog/

		-h
			print usage

	example)

	./msgform3.pl
		smon message from Today's msglog

	./msgform3.pl (file)
		smon message from file

	./msgform3.pl imsi=XXXX msisdn=XXXX
		only specified imsi/msisdn (matching)

	./msgform3.pl -C
		from 'view_xxsmon file' command output

EOL
}


