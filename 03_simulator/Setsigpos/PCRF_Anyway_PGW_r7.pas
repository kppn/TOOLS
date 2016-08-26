set {
    generation_type = passive;
#	generation_type = singleton;
	
	public interface_type   = 0x01000016;
	public GX               = 0x01000016;
	public GXX              = 0x01000032;
	private event_detector  = 0;
	
	control cmd_ratchange;
	control cmd_qoschange;
	control _____________________________dummy1;
	control set_User_Information;
	
	control _____________________________dummy2;
	control limit_over    = 0;
	control odb           = 0;
	control zantei        = 0;
	control teigaku       = 0;
	control teigaku_mvno_qci = 9;
	control cca_update_ng = 0;	# 1:Experimental-Result, 2:Result-Code
	control user_auth_pass_ng = 0;
	control user_auth_prot = 0x02; # 0:ZERO, 1:CHAP, 2:PAP, 3:NONE ※MOPERA,DCM_WCS用のみ設定
	control id_notification = 0x01; # 発着ID通知 非通知(0)/通知(1)
	
	control _____________________________dummy3;
	control blk_apn_y-mode = 0;
	control blk_apn_o-mode = 0;
	control blk_apn_noperu = 0;
	control blk_apn_noperi = 0;
	
	control _____________________________dummy4;
	control set_base_name_1_Spmode = 0x53;	#'S'=0x53(83)
	control set_base_name_2_Spmode = 0x53;	#'S'=0x53(83)
	control set_base_name_3_Spmode = 0x53;	#'S'=0x53(83)
	control set_base_name_Mopera = 0x4d;	#'M'=0x4d(77)
	
	
	# Session-Id格納用 (テンポラリ)
	private stmp_len = 0;
	private stmp_01 = 0; private stmp_02 = 0; private stmp_03 = 0; private stmp_04 = 0; private stmp_05 = 0; private stmp_06 = 0; private stmp_07 = 0; private stmp_08 = 0; private stmp_09 = 0; private stmp_10 = 0; private stmp_11 = 0; private stmp_12 = 0; private stmp_13 = 0; private stmp_14 = 0; private stmp_15 = 0; private stmp_16 = 0; private stmp_17 = 0;
	
	# Session-Id格納用 (セッション4個分)
	private s1_len = 0;
	private s2_len = 0;
	private s3_len = 0;
	private s4_len = 0;
	private s1_01 = 0; private s1_02 = 0; private s1_03 = 0; private s1_04 = 0; private s1_05 = 0; private s1_06 = 0; private s1_07 = 0; private s1_08 = 0; private s1_09 = 0; private s1_10 = 0; private s1_11 = 0; private s1_12 = 0; private s1_13 = 0; private s1_14 = 0; private s1_15 = 0; private s1_16 = 0; private s1_17 = 0;
	private s2_01 = 0; private s2_02 = 0; private s2_03 = 0; private s2_04 = 0; private s2_05 = 0; private s2_06 = 0; private s2_07 = 0; private s2_08 = 0; private s2_09 = 0; private s2_10 = 0; private s2_11 = 0; private s2_12 = 0; private s2_13 = 0; private s2_14 = 0; private s2_15 = 0; private s2_16 = 0; private s2_17 = 0;
	private s3_01 = 0; private s3_02 = 0; private s3_03 = 0; private s3_04 = 0; private s3_05 = 0; private s3_06 = 0; private s3_07 = 0; private s3_08 = 0; private s3_09 = 0; private s3_10 = 0; private s3_11 = 0; private s3_12 = 0; private s3_13 = 0; private s3_14 = 0; private s3_15 = 0; private s3_16 = 0; private s3_17 = 0;    
	private s4_01 = 0; private s4_02 = 0; private s4_03 = 0; private s4_04 = 0; private s4_05 = 0; private s4_06 = 0; private s4_07 = 0; private s4_08 = 0; private s4_09 = 0; private s4_10 = 0; private s4_11 = 0; private s4_12 = 0; private s4_13 = 0; private s4_14 = 0; private s4_15 = 0; private s4_16 = 0; private s4_17 = 0;
	
	private current_session = 0;	# Current operation session
	
	private s1_used = 0;		# 
	private s2_used = 0;		# 
	private s3_used = 0;		# 
	private s4_used = 0;		# 
	private s_same = 0;
	
	private s1_call_kind = 0;		# 
	private s2_call_kind = 0;		# 
	private s3_call_kind = 0;		# 
	private s4_call_kind = 0;		# 
	private n_sessions = 0;
	
	private s1_notified_pat = 0;		# Notified Priservation-Allowed-Time Value
	private s2_notified_pat = 0;		# 
	private s3_notified_pat = 0;		# 
	private s4_notified_pat = 0;		# 
	
	private first_dcm-wcs_session = 0;
	private session_release_cause = 1;
	
	# Request-Types
	private reqtype = 0;
		public REQTYPE_INITIAL     = 1;
		public REQTYPE_UPDATE      = 2;
		public REQTYPE_TERMINATION = 3;
	
	public call_kind = 0;
		# Call kind Values
		public IMODE	=  1;
		public MOPERA	= 11;
		public MVNO	= 21;
		public DCM_WCS	= 31;
	
	timer   find_avp_tm = 2;   # own event trigger
	# AVP Codes
	private find_avp    = 0;
		public AVPCODE_CALLED_STATION_ID  = 0x0000001e;
		public AVPCODE_EVENT_TRIGGER      = 0x000003ee;
		public AVPCODE_RAT_TYPE           = 0x00000408;
		public AVPCODE_FRAMED_IPV6_PREFIX = 0x00000061;
		public AVPCODE_CHARGING_RULE_REPORT = 0x000003FA;
	
	private avp_value_p = 0;
	private avpval_called_station_id1 = 0;		# store first 6 octet in 2 variables.
	private avpval_called_station_id2 = 0;		#     e.g. APN: i-mode.docomo.ne.jp
							#            avpval_called_station_id1: 0x692d6d6f "i-mo"
							#            avpval_called_station_id2: 0x00006465 "de"
	private avpval_called_station_id_tmp = 0;	# temporary. cut apn charactor 1 to 3 for call kind
							#     e.g. '-mo'
	
	private avpval_framed_ipv6_prefix1  = 0;
	private avpval_framed_ipv6_prefix2  = 0;
	private pos_docomo_container_ipv6prefix = 0;
	
	private avpval_preservation_allowed_time = 0;
		public AVPVAL_PRESERVATION_ALLOWED_TIMER_IMODE	= 0;
		public AVPVAL_PRESERVATION_ALLOWED_TIMER_MOPERA = 17;
		public AVPVAL_PRESERVATION_ALLOWED_TIMER_DCM_WCS = 0;
	
	# Event-Trigger Values
	private avpval_event_trigger     = 0;
		public RAT_CHANGE		=  2;
		public UE_IP_ADDRESS_ALLOCATE 	= 18;
		public REVALIDATION_TIMEOUT	= 17;
		public VOLUME_THRESHOLD		= 50;
		public CONTAINER_DETECTION	= 51;
	
	
	# RAT-Type Value
	private avpval_rat_type          = 0;
	
	# Session not authorilized in service policy (ODB, or Limit Over)
	private send_ng                  = 0;
	
	
	# AVP GET Logic
	private avp_code    = 0;
	private avp_p       = 0;
	private len         = 0;
	private len_p       = 0;
	private len_msg     = 0;
	private tmp_padd    = 0;
	private npadd       = 0;
	private avp_flag    = 0;
	private i           = 0;  # Loop Counter
	
	private dnsv6addr1  = 0;
	private dnsv6addr2  = 0;
	private dnsv6addr3  = 0;
	private dnsv6addr4  = 0;
	
	private CCR_UPDATE_CONTAINER_DETECTION_DOCOMO_CONTAINER_DNSV6ADDRESS	= 466; 












	private CCA_INIT_DCM_WCS_LIMIT_POS_BASE_NAME_1	= 370;
	private CCA_INIT_DCM_WCS_LIMIT_POS_PRESERVATION_ALLOWED_TIME	= 716;
	private CCA_INIT_DCM_WCS_POS_AUTH_PROT	= 527;
	private CCA_INIT_DCM_WCS_POS_ID_NOTIFICATION	= 595;
	private CCA_INIT_DCM_WCS_POS_PRESERVATION_ALLOWED_TIME	= 608;
	private CCA_INIT_DCM_WCS_POS_USERID_AIUTH_PASS	= 578;
	private CCA_INIT_IMODE_POS_DOCOMO_CONTAINER_IPV6PREFIX	= 629;
	private CCA_INIT_IMODE_POS_DOCOMO_CONTAINER_USER_INFORMATION	= 616;
	private CCA_INIT_IMODE_POS_PRESERVATION_ALLOWED_TIME	= 600;
	private CCA_INIT_IMODE_TEIGAKU_POS_DOCOMO_CONTAINER_IPV6PREFIX	= 693;
	private CCA_INIT_IMODE_TEIGAKU_POS_DOCOMO_CONTAINER_USER_INFORMATION	= 680;
	private CCA_INIT_IMODE_TEIGAKU_POS_PRESERVATION_ALLOWED_TIME	= 648;
	private CCA_INIT_IMODE_TEIGAKU_POS_QCI	= 384;
	private CCA_INIT_MOPERA_POS_AUTH_PROT	= 707;
	private CCA_INIT_MOPERA_POS_BASE_NAME	= 368;
	private CCA_INIT_MOPERA_POS_PRESERVATION_ALLOWED_TIME	= 788;
	private CCA_INIT_MOPERA_TEIGAKU_POS_PRESERVATION_ALLOWED_TIME	= 672;
	private CCA_INIT_MOPERA_TEIGAKU_POS_QCI	= 368;
	private CCA_INIT_MOPERA_ZANTEI_POS_PRESERVATION_ALLOWED_TIME	= 640;
	private CCA_INIT_MVNO_POS_QCI	= 184;
	private CCA_UPDATE_IMODE_CONTAINER_DETECTION_POS_PCO_DNSV6ADDRESS	= 328;
	private RAR_PRESERVATION_ALLOWED_TIME_POS_PRESERVATION_ALLOWED_TIME	= 380;
	private RAR_QOSCHANGE_POS_QCI	= 392;
	private RAR_RATCHANGE_POS_DOCOMO_CONTAINER_RATTYPE	= 400;
	private RAR_SESSION_REL_POS_SESSION_REL_CAUSE	= 380;

	transit(CCR_ATTACH);
}




in CCR_ATTACH {

	#################################################################
	###
	### Select signal type to send
	### 
	case execution() {
	
		#######################
		### CCR (INITIAL)
		if (reqtype == REQTYPE_INITIAL) { 
			
			### Request NG in service status
			if (call_kind  == MOPERA) { increase(send_ng, 1); }
			if (call_kind  == MVNO)   { increase(send_ng, 1); }
			if (limit_over == 1)      { increase(send_ng, 1); }
			if (odb        == 1)      { increase(send_ng, 1); }
			if (send_ng >= 2) {
				send(CCA_INIT_NG);   setvariable(send_ng, 0);
				if ( current_session == 1 ) { setvariable(s1_used, 0); } if ( current_session == 2 ) { setvariable(s1_used, 0); }  if ( current_session == 3 ) { setvariable(s1_used, 0); } if ( current_session == 4 ) { setvariable(s1_used, 0); }
				transit();
			}
			setvariable(send_ng, 0);
			
			### Request NG because APN Blocking. 
			if (blk_apn_y-mode == 1) { if (avpval_called_station_id1 == 0x792d6d6f) { if (avpval_called_station_id2 == 0x00006465) {
						send(CCA_INIT_NG); 
						if ( current_session == 1 ) { setvariable(s1_used, 0); } if ( current_session == 2 ) { setvariable(s1_used, 0); }  if ( current_session == 3 ) { setvariable(s1_used, 0); } if ( current_session == 4 ) { setvariable(s1_used, 0); }  	transit(); 
			}}}
			if (blk_apn_o-mode == 1) { if (avpval_called_station_id1 == 0x6f2d6d6f) { if (avpval_called_station_id2 == 0x00006465) {
						send(CCA_INIT_NG); 
						if ( current_session == 1 ) { setvariable(s1_used, 0); } if ( current_session == 2 ) { setvariable(s1_used, 0); }  if ( current_session == 3 ) { setvariable(s1_used, 0); } if ( current_session == 4 ) { setvariable(s1_used, 0); }  	transit(); 
			}}}
			if (blk_apn_noperu == 1) { if (avpval_called_station_id1 == 0x6e6f7065) { if (avpval_called_station_id2 == 0x00007275) {
						send(CCA_INIT_NG); 
						if ( current_session == 1 ) { setvariable(s1_used, 0); } if ( current_session == 2 ) { setvariable(s1_used, 0); }  if ( current_session == 3 ) { setvariable(s1_used, 0); } if ( current_session == 4 ) { setvariable(s1_used, 0); }  	transit(); 
			}}}
			if (blk_apn_noperi == 1) { if (avpval_called_station_id1 == 0x6e6f7065) { if (avpval_called_station_id2 == 0x00007269) {
						send(CCA_INIT_NG); 
						if ( current_session == 1 ) { setvariable(s1_used, 0); } if ( current_session == 2 ) { setvariable(s1_used, 0); }  if ( current_session == 3 ) { setvariable(s1_used, 0); } if ( current_session == 4 ) { setvariable(s1_used, 0); }  	transit(); 
			}}}
			
			setvariable(pos_docomo_container_ipv6prefix, CCA_INIT_IMODE_POS_DOCOMO_CONTAINER_IPV6PREFIX);
			increase(pos_docomo_container_ipv6prefix, 2);
			setsigdata(CCA_INIT_IMODE, avpval_framed_ipv6_prefix1, pos_docomo_container_ipv6prefix, 4, 0xFFFFFFFF); increase(pos_docomo_container_ipv6prefix, 4);
			setsigdata(CCA_INIT_IMODE, avpval_framed_ipv6_prefix2, pos_docomo_container_ipv6prefix, 4, 0xFFFFFFFF); 
			
			setvariable(pos_docomo_container_ipv6prefix, CCA_INIT_IMODE_TEIGAKU_POS_DOCOMO_CONTAINER_IPV6PREFIX);
			increase(pos_docomo_container_ipv6prefix, 2);
			setsigdata(CCA_INIT_IMODE_TEIGAKU, avpval_framed_ipv6_prefix1, pos_docomo_container_ipv6prefix, 4, 0xFFFFFFFF);
			setsigdata(CCA_INIT_IMODE_TEIGAKU, avpval_framed_ipv6_prefix2, pos_docomo_container_ipv6prefix, 4, 0xFFFFFFFF);
			
			
			### Request Success
			
			increase(n_sessions, 1);
			snap("Session Number", n_sessions);
			
			
			### Set call kind (i-mode / mopera)
			if (current_session == 1) { setvariable(s1_call_kind, call_kind); }
			if (current_session == 2) { setvariable(s2_call_kind, call_kind); }
			if (current_session == 3) { setvariable(s3_call_kind, call_kind); }
			if (current_session == 4) { setvariable(s4_call_kind, call_kind); }
			
			
			### Set Preservation-Allowed-Time
			if (interface_type == GX) { 
				if (call_kind == IMODE) {
					setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_IMODE);
				}
				if (call_kind == MOPERA) {
					setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_MOPERA);
				}
				if (call_kind == DCM_WCS) {
					setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_DCM_WCS);
				}
				
				# If session number is 1, don't start Preservavation Timer
				if (n_sessions == 1) {
					setvariable(avpval_preservation_allowed_time, 0);
				}
			}
			
			if (interface_type == GX) { if (call_kind == IMODE) {
				# Do nothing
				# Always 0 for i-mode call. In pdu definition, 0 witten.
			}
			if (interface_type == GX) { if (call_kind == MOPERA) {
				setsigdata(CCA_INIT_MOPERA, 		avpval_preservation_allowed_time, CCA_INIT_MOPERA_POS_PRESERVATION_ALLOWED_TIME,		4, 0xFFFFFFFF);
				setsigdata(CCA_INIT_MOPERA, 		user_auth_prot , CCA_INIT_MOPERA_POS_AUTH_PROT,		1, 0xFF);
				setsigdata(CCA_INIT_MOPERA_TEIGAKU,	avpval_preservation_allowed_time, CCA_INIT_MOPERA_TEIGAKU_POS_PRESERVATION_ALLOWED_TIME, 	4, 0xFFFFFFFF);
				setsigdata(CCA_INIT_MOPERA_ZANTEI,	avpval_preservation_allowed_time, CCA_INIT_MOPERA_ZANTEI_POS_PRESERVATION_ALLOWED_TIME,		4, 0xFFFFFFFF);
			}
			if (interface_type == GX) { if (call_kind == DCM_WCS) {
				setsigdata(CCA_INIT_DCM_WCS, 		avpval_preservation_allowed_time, CCA_INIT_DCM_WCS_POS_PRESERVATION_ALLOWED_TIME,		4, 0xFFFFFFFF);
				setsigdata(CCA_INIT_DCM_WCS, 		user_auth_prot , CCA_INIT_DCM_WCS_POS_AUTH_PROT,		1, 0xFF);
				setsigdata(CCA_INIT_DCM_WCS, 		id_notification , CCA_INIT_DCM_WCS_POS_ID_NOTIFICATION,		1, 0xFF);
				setsigdata(CCA_INIT_DCM_WCS_LIMIT,	avpval_preservation_allowed_time, CCA_INIT_DCM_WCS_LIMIT_POS_PRESERVATION_ALLOWED_TIME,		4, 0xFFFFFFFF);
				if (user_auth_pass_ng != 0) {
					setsigdata(CCA_INIT_DCM_WCS,	0x45, CCA_INIT_DCM_WCS_POS_USERID_AIUTH_PASS,		1, 0xFF);
				}
			}}}}
			
			if (current_session == 1) { setvariable(s1_notified_pat, avpval_preservation_allowed_time); }
			if (current_session == 2) { setvariable(s2_notified_pat, avpval_preservation_allowed_time); }
			if (current_session == 3) { setvariable(s3_notified_pat, avpval_preservation_allowed_time); }
			if (current_session == 4) { setvariable(s4_notified_pat, avpval_preservation_allowed_time); }
			
			
			### CCA Send
			if (call_kind == IMODE) {
				# For i-mode, Gx :  CCA include Docomo-Container.
				#             Gxc:  CCA include APN-Service-Information
				if (teigaku == 1) {
					send(CCA_INIT_IMODE_TEIGAKU);
				}
				else {
					send(CCA_INIT_IMODE);
				}
			}
			
			if (call_kind == MOPERA) {
				# For mopera, Gx :  CCA !!!NOT!!! include Docomo-Container.
				#             Gxc:  CCA none of special AVPs.
				
				if (zantei == 1) {
					send(CCA_INIT_MOPERA_ZANTEI);
				}
				else{if (teigaku == 1) {
					send(CCA_INIT_MOPERA_TEIGAKU);
				}
				else {
					send(CCA_INIT_MOPERA);
				}}
			}
			
			if (call_kind == DCM_WCS) {
				if( limit_over == 0 ){
					send(CCA_INIT_DCM_WCS);
					snap("send CCA_INIT_DCM_WCS)");
				}else{
					send(CCA_INIT_DCM_WCS_LIMIT);
					snap("send CCA_INIT_DCM_WCS_LIMIT)");
				}

				# Multi-Spmode判定
				if( interface_type == GXX ){ if( n_sessions > 1 ) {
					if( current_session != 1 ){ if( s1_used == 1 ){ if( s1_call_kind == DCM_WCS ){
					        setvariable(first_dcm-wcs_session, 1);
					}}}
					if( current_session != 2 ){ if( s2_used == 1 ){ if( s2_call_kind == DCM_WCS ){
					        setvariable(first_dcm-wcs_session, 2);
					}}}
					if( current_session != 3 ){ if( s3_used == 1 ){ if( s3_call_kind == DCM_WCS ){
					        setvariable(first_dcm-wcs_session, 3);
					}}}
					if( current_session != 4 ){ if( s4_used == 1 ){ if( s4_call_kind == DCM_WCS ){
					        setvariable(first_dcm-wcs_session, 4);
					}}}

					if( first_dcm-wcs_session != 0 ){
					        snap("Multi-Spmode!!");
					        snap("First Spmode Session Number =", first_dcm-wcs_session);
					        isc_send(PCRF_P_1, SYNCHRO, 103, first_dcm-wcs_session);
					}

				}}


			}

			if (call_kind == MVNO) {
				# For mvno  , Gx :  not defined
				#             Gxc:  CCA include Revalidation-Time and Volume-Threshold
				send(CCA_INIT_MVNO);
			}
			
			if (interface_type == GX) { if (n_sessions >= 2) { 
				transit_execute(RAR_PRESERVATION_ALLOWED_TIME_SEND);
			}}
		}
		
		
		#######################
		### CCR (UPDATE)
		if (reqtype == REQTYPE_UPDATE) {
			
			##############
			# Gx Event
			
			if (cca_update_ng == 1) {
				snap("send CCA_UPDATE_NG");
				send(CCA_UPDATE_NG);
				transit();
			}
			if (cca_update_ng == 2) {
				snap("send CCA_UPDATE_NG_RESULT_CODE");
				send(CCA_UPDATE_NG_RESULT_CODE);
				transit();
			}
			
			if ( avpval_event_trigger == CONTAINER_DETECTION ) {
				# CONTAINER_DETECTION is specific event of i-mode
				# For i-mode, Gx : CCA(update) has PCO:DNSv6
				#             Gxc: CCA(update) has 
				
				# Get DNSv6 Address from CCR and Set to CCA 
				getsigdata(dnsv6addr1, CCR_UPDATE_CONTAINER_DETECTION_DOCOMO_CONTAINER_DNSV6ADDRESS, 4, 0xFFFFFFFF); increase(CCR_UPDATE_CONTAINER_DETECTION_DOCOMO_CONTAINER_DNSV6ADDRESS, 4);
				getsigdata(dnsv6addr2, CCR_UPDATE_CONTAINER_DETECTION_DOCOMO_CONTAINER_DNSV6ADDRESS, 4, 0xFFFFFFFF); increase(CCR_UPDATE_CONTAINER_DETECTION_DOCOMO_CONTAINER_DNSV6ADDRESS, 4);
				getsigdata(dnsv6addr3, CCR_UPDATE_CONTAINER_DETECTION_DOCOMO_CONTAINER_DNSV6ADDRESS, 4, 0xFFFFFFFF); increase(CCR_UPDATE_CONTAINER_DETECTION_DOCOMO_CONTAINER_DNSV6ADDRESS, 4);
				getsigdata(dnsv6addr4, CCR_UPDATE_CONTAINER_DETECTION_DOCOMO_CONTAINER_DNSV6ADDRESS, 4, 0xFFFFFFFF); increase(CCR_UPDATE_CONTAINER_DETECTION_DOCOMO_CONTAINER_DNSV6ADDRESS, 4);
				decrease(CCR_UPDATE_CONTAINER_DETECTION_DOCOMO_CONTAINER_DNSV6ADDRESS, 16);
				setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, dnsv6addr1, CCA_UPDATE_IMODE_CONTAINER_DETECTION_POS_PCO_DNSV6ADDRESS, 4, 0xFFFFFFFF); increase(CCA_UPDATE_IMODE_CONTAINER_DETECTION_POS_PCO_DNSV6ADDRESS, 4);
				setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, dnsv6addr2, CCA_UPDATE_IMODE_CONTAINER_DETECTION_POS_PCO_DNSV6ADDRESS, 4, 0xFFFFFFFF); increase(CCA_UPDATE_IMODE_CONTAINER_DETECTION_POS_PCO_DNSV6ADDRESS, 4);
				setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, dnsv6addr3, CCA_UPDATE_IMODE_CONTAINER_DETECTION_POS_PCO_DNSV6ADDRESS, 4, 0xFFFFFFFF); increase(CCA_UPDATE_IMODE_CONTAINER_DETECTION_POS_PCO_DNSV6ADDRESS, 4);
				setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, dnsv6addr4, CCA_UPDATE_IMODE_CONTAINER_DETECTION_POS_PCO_DNSV6ADDRESS, 4, 0xFFFFFFFF); increase(CCA_UPDATE_IMODE_CONTAINER_DETECTION_POS_PCO_DNSV6ADDRESS, 4);
				decrease(CCA_UPDATE_IMODE_CONTAINER_DETECTION_POS_PCO_DNSV6ADDRESS, 16);
				
				send(CCA_UPDATE_IMODE_CONTAINER_DETECTION);
			}
			
			if ( avpval_event_trigger == UE_IP_ADDRESS_ALLOCATE ) {
				# UE_IP_ADDRESS_ALLOCATE is specific event of RADIUS IP allocation(Mopera/dcm-wcs)
				# For mopera/dcm-wcs, Gx : CCA(update) has PCO:IPCP
				#             Gxc: CCA(update) none of special AVPs.
				send(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION);
			}
			
			#############
			# Common Event
			if ( avpval_event_trigger == RAT_CHANGE ) {
				send(CCA_UPDATE_RAT_CHANGE);
				setvariable(find_avp, AVPCODE_RAT_TYPE);
				transit_execute(GET_AVP_VENDOR_VALUE_POINT);
			}
			
			############
			# QoS Update
			if ( avpval_event_trigger == REVALIDATION_TIMEOUT ) {
				send(CCA_UPDATE_SCHEDULING);
				snap("REVALIDATION_TIMEOUT occured. send CCA");
				
				# For RAR send, notify Own node(for common sequence) and Other PCRF node
				snap("RAR Notification from: ", interface_type);
				setvariable(event_detector, interface_type);
				if (interface_type == GX) {
					isc_send(PCRF_S_1, SYNCHRO, 100, interface_type);
				}
				else {
					isc_send(PCRF_P_1, SYNCHRO, 100, interface_type);
				}
				transit_execute(RAR_QOSCHANGE_SEND);
			}
			if ( avpval_event_trigger == VOLUME_THRESHOLD ) {
				send(CCA_UPDATE_SCHEDULING);
				snap("VOLUME_THRESHOLD occured. send CCA");
				
				# For RAR send, notify Own node(for common sequence) and Other PCRF node
				snap("RAR Notification from: ", interface_type);
				setvariable(event_detector, interface_type);
				if (interface_type == GX) {
					isc_send(PCRF_S_1, SYNCHRO, 101, interface_type);
				}
				else {
					isc_send(PCRF_P_1, SYNCHRO, 101, interface_type);
				}
				transit_execute(RAR_QOSCHANGE_SEND);
			}
		}
		
		
		#######################
		### CCR (TERMINATION)
		if (reqtype == REQTYPE_TERMINATION) {
			decrease(n_sessions, 1);
			if (n_sessions < 0) {
				setvariable(n_sessions, 0);
			}
			snap("Session Number", n_sessions);
			
			send(CCA_TERM);
			
			if (interface_type == GX) { if (n_sessions == 1) { 
				transit_execute(RAR_PRESERVATION_ALLOWED_TIME_SEND);
			}}
		}
	}
	
	
	#################################################################
	###
	### Signal receive and session Management
	### 
	case receive (CC-Request, CC-Request-Type = initial) {
	
		setvariable(reqtype, REQTYPE_INITIAL);
		
		### Get Session-Id from received CCR.
		snap("CCR INIT : GET_SESSION_ID");
		getsigdata(stmp_len, 24, 4, 0x00FFFFFF);
		getsigdata(stmp_01, 28, 4,  0xFFFFFFFF); 			getsigdata(stmp_02, 32, 4, 0xFFFFFFFF); getsigdata(stmp_03, 36, 4, 0xFFFFFFFF); getsigdata(stmp_04, 40, 4, 0xFFFFFFFF); getsigdata(stmp_05, 44, 4, 0xFFFFFFFF); getsigdata(stmp_06, 48, 4, 0xFFFFFFFF); getsigdata(stmp_07, 52, 4, 0xFFFFFFFF); getsigdata(stmp_08, 56, 4, 0xFFFFFFFF); getsigdata(stmp_09, 60, 4, 0xFFFFFFFF); getsigdata(stmp_10, 64, 4, 0xFFFFFFFF); getsigdata(stmp_11, 68, 4, 0xFFFFFFFF); getsigdata(stmp_12, 72, 4, 0xFFFFFFFF); getsigdata(stmp_13, 76, 4, 0xFFFFFFFF); getsigdata(stmp_14, 80, 4, 0xFFFFFFFF); getsigdata(stmp_15, 84, 4, 0xFFFFFFFF); getsigdata(stmp_16, 88, 4, 0xFFFFFFFF); getsigdata(stmp_17, 92, 4, 0xFFFFFFFF); 
		
		### Allocate session. Copy Session-Id to unused session valiable.
		if ( s1_used == 0 ) {
			setvariable(s1_used, 1); 
			setvariable(current_session, 1); 
			snap("STATE_ALLOCATE_SESSION", current_session);
			setvariable(s1_len, stmp_len);
			setvariable(s1_01, stmp_01); 				setvariable(s1_02, stmp_02); setvariable(s1_03, stmp_03); setvariable(s1_04, stmp_04); setvariable(s1_05, stmp_05); setvariable(s1_06, stmp_06); setvariable(s1_07, stmp_07); setvariable(s1_08, stmp_08); setvariable(s1_09, stmp_09); setvariable(s1_10, stmp_10); setvariable(s1_11, stmp_11); setvariable(s1_12, stmp_12); setvariable(s1_13, stmp_13); setvariable(s1_14, stmp_14); setvariable(s1_15, stmp_15); setvariable(s1_16, stmp_16); setvariable(s1_17, stmp_17);
		}
		else { if ( s2_used == 0 ) {
			setvariable(s2_used, 1); 
			setvariable(current_session, 2); 
			snap("STATE_ALLOCATE_SESSION", current_session);
			setvariable(s2_len, stmp_len);
			setvariable(s2_01, stmp_01); 				setvariable(s2_02, stmp_02); setvariable(s2_03, stmp_03); setvariable(s2_04, stmp_04); setvariable(s2_05, stmp_05); setvariable(s2_06, stmp_06); setvariable(s2_07, stmp_07); setvariable(s2_08, stmp_08); setvariable(s2_09, stmp_09); setvariable(s2_10, stmp_10); setvariable(s2_11, stmp_11); setvariable(s2_12, stmp_12); setvariable(s2_13, stmp_13); setvariable(s2_14, stmp_14); setvariable(s2_15, stmp_15); setvariable(s2_16, stmp_16); setvariable(s2_17, stmp_17);
		}
		else { if ( s3_used == 0 ) {
			setvariable(s3_used, 1); 
			setvariable(current_session, 3); 
			snap("STATE_ALLOCATE_SESSION", current_session);
			setvariable(s3_len, stmp_len);
			setvariable(s3_01, stmp_01); 				setvariable(s3_02, stmp_02); setvariable(s3_03, stmp_03); setvariable(s3_04, stmp_04); setvariable(s3_05, stmp_05); setvariable(s3_06, stmp_06); setvariable(s3_07, stmp_07); setvariable(s3_08, stmp_08); setvariable(s3_09, stmp_09); setvariable(s3_10, stmp_10); setvariable(s3_11, stmp_11); setvariable(s3_12, stmp_12); setvariable(s3_13, stmp_13); setvariable(s3_14, stmp_14); setvariable(s3_15, stmp_15); setvariable(s3_16, stmp_16); setvariable(s3_17, stmp_17);
		}
		else { if ( s4_used == 0 ) {
			setvariable(s4_used, 1); 
			setvariable(current_session, 4); 
			snap("STATE_ALLOCATE_SESSION", current_session);
			setvariable(s4_len, stmp_len);
			setvariable(s4_01, stmp_01);				 setvariable(s4_02, stmp_02); setvariable(s4_03, stmp_03); setvariable(s4_04, stmp_04); setvariable(s4_05, stmp_05); setvariable(s4_06, stmp_06); setvariable(s4_07, stmp_07); setvariable(s4_08, stmp_08); setvariable(s4_09, stmp_09); setvariable(s4_10, stmp_10); setvariable(s4_11, stmp_11); setvariable(s4_12, stmp_12); setvariable(s4_13, stmp_13); setvariable(s4_14, stmp_14); setvariable(s4_15, stmp_15); setvariable(s4_16, stmp_16); setvariable(s4_17, stmp_17);
		}
		}}}
		### set Session-Id to CCA 
		## 以下では、このシナリオで定義された全ての信号に対してsession-idを設定する。
		## 判別ロジックを入れると複雑になりすぎるため。
		## ツールで定義できるように後で作る
		setsigdata(CCA_INIT_MOPERA,		stmp_len, 24, 4, 0xFFFFFFFF);
		setsigdata(CCA_INIT_MOPERA, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_INIT_MOPERA, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA, stmp_17, 92, 4, 0xFFFFFFFF); 
		setsigdata(CCA_INIT_IMODE,		stmp_len, 24, 4, 0xFFFFFFFF);
		setsigdata(CCA_INIT_IMODE, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_INIT_IMODE, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE, stmp_17, 92, 4, 0xFFFFFFFF); 
		setsigdata(CCA_INIT_MVNO,		stmp_len, 24, 4, 0xFFFFFFFF);
		setsigdata(CCA_INIT_MVNO, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_INIT_MVNO, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MVNO, stmp_17, 92, 4, 0xFFFFFFFF); 
		setsigdata(CCA_INIT_NG,			stmp_len, 24, 4, 0xFFFFFFFF);
		setsigdata(CCA_INIT_NG, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_INIT_NG, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_NG, stmp_17, 92, 4, 0xFFFFFFFF); 
		setsigdata(CCA_INIT_IMODE_TEIGAKU,		stmp_len, 24, 4, 0xFFFFFFFF);
		setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_IMODE_TEIGAKU, stmp_17, 92, 4, 0xFFFFFFFF); 
		setsigdata(CCA_INIT_MOPERA_ZANTEI,	stmp_len, 24, 4, 0xFFFFFFFF);
		setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_ZANTEI, stmp_17, 92, 4, 0xFFFFFFFF); 
		setsigdata(CCA_INIT_MOPERA_TEIGAKU,	stmp_len, 24, 4, 0xFFFFFFFF);
		setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_MOPERA_TEIGAKU, stmp_17, 92, 4, 0xFFFFFFFF); 
	
		setsigdata(CCA_INIT_DCM_WCS,		stmp_len, 24, 4, 0xFFFFFFFF);
		setsigdata(CCA_INIT_DCM_WCS, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_INIT_DCM_WCS, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS, stmp_17, 92, 4, 0xFFFFFFFF); 

		setsigdata(CCA_INIT_DCM_WCS_LIMIT,		stmp_len, 24, 4, 0xFFFFFFFF);
		setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_INIT_DCM_WCS_LIMIT, stmp_17, 92, 4, 0xFFFFFFFF); 

		setvariable(find_avp, AVPCODE_CALLED_STATION_ID);
		transit_execute(GET_AVP_VENDOR_VALUE_POINT);
	}
	
	
	case receive (CC-Request, CC-Request-Type = update) {
		
		setvariable(reqtype, REQTYPE_UPDATE);
		
		### Get Session-Id from received CCR (UPDATE).
		snap("CCR UPDATE : GET_SESSION_ID");
		getsigdata(stmp_len, 24, 4, 0x00FFFFFF);
		getsigdata(stmp_01, 28, 4, 0xFFFFFFFF); 			getsigdata(stmp_02, 32, 4, 0xFFFFFFFF); getsigdata(stmp_03, 36, 4, 0xFFFFFFFF); getsigdata(stmp_04, 40, 4, 0xFFFFFFFF); getsigdata(stmp_05, 44, 4, 0xFFFFFFFF); getsigdata(stmp_06, 48, 4, 0xFFFFFFFF); getsigdata(stmp_07, 52, 4, 0xFFFFFFFF); getsigdata(stmp_08, 56, 4, 0xFFFFFFFF); getsigdata(stmp_09, 60, 4, 0xFFFFFFFF); getsigdata(stmp_10, 64, 4, 0xFFFFFFFF); getsigdata(stmp_11, 68, 4, 0xFFFFFFFF); getsigdata(stmp_12, 72, 4, 0xFFFFFFFF); getsigdata(stmp_13, 76, 4, 0xFFFFFFFF); getsigdata(stmp_14, 80, 4, 0xFFFFFFFF); getsigdata(stmp_15, 84, 4, 0xFFFFFFFF); getsigdata(stmp_16, 88, 4, 0xFFFFFFFF); getsigdata(stmp_17, 92, 4, 0xFFFFFFFF); 

		### Find allocated session
		if ( stmp_01 == s1_01 ) { increase(s_same); }			 if ( stmp_02 == s1_02 ) { increase(s_same); } if ( stmp_03 == s1_03 ) { increase(s_same); } if ( stmp_04 == s1_04 ) { increase(s_same); } if ( stmp_05 == s1_05 ) { increase(s_same); } if ( stmp_06 == s1_06 ) { increase(s_same); } if ( stmp_07 == s1_07 ) { increase(s_same); } if ( stmp_08 == s1_08 ) { increase(s_same); } if ( stmp_09 == s1_09 ) { increase(s_same); } if ( stmp_10 == s1_10 ) { increase(s_same); } if ( stmp_11 == s1_11 ) { increase(s_same); } if ( stmp_12 == s1_12 ) { increase(s_same); } if ( stmp_13 == s1_13 ) { increase(s_same); } if ( stmp_14 == s1_14 ) { increase(s_same); } if ( stmp_15 == s1_15 ) { increase(s_same); } if ( stmp_16 == s1_16 ) { increase(s_same); } if ( stmp_17 == s1_17 ) { increase(s_same); } 
		if ( s_same == 17) {
			setvariable(current_session, 1);
		}
		setvariable(s_same, 0);
		
		if ( stmp_01 == s2_01 ) { increase(s_same); } 			if ( stmp_02 == s2_02 ) { increase(s_same); } if ( stmp_03 == s2_03 ) { increase(s_same); } if ( stmp_04 == s2_04 ) { increase(s_same); } if ( stmp_05 == s2_05 ) { increase(s_same); } if ( stmp_06 == s2_06 ) { increase(s_same); } if ( stmp_07 == s2_07 ) { increase(s_same); } if ( stmp_08 == s2_08 ) { increase(s_same); } if ( stmp_09 == s2_09 ) { increase(s_same); } if ( stmp_10 == s2_10 ) { increase(s_same); } if ( stmp_11 == s2_11 ) { increase(s_same); } if ( stmp_12 == s2_12 ) { increase(s_same); } if ( stmp_13 == s2_13 ) { increase(s_same); } if ( stmp_14 == s2_14 ) { increase(s_same); } if ( stmp_15 == s2_15 ) { increase(s_same); } if ( stmp_16 == s2_16 ) { increase(s_same); } if ( stmp_17 == s2_17 ) { increase(s_same); } 
		if ( s_same == 17) {
			setvariable(current_session, 2);
		}
		setvariable(s_same, 0);
		
		if ( stmp_01 == s3_01 ) { increase(s_same); }			 if ( stmp_02 == s3_02 ) { increase(s_same); } if ( stmp_03 == s3_03 ) { increase(s_same); } if ( stmp_04 == s3_04 ) { increase(s_same); } if ( stmp_05 == s3_05 ) { increase(s_same); } if ( stmp_06 == s3_06 ) { increase(s_same); } if ( stmp_07 == s3_07 ) { increase(s_same); } if ( stmp_08 == s3_08 ) { increase(s_same); } if ( stmp_09 == s3_09 ) { increase(s_same); } if ( stmp_10 == s3_10 ) { increase(s_same); } if ( stmp_11 == s3_11 ) { increase(s_same); } if ( stmp_12 == s3_12 ) { increase(s_same); } if ( stmp_13 == s3_13 ) { increase(s_same); } if ( stmp_14 == s3_14 ) { increase(s_same); } if ( stmp_15 == s3_15 ) { increase(s_same); } if ( stmp_16 == s3_16 ) { increase(s_same); } if ( stmp_17 == s3_17 ) { increase(s_same); } 
		if ( s_same == 17) {
			setvariable(current_session, 3);
		}
		setvariable(s_same, 0);
		
		if ( stmp_01 == s4_01 ) { increase(s_same); }			 if ( stmp_02 == s4_02 ) { increase(s_same); } if ( stmp_03 == s4_03 ) { increase(s_same); } if ( stmp_04 == s4_04 ) { increase(s_same); } if ( stmp_05 == s4_05 ) { increase(s_same); } if ( stmp_06 == s4_06 ) { increase(s_same); } if ( stmp_07 == s4_07 ) { increase(s_same); } if ( stmp_08 == s4_08 ) { increase(s_same); } if ( stmp_09 == s4_09 ) { increase(s_same); } if ( stmp_10 == s4_10 ) { increase(s_same); } if ( stmp_11 == s4_11 ) { increase(s_same); } if ( stmp_12 == s4_12 ) { increase(s_same); } if ( stmp_13 == s4_13 ) { increase(s_same); } if ( stmp_14 == s4_14 ) { increase(s_same); } if ( stmp_15 == s4_15 ) { increase(s_same); } if ( stmp_16 == s4_16 ) { increase(s_same); } if ( stmp_17 == s4_17 ) { increase(s_same); } 
		if ( s_same == 17) {
			setvariable(current_session, 4);
		}
		setvariable(s_same, 0);
		
		snap("STATE_FIND_SESSION", current_session);
		
		### set Session-Id to CCA 
		## 以下では、このシナリオで定義された全ての信号に対してsession-idを設定する。
		## 判別ロジックを入れると複雑になりすぎるため。
		## ツールで定義できるように後で作る
		setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_len, 24, 4, 0x00FFFFFF);
		setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_RAT_CHANGE, stmp_17, 92, 4, 0xFFFFFFFF); 
		setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_len, 24, 4, 0x00FFFFFF);
		setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_IMODE_CONTAINER_DETECTION, stmp_17, 92, 4, 0xFFFFFFFF); 
		setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_len, 24, 4, 0x00FFFFFF);
		setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION, stmp_17, 92, 4, 0xFFFFFFFF); 
		setsigdata(CCA_UPDATE_SCHEDULING, stmp_len, 24, 4, 0x00FFFFFF);
		setsigdata(CCA_UPDATE_SCHEDULING, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_UPDATE_SCHEDULING, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_SCHEDULING, stmp_17, 92, 4, 0xFFFFFFFF); 
		setsigdata(CCA_UPDATE_NG, stmp_len, 24, 4, 0x00FFFFFF);
		setsigdata(CCA_UPDATE_NG, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_UPDATE_NG, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG, stmp_17, 92, 4, 0xFFFFFFFF); 

		setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_len, 24, 4, 0x00FFFFFF);
		setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_UPDATE_NG_RESULT_CODE, stmp_17, 92, 4, 0xFFFFFFFF); 
		
		setvariable(find_avp, AVPCODE_EVENT_TRIGGER);
		transit_execute(GET_AVP_VENDOR_VALUE_POINT);
	}
	
	
	
	case receive (CC-Request, CC-Request-Type = termination) {
		
		setvariable(reqtype, REQTYPE_TERMINATION);
		
		### Get Session-Id from received CCR (TERMINATION).
		snap("CCR TERMINATION : GET_SESSION_ID");
		getsigdata(stmp_len, 24, 4, 0x00FFFFFF);
		getsigdata(stmp_01, 28, 4, 0xFFFFFFFF); 			getsigdata(stmp_02, 32, 4, 0xFFFFFFFF); getsigdata(stmp_03, 36, 4, 0xFFFFFFFF); getsigdata(stmp_04, 40, 4, 0xFFFFFFFF); getsigdata(stmp_05, 44, 4, 0xFFFFFFFF); getsigdata(stmp_06, 48, 4, 0xFFFFFFFF); getsigdata(stmp_07, 52, 4, 0xFFFFFFFF); getsigdata(stmp_08, 56, 4, 0xFFFFFFFF); getsigdata(stmp_09, 60, 4, 0xFFFFFFFF); getsigdata(stmp_10, 64, 4, 0xFFFFFFFF); getsigdata(stmp_11, 68, 4, 0xFFFFFFFF); getsigdata(stmp_12, 72, 4, 0xFFFFFFFF); getsigdata(stmp_13, 76, 4, 0xFFFFFFFF); getsigdata(stmp_14, 80, 4, 0xFFFFFFFF); getsigdata(stmp_15, 84, 4, 0xFFFFFFFF); getsigdata(stmp_16, 88, 4, 0xFFFFFFFF); getsigdata(stmp_17, 92, 4, 0xFFFFFFFF); 
		
		### Find allocated session
		if ( stmp_01 == s1_01 ) { increase(s_same); }			 if ( stmp_02 == s1_02 ) { increase(s_same); } if ( stmp_03 == s1_03 ) { increase(s_same); } if ( stmp_04 == s1_04 ) { increase(s_same); } if ( stmp_05 == s1_05 ) { increase(s_same); } if ( stmp_06 == s1_06 ) { increase(s_same); } if ( stmp_07 == s1_07 ) { increase(s_same); } if ( stmp_08 == s1_08 ) { increase(s_same); } if ( stmp_09 == s1_09 ) { increase(s_same); } if ( stmp_10 == s1_10 ) { increase(s_same); } if ( stmp_11 == s1_11 ) { increase(s_same); } if ( stmp_12 == s1_12 ) { increase(s_same); } if ( stmp_13 == s1_13 ) { increase(s_same); } if ( stmp_14 == s1_14 ) { increase(s_same); } if ( stmp_15 == s1_15 ) { increase(s_same); } if ( stmp_16 == s1_16 ) { increase(s_same); } if ( stmp_17 == s1_17 ) { increase(s_same); } 
		if ( s_same == 17) {
			setvariable(current_session, 1);
		}
		setvariable(s_same, 0);
		
		if ( stmp_01 == s2_01 ) { increase(s_same); } 			if ( stmp_02 == s2_02 ) { increase(s_same); } if ( stmp_03 == s2_03 ) { increase(s_same); } if ( stmp_04 == s2_04 ) { increase(s_same); } if ( stmp_05 == s2_05 ) { increase(s_same); } if ( stmp_06 == s2_06 ) { increase(s_same); } if ( stmp_07 == s2_07 ) { increase(s_same); } if ( stmp_08 == s2_08 ) { increase(s_same); } if ( stmp_09 == s2_09 ) { increase(s_same); } if ( stmp_10 == s2_10 ) { increase(s_same); } if ( stmp_11 == s2_11 ) { increase(s_same); } if ( stmp_12 == s2_12 ) { increase(s_same); } if ( stmp_13 == s2_13 ) { increase(s_same); } if ( stmp_14 == s2_14 ) { increase(s_same); } if ( stmp_15 == s2_15 ) { increase(s_same); } if ( stmp_16 == s2_16 ) { increase(s_same); } if ( stmp_17 == s2_17 ) { increase(s_same); } 
		if ( s_same == 17) {
			setvariable(current_session, 2);
		}
		setvariable(s_same, 0);
		
		if ( stmp_01 == s3_01 ) { increase(s_same); }			 if ( stmp_02 == s3_02 ) { increase(s_same); } if ( stmp_03 == s3_03 ) { increase(s_same); } if ( stmp_04 == s3_04 ) { increase(s_same); } if ( stmp_05 == s3_05 ) { increase(s_same); } if ( stmp_06 == s3_06 ) { increase(s_same); } if ( stmp_07 == s3_07 ) { increase(s_same); } if ( stmp_08 == s3_08 ) { increase(s_same); } if ( stmp_09 == s3_09 ) { increase(s_same); } if ( stmp_10 == s3_10 ) { increase(s_same); } if ( stmp_11 == s3_11 ) { increase(s_same); } if ( stmp_12 == s3_12 ) { increase(s_same); } if ( stmp_13 == s3_13 ) { increase(s_same); } if ( stmp_14 == s3_14 ) { increase(s_same); } if ( stmp_15 == s3_15 ) { increase(s_same); } if ( stmp_16 == s3_16 ) { increase(s_same); } if ( stmp_17 == s3_17 ) { increase(s_same); } 
		if ( s_same == 17) {
			setvariable(current_session, 3);
		}
		setvariable(s_same, 0);
		
		if ( stmp_01 == s4_01 ) { increase(s_same); }			 if ( stmp_02 == s4_02 ) { increase(s_same); } if ( stmp_03 == s4_03 ) { increase(s_same); } if ( stmp_04 == s4_04 ) { increase(s_same); } if ( stmp_05 == s4_05 ) { increase(s_same); } if ( stmp_06 == s4_06 ) { increase(s_same); } if ( stmp_07 == s4_07 ) { increase(s_same); } if ( stmp_08 == s4_08 ) { increase(s_same); } if ( stmp_09 == s4_09 ) { increase(s_same); } if ( stmp_10 == s4_10 ) { increase(s_same); } if ( stmp_11 == s4_11 ) { increase(s_same); } if ( stmp_12 == s4_12 ) { increase(s_same); } if ( stmp_13 == s4_13 ) { increase(s_same); } if ( stmp_14 == s4_14 ) { increase(s_same); } if ( stmp_15 == s4_15 ) { increase(s_same); } if ( stmp_16 == s4_16 ) { increase(s_same); } if ( stmp_17 == s4_17 ) { increase(s_same); } 
		if ( s_same == 17) {
			setvariable(current_session, 4);
		}
		setvariable(s_same, 0);
		
		snap("STATE_FIND_SESSION", current_session);
		
		### Free session. 
		if ( current_session == 1 ) { setvariable(s1_used, 0); }
		if ( current_session == 2 ) { setvariable(s2_used, 0); }
		if ( current_session == 3 ) { setvariable(s3_used, 0); }
		if ( current_session == 4 ) { setvariable(s4_used, 0); }
		
		setsigdata(CCA_TERM, stmp_len, 24, 4, 0x00FFFFFF);
		setsigdata(CCA_TERM, stmp_01, 28, 4, 0xFFFFFFFF); 		setsigdata(CCA_TERM, stmp_02, 32, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_03, 36, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_04, 40, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_05, 44, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_06, 48, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_07, 52, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_08, 56, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_09, 60, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_10, 64, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_11, 68, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_12, 72, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_13, 76, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_14, 80, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_15, 84, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_16, 88, 4, 0xFFFFFFFF); setsigdata(CCA_TERM, stmp_17, 92, 4, 0xFFFFFFFF); 
		#setvariable(current_session, 0);
		
		transit_execute();
	}
	
	
	
	
	
	#################################################################
	###
	### Retrieve APN
	### 
	case expiry( find_avp_tm ) {
		# from GET_AVP_VENDOR_VALUE_POINT
		
		if (find_avp == AVPCODE_CALLED_STATION_ID) {
			getsigdata(avpval_called_station_id_tmp, avp_value_p, 4, 0x00FFFFFF);
			
			getsigdata(avpval_called_station_id1, avp_value_p, 4, 0xFFFFFFFF);
			increase(avp_value_p, 4);
			getsigdata(avpval_called_station_id2, avp_value_p, 4, 0xFFFFFFFF);
			# get upper 32 bit
			divide(  avpval_called_station_id2, 0x10000, avpval_called_station_id2);
			
			snap("Retrieve CALLED_STATION_ID[1]", avpval_called_station_id1);
			snap("Retrieve CALLED_STATION_ID[2]", avpval_called_station_id2);
			
			# call kind i-mode    ---  y"-mo"de.docomo.ne.jp / o"-mo"de.docomo.ne.jp
			# call kind mopera    ---  n"ope"ru.ne.jp        / n"ope"ri.ne.jp
			# call kind mvno      ---- m"vno"01.ne.jp
			# call kind dcm-wcs    --- d"cm-"wcs.ne.jp
			#      
			if (avpval_called_station_id_tmp == 0x2d6d6f) { setvariable( call_kind, IMODE ); }
			if (avpval_called_station_id_tmp == 0x6f7065) { setvariable( call_kind, MOPERA ); }
			if (avpval_called_station_id_tmp == 0x766e6f) { setvariable( call_kind, MVNO ); }
			if (avpval_called_station_id_tmp == 0x636d2d) { setvariable( call_kind, DCM_WCS ); }
			
			if (interface_type == GX ) { if ( call_kind == IMODE ) { 
				setvariable( find_avp, AVPCODE_FRAMED_IPV6_PREFIX ); 
				transit_execute(GET_AVP_VENDOR_VALUE_POINT);
			}}
			
			snap("Retrieve CALL_KIND", call_kind);
			setvariable( find_avp, 0);
			transit_execute( CCR_ATTACH );
		}
		
		if ( find_avp == AVPCODE_FRAMED_IPV6_PREFIX ) {
			increase(avp_value_p, 2);	# through 2 oct of reserved/prefix-len 
			
			getsigdata(avpval_framed_ipv6_prefix1, avp_value_p, 4, 0xFFFFFFFF);
			increase(avp_value_p, 4);
			getsigdata(avpval_framed_ipv6_prefix2, avp_value_p, 4, 0xFFFFFFFF);
			
			snap("Retrieve FRAMED_IPV6_PREFIX 1", avpval_framed_ipv6_prefix1);
			snap("Retrieve FRAMED_IPV6_PREFIX 2", avpval_framed_ipv6_prefix2);
			
			setvariable( find_avp, 0);
			transit_execute( CCR_ATTACH );
		}
		
		if (find_avp == AVPCODE_EVENT_TRIGGER) {
			getsigdata(avpval_event_trigger, avp_value_p, 4, 0xFFFFFFFF);
			
			snap("Retrieve EVENT_TRIGGER", avpval_event_trigger);
			setvariable( find_avp, 0);
			transit_execute( CCR_ATTACH );
		}
		
		if (find_avp == AVPCODE_RAT_TYPE) {
			getsigdata(avpval_rat_type, avp_value_p, 4, 0xFFFFFFFF);
			
			snap("Retrieve RAT-TYPE", avpval_rat_type);
			setvariable( find_avp, 0);
			if( call_kind == IMODE ){
				isc_send(PCRF_P_1, SYNCHRO, 102, interface_type);
			}
			transit();
		}
		
		snap("!!! LOST THE WAY !!!");
	}
}





in RAR_RATCHANGE_SEND {
	case execution () {
		# send RAR to all session at Gxx interface
		if (interface_type == GXX) {
			# do nothing
		}
		
		# send RAR to other session at Gx interface
		if (interface_type == GX) {
			# Set RAT-Type. ISC from S-PCRF or control variable operation.
			setsigdata(RAR_RATCHANGE, avpval_rat_type, RAR_RATCHANGE_POS_DOCOMO_CONTAINER_RATTYPE, 1, 0xFF);
			
			# Send RAR to All session
			if (s1_used == 1) { 
				setsigdata(RAR_RATCHANGE, s1_len, 24, 4, 0x00FFFFFF);
				setsigdata(RAR_RATCHANGE, s1_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s1_17, 92, 4, 0xFFFFFFFF);
				send(RAR_RATCHANGE);
				snap("Session1 RAR Send");
			}
			if (s2_used == 1) {
				setsigdata(RAR_RATCHANGE, s2_len, 24, 4, 0x00FFFFFF);
				setsigdata(RAR_RATCHANGE, s2_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s2_17, 92, 4, 0xFFFFFFFF);
				send(RAR_RATCHANGE);
				snap("Session2 RAR Send");
			}
			if (s3_used == 1) {
				setsigdata(RAR_RATCHANGE, s3_len, 24, 4, 0x00FFFFFF);
				setsigdata(RAR_RATCHANGE, s3_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s3_17, 92, 4, 0xFFFFFFFF);
				send(RAR_RATCHANGE);
				snap("Session3 RAR Send");
			}
			if (s4_used == 1) {
				setsigdata(RAR_RATCHANGE, s4_len, 24, 4, 0x00FFFFFF);
				setsigdata(RAR_RATCHANGE, s4_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_RATCHANGE, s4_17, 92, 4, 0xFFFFFFFF);
				send(RAR_RATCHANGE);
				snap("Session4 RAR Send");
			}
		}
		
		### Return Main State
		transit(CCR_ATTACH);
	}
}





in RAR_QOSCHANGE_SEND {
	case execution () {
		# send RAR to all session at Gxx interface
		if (interface_type == GXX) {
			if (s1_used == 1) { 
				setsigdata(RAR_QOSCHANGE, s1_len, 24, 4, 0x00FFFFFF);
				setsigdata(RAR_QOSCHANGE, s1_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_17, 92, 4, 0xFFFFFFFF);
				send(RAR_QOSCHANGE);
				snap("Session1 RAR Send");
			}
			if (s2_used == 1) {
				setsigdata(RAR_QOSCHANGE, s2_len, 24, 4, 0x00FFFFFF);
				setsigdata(RAR_QOSCHANGE, s2_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_17, 92, 4, 0xFFFFFFFF);
				send(RAR_QOSCHANGE);
				snap("Session2 RAR Send");
			}
			if (s3_used == 1) {
				setsigdata(RAR_QOSCHANGE, s3_len, 24, 4, 0x00FFFFFF);
				setsigdata(RAR_QOSCHANGE, s3_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_17, 92, 4, 0xFFFFFFFF);
				send(RAR_QOSCHANGE);
				snap("Session3 RAR Send");
			}
			if (s4_used == 1) {
				setsigdata(RAR_QOSCHANGE, s4_len, 24, 4, 0x00FFFFFF);
				setsigdata(RAR_QOSCHANGE, s4_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_17, 92, 4, 0xFFFFFFFF);
				send(RAR_QOSCHANGE);
				snap("Session4 RAR Send");
			}
		}
		
		# send RAR to other session at Gx interface
		if (interface_type == GX) {
			# Not send RAR to that has sent CCA session
			if (event_detector == GX) {
				if (s1_used == 1) { if (current_session != 1) {
					setsigdata(RAR_QOSCHANGE, s1_len, 24, 4, 0x00FFFFFF);
					setsigdata(RAR_QOSCHANGE, s1_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_17, 92, 4, 0xFFFFFFFF);
					send(RAR_QOSCHANGE);
					snap("Session1 RAR Send");
				}}
				if (s2_used == 1) { if (current_session != 2) {
					setsigdata(RAR_QOSCHANGE, s2_len, 24, 4, 0x00FFFFFF);
					setsigdata(RAR_QOSCHANGE, s2_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_17, 92, 4, 0xFFFFFFFF);
					send(RAR_QOSCHANGE);
					snap("Session2 RAR Send");
				}}
				if (s3_used == 1) { if (current_session != 3) {
					setsigdata(RAR_QOSCHANGE, s3_len, 24, 4, 0x00FFFFFF);
					setsigdata(RAR_QOSCHANGE, s3_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_17, 92, 4, 0xFFFFFFFF);
					send(RAR_QOSCHANGE);
					snap("Session3 RAR Send");
				}}
				if (s4_used == 1) { if (current_session != 4) {
					setsigdata(RAR_QOSCHANGE, s4_len, 24, 4, 0x00FFFFFF);
					setsigdata(RAR_QOSCHANGE, s4_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_17, 92, 4, 0xFFFFFFFF);
					send(RAR_QOSCHANGE);
					snap("Session4 RAR Send");
				}}
			}
			# Send RAR to All session
			else {
				if (s1_used == 1) { 
					setsigdata(RAR_QOSCHANGE, s1_len, 24, 4, 0x00FFFFFF);
					setsigdata(RAR_QOSCHANGE, s1_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s1_17, 92, 4, 0xFFFFFFFF);
					send(RAR_QOSCHANGE);
					snap("Session1 RAR Send");
				}
				if (s2_used == 1) {
					setsigdata(RAR_QOSCHANGE, s2_len, 24, 4, 0x00FFFFFF);
					setsigdata(RAR_QOSCHANGE, s2_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s2_17, 92, 4, 0xFFFFFFFF);
					send(RAR_QOSCHANGE);
					snap("Session2 RAR Send");
				}
				if (s3_used == 1) {
					setsigdata(RAR_QOSCHANGE, s3_len, 24, 4, 0x00FFFFFF);
					setsigdata(RAR_QOSCHANGE, s3_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s3_17, 92, 4, 0xFFFFFFFF);
					send(RAR_QOSCHANGE);
					snap("Session3 RAR Send");
				}
				if (s4_used == 1) {
					setsigdata(RAR_QOSCHANGE, s4_len, 24, 4, 0x00FFFFFF);
					setsigdata(RAR_QOSCHANGE, s4_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_QOSCHANGE, s4_17, 92, 4, 0xFFFFFFFF);
					send(RAR_QOSCHANGE);
					snap("Session4 RAR Send");
				}
			}
		}
		
		### Return Main State
		transit(CCR_ATTACH);
	}
}




in RAR_PRESERVATION_ALLOWED_TIME_SEND {
	case execution () {
		snap("current_session", current_session);
		snap("s1_used", s1_used);
		snap("s2_used", s2_used);
		snap("s3_used", s3_used);
		snap("s4_used", s4_used);
		
		# send RAR(Preservation-Allowd-Time) to exist session at Gx interface
		if (s1_used == 1) { if (current_session != 1) {
			setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_len, 24, 4, 0x00FFFFFF);
			setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s1_17, 92, 4, 0xFFFFFFFF);
			
			# 呼を切断時、残り1呼ならその呼へ通知済み・未通知に拘わらず0でRAR送信
			if (n_sessions == 1) {
				setvariable(avpval_preservation_allowed_time, 0);
				setsigdata(RAR_PRESERVATION_ALLOWED_TIME, avpval_preservation_allowed_time, RAR_PRESERVATION_ALLOWED_TIME_POS_PRESERVATION_ALLOWED_TIME, 4, 0xFFFFFFFF);
				
				send(RAR_PRESERVATION_ALLOWED_TIME);
				snap("Session1 RAR Send");
				
				setvariable(s1_notified_pat, avpval_preservation_allowed_time);
			}
			# 呼を接続or切断時に2呼以上、かつ既存呼へ未通知(0通知済みは未通知扱い)なら、既存呼へAPN設定値でRAR送信
			if (n_sessions > 1) { if (s1_notified_pat == 0) {
				if (s1_call_kind == IMODE)  { setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_IMODE);   }
				if (s1_call_kind == MOPERA) { setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_MOPERA);  }
				if (s1_call_kind == DCM_WCS) { setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_DCM_WCS);  }
				setsigdata(RAR_PRESERVATION_ALLOWED_TIME, avpval_preservation_allowed_time, RAR_PRESERVATION_ALLOWED_TIME_POS_PRESERVATION_ALLOWED_TIME, 4, 0xFFFFFFFF);
					
				send(RAR_PRESERVATION_ALLOWED_TIME);
				snap("Session1 RAR Send");
					
				setvariable(s1_notified_pat, avpval_preservation_allowed_time);
			}}
		}}
		
		if (s2_used == 1) { if (current_session != 2) {
			setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_len, 24, 4, 0x00FFFFFF);
			setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s2_17, 92, 4, 0xFFFFFFFF);
			
			# 呼を切断時、残り1呼ならその呼へ通知済み・未通知に拘わらず0でRAR送信
			if (n_sessions == 1) {
				setvariable(avpval_preservation_allowed_time, 0);
				setsigdata(RAR_PRESERVATION_ALLOWED_TIME, avpval_preservation_allowed_time, RAR_PRESERVATION_ALLOWED_TIME_POS_PRESERVATION_ALLOWED_TIME, 4, 0xFFFFFFFF);
				
				send(RAR_PRESERVATION_ALLOWED_TIME);
				snap("Session2 RAR Send");
				
				setvariable(s2_notified_pat, avpval_preservation_allowed_time);
			}
			# 呼を接続or切断時に2呼以上、かつ既存呼へ未通知(0通知済みは未通知扱い)なら、既存呼へAPN設定値でRAR送信
			if (n_sessions > 1) { if (s2_notified_pat == 0) {
				if (s2_call_kind == IMODE)  { setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_IMODE);   }
				if (s2_call_kind == MOPERA) { setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_MOPERA);  }
				if (s2_call_kind == DCM_WCS) { setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_DCM_WCS);  }
				setsigdata(RAR_PRESERVATION_ALLOWED_TIME, avpval_preservation_allowed_time, RAR_PRESERVATION_ALLOWED_TIME_POS_PRESERVATION_ALLOWED_TIME, 4, 0xFFFFFFFF);
					
				send(RAR_PRESERVATION_ALLOWED_TIME);
				snap("Session2 RAR Send");
					
				setvariable(s2_notified_pat, avpval_preservation_allowed_time);
			}}
		}}		
		
		if (s3_used == 1) { if (current_session != 3) {
			setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_len, 24, 4, 0x00FFFFFF);
			setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s3_17, 92, 4, 0xFFFFFFFF);
			
			# 呼を切断時、残り1呼ならその呼へ通知済み・未通知に拘わらず0でRAR送信
			if (n_sessions == 1) {
				setvariable(avpval_preservation_allowed_time, 0);
				setsigdata(RAR_PRESERVATION_ALLOWED_TIME, avpval_preservation_allowed_time, RAR_PRESERVATION_ALLOWED_TIME_POS_PRESERVATION_ALLOWED_TIME, 4, 0xFFFFFFFF);
				
				send(RAR_PRESERVATION_ALLOWED_TIME);
				snap("Session3 RAR Send");
				
				setvariable(s3_notified_pat, avpval_preservation_allowed_time);
			}
			# 呼を接続or切断時に2呼以上、かつ既存呼へ未通知(0通知済みは未通知扱い)なら、既存呼へAPN設定値でRAR送信
			if (n_sessions > 1) { if (s3_notified_pat == 0) {
				if (s3_call_kind == IMODE)  { setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_IMODE);   }
				if (s3_call_kind == MOPERA) { setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_MOPERA);  }
				if (s3_call_kind == DCM_WCS) { setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_DCM_WCS);  }
				setsigdata(RAR_PRESERVATION_ALLOWED_TIME, avpval_preservation_allowed_time, RAR_PRESERVATION_ALLOWED_TIME_POS_PRESERVATION_ALLOWED_TIME, 4, 0xFFFFFFFF);
					
				send(RAR_PRESERVATION_ALLOWED_TIME);
				snap("Session3 RAR Send");
					
				setvariable(s3_notified_pat, avpval_preservation_allowed_time);
			}}
		}}		
		
		if (s4_used == 1) { if (current_session != 3) {
			setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_len, 24, 4, 0x00FFFFFF);
			setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_PRESERVATION_ALLOWED_TIME, s4_17, 92, 4, 0xFFFFFFFF);
			
			# 呼を切断時、残り1呼ならその呼へ通知済み・未通知に拘わらず0でRAR送信
			if (n_sessions == 1) {
				setvariable(avpval_preservation_allowed_time, 0);
				setsigdata(RAR_PRESERVATION_ALLOWED_TIME, avpval_preservation_allowed_time, RAR_PRESERVATION_ALLOWED_TIME_POS_PRESERVATION_ALLOWED_TIME, 4, 0xFFFFFFFF);
				
				send(RAR_PRESERVATION_ALLOWED_TIME);
				snap("Session4 RAR Send");
				
				setvariable(s4_notified_pat, avpval_preservation_allowed_time);
			}
			# 呼を接続or切断時に2呼以上、かつ既存呼へ未通知(0通知済みは未通知扱い)なら、既存呼へAPN設定値でRAR送信
			if (n_sessions > 1) { if (s4_notified_pat == 0) {
				if (s4_call_kind == IMODE)  { setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_IMODE);   }
				if (s4_call_kind == MOPERA) { setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_MOPERA);  }
				if (s4_call_kind == DCM_WCS) { setvariable(avpval_preservation_allowed_time, AVPVAL_PRESERVATION_ALLOWED_TIMER_DCM_WCS);  }
				setsigdata(RAR_PRESERVATION_ALLOWED_TIME, avpval_preservation_allowed_time, RAR_PRESERVATION_ALLOWED_TIME_POS_PRESERVATION_ALLOWED_TIME, 4, 0xFFFFFFFF);
					
				send(RAR_PRESERVATION_ALLOWED_TIME);
				snap("Session4 RAR Send");
					
				setvariable(s4_notified_pat, avpval_preservation_allowed_time);
			}}
		}}		
		
		### Return Main State
		transit(CCR_ATTACH);
	}
}





in RAR_SESSION_REL_SEND {
	case execution () {
		# send RAR to all session at Gxx interface
		if (interface_type == GXX) {
			# do nothing
		}
		
		# send RAR to other session at Gx interface
		if (interface_type == GX) {
			# Set Session Release Cause
			setsigdata(RAR_SESSION_REL, session_release_cause, RAR_SESSION_REL_POS_SESSION_REL_CAUSE, 4, 0x000000FF);
			
			# Send RAR to All session
			if (first_dcm-wcs_session == 1) { if (s1_used == 1) { 
				setsigdata(RAR_SESSION_REL, s1_len, 24, 4, 0x00FFFFFF);
				setsigdata(RAR_SESSION_REL, s1_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s1_17, 92, 4, 0xFFFFFFFF);
				send(RAR_SESSION_REL);
				snap("Session1 RAR Send");
			}}
			if (first_dcm-wcs_session == 2) { if (s2_used == 1) {
				setsigdata(RAR_SESSION_REL, s2_len, 24, 4, 0x00FFFFFF);
				setsigdata(RAR_SESSION_REL, s2_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s2_17, 92, 4, 0xFFFFFFFF);
				send(RAR_SESSION_REL);
				snap("Session2 RAR Send");
			}}
			if (first_dcm-wcs_session == 3) { if (s3_used == 1) {
				setsigdata(RAR_SESSION_REL, s3_len, 24, 4, 0x00FFFFFF);
				setsigdata(RAR_SESSION_REL, s3_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s3_17, 92, 4, 0xFFFFFFFF);
				send(RAR_SESSION_REL);
				snap("Session3 RAR Send");
			}}
			if (first_dcm-wcs_session == 4) { if (s4_used == 1) {
				setsigdata(RAR_SESSION_REL, s4_len, 24, 4, 0x00FFFFFF);
				setsigdata(RAR_SESSION_REL, s4_01, 28, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_02, 32, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_03, 36, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_04, 40, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_05, 44, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_06, 48, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_07, 52, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_08, 56, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_09, 60, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_10, 64, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_11, 68, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_12, 72, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_13, 76, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_14, 80, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_15, 84, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_16, 88, 4, 0xFFFFFFFF); setsigdata(RAR_SESSION_REL, s4_17, 92, 4, 0xFFFFFFFF);
				send(RAR_SESSION_REL);
				snap("Session4 RAR Send");
			}}
		}
		
		### Return Main State
		transit(CCR_ATTACH);
	}
}





in ANY_STATE {
	case kill {
		transit(NULL_STATE);
	}
	
	
	case receive (Re-Auth-Answer) {
		# Nothing to do
	}
	
	
	
	
	
	# Receive event detection node, and go to RAR
	case isc_receive(SYNCHRO, 100, event_detector)
	case isc_receive(SYNCHRO, 101, event_detector) {
		snap("QoS Update event occured. from ISC notification");
		transit_execute(RAR_QOSCHANGE_SEND);
	}
	
	# Receive RAT-Type  and go to RAR. 
	case control (cmd_ratchange) {
		setvariable(avpval_rat_type, cmd_ratchange);
		snap("RAT-Type event occured. from control variable operation");
		transit_execute(RAR_RATCHANGE_SEND);
	}
	case isc_receive(SYNCHRO, 102, avpval_rat_type) {
		snap("RAT-Type event occured. from ISC notification");
		transit_execute(RAR_RATCHANGE_SEND);
	}
	
	##################
	# Multi-Spmode trigger PCRF initiated Bearer Deactivation 
	case isc_receive(SYNCHRO, 103, first_dcm-wcs_session) {
		snap("Multi-Spmode trigger PCRF initiated Bearer Deactivation");
		transit_execute(RAR_SESSION_REL_SEND);
	}
	
    	##################
    	# User-Information
	case control ( set_User_Information ) {
    		setsigdata(CCA_INIT_IMODE, set_User_Information, 
    				CCA_INIT_IMODE_POS_DOCOMO_CONTAINER_USER_INFORMATION, 3, 0x0000FF);
    		snap("User Information Set:", set_User_Information);
	}
	
    	##################
    	# QCI
    	case control ( teigaku_mvno_qci ) {
    		setsigdata(CCA_INIT_IMODE_TEIGAKU,    teigaku_mvno_qci,  CCA_INIT_IMODE_TEIGAKU_POS_QCI,  4, 0x000000FF);
    		setsigdata(CCA_INIT_MOPERA_TEIGAKU,   teigaku_mvno_qci,  CCA_INIT_MOPERA_TEIGAKU_POS_QCI, 4, 0x000000FF);
    		setsigdata(CCA_INIT_MVNO,             teigaku_mvno_qci,  CCA_INIT_MVNO_POS_QCI,           4, 0x000000FF);
    		snap("QCI Set:", teigaku_mvno_qci);
    	}

    	##################
    	# Charging-Rule-Base-Name
    	#case control ( set_base_name_1_Spmode ) {
		#setsigdata(CCA_INIT_DCM_WCS, set_base_name_1_Spmode, CCA_INIT_DCM_WCS_POS_BASE_NAME_1,  1, 0xFF);
		#setsigdata(CCA_INIT_DCM_WCS_LIMIT, set_base_name_1_Spmode, CCA_INIT_DCM_WCS_POS_BASE_NAME_1,  1, 0xFF);
    	#	snap("Charging-Rule-Base-Name 1 Set:", set_base_name_1_Spmode);
    	#}
    	#case control ( set_base_name_2_Spmode ) {
		#setsigdata(CCA_INIT_DCM_WCS, set_base_name_2_Spmode, CCA_INIT_DCM_WCS_POS_BASE_NAME_2,  1, 0xFF);
#		#setsigdata(CCA_INIT_DCM_WCS_LIMIT, set_base_name_2_Spmode, CCA_INIT_DCM_WCS_POS_BASE_NAME_2,  1, 0xFF);
    	#	snap("Charging-Rule-Base-Name 2 Set:", set_base_name_2_Spmode);
    	#}
    	#case control ( set_base_name_3_Spmode ) {
		#setsigdata(CCA_INIT_DCM_WCS, set_base_name_3_Spmode, CCA_INIT_DCM_WCS_POS_BASE_NAME_3,  1, 0xFF);
    	#	snap("Charging-Rule-Base-Name 3 Set:", set_base_name_3_Spmode);
    	#}
    	case control ( set_base_name_Mopera ) {
		setsigdata(CCA_INIT_MOPERA, set_base_name_Mopera, CCA_INIT_MOPERA_POS_BASE_NAME,  1, 0xFF);
    		snap("Charging-Rule-Base-Name(Mopera) Set:", set_base_name_Mopera);
    	}

}





########
# set avp_value_p to AVP's Value offset
#
in GET_AVP_VENDOR_VALUE_POINT {
	case execution {
		if (i == 0) {
			getsigdata(len_msg, 0, 4, 0x00ffffff);
			increase(avp_p, 20);    # Through DIAMETER Header
		}
		getsigdata(avp_code, avp_p, 4 );
		if( avp_code == find_avp )
		{
			# AVP Found !!!!!!
			snap("GET_AVP_VENDOR_VALUE_POINT", avp_code);
			
			setvariable(avp_value_p, avp_p);
			setvariable(len_p, avp_p);
			increase(len_p, 4);
			getsigdata(avp_flag, len_p, 1, 0x80);
			if (avp_flag == 0x80) {	increase(avp_value_p, 12); }
			else {  		increase(avp_value_p, 8);  }
			
			setvariable( avp_code  , 0);
			setvariable( avp_p     , 0);
			setvariable( len       , 0);
			setvariable( len_p     , 0);
			setvariable( tmp_padd  , 0);
			setvariable( npadd     , 0);
			setvariable( avp_flag  , 0);
			setvariable( i         , 0);
			
			start_timer(find_avp_tm);
			transit(CCR_ATTACH);
		}
		
		### PCCルールインストールNG時
		# NG応答
		if( avp_code == AVPCODE_CHARGING_RULE_REPORT ){
			snap("AVPCODE_CHARGING_RULE_REPORT");

			setvariable( avp_code  , 0);
			setvariable( avp_p     , 0);
			setvariable( len       , 0);
			setvariable( len_p     , 0);
			setvariable( tmp_padd  , 0);
			setvariable( npadd     , 0);
			setvariable( avp_flag  , 0);
			setvariable( i         , 0);
			transit_execute( CCR_ATTACH );
		}

		setvariable(len_p, avp_p);
		increase(len_p, 4);
		
		getsigdata(len, len_p, 4, 0x00ffffff);

		mod(len, 4, tmp_padd);
		setvariable(npadd, 4);
		decrease(npadd, tmp_padd);
		if ( npadd == 4){
			setvariable(npadd, 0);
		}
		increase(avp_p, len);
		increase(avp_p, npadd);

		increase(i);

		# 無限ループガード処理
		if( avp_p >= len_msg ){
			snap("Not find AVP code!!");

			setvariable( avp_code  , 0);
			setvariable( avp_p     , 0);
			setvariable( len       , 0);
			setvariable( len_p     , 0);
			setvariable( tmp_padd  , 0);
			setvariable( npadd     , 0);
			setvariable( avp_flag  , 0);
			setvariable( i         , 0);
			transit( CCR_ATTACH );
		}

		transit_execute(GET_AVP_VENDOR_VALUE_POINT);
	}
}





#########################################################################################
# PDU Definition
#########################################################################################



#==================================================================================
pdu CCA_INIT_IMODE {
	01                                   # Version: 1
	00028c                               # Message Length: 658
	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000110                               # Command-Code: 272(Credit-Control-Answer)
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67 000000
	
	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000001
	0000019f 40 00000c  00000000
	
	### Result-Code
	0000010c 40 00000c  000007d1    #   2001(DIAMETER_SUCCESS)
	
	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List
	
	### Bearer-Control-Mode
	000003FF C0 000010 000028AF  00000002	#   2(UE_NW)
	
	### Event-Trigger
	#000003EE C0 000010 000028AF
	#	00000011	# Revalidation-Time
	
	### Event-Trigger
	#000003EE C0 000010 000028AF
	#	00000032	# Volume-Threashold
	
	### OFFLINE
	# ★i-modeはEPC非課金
	000003F0 c0 000010 000028af  00000000	# 0:DISABLE_OFFLINE
	
	### QoS-Information
	000003f8 c0 000058 000028af
		00000404 c0 000010 000028af  00000009	### QCI
		00000411 c0 000010 000028af  FFFFFED8	### AMBR UL
		00000410 c0 000010 000028af  FFFFFED8	### AMBR DL
		0000040A C0 00001C 000028AF		### ARP
			00000416 C0 000010 000028AF  0000000f	### Priority-Level
	
	### Revalidation-Time
	#00000412 C0 000010 000028AF
	#	CFBD0000
	
	### Subscribed-Carrier-Name
	00001300 C0 00000D 00000580
		0a000000
	
	### User-Equipment-Info
	000001ca 00 00002c
		000001cb 00 00000c  00000000		### User-Equipment-Info-Type  0(IMEISV)
		000001cc 00 000018  31313131 31313131	### User-Equipment-Info-Value
				    31313131 31313131
	
	### CA-Code
	00001309 C0 00000F 00000580  2300f000
	
	### MSISDN
	000002BD C0 000012 000028AF  18088117 10740000
	
	### Charging-Target-Flag
	00001310 C0 000010 00000580  00000000	#  bit0:課金対象表示 (1:専用線,0:移動機)
	
	### Dedicated-Line-Service-Flag
	# ★i-modeの時は載らないはず。
	# 00001311 C0 000010 00000580  00000002	#  bit1:mopera  / bit0:閉域
	
	### Authentication-Protocol
	00001315 C0 000010 00000580  00000000	# 0:ZERO, 1:CHAP, 2:PAP, 3:NONE
	
	### APN-Profile
	# ★i-modeは発ID認証なし
	00001316 C0 00002c 00000580
		### UserID-Authentication
		00001317 C0 000010 00000580
			00000000	# 1(USE) / 0(Not USE)
		### UserID-Authentication-Password
		#00001318 C0 000016 00000580
		#	41736365 6e642d43 4c494400
		### ID-Notification
		00001319 C0 000010 00000580
			00000001
	
	### Preservation-Allowed-Time
	0000131D C0 000010 00000580 
		00000000		#[POS_PRESERVATION_ALLOWED_TIME]
	
	### Volume-Threashold
	#00001313 C0 000010 00000580
	#	00000400

	### DOCOMO-Container
	00001323 80 000036 00000580
		00 01 01	#[POS_DOCOMO_CONTAINER_USER_INFORMATION]
				# User-Information: pad / ロー許 / OTA暫 / オン暫 / 通停 / リミ超 / リミ契 /i-mode
		01 01 45	# Terminal-Type   : FOMA外 / Dual / pad / pad / pad / U着 / PoC / 拡U着
		02 05 1234561212# IMEISV
		03 10 2001 0056 0000 0001 0000 0000 0000 0000	# IPv6 Prefix #[POS_DOCOMO_CONTAINER_IPV6PREFIX]
		05 03 2300f0	# CA-Code
		06 01 0a	# Subscribed-Carrier-Name
		09 01 06	# RAT-Type : 6:E-UTRAN, 1:UTRAN
		0000 # DIAMETER Padding
}




#==================================================================================
pdu CCA_INIT_IMODE_TEIGAKU {
	01                                   # Version: 1
	0002cc                               # Message Length: 658
	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000110                               # Command-Code: 272(Credit-Control-Answer)
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67 000000
	
	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000001
	0000019f 40 00000c  00000000
	
	### Result-Code
	0000010c 40 00000c  000007d1    #   2001(DIAMETER_SUCCESS)
	
	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List
	
	### Bearer-Control-Mode
	000003FF C0 000010 000028AF  00000002	#   2(UE_NW)
	
	### Event-Trigger
	000003EE C0 000010 000028AF
		00000011	# Revalidation-Time
	
	### Event-Trigger
	000003EE C0 000010 000028AF
		00000032	# Volume-Threashold
	
	### OFFLINE
	# ★i-modeはEPC非課金
	000003F0 c0 000010 000028af  00000000	# 0:DISABLE_OFFLINE
	
	### QoS-Information
	000003f8 c0 000058 000028af
		00000404 c0 000010 000028af		### QCI
			00000009				#[POS_QCI]
		00000411 c0 000010 000028af  FFFFFED8	### AMBR UL
		00000410 c0 000010 000028af  FFFFFED8	### AMBR DL
		0000040A C0 00001C 000028AF		### ARP
			00000416 C0 000010 000028AF  0000000f	### Priority-Level
	
	### Revalidation-Time
	00000412 C0 000010 000028AF
		ffffffff
	
	### Subscribed-Carrier-Name
	00001300 C0 00000D 00000580
		0a000000
	
	### User-Equipment-Info
	000001ca 00 00002c
		000001cb 00 00000c  00000000		### User-Equipment-Info-Type  0(IMEISV)
		000001cc 00 000018  31313131 31313131	### User-Equipment-Info-Value
				    31313131 31313131
	
	### CA-Code
	00001309 C0 00000F 00000580  2300f000
	
	### MSISDN
	000002BD C0 000012 000028AF  18088117 10740000
	
	### Charging-Target-Flag
	00001310 C0 000010 00000580  00000000	#  bit0:課金対象表示 (1:専用線,0:移動機)
	
	### Dedicated-Line-Service-Flag
	# ★i-modeの時は載らないはず。
	# 00001311 C0 000010 00000580  00000002	#  bit1:mopera  / bit0:閉域
	
	### Authentication-Protocol
	00001315 C0 000010 00000580  00000000	# 0:ZERO, 1:CHAP, 2:PAP, 3:NONE
	
	### APN-Profile
	# ★i-modeは発ID認証なし
	00001316 C0 00002c 00000580
		### UserID-Authentication
		00001317 C0 000010 00000580
			00000000	# 1(USE) / 0(Not USE)
		### UserID-Authentication-Password
		#00001318 C0 000016 00000580
		#	41736365 6e642d43 4c494400
		### ID-Notification
		00001319 C0 000010 00000580
			00000001
	
	### Preservation-Allowed-Time
	0000131D C0 000010 00000580
		 00000000		#[POS_PRESERVATION_ALLOWED_TIME]
	
	### Volume-Threashold
	00001313 C0 000010 00000580
		00100000

	### DOCOMO-Container
	00001323 80 000036 00000580
		00 01 01	#[POS_DOCOMO_CONTAINER_USER_INFORMATION]
				# User-Information: pad / ロー許 / OTA暫 / オン暫 / 通停 / リミ超 / リミ契 /i-mode
		01 01 45	# Terminal-Type   : FOMA外 / Dual / pad / pad / pad / U着 / PoC / 拡U着
		02 05 1234561212# IMEISV
		03 10 2001 0056 0000 0001 0000 0000 0000 0000	# IPv6 Prefix #[POS_DOCOMO_CONTAINER_IPV6PREFIX]
		05 03 2300f0	# CA-Code
		06 01 0a	# Subscribed-Carrier-Name
		09 01 06	# RAT-Type : 6:E-UTRAN, 1:UTRAN
		0000 # DIAMETER Padding
}






#==================================================================================
#================================#
#   No Charging-Rule-Base-Name   #
#================================#
#pdu CCA_INIT_MOPERA { 
#	01                                   # Version: 1
#	000274                               # Message Length: 658
#	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
#	000110                               # Command-Code: 272(Credit-Control-Answer)
#	01000016                             # Application-ID: 16777238(unknown)
#	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
#	00000000                             # End-to-End Identifier: 0x00000000(0)
#	
#	### Session-Id
#	00000107
#	40
#	00004b
#		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
#		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
#		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
#	
#	### Auth-Application-Id
#	00000102 40 00000c 01000016
#	
#	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
#	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770	706e6574 776f726b 2e6f7267
#	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72	67000000
#	
#	### CC-Request-Type & CC-Request-Number
#	000001a0 40 00000c  00000001
#	0000019f 40 00000c  00000000
#	
#	### Result-Code
#	0000010c 40 00000c  000007d1    #   2001(DIAMETER_SUCCESS)
#	
#	### Supported-Features
#	00000274 C0 000038 000028AF
#		0000010A 40 00000C  000028AF		### Vendor-Id
#		00000275 80 000010 000028AF  00000001	### Feature-List-ID
#		00000276 80 000010 000028AF  00000001	### Feature-List
#	
#	### Bearer-Control-Mode
#	000003FF C0 000010 000028AF  00000002	#   2(UE_NW)
#	
#	### Event-Trigger
#	#000003EE C0 000010 000028AF
#	#	00000011	# Revalidation-Time
#	
#	### Event-Trigger
#	#000003EE C0 000010 000028AF
#	#	00000032	# Volume-Threashold
#	
#	### QoS-Information
#	000003f8 c0 000058 000028af
#		00000404 c0 000010 000028af  00000009	### QCI
#		00000411 c0 000010 000028af  FFFFFED8	### AMBR UL
#		00000410 c0 000010 000028af  FFFFFED8	### AMBR DL
#		0000040A C0 00001C 000028AF		### ARP
#			00000416 C0 000010 000028AF  0000000f	### Priority-Level
#	
#	### Revalidation-Time
#	#00000412 C0 000010 000028AF
#	#	CFBD0000
#	
#	### Subscribed-Carrier-Name
#	00001300 C0 00000D 00000580
#		0a000000
#	
#	### User-Equipment-Info
#	000001ca 00 00002c
#		000001cb 00 00000c  00000000		### User-Equipment-Info-Type  0(IMEISV)
#		000001cc 00 000018  31313131 31313131	### User-Equipment-Info-Value
#				    31313131 31313131
#	
#	### CA-Code
#	00001309 C0 00000F 00000580  2300f000
#	
#	### MSISDN
#	000002BD C0 000012 000028AF  18088117 10740000
#	
#	### Charging-Target-Flag
#	00001310 C0 000010 00000580  00000000	#   Value : 0(課金対象表示:OFF)
#	
#	### Dedicated-Line-Service-Flag
#	00001311 C0 000010 00000580  00000002	#  bit1:mopera  / bit0:閉域
#	
#	### Authentication-Protocol
#	00001315 C0 000010 00000580  00000002	# 0:ZERO, 1:CHAP, 2:PAP, 3:NONE
#	
#	### APN-Profile
#	00001316 C0 000044 00000580
#		### UserID-Authentication
#		00001317 C0 000010 00000580
#			00000001	# 1(USE) / 0(Not USE)
#		### UserID-Authentication-Password
#		00001318 C0 000017 00000580
#			41736365 6e642d43 4c494400
#		### ID-Notification
#		00001319 C0 000010 00000580
#			00000001
#	
#	### Preservation-Allowed-Time
#	0000131D C0 000010 00000580
#		00000000		#[POS_PRESERVATION_ALLOWED_TIME]
#	
#	### Volume-Threashold
#	#00001313 C0 000010 00000580
#	#	00000400
#}




#==================================================================================
pdu CCA_INIT_MOPERA {
	01                                   # Version: 1
	000318                               # Message Length: 792
	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000110                               # Command-Code: 272(Credit-Control-Answer)
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770	706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72	67000000
	
	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000001
	0000019f 40 00000c  00000000
	
	### Result-Code
	0000010c 40 00000c  000007d1    #   2001(DIAMETER_SUCCESS)
	
	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List
	
	### Bearer-Control-Mode
	000003FF C0 000010 000028AF  00000002	#   2(UE_NW)
	
	### Event-Trigger
	#000003EE C0 000010 000028AF
	#	00000011	# Revalidation-Time
	
	### Event-Trigger
	#000003EE C0 000010 000028AF
	#	00000032	# Volume-Threashold
	
	### Charging-Rule-Install
        000003E9 C0 0000A4 000028AF
		000003EC C0 000032 000028AF	# Charging-Rule-Base-Name
			# Charge-Free-For-Mail-Service-in-Mopera
			4368617267652d467265652d466f722d4d61696c2d536572766963652d696e2d
				4d6f70657261 0000	#[POS_BASE_NAME]
		000003EC C0 000034 000028AF	# Charging-Rule-Base-Name
			# Charge-Free-For-Packet-Service-in-Mopera
			4368617267652d467265652d466f722d5061636b65742d536572766963652d696e2d4d6f70657261
		000003EC C0 00002D 000028AF	# Charging-Rule-Base-Name
			# Default-Charge-For-Packet-Service
			44656661756c742d4368617267652d466f722d5061636b65742d53657276696365 000000

	### QoS-Information
	000003f8 c0 000058 000028af
		00000404 c0 000010 000028af  00000009	### QCI
		00000411 c0 000010 000028af  FFFFFED8	### AMBR UL
		00000410 c0 000010 000028af  FFFFFED8	### AMBR DL
		0000040A C0 00001C 000028AF		### ARP
			00000416 C0 000010 000028AF  0000000f	### Priority-Level
	
	### Revalidation-Time
	#00000412 C0 000010 000028AF
	#	CFBD0000
	
	### Subscribed-Carrier-Name
	00001300 C0 00000D 00000580
		0a000000
	
	### User-Equipment-Info
	000001ca 00 00002c
		000001cb 00 00000c  00000000		### User-Equipment-Info-Type  0(IMEISV)
		000001cc 00 000018  31313131 31313131	### User-Equipment-Info-Value
				    31313131 31313131
	
	### CA-Code
	00001309 C0 00000F 00000580  2300f000
	
	### MSISDN
	000002BD C0 000012 000028AF  18088117 10740000
	
	### Charging-Target-Flag
	00001310 C0 000010 00000580  00000000	#   Value : 0(課金対象表示:OFF)
	
	### Dedicated-Line-Service-Flag
	00001311 C0 000010 00000580  00000002	#  bit1:mopera  / bit0:閉域
	
	### Authentication-Protocol
	00001315 C0 000010 00000580  000000
	02      #[POS_AUTH_PROT]                # 0:ZERO, 1:CHAP, 2:PAP, 3:NONE
	
	### APN-Profile
	00001316 C0 000044 00000580
		### UserID-Authentication
		00001317 C0 000010 00000580
			00000001	# 1(USE) / 0(Not USE)
		### UserID-Authentication-Password
		00001318 C0 000017 00000580
			41736365 6e642d43 4c494400
		### ID-Notification
		00001319 C0 000010 00000580
			00000001
	
	### Preservation-Allowed-Time
	0000131D C0 000010 00000580
		00000000		#[POS_PRESERVATION_ALLOWED_TIME]
	
	### Volume-Threashold
	#00001313 C0 000010 00000580
	#	00000400
}




#==================================================================================
pdu CCA_INIT_MOPERA_TEIGAKU {
	01                                   # Version: 1
	0002b4                               # Message Length: 658
	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000110                               # Command-Code: 272(Credit-Control-Answer)
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770	706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72	67000000
	
	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000001
	0000019f 40 00000c  00000000
	
	### Result-Code
	0000010c 40 00000c  000007d1    #   2001(DIAMETER_SUCCESS)
	
	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List
	
	### Bearer-Control-Mode
	000003FF C0 000010 000028AF  00000002	#   2(UE_NW)
	
	### Event-Trigger
	000003EE C0 000010 000028AF
		00000011	# Revalidation-Time
	
	### Event-Trigger
	000003EE C0 000010 000028AF
		00000032	# Volume-Threashold
	
	### QoS-Information
	000003f8 c0 000058 000028af
		00000404 c0 000010 000028af		### QCI
			00000009				#[POS_QCI]
		00000411 c0 000010 000028af  FFFFFED8	### AMBR UL
		00000410 c0 000010 000028af  FFFFFED8	### AMBR DL
		0000040A C0 00001C 000028AF		### ARP
			00000416 C0 000010 000028AF  0000000f	### Priority-Level
	
	### Revalidation-Time
	00000412 C0 000010 000028AF
		ffffffff	# Revalidation-Time
	
	### Subscribed-Carrier-Name
	00001300 C0 00000D 00000580
		0a000000
	
	### User-Equipment-Info
	000001ca 00 00002c
		000001cb 00 00000c  00000000		### User-Equipment-Info-Type  0(IMEISV)
		000001cc 00 000018  31313131 31313131	### User-Equipment-Info-Value
				    31313131 31313131
	
	### CA-Code
	00001309 C0 00000F 00000580  2300f000
	
	### MSISDN
	000002BD C0 000012 000028AF  18088117 10740000
	
	### Charging-Target-Flag
	00001310 C0 000010 00000580  00000000	#   Value : 0(課金対象表示:OFF)
	
	### Dedicated-Line-Service-Flag
	00001311 C0 000010 00000580  00000002	#  bit1:mopera  / bit0:閉域
	
	### Authentication-Protocol
	00001315 C0 000010 00000580  00000002	# 0:ZERO, 1:CHAP, 2:PAP, 3:NONE
	
	### APN-Profile
	00001316 C0 000044 00000580
		### UserID-Authentication
		00001317 C0 000010 00000580
			00000001	# 1(USE) / 0(Not USE)
		### UserID-Authentication-Password
		00001318 C0 000017 00000580
			41736365 6e642d43 4c494400
		### ID-Notification
		00001319 C0 000010 00000580
			00000001
	
	### Preservation-Allowed-Time
	0000131D C0 000010 00000580 
		00000000		#[POS_PRESERVATION_ALLOWED_TIME]
	
	### Volume-Threashold
	00001313 C0 000010 00000580
		00100000	# Volume-Threashold
}





#==================================================================================
#### 
#### 「Offline」が載ること以外はMOPERAと同じ。直接はいじらない
#### 
pdu CCA_INIT_MOPERA_ZANTEI {
	01                                   # Version: 1
	000284                               # Message Length: 658
	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000110                               # Command-Code: 272(Credit-Control-Answer)
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770	706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72	67000000
	
	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000001
	0000019f 40 00000c  00000000
	
	### Result-Code
	0000010c 40 00000c  000007d1    #   2001(DIAMETER_SUCCESS)
	
	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List
	
	### Bearer-Control-Mode
	000003FF C0 000010 000028AF  00000002	#   2(UE_NW)
	
	### Event-Trigger
	#000003EE C0 000010 000028AF
	#	00000011	# Revalidation-Time
	
	### Event-Trigger
	#000003EE C0 000010 000028AF
	#	00000032	# Volume-Threashold
	
	### OFFLINE
	# ★i-modeはEPC非課金
	000003F0 c0 000010 000028af  00000000	# 0:DISABLE_OFFLINE
	
	### QoS-Information
	000003f8 c0 000058 000028af
		00000404 c0 000010 000028af  00000009	### QCI
		00000411 c0 000010 000028af  FFFFFED8	### AMBR UL
		00000410 c0 000010 000028af  FFFFFED8	### AMBR DL
		0000040A C0 00001C 000028AF		### ARP
			00000416 C0 000010 000028AF  0000000f	### Priority-Level
	
	### Revalidation-Time
	#00000412 C0 000010 000028AF
	#	CFBD0000
	
	### Subscribed-Carrier-Name
	00001300 C0 00000D 00000580
		0a000000
	
	### User-Equipment-Info
	000001ca 00 00002c
		000001cb 00 00000c  00000000		### User-Equipment-Info-Type  0(IMEISV)
		000001cc 00 000018  31313131 31313131	### User-Equipment-Info-Value
				    31313131 31313131
	
	### CA-Code
	00001309 C0 00000F 00000580  2300f000
	
	### MSISDN
	000002BD C0 000012 000028AF  18088117 10740000
	
	### Charging-Target-Flag
	00001310 C0 000010 00000580  00000000	#   Value : 0(課金対象表示:OFF)
	
	### Dedicated-Line-Service-Flag
	00001311 C0 000010 00000580  00000002	#  bit1:mopera  / bit0:閉域
	
	### Authentication-Protocol
	00001315 C0 000010 00000580  00000002	# 0:ZERO, 1:CHAP, 2:PAP, 3:NONE
	
	### APN-Profile
	00001316 C0 000044 00000580
		### UserID-Authentication
		00001317 C0 000010 00000580
			00000001	# 1(USE) / 0(Not USE)
		### UserID-Authentication-Password
		00001318 C0 000017 00000580
			41736365 6e642d43 4c494400
		### ID-Notification
		00001319 C0 000010 00000580
			00000001
	
	### Preservation-Allowed-Time
	0000131D C0 000010 00000580 
		00000000		#[POS_PRESERVATION_ALLOWED_TIME]
	
	### Volume-Threashold
	#00001313 C0 000010 00000580
	#	00000400
}




#==================================================================================
pdu CCA_INIT_DCM_WCS {
	01                                   # Version: 1
	00024c                               # Message Length: 612
	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000110                               # Command-Code: 272(Credit-Control-Answer)
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770	706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72	67000000
	
	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000001
	0000019f 40 00000c  00000000
	
	### Result-Code
	0000010c 40 00000c  000007d1    #   2001(DIAMETER_SUCCESS)
	
	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List
	
	### Bearer-Control-Mode
	000003FF C0 000010 000028AF  00000002	#   2(UE_NW)
	
	### Event-Trigger
	#000003EE C0 000010 000028AF
	#	00000011	# Revalidation-Time
	
	### Event-Trigger
	#000003EE C0 000010 000028AF
	#	00000032	# Volume-Threashold
	
	### QoS-Information
	000003f8 c0 000058 000028af
		00000404 c0 000010 000028af  00000009	### QCI
		00000411 c0 000010 000028af  FFFFFED8	### AMBR UL
		00000410 c0 000010 000028af  FFFFFED8	### AMBR DL
		0000040A C0 00001C 000028AF		### ARP
			00000416 C0 000010 000028AF  0000000f	### Priority-Level
	
	### Revalidation-Time
	#00000412 C0 000010 000028AF
	#	CFBD0000
	
	### Subscribed-Carrier-Name
	00001300 C0 00000D 00000580
		0a000000
	
	### User-Equipment-Info
	000001ca 00 00002c
		000001cb 00 00000c  00000000		### User-Equipment-Info-Type  0(IMEISV)
		000001cc 00 000018  31313131 31313131	### User-Equipment-Info-Value
				    31313131 31313131
	
	### CA-Code
	00001309 C0 00000F 00000580  2300f000
	
	### MSISDN
	000002BD C0 000012 000028AF  18088117 10740000
	
	### Charging-Target-Flag
	00001310 C0 000010 00000580  00000000	#   Value : 0(課金対象表示:OFF)
	
	### Dedicated-Line-Service-Flag
	#00001311 C0 000010 00000580  00000002	#  bit1:mopera  / bit0:閉域
	
	### Authentication-Protocol
	00001315 C0 000010 00000580  000000
	02      #[POS_AUTH_PROT]                # 0:ZERO, 1:CHAP, 2:PAP, 3:NONE
	
	### APN-Profile
	00001316 C0 00002c 00000580
		### UserID-Authentication
		00001317 C0 000010 00000580
			00000000	# 1(USE) / 0(Not USE)
		### UserID-Authentication-Password
		#00001318 C0 000017 00000580
		#	41736365 6e642d43 4c49
		#	44			#[POS_USERID_AIUTH_PASS]
		#	00
		### ID-Notification
		00001319 C0 000010 00000580
			000000
			01			#[POS_ID_NOTIFICATION]
	
	### Preservation-Allowed-Time
	0000131D C0 000010 00000580
		00000000		#[POS_PRESERVATION_ALLOWED_TIME]
	
	### Volume-Threashold
	#00001313 C0 000010 00000580
	#	00000400
}

#==================================================================================
pdu CCA_INIT_DCM_WCS_LIMIT {
	01                                   # Version: 1
	0002D0                               # Message Length: 720
	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000110                               # Command-Code: 272(Credit-Control-Answer)
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770	706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72	67000000
	
	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000001
	0000019f 40 00000c  00000000
	
	### Result-Code
	0000010c 40 00000c  000007d1    #   2001(DIAMETER_SUCCESS)
	
	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List
	
	### Bearer-Control-Mode
	000003FF C0 000010 000028AF  00000002	#   2(UE_NW)
	
	### Event-Trigger
	#000003EE C0 000010 000028AF
	#	00000011	# Revalidation-Time
	
	### Event-Trigger
	#000003EE C0 000010 000028AF
	#	00000032	# Volume-Threashold
	
	### Charging-Rule-Install
        000003E9 C0 00006C 000028AF
		000003EC C0 000034 000028AF	# Charging-Rule-Base-Name
			# Charge-Free-For-Packet-Service-in-Spmode
			4368617267652d467265652d466f722d5061636b65742d536572766963652d696e2d
				53706d6f6465	#[POS_BASE_NAME_1]
                000003EC C0 00002B 000028AF     # Charging-Rule-Base-Name
			# Default-Drop-For-Packet-Service
                        44656661756c742d44726f702d466f722d5061636b65742d53657276696365 00

	### QoS-Information
	000003f8 c0 000058 000028af
		00000404 c0 000010 000028af  00000009	### QCI
		00000411 c0 000010 000028af  FFFFFED8	### AMBR UL
		00000410 c0 000010 000028af  FFFFFED8	### AMBR DL
		0000040A C0 00001C 000028AF		### ARP
			00000416 C0 000010 000028AF  0000000f	### Priority-Level
	
	### Revalidation-Time
	#00000412 C0 000010 000028AF
	#	CFBD0000
	
	### Subscribed-Carrier-Name
	00001300 C0 00000D 00000580
		0a000000
	
	### User-Equipment-Info
	000001ca 00 00002c
		000001cb 00 00000c  00000000		### User-Equipment-Info-Type  0(IMEISV)
		000001cc 00 000018  31313131 31313131	### User-Equipment-Info-Value
				    31313131 31313131
	
	### CA-Code
	00001309 C0 00000F 00000580  2300f000
	
	### MSISDN
	000002BD C0 000012 000028AF  18088117 10740000
	
	### Charging-Target-Flag
	00001310 C0 000010 00000580  00000000	#   Value : 0(課金対象表示:OFF)
	
	### Dedicated-Line-Service-Flag
	#00001311 C0 000010 00000580  00000002	#  bit1:mopera  / bit0:閉域
	
	### Authentication-Protocol
	00001315 C0 000010 00000580  00000002	# 0:ZERO, 1:CHAP, 2:PAP, 3:NONE
	
	### APN-Profile
	00001316 C0 000044 00000580
		### UserID-Authentication
		00001317 C0 000010 00000580
			00000001	# 1(USE) / 0(Not USE)
		### UserID-Authentication-Password
		00001318 C0 000017 00000580
			41736365 6e642d43 4c494400
		### ID-Notification
		00001319 C0 000010 00000580
			00000001
	
	### Preservation-Allowed-Time
	0000131D C0 000010 00000580
		00000000		#[POS_PRESERVATION_ALLOWED_TIME]
	
	### Volume-Threashold
	#00001313 C0 000010 00000580
	#	00000400
}





#==================================================================================
#### 
#### P-GW側ではMVNOのPCRFアクセスはされないためダミー
#### 
pdu CCA_INIT_MVNO {
	01 000248 40 000110 01000016 00000000 00000000 
	00000107 40 000020  6e61732e 6d6e6f2e 6e65743b 31323334	35363738 39303b30
	00000102 40 00000c  01000016
	00000108 40 000034
		70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029
		6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67000000
	000001a0 40 00000c  00000001
	0000019f 40 00000c  00000000
	#[POS_QCI]
}




#==================================================================================
pdu CCA_INIT_NG {
	01 
	000104			#  Length
	40000110		# Flag / Command-Code: 272(Credit-Control-Answer)
	01000016 		# Application-ID: 16777266(unknown)
	00000000		# Hop-by-Hop Identifier: 0x00000000(0)
	00000000		# End-to-End Identifier: 0x00000000(0)

	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBE 00

	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67 000000

	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000001
	0000019f 40 00000c  00000000

	### Experimental-Result
	00000129 40 000020 
		0000010a 40 00000c  000028af	### Vendor-Id
		0000012a 40 00000c  00001417	### Experimental-Result-Code (BEARER_NOT_AUTH)
}





#==================================================================================
pdu CCA_UPDATE_IMODE_CONTAINER_DETECTION {
	01                                   # Version: 1
	000158                               # Message Length
	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000110                               # Command-Code: 272(Credit-Control-Answer)
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)

	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00


	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770	706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72	67000000
	
	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000002
	0000019f 40 00000c  00000000
	
	### Result-Code
	0000010c 40 00000c  000007d1    #   2001(DIAMETER_SUCCESS)

	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List
	
	### Bearer-Control-Mode
	000003FF C0 000010 000028AF  00000002	#   2(UE_NW)
	
	### PCO
	0000130B C0 000020 
		00000580
		80
		0003 10 # DNSv6 Address
			20010002000000000000000000000001 #[POS_PCO_DNSV6ADDRESS]
}




#==================================================================================
pdu CCA_UPDATE_MOPERA_IP_ADDRESS_ALLOCATION{
	01                                   # Version: 1
	000158                               # Message Length
	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000110                               # Command-Code: 272(Credit-Control-Answer)
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)

	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00

	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770	706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72	67000000
	
	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000002
	0000019f 40 00000c  00000000
	
	### Result-Code
	0000010c 40 00000c  000007d1    #   2001(DIAMETER_SUCCESS)

	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List
	
	### Bearer-Control-Mode
	000003FF C0 000010 000028AF  00000002	#   2(UE_NW)

	### PCO
	0000130B C0 000020 
		00000580
		80
		8021 10 03 00 0010
			03 06 c0a8e381
			81 06 c0a80001
#			83 06 c0a80002

}


#==================================================================================
pdu CCA_UPDATE_RAT_CHANGE {
	01 000248 40 000110 01000016 00000000 00000000 
	00000107 40 000020  6e61732e 6d6e6f2e 6e65743b 31323334	35363738 39303b30
	00000102 40 00000c  01000016
	00000108 40 000034
		70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029
		6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67000000
	000001a0 40 00000c  00000001
	0000019f 40 00000c  00000000

}



#==================================================================================
pdu CCA_UPDATE_SCHEDULING {
	01                                   # Version: 1
	000154                               # Message Length: 658
	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000110                               # Command-Code: 272(Credit-Control-Answer)
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67 000000
	
	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000002
	0000019f 40 00000c  00000000

	### Result-Code
	0000010c 40 00000c  000007d1    #   2001(DIAMETER_SUCCESS)

	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List

	### QoS-Information
	000003f8 c0 00001c 000028af
		00000404 c0 000010 000028af		### QCI
			00000063

	### Volume-Threashold
	00001313 C0 000010 00000580
		00200000
}





#==================================================================================
pdu CCA_UPDATE_NG {
	01                                   # Version: 1
	00013c                               # Message Length: 658
	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000110                               # Command-Code: 272(Credit-Control-Answer)
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67 000000
	
	### Experimental-Result
	00000129 40 000020 
		0000010a 40 00000c  000028af	### Vendor-Id
		0000012a 40 00000c  00001417	### Experimental-Result-Code (BEARER_NOT_AUTORIZED)
	
	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000002
	0000019f 40 00000c  00000000

	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List
}




#==================================================================================
pdu CCA_UPDATE_NG_RESULT_CODE {
	01                                   # Version: 1
	000128                               # Message Length: 296
	40                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000110                               # Command-Code: 272(Credit-Control-Answer)
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67 000000
	
	### Result-Code
	0000010C 40 00000c  0000138B	### DIAMETER_AUTHORIZATION_REJECTED
	
	### Experimental-Result
#	00000129 40 000020 
#		0000010a 40 00000c  000028af	### Vendor-Id
#		0000012a 40 00000c  00001416	### Experimental-Result-Code (PCC_RULE_EVENT)
	
	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000002
	0000019f 40 00000c  00000000

	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List
}




#==================================================================================
pdu RAR_RATCHANGE {
	01                                   # Version: 1
	000180                               # Message Length: 658
	c0                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000102                               # Command-Code: Re-Auth Request
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67 000000
	
	### Destination-Realm & Destination-Host ("s-gw1.node.epc.mnc010.mcc440.3gppnetwork.org")
	0000011b 40 000029  6570632e 6d6e6330 31302e6d 63633434 302e3367 70706e65 74776f72 6b2e6f72 67000000
	00000125 40 000034  702d6777 312e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	
	### Re-Auth-Request-Type
	0000011d 40 00000c  00000000

	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List

	### Preservation-Allowed-Time
	#0000131D C0 000010 00000580  00000000

	### DOCOMO-Container
	00001323 80 000021 00000580
		03 10 
			2001 004e 0000 0001 0000 0000 0000 0000
		09 01 
			06	# RAT-Type : 6:E-UTRAN, 1:UTRAN		#[POS_DOCOMO_CONTAINER_RATTYPE]
		000000 # DIAMETER Padding

}



#==================================================================================
pdu RAR_QOSCHANGE {
	01                                   # Version: 1
	00018c                               # Message Length: 658
	c0                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000102                               # Command-Code: Re-Auth Request
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67 000000
	
	### Destination-Realm & Destination-Host ("s-gw1.node.epc.mnc010.mcc440.3gppnetwork.org")
	0000011b 40 000029  6570632e 6d6e6330 31302e6d 63633434 302e3367 70706e65 74776f72 6b2e6f72 67000000
	00000125 40 000034  702d6777 312e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	
	### Re-Auth-Request-Type
	0000011d 40 00000c  00000000

	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List

	### QoS-Information
	000003f8 c0 00001c 000028af
		00000404 c0 000010 000028af		### QCI
			00000063				#[POS_QCI]
}



#==================================================================================
pdu RAR_PRESERVATION_ALLOWED_TIME {
	01                                   # Version: 1
	00017f                               # Message Length: 658
	c0                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000102                               # Command-Code: Re-Auth Request
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67 000000
	
	### Destination-Realm & Destination-Host ("s-gw1.node.epc.mnc010.mcc440.3gppnetwork.org")
	0000011b 40 000029  6570632e 6d6e6330 31302e6d 63633434 302e3367 70706e65 74776f72 6b2e6f72 67000000
	00000125 40 000034  702d6777 312e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	
	### Re-Auth-Request-Type
	0000011d 40 00000c  00000000

	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List

	### Preservation-Allowed-Time
	0000131D C0 000010 00000580 
		00000000				#[POS_PRESERVATION_ALLOWED_TIME]
}




#==================================================================================
pdu RAR_SESSION_REL {
	01                                   # Version: 1
	000180                               # Message Length: 384
	c0                                   # Command Flag: Request=0, Proxiable=1, Error=0, reTransmit=0
	000102                               # Command-Code: Re-Auth Request
	01000016                             # Application-ID: 16777238(unknown)
	00000000                             # Hop-by-Hop Identifier: 0x00000000(0)
	00000000                             # End-to-End Identifier: 0x00000000(0)
	
	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBE 00
	
	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67 000000
	
	### Destination-Realm & Destination-Host ("s-gw1.node.epc.mnc010.mcc440.3gppnetwork.org")
	0000011b 40 000029  6570632e 6d6e6330 31302e6d 63633434 302e3367 70706e65 74776f72 6b2e6f72 67000000
	00000125 40 000034  702d6777 312e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	
	### Re-Auth-Request-Type
	0000011d 40 00000c  00000000

	### Supported-Features
	00000274 C0 000038 000028AF
		0000010A 40 00000C  000028AF		### Vendor-Id
		00000275 80 000010 000028AF  00000001	### Feature-List-ID
		00000276 80 000010 000028AF  00000001	### Feature-List

	### Session-Release-Cause
	00000415 C0 000010 000028AF
		00000001		#[POS_SESSION_REL_CAUSE]

}



#==================================================================================
pdu CCA_TERM {
	01 
	0000f0			#  Length
	40000110		# Flag / Command-Code: 272(Credit-Control-Answer)
	01000016 		# Application-ID: 16777266(unknown)
	00000000		# Hop-by-Hop Identifier: 0x00000000(0)
	00000000		# End-to-End Identifier: 0x00000000(0)

	### Session-Id
	00000107
	40
	00004b
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF DEADBEAF 
		DEADBE 00

	### Auth-Application-Id
	00000102 40 00000c 01000016
	
	### Origin-Host & Origin-Realm ("pcrf0.node.epc.mnc010.mcc440.3gppnetwork.org")
	00000108 40 000034  70637266 302e6e6f 64652e65 70632e6d 6e633031 302e6d63 63343430 2e336770 706e6574 776f726b 2e6f7267
	00000128 40 000029  6570632E 6D6E6330 31302E6D 63633434 302E3367 70706E65 74776F72 6B2E6F72 67 000000

	### CC-Request-Type & CC-Request-Number
	000001a0 40 00000c  00000003
	0000019f 40 00000c  00000000

	### Result-Code
	0000010c 40 00000c  000007d1    #   2001(DIAMETER_SUCCESS)
}




