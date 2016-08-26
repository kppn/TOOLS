
package BHCA_CHK_Traffic_Def_NxGSN_D_CPU;

our @Procedure : shared;

@Procedure = (
      #Num  #Name                           #ScenarioName                          #100BHAC  #Chk_TrafficName    #Chk_OK_Traffic           #tmp  #tmp  #tmp
         1 ,"000_AtDt_intra                 "  ,"000_AtDt_intra_RNC"                  ,    5937 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,   2 ,"001_AtDt_inter                 "  ,"001_AtDt_inter_RNC"                  ,    9688 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,   3 ,"010_RAU_intra                  "  ,"010_RAU_intra_RNC"                   ,  244442 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   4 ,"011_RAU_inter_inter            "  ,"011_RAU_inter_inter_RNC_CHOAN"       ,   95573 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   5 ,"012_RAU_inter_intra            "  ,"012_RAU_inter_intra_RNC_CHOAN"       ,   95573 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   6 ,"013_RAU_inter_imode            "  ,"013_RAU_inter_imode_RNC"             ,  207680 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   7 ,"016_RAU_inter_imode_SG_send    "  ,"016_RAU_inter_imode_SG_SGSN_send"    ,   31787 ,"ATTEMPT_U_P_C_REQUEST"                  ,"RCV_U_P_C_RESPONSE"           ,  1 ,  "" , "" , ""
     ,   8 ,"016_RAU_inter_imode_SG_recieve "  ,"016_RAU_inter_imode_SG_SGSN_recieve" ,      -1 ,"SND_U_P_C_REQUEST"                      ,"RCV_U_P_C_RESPONSE"           ,  1 ,  "" , "" , ""

     ,   9 ,"020_Active_imode               "  ,"020_Active_imode_RNC"                ,   172360 ,"ATTEMPT_SERVICE_REQUEST"               ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  10 ,"021_Active_mopera              "  ,"021_Active_mopera_RNC"               ,     1467 ,"ATTEMPT_SERVICE_REQUEST"               ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  11 ,"023_Active_imode_SG            "  ,"023_Active_imode_SG_SGSN"            ,  701369 ,"ATTEMPT_C_P_C_REQUEST"                  ,"RCV_C_P_C_RESPONSE"           ,  1 ,  "" , "" , ""
     ,  12 ,"023_Active_imode_SG_1          "  ,"023_Active_imode_SG_SGSN_1"          ,  701369 ,"ATTEMPT_C_P_C_REQUEST"                  ,"RCV_C_P_C_RESPONSE"           ,  1 ,  "" , "" , ""

     ,  13 ,"025_Active_mopera_SG           "  ,"025_Active_mopera_SG_SGSN"           ,   15878 ,"ATTEMPT_C_P_C_REQUEST"                  ,"RCV_C_P_C_RESPONSE"           ,  1 ,  "" , "" , ""

     ,  14 ,"028_Active_spmode_GG           "  ,"028_Active_spmode_GG_RNC"            ,    9115 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  15 ,"030_Term_imode                 "  ,"030_Term_imode_NWMP"                 ,   55755 ,"ATTEMPT_TERMINATING_INFORMATION"        ,"SND_RELEASE_INFORMATION_RSP"  ,  1 ,  "" , "" , ""
     ,  16 ,"030_Term_imode_1               "  ,"030_Term_imode_NWMP_1"               ,   55755 ,"ATTEMPT_TERMINATING_INFORMATION"        ,"SND_RELEASE_INFORMATION_RSP"  ,  1 ,  "" , "" , ""

     ,  17 ,"032_Term_mopera                "  ,"032_Term_mopera_RNC"                 ,      -1 ,"SND_SERVICE_REQUEST"                    ,"RCV_A_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  18 ,"033_Term_imode_SG              "  ,"033_Term_imode_SG_NWMP"              ,  313950 ,"ATTEMPT_TERMINATING_INFORMATION"        ,"SND_RELEASE_INFORMATION_RSP"  ,  1 ,  "" , "" , ""
     ,  19 ,"033_Term_imode_SG_1            "  ,"033_Term_imode_SG_NWMP_1"            ,  313950 ,"ATTEMPT_TERMINATING_INFORMATION"        ,"SND_RELEASE_INFORMATION_RSP"  ,  1 ,  "" , "" , ""

     ,  20 ,"040_Relocation_intra_imode_rec "  ,"040_Relocation_intra_imode_RNC_rec"   , 160388 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""
     ,  21 ,"040_Relocation_intra_imode_send"  ,"040_Relocation_intra_imode_RNC_send"  , 160388 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""

     ,  22 ,"041_Relocation_inter_imode_IN  "  ,"041_Relocation_inter_imode_RNC"      ,   35641 ,"RCV_RELOCATION_REQUEST"                 ,"SND_RELOCATION_COMPLETE"      ,  1 ,  "" , "" , ""
     ,  23 ,"041_Relocation_inter_imode_OUT "  ,"041_Relocation_inter_imode_SGSN"     ,      -1 ,"RCV_FORWARD_RELOCATION_REQUEST"         ,"RCV_FORWARD_RELOCATION_COMPLETE_ACKNOWLEDGE"       ,  1 ,  "" , "" , ""

     ,  24 ,"045_Relocation_inter_imode_SG_S"  ,"045_Relocation_inter_imode_SG_SGSN_send"    ,   96852 ,"ATTEMPT_U_P_C_REQUEST"     ,"RCV_U_P_C_RESPONSE"           ,  1 ,  "" , "" , ""
     ,  25 ,"045_Relocation_inter_imode_SG_R"  ,"045_Relocation_inter_imode_SG_SGSN_recieve" ,      -1 ,"SND_U_P_C_REQUEST"         ,"RCV_U_P_C_RESPONSE"           ,  1 ,  "" , "" , ""

     ,  26 ,"051_Preservation_UE_GG         "  ,"051_Preservation_UE_GG_RNC"          ,  329085 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""
     ,  27 ,"051_Preservation_UE_GG_1       "  ,"051_Preservation_UE_GG_RNC_1"        ,  329085 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""
     ,  28 ,"051_Preservation_UE_GG_2       "  ,"051_Preservation_UE_GG_RNC_2"        ,  329085 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""
     ,  29 ,"051_Preservation_UE_GG_3       "  ,"051_Preservation_UE_GG_RNC_3"        ,  329085 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  30 ,"054_Preservation_UP_GGSN       "  ,"054_Preservation_UP_GGSN"            ,  948425 ,"SND_PING"                               ,"RCV_CONNECTION_STATUS"        ,  1 ,  "" , "" , ""
     ,  31 ,"054_Preservation_UP_RNC        "  ,"054_Preservation_UP_RNC"             ,      -1 ,"RCV_PAGING"                             ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  32 ,"060_SMS-MO                     "  ,"060_SMS-MO_RNC"                      ,    2913 ,"SND_SERVICE_REQUEST"                    ,"RCV_IU_RELEASE_COMMAND"       ,  1 ,  "" , "" , ""

     ,  33 ,"061_SMS-MT                     "  ,"061_SMS-MT_ASN"                      ,  286215 ,"ATTEMPT_MT_F_S_REQUEST"                 ,"RCV_MT_F_S_RESPONSE"          ,  1 ,  "" , "" , ""

     ,  34 ,"062_SMS-Push_GG                "  ,"062_SMS-Push_GG_NWMP"                ,   16700 ,"ATTEMPT_SMSINFO_IND"                    ,"RCV_SMSINFO_RSLT"             ,  1 ,  "" , "" , ""

     ,  35 ,"070_MTLR                       "  ,"070_MTLR_MSA"                        ,     599 ,"ATTEMPT_LCS_SERVICE_REQ"                ,"RCV_LCS_SERVICE_RES"          ,  1 ,  "" , "" , ""

     ,  36 ,"071_02B_LCS                    "  ,"071_02B_MSA"                         ,   38557 ,"ATTEMPT_LCS_SERVICE_REQ"                ,"RCV_LCS_SERVICE_RES"          ,  1 ,  "" , "" , ""

     ,  37 ,"072_MOLR                       "  ,"072_MOLR_ASN"                        ,    6767 ,"ATTEMPT_SLR"                            ,"RCV_SLR"                      ,  1 ,  "" , "" , ""

     ,  38 ,"080_CS_term                    "  ,"COMMON_SIN_31"                       ,   89410 ,"SND_PAGING_REQ"                         ,"PAGING_RCV_at_RNC"            ,  1 ,  "" , "" , ""

     ,  39 ,"                               "  ,"dummy"                               ,      -1 ,"dummy"                                   ,"dummy"                       ,  1 ,  "" , "" , ""

     ,  40 ,"100_AtDt_intra_LTE             "  ,"100_AtDt_intra_LTE_RNC"              ,    2366 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,  41 ,"101_AtDt_inter_sg_LTE          "  ,"101_AtDt_inter_sg_LTE_RNC"           ,    1930 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,  42 ,"102_AtDt_inter_mm_LTE          "  ,"102_AtDt_inter_mm_LTE_RNC"           ,    1930 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,  43 ,"110_RAU_intra_LTE_RNC_send     "  ,"110_RAU_intra_LTE_RNC_send"          ,   48706 ,"ATTEMPT_RA_UPDATE_REQUEST"              ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""
     ,  44 ,"110_RAU_intra_LTE_RNC_receive  "  ,"110_RAU_intra_LTE_RNC_receive"       ,      -1 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,  45 ,"111_RAU_inter_sg_LTE           "  ,"111_RAU_inter_sg_LTE_RNC"            ,   79467 ,"ATTEMPT_RA_UPDATE_REQUEST"              ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,  46 ,"113_TAU                        "  ,"113_TAU_RNC"                         ,   68173 ,"SND_ISC_FORWARD_PTMSI_1_ptmsi_sig_toMME"   ,"RCV_ISC_SYNCHRO_10"        ,  1 ,  "" , "" , ""

     ,  47 ,"114_TAU_chgsg                  "  ,"114_TAU_chgsg_RNC"                   ,   39734 ,"SND_ISC_FORWARD_PTMSI_1_ptmsi_sig_toMME"   ,"RCV_ISC_SYNCHRO_10"        ,  1 ,  "" , "" , ""

     ,  48 ,"120_Active_spmode_LTE          "  ,"120_Active_spmode_LTE_RNC"           ,    3632 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  49 ,"121_Active_mopera_LTE          "  ,"121_Active_mopera_LTE_RNC"           ,     963 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  50 ,"140_Relocation_intra_REC       "  ,"140_Relocation_intra_RNC_receive"    ,    2238 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""
     ,  51 ,"140_Relocation_intra_SND       "  ,"140_Relocation_intra_RNC_send"       ,    2238 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""

     ,  52 ,"141_Relocation_inter_RNC       "  ,"141_Relocation_inter_RNC"            ,     248 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"SND_RELOCATION_COMPLETE"      ,  1 ,  "" , "" , ""

     ,  53 ,"142_HO                         "  ,"142_HO_RNC"                          ,     262 ,"RCV_ISC_FORWARD_PDPADDR_0"              ,"SND_RELOCATION_COMPLETE"      ,  1 ,  "" , "" , ""

     ,  54 ,"150_Preservation_UE            "  ,"150_Preservation_UE_RNC"             ,   20478 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  55 ,"151_Preservation_UP            "  ,"151_Preservation_UP_S-GW"            ,   14755 ,"ATTEMPT_D_D_N"                          ,"SND_R_A_B_RES"                ,  1 ,  "" , "" , ""

     ,  56 ,"161_SMS-MT_LTE                 "  ,"161_SMS-MT_LTE_MME"                  ,   80321 ,"SND_CS_PAGING"                          ,"PAGING_RCV_at_RNC"            ,  1 ,  "" , "" , ""

     ,  57 ,"180_CS_Active_ISRact           "  ,"180_CS_Active_ISRact_RNC"            ,   56879 ,"ATTEMPT_RA_UPDATE"                      ,"COMPLETE_RA_UPDATE"           ,  1 ,  "" , "" , ""

     ,  58 ,"181_CS_Term_ISRdeact           "  ,"181_CS_Term_ISRdeact_RNC"            ,   44690 ,"ATTEMPT_RA_UPDATE_REQUEST"              ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

  );


sub get_procedure
{
	return @Procedure;
}



