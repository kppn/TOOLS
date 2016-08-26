#!/usr/bin/perl

###########################################################
# Change History
#
#	2011/2/16
#		* indenting S5-GTP
#
###########################################################

use Time::HiRes qw/usleep/;
use sort '_mergesort';
use sort 'stable';

#print sort::current;


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
	GTP => 0,
	S5GTP => 4,
	PMIP => 4,
	DIAMETER => 8,
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



$target = 'M';
#$today = `date '+%y%m%d'`;
#chomp($today);
#$file = '/SYSTEM/LOG_COM/msglog/msg' . $today . '.log';
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
	}
	if ($arg =~ /^[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}$/) {
		next;
	}
	if ($arg =~ /^msisdn=(81.*)/) {
		push @target_subid, $1;
		next;
	}
	if ($arg =~ /^imsi=(440.*)/) {
		push @target_subid, $1;
		next;
	}
	if ($arg =~ /^guti=(.*)/) {
		push @target_subid, $1;
		next;
	}
	#if ($arg =~ /^[^\-0-9]{1}.+$/) {
	if ($arg =~ /^[a-z0-9].+$/) {
		$file = $arg;
		next;
	}
}
print "file: $file\n";



sub istarget_subid {
	my $subid = shift;

	foreach $target_subid (@_) {
		$target_exist++ if $target_subid ne "";
	}
	return 1 if $target_exist == 0;

	foreach $target_subid (@_) {
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

	while(<FILE>) {
		$filereadsize += length($_);
		chomp();
	
		if (/^${target}.*signal_monitor_report (msisdn|imsi|guti)=([0-9a-z]+)/) {
			$subid = $2;
			
			if ( not istarget_subid($subid, @target_subid)) {
				next;
			}
			while (<FILE>) {
				$filereadsize += length($_);		
	
				$proto  = $1 if ( /([A-Z]+) signal monitor/ );
				$server = $1 if ( /([sp]-gw) gwp/ );
				$server = $1 if ( /(mmp..)/ );
				$time   = $1 if ( /([0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3})/ );
				$dir    = $1 if ( /kind=(...)/ );
	
				$sig = $1 and last if ( /sig=([a-z_\-\(\)]+)/ );
			}
	
			$proto = "S5GTP" if is_s5gtp($server, $dir, $sig);
			
			push @sigarray,	{proto   => $proto,
					 server  => $server,
					 time    => $time,
					 dir     => $dir,
					 sig     => $sig};
		}
	}
	
	
	foreach $sigref (@sigarray) {
		my $srcname = $sigref->{sig};
	
		foreach $change_name (keys %change_table ) {
			$sigref->{sig} =~ s/$change_name/$change_table{$change_name}/;
		}
		$line = "$sigref->{time} $sigref->{server} $sigref->{dir}   ";
		$line .= " " x $indent_def{$sigref->{proto}};
		$line .= "$sigref->{sig}";
	
		push @displines, $line;
	}
	
	@displines = sort {substr($a,0,12) cmp substr($b,0,12)} @displines;
	foreach $line (@displines) {
		$line =~ /([0-9]{2}):([0-9]{2}):([0-9]{2}).*   (.*)/;
		$time_sec = $1 * 3600 + $2 * 60 + $3;
		$sig = $4;
	
		if (($time_sec - $old_time_sec) > 30) {
			$sepa = 1;
		}
		if ($sig eq "create_session_request") {
			if ($old_sig eq "modify_bearer_response" or
			    $old_sig =~ "response" or
			    $old_sig =~ "STOP") {
				$sepa = 1;
			}
		}	
		print "$1:$2:$3 ---------------------------------------------\n" if $sepa == 1;
	
		print "$line\n";
	
		$old_time_sec = $time_sec;
		$old_sig = $sig;
		$sepa = 0;
	}
	
	close(FILE);

	exit(0) if $mode{tail} != 1;

	@sigarray = ();
	@displines = ();
	$filesize_old = $filesize;
	$sepa = 1;
	sleep(1);
}





sub print_usage {
print <<EOL;

	./msgform3.pl [-f] [-C] [imsi=XXXX] [msisdn=XXXX] [guti=XXXX] [(file)]

	options
		-f 
			output appended data as the file grows.

		-C
			From 'view_xxsmon file' command output.
			If this option is not presented, target is smon 
			asynchronous message.

		imsi/msisdn/guti
			print specific subscriber's smon only.
			set all options to match all signal.

		(file)
			target file.
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












