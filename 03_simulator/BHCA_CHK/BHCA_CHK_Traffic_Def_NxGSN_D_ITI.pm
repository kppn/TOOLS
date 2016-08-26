
package BHCA_CHK_Traffic_Def_NxGSN_D_ITI;

our @Procedure : shared;

@Procedure = (
      #Num  #Name                           #ScenarioName                          #100BHAC  #Chk_TrafficName    #Chk_OK_Traffic           #tmp  #tmp  #tmp
         1 ,"000_AtDt_intra                 "  ,"000_AtDt_intra_RNC"                  ,   11614 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,   2 ,"001_AtDt_inter                 "  ,"001_AtDt_inter_RNC"                  ,   21569 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,   3 ,"010_RAU_intra                  "  ,"010_RAU_intra_RNC"                   ,  766542 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   4 ,"011_RAU_inter_inter            "  ,"011_RAU_inter_inter_RNC_CHOAN"       ,  596707 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   5 ,"012_RAU_inter_intra            "  ,"012_RAU_inter_intra_RNC_CHOAN"       ,  596707 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   6 ,"014_RAU_inter_PDP              "  ,"014_RAU_inter_spmode_RNC"            ,  230164 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   7 ,"015_RAU_inter_spmode_SG_SND    "  ,"015_RAU_inter_spmode_SG_SGSN_send"    ,  557937 ,"ATTEMPT_U_P_C_REQUEST"                 ,"RCV_U_P_C_RESPONSE"           ,  1 ,  "" , "" , ""
     ,   8 ,"015_RAU_inter_spmode_SG_RCV    "  ,"015_RAU_inter_spmode_SG_SGSN_recieve" ,      -1 ,"SND_U_P_C_REQUEST"                     ,"RCV_U_P_C_RESPONSE"           ,  1 ,  "" , "" , ""

     ,   9 ,"022_Active_spmode              "  ,"022_Active_spmode_RNC"               ,   21332 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  10 ,"024_Active_spmode_SG_SGSN      "  ,"024_Active_spmode_SG_SGSN"           ,  328667 ,"ATTEMPT_C_P_C_REQUEST"                  ,"RCV_C_P_C_RESPONSE"           ,  1 ,  "" , "" , ""

     ,  11 ,"026_Active_imode_GG            "  ,"026_Active_imode_GG_RNC"             ,  134205 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  12 ,"027_Active_mopera_GG           "  ,"027_Active_mopera_GG_RNC"            ,    1761 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  13 ,"035_Term_imode_GG              "  ,"035_Term_imode_GG_GGSN"              ,   88391 ,"ATTEMPT_PDU_NOTIFICATION_REQ"           ,"SND_C_P_C_RESPONSE"           ,  1 ,  "" , "" , ""

     ,  14 ,"036_Term_mopera_GG             "  ,"036_Term_mopera_GG_GGSN"             ,    1160 ,"ATTEMPT_PDU_NOTIFICATION_REQ"           ,"SND_C_P_C_RESPONSE"           ,  1 ,  "" , "" , ""

     ,  15 ,"042_Relocation_intra_spmode_REC"  ,"042_Relocation_intra_spmode_RNC_rec"  ,  180033 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""
     ,  16 ,"042_Relocation_intra_spmode_SND"  ,"042_Relocation_intra_spmode_RNC_send" ,  180033 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""

     ,  17 ,"043_Relocation_inter_spmode_IN "  ,"043_Relocation_inter_spmode_RNC"      ,   40007 ,"RCV_RELOCATION_REQUEST"                 ,"SND_RELOCATION_COMPLETE"      ,  1 ,  "" , "" , ""
     ,  18 ,"043_Relocation_inter_spmode_OUT"  ,"043_Relocation_inter_spmode_SGSN"     ,      -1 ,"RCV_FORWARD_RELOCATION_REQUEST"         ,"RCV_FORWARD_RELOCATION_COMPLETE_ACKNOWLEDGE"       ,  1 ,  "" , "" , ""

     ,  19 ,"044_Relocation_inter_spmod_SG_S"  ,"044_Relocation_inter_spmode_SG_SGSN_send"    ,   60388 ,"ATTEMPT_U_P_C_REQUEST"     ,"RCV_U_P_C_RESPONSE"           ,  1 ,  "" , "" , ""
     ,  20 ,"044_Relocation_inter_spmod_SG_R"  ,"044_Relocation_inter_spmode_SG_SGSN_recieve" ,      -1 ,"SND_U_P_C_REQUEST"         ,"RCV_U_P_C_RESPONSE"           ,  1 ,  "" , "" , ""

     ,  21 ,"050_Preservation_UE            "  ,"050_Preservation_UE_RNC"             ,  158009 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  22 ,"050_Preservation_UE_1          "  ,"050_Preservation_UE_RNC_1"           ,  158009 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  23 ,"050_Preservation_UE_2          "  ,"050_Preservation_UE_RNC_2"           ,  158009 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  24 ,"050_Preservation_UE_3          "  ,"050_Preservation_UE_RNC_3"           ,  158009 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  25 ,"052_Preservation_UP            "  ,"052_Preservation_UP_RNC"             ,      -1 ,"RCV_PAGING"                             ,"RCV_IU_RELEASE_COMMAND"       ,  1 ,  "" , "" , ""

     ,  26 ,"055_Preservation_UE_SG         "  ,"055_Preservation_UE_SG_SGSN"         , 1431314 ,"SND_CONNECTION_STATUS_RECOVER"          ,"SND_CONNECTION_STATUS"        ,  1 ,  "" , "" , ""

     ,  27 ,"056_Preservation_UP_SG         "  ,"056_Preservation_UP_SG_SGSN"         , 1081910 ,"SND_CONNECTION_STATUS"                  ,"RCV_ISC_SYNCHRO_3"            ,  1 ,  "" , "" , ""

     ,  28 ,"060_SMS-MO                     "  ,"060_SMS-MO_RNC"                      ,     557 ,"SND_SERVICE_REQUEST"                    ,"RCV_IU_RELEASE_COMMAND"       ,  1 ,  "" , "" , ""

     ,  29 ,"061_SMS-MT                     "  ,"061_SMS-MT_ASN"                      ,  237582 ,"ATTEMPT_MT_F_S_REQUEST"                 ,"RCV_MT_F_S_RESPONSE"          ,  1 ,  "" , "" , ""

     ,  30 ,"062_SMS-Push_GG                "  ,"062_SMS-Push_GG_NWMP"                ,   16700 ,"ATTEMPT_SMSINFO_IND"                    ,"RCV_SMSINFO_RSLT"             ,  1 ,  "" , "" , ""

     ,  31 ,"070_MTLR                       "  ,"070_MTLR_MSA"                        ,   39157 ,"ATTEMPT_LCS_SERVICE_REQ"                ,"RCV_LCS_SERVICE_RES"          ,  1 ,  "" , "" , ""

     ,  32 ,"072_MOLR                       "  ,"072_MOLR_ASN"                        ,    6767 ,"ATTEMPT_SLR"                            ,"RCV_SLR"                      ,  1 ,  "" , "" , ""

     ,  33 ,"073_02B_GG_ASN                 "  ,"073_02B_GG_ASN"                      ,   13823 ,"MAP_PSL"                                ,"RCV_ISC_SYNCHRO_5"            ,  1 ,  "" , "" , ""

     ,  34 ,"080_CS_term                    "  ,"COMMON_SIN_31"                       ,   31307 ,"SND_PAGING_REQ"                         ,"PAGING_RCV_at_RNC"            ,  1 ,  "" , "" , ""

     ,  35 ,"                               "  ,"dummy"                               ,      -1 ,"dummy"                                   ,"dummy"                       ,  1 ,  "" , "" , ""

     ,  36 ,"100_AtDt_intra_LTE             "  ,"100_AtDt_intra_LTE_RNC"              ,    1507 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,  37 ,"101_AtDt_inter_sg_LTE          "  ,"101_AtDt_inter_sg_LTE_RNC"           ,    1400 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,  38 ,"102_AtDt_inter_mm_LTE          "  ,"102_AtDt_inter_mm_LTE_RNC"           ,    1400 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,  39 ,"110_RAU_intra_LTE_RNC_send     "  ,"110_RAU_intra_LTE_RNC_send"          ,   49758 ,"ATTEMPT_RA_UPDATE_REQUEST"              ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""
     ,  40 ,"110_RAU_intra_LTE_RNC_receive  "  ,"110_RAU_intra_LTE_RNC_receive"       ,      -1 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,  41 ,"111_RAU_inter_sg_LTE           "  ,"111_RAU_inter_sg_LTE_RNC"            ,   92408 ,"ATTEMPT_RA_UPDATE_REQUEST"              ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,  40  ,"113_TAU                        "  ,"113_TAU_RNC"                        ,   56159 ,"SND_ISC_FORWARD_PTMSI_1_ptmsi_sig_toMME"   ,"RCV_ISC_SYNCHRO_10"        ,  1 ,  "" , "" , ""

     ,  42 ,"114_TAU_chgsg                  "  ,"114_TAU_chgsg_RNC"                   ,   46204 ,"SND_ISC_FORWARD_PTMSI_1_ptmsi_sig_toMME"   ,"RCV_ISC_SYNCHRO_10"        ,  1 ,  "" , "" , ""

     ,  43 ,"120_Active_spmode_LTE          "  ,"120_Active_spmode_LTE_RNC"           ,    2769 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  44 ,"121_Active_mopera_LTE          "  ,"121_Active_mopera_LTE_RNC"           ,     379 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  45 ,"140_Relocation_intra_REC       "  ,"140_Relocation_intra_RNC_receive"    ,    1928 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""
     ,  46 ,"140_Relocation_intra_SND       "  ,"140_Relocation_intra_RNC_send"       ,    1928 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""

     ,  47 ,"141_Relocation_inter_RNC       "  ,"141_Relocation_inter_RNC"            ,     214 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"SND_RELOCATION_COMPLETE"      ,  1 ,  "" , "" , ""

     ,  48 ,"142_HO                         "  ,"142_HO_RNC"                          ,     214 ,"RCV_ISC_FORWARD_PDPADDR_0"              ,"SND_RELOCATION_COMPLETE"      ,  1 ,  "" , "" , ""

     ,  49 ,"150_Preservation_UE            "  ,"150_Preservation_UE_RNC"             ,    8062 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  50 ,"151_Preservation_UP            "  ,"151_Preservation_UP_S-GW"            ,    5162 ,"ATTEMPT_D_D_N"                          ,"SND_R_A_B_RES"                ,  1 ,  "" , "" , ""

     ,  51 ,"161_SMS-MT_LTE                 "  ,"161_SMS-MT_LTE_MME"                  ,   19708 ,"SND_CS_PAGING"                          ,"PAGING_RCV_at_RNC"            ,  1 ,  "" , "" , ""

     ,  52 ,"180_CS_Active_ISRact           "  ,"180_CS_Active_ISRact_RNC"            ,   19910 ,"ATTEMPT_RA_UPDATE"                      ,"COMPLETE_RA_UPDATE"           ,  1 ,  "" , "" , ""

     ,  53 ,"181_CS_Term_ISRdeact           "  ,"181_CS_Term_ISRdeact_RNC"            ,   15644 ,"ATTEMPT_RA_UPDATE_REQUEST"              ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

  );


sub get_procedure
{
	return @Procedure;
}



