
package BHCA_CHK_Traffic_Def_xGSN_C_PKT;

our @Procedure : shared;

@Procedure = (
      #Num  #Name                           #ScenarioName                          #100BHAC  #Chk_TrafficName    #Chk_OK_Traffic           #tmp  #tmp  #tmp
         1 ,"000_AtDt_intra                 "  ,"000_AtDt_intra_RNC"                  ,   12031 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,   2 ,"001_AtDt_inter                 "  ,"001_AtDt_inter_RNC"                  ,    8020 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,   3 ,"010_RAU_intra                  "  ,"010_RAU_intra_RNC"                   ,  140366 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   4 ,"011_RAU_inter_inter            "  ,"011_RAU_inter_inter_RNC_CHOAN"       ,   37810 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   5 ,"012_RAU_inter_intra            "  ,"012_RAU_inter_intra_RNC_CHOAN"       ,   37810 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   6 ,"014_RAU_inter_PDP              "  ,"014_RAU_inter_spmode_RNC"            ,   17955 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   7 ,"020_Active_imode               "  ,"020_Active_imode_RNC"                ,  186083 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,   8 ,"021_Active_mopera              "  ,"021_Active_mopera_RNC"               ,    3174 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,   9 ,"022_Active_spmode              "  ,"022_Active_spmode_RNC"               ,    8641 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  10 ,"023_Active_imode_SG            "  ,"023_Active_imode_SG_SGSN"            ,   31772 ,"ATTEMPT_C_P_C_REQUEST"                  ,"RCV_C_P_C_RESPONSE"           ,  1 ,  "" , "" , ""

     ,  11 ,"030_Term_imode_1               "  ,"030_Term_imode_NWMP"                 ,   50099 ,"ATTEMPT_TERMINATING_INFORMATION"        ,"SND_RELEASE_INFORMATION_RSP"  ,  1 ,  "" , "" , ""
     ,  12 ,"030_Term_imode_2               "  ,"030_Term_imode_NWMP"                 ,   50099 ,"ATTEMPT_TERMINATING_INFORMATION"        ,"SND_RELEASE_INFORMATION_RSP"  ,  1 ,  "" , "" , ""

     ,  13 ,"032_Term_mopera                "  ,"032_Term_mopera_RNC"                 ,      -1 ,"SND_SERVICE_REQUEST"                    ,"RCV_IPCP_CONFIGURE_ACK"       ,  1 ,  "" , "" , ""

     ,  14 ,"033_Term_imode_SG_1            "  ,"033_Term_imode_SG_NWMP"              ,    8554 ,"ATTEMPT_TERMINATING_INFORMATION"        ,"SND_RELEASE_INFORMATION_RSP"  ,  1 ,  "" , "" , ""
     ,  15 ,"033_Term_imode_SG_2            "  ,"033_Term_imode_SG_NWMP_1"            ,    8554 ,"ATTEMPT_TERMINATING_INFORMATION"        ,"SND_RELEASE_INFORMATION_RSP"  ,  1 ,  "" , "" , ""

     ,  16 ,"040_Relocation_intra_imode_REC "  ,"040_Relocation_intra_imode_RNC_rec"  ,   44000 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""
     ,  17 ,"040_Relocation_intra_imode_SND "  ,"040_Relocation_intra_imode_RNC_send" ,   44000 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""

     ,  18 ,"041_Relocation_inter_imode_IN  "  ,"041_Relocation_inter_imode_RNC"      ,   88001 ,"RCV_RELOCATION_REQUEST"                 ,"SND_RELOCATION_COMPLETE"      ,  1 ,  "" , "" , ""
     ,  19 ,"041_Relocation_inter_imode_OUT "  ,"041_Relocation_inter_imode_SGSN"     ,      -1 ,"RCV_FORWARD_RELOCATION_REQUEST"         ,"RCV_FORWARD_RELOCATION_COMPLETE_ACKNOWLEDGE"       ,  1 ,  "" , "" , ""

     ,  20 ,"050_Preservation_UE            "  ,"050_Preservation_UE_RNC_CHOAN"       ,  256545 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  21 ,"052_Preservation_UP            "  ,"052_Preservation_UP_RNC"             ,      -1 ,"RCV_PAGING"                             ,"RCV_IU_RELEASE_COMMAND"       ,  1 ,  "" , "" , ""

     ,  22 ,"055_Preservation_UE_SG         "  ,"055_Preservation_UE_SG_SGSN"         ,   62055 ,"SND_CONNECTION_STATUS_RECOVER"          ,"SND_CONNECTION_STATUS"        ,  1 ,  "" , "" , ""

     ,  23 ,"056_Preservation_UP_SG         "  ,"056_Preservation_UP_SG_SGSN"         ,   15513 ,"SND_CONNECTION_STATUS"                  ,"RCV_ISC_SYNCHRO_3"            ,  1 ,  "" , "" , ""

     ,  24 ,"057_Presevation_NW             "  ,"057_Presevation_NW"                  ,  307800 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  25 ,"060_SMS-MO                     "  ,"060_SMS-MO_RNC"                      ,     582 ,"SND_SERVICE_REQUEST"                    ,"RCV_IU_RELEASE_COMMAND"       ,  1 ,  "" , "" , ""

     ,  26 ,"061_SMS-MT                     "  ,"061_SMS-MT_ASN"                      ,   84220 ,"ATTEMPT_MT_F_S_REQUEST"                 ,"RCV_MT_F_S_RESPONSE"          ,  1 ,  "" , "" , ""

     ,  27 ,"062_SMS-Push_GG                "  ,"062_SMS-Push_GG_NWMP"                ,   10080 ,"ATTEMPT_SMSINFO_IND"                    ,"RCV_SMSINFO_RSLT"             ,  1 ,  "" , "" , ""

     ,  28 ,"070_MTLR                       "  ,"070_MTLR_MSA"                        ,     299 ,"ATTEMPT_LCS_SERVICE_REQ"                ,"RCV_LCS_SERVICE_RES"          ,  1 ,  "" , "" , ""

     ,  29 ,"071_02B_LCS                    "  ,"071_02B_MSA"                         ,   14549 ,"ATTEMPT_LCS_SERVICE_REQ"                ,"RCV_LCS_SERVICE_RES"          ,  1 ,  "" , "" , ""

     ,  30 ,"072_MOLR                       "  ,"072_MOLR_ASN"                        ,    3960 ,"ATTEMPT_SLR"                            ,"RCV_SLR"                      ,  1 ,  "" , "" , ""

     ,  31 ,"080_CS_term                    "  ,"COMMON_SIN_28"                       ,   31637 ,"SND_PAGING_REQ"                         ,"PAGING_RCV_at_RNC"            ,  1 ,  "" , "" , ""

     ,  32 ,"                               "  ,"dummy"                               ,      -1 ,"dummy"                                   ,"dummy"                       ,  1 ,  "" , "" , ""

     ,  33 ,"100_AtDt_intra_LTE             "  ,"100_AtDt_intra_LTE_RNC"              ,    4489 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,  34 ,"101_AtDt_inter_sg_LTE          "  ,"101_AtDt_inter_sg_LTE_RNC"           ,    1499 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,  35 ,"102_AtDt_inter_mm_LTE          "  ,"102_AtDt_inter_mm_LTE_RNC"           ,    1499 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,  36 ,"110_RAU_intra_LTE_RNC_send     "  ,"110_RAU_intra_LTE_RNC_send"          ,   26240 ,"ATTEMPT_RA_UPDATE_REQUEST"              ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""
     ,  37 ,"110_RAU_intra_LTE_RNC_receive  "  ,"110_RAU_intra_LTE_RNC_receive"       ,      -1 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,  38 ,"111_RAU_inter_sg_LTE           "  ,"111_RAU_inter_sg_LTE_RNC"            ,   17493 ,"ATTEMPT_RA_UPDATE_REQUEST"              ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,  39  ,"113_TAU                        "  ,"113_TAU_RNC"                         ,  29701 ,"SND_ISC_FORWARD_PTMSI_1_ptmsi_sig_toMME"   ,"RCV_ISC_SYNCHRO_10"        ,  1 ,  "" , "" , ""

     ,  40 ,"114_TAU_chgsg                  "  ,"114_TAU_chgsg_RNC"                   ,    8747 ,"SND_ISC_FORWARD_PTMSI_1_ptmsi_sig_toMME"   ,"RCV_ISC_SYNCHRO_10"        ,  1 ,  "" , "" , ""

     ,  41 ,"120_Active_spmode_LTE          "  ,"120_Active_spmode_LTE_RNC"           ,    3955 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  42 ,"121_Active_mopera_LTE          "  ,"121_Active_mopera_LTE_RNC"           ,    2235 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  43 ,"140_Relocation_intra_REC       "  ,"140_Relocation_intra_RNC_receive"    ,    1016 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""
     ,  44 ,"140_Relocation_intra_SND       "  ,"140_Relocation_intra_RNC_send"       ,    1016 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""

     ,  45 ,"141_Relocation_inter_RNC       "  ,"141_Relocation_inter_RNC"            ,    1016 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"SND_RELOCATION_COMPLETE"      ,  1 ,  "" , "" , ""

     ,  46 ,"142_HO                         "  ,"142_HO_RNC"                          ,    1016 ,"RCV_ISC_FORWARD_PDPADDR_0"              ,"SND_RELOCATION_COMPLETE"      ,  1 ,  "" , "" , ""

     ,  47 ,"150_Preservation_UE            "  ,"150_Preservation_UE_RNC"             ,   11655 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  48 ,"151_Preservation_UP            "  ,"151_Preservation_UP_S-GW"            ,    2913 ,"ATTEMPT_D_D_N"                          ,"SND_R_A_B_RES"                ,  1 ,  "" , "" , ""

     ,  49 ,"161_SMS-MT_LTE                 "  ,"161_SMS-MT_LTE_MME"                  ,   59426 ,"SND_CS_PAGING"                          ,"PAGING_RCV_at_RNC"            ,  1 ,  "" , "" , ""

     ,  50 ,"180_CS_Active_ISRact           "  ,"180_CS_Active_ISRact_RNC"            ,   20954 ,"ATTEMPT_RA_UPDATE"                      ,"COMPLETE_RA_UPDATE"           ,  1 ,  "" , "" , ""

     ,  51 ,"181_CS_Term_ISRdeact           "  ,"181_CS_Term_ISRdeact_RNC"            ,   15807 ,"ATTEMPT_RA_UPDATE_REQUEST"              ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

  );


sub get_procedure
{
	return @Procedure;
}



