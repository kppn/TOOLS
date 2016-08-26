
while(<>) {
	if(/^M.*([sp]-gw) gwp00 tm=(\d\d:\d\d:\d\d\.\d\d\d) kind=([a-z]{3})/) {
		chomp();
		$head = "$2 $1 $3\t";
		$time = $2;

		$_ = <STDIN>;
		chomp();

		s/access_request/            Auth-Req/;
		s/access_accept/            Auth-Ack/;
		s/access_reject/            Auth-Rej/;
	
		s/accounting_request_start/            Acct-reQ(START)/;
		s/accounting_response_start/            Acct-reS(START)/;
		s/accounting_request_stop/            Acct-reQ(STOP)/;
		s/accounting_response_stop/            Acct-reS(STOP)/;
		s/accounting_request_interim_update/            Acct-ReQ(INTERIM)/;
		s/accounting_response_interim_update/            Acct-ReS(INTERIM)/;
	
		s/credit_control_request/        CC-Req/;
		s/credit_control_answer/        CC-Ans/;
		s/re_auth_request/        RAR/;
		s/re_auth_answer/        RAA/;
		s/initial_request/init/;
		s/update_request/update/;
		s/termination_request/term/;
	
		s/proxy_binding_update/    PBU/;
		s/proxy_binding_acknowledgement/    PBA/;
		s/binding_revocation_indication/    BR-Ind/;
		s/binding_revocation_acknowledgement/    BR-Ack/;
		s/connection_creation/cre/;
		s/connection_deletion/del/;
	
		# s/create_session_request/C.S.reQ/;
		# s/create_session_response/C.S.reS/;
		# s/modify_bearer_request/M.B.reQ/;
		# s/modify_bearer_response/M.B.reS/;
		# s/delete_bearer_request/D.B.reQ/;
		# s/delete_bearer_response/D.B.reS/;
		
		/sig=(.*)/;
		$msg = $1;

		print "$time -------------------------\n" if $msg eq "create_session_request";
		print "$time -------------------------\n" if $msg eq "delete_session_request";
		print "$head$msg";
		print "\n";
	}
}





# M00000            # PMIP signal monitor #
# M00000            p-gw gwp00 tm=14:07:33.193 kind=rec seq_no=00010
# M00000            sig=proxy_binding_update(connection_creation)
# --
# M00000            # PMIP signal monitor #
# M00000            p-gw gwp00 tm=14:07:35.403 kind=rec seq_no=00011
# M00000            sig=proxy_binding_update(connection_creation)
# --
# M00000            # PMIP signal monitor #
# M00000            p-gw gwp00 tm=14:07:39.624 kind=rec seq_no=00012
# M00000            sig=proxy_binding_update(connection_creation)
# --
# --
# M00000            # PMIP signal monitor #
# M00000            p-gw gwp00 tm=14:07:47.868 kind=rec seq_no=00014
# M00000            sig=proxy_binding_update(connection_creation)
# --
# --
# M00000            # PMIP signal monitor #
# M00000            p-gw gwp00 tm=14:08:02.662 kind=snd seq_no=00022
# M00000            sig=proxy_binding_acknowledgement(connection_creation)
# --
# --
# M00000            # PMIP signal monitor #
# M00000            p-gw gwp00 tm=14:08:42.050 kind=rec seq_no=00025
# M00000            sig=proxy_binding_update(connection_deletion)
# --
# --
# M00000            # PMIP signal monitor #
# M00000            p-gw gwp00 tm=14:08:42.080 kind=snd seq_no=00029
# M00000            sig=proxy_binding_acknowledgement(connection_deletion)
# --
# --
# M00000            # PMIP signal monitor #
# M00000            p-gw gwp00 tm=14:09:13.464 kind=rec seq_no=00031
# M00000            sig=proxy_binding_update(connection_creation)
# --
# --
# M00000            # PMIP signal monitor #
# M00000            p-gw gwp00 tm=14:09:13.540 kind=snd seq_no=00040
# M00000            sig=proxy_binding_acknowledgement(connection_creation)
# --
# --
# M00000            # PMIP signal monitor #
# M00000            p-gw gwp00 tm=14:19:46.308 kind=snd seq_no=00043
# M00000            sig=binding_revocation_indication
# --
# M00000            # PMIP signal monitor #
# M00000            p-gw gwp00 tm=14:19:47.421 kind=snd seq_no=00044
# M00000            sig=binding_revocation_indication


# 14:08:02.664 p-gw snd   accounting_request_start
# 14:08:02.672 p-gw rec   accounting_response_start
# 14:08:42.050 p-gw rec   proxy_binding_update(connection_deletion)
# 14:08:42.065 p-gw snd   credit_control_request(termination_request)
# 14:08:42.068 p-gw rec   credit_control_answer(termination_request)
# 14:08:42.077 p-gw snd   accounting_request_stop
# 14:08:42.080 p-gw snd   proxy_binding_acknowledgement(connection_deletion)
# 14:08:42.086 p-gw rec   accounting_response_stop
# 14:09:13.464 p-gw rec   proxy_binding_update(connection_creation)
# 14:09:13.472 p-gw snd   credit_control_request(initial_request)
# 14:09:13.475 p-gw rec   credit_control_answer(initial_request)
# 14:09:13.481 p-gw snd   access_request
# 14:09:13.488 p-gw rec   access_accept
# 14:09:13.494 p-gw snd   access_request
# 14:09:13.500 p-gw rec   access_accept
# 14:09:13.505 p-gw snd   credit_control_request(update_request)
# 14:09:13.508 p-gw rec   credit_control_answer(update_request)
# 14:09:13.540 p-gw snd   proxy_binding_acknowledgement(connection_creation)
# 14:09:13.543 p-gw snd   accounting_request_start
# 14:09:13.554 p-gw rec   accounting_response_start



# M00000 2009/10/28 14:08:03 gwp000
# M00000 2935002 293500200000000000000000
# M00000 #.. signal_monitor_report msisdn=818018710149
# M00000            # RADIUS signal monitor #
# M00000            p-gw gwp00 tm=14:08:02.664 kind=snd seq_no=00023
# M00000            sig=accounting_request_start


