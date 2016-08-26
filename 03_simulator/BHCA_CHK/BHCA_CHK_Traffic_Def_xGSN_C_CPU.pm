
package BHCA_CHK_Traffic_Def_xGSN_C_CPU;

our @Procedure : shared;

@Procedure = (
      #Num  #Name                           #ScenarioName                          #100BHAC  #Chk_TrafficName    #Chk_OK_Traffic           #tmp  #tmp  #tmp
         1 ,"000_AtDt_intra                 "  ,"000_AtDt_intra_RNC"                  ,   10564 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,   2 ,"001_AtDt_inter                 "  ,"001_AtDt_inter_RNC"                  ,    7043 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,   3 ,"010_RAU_intra                  "  ,"010_RAU_intra_RNC"                   ,  331034 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   4 ,"011_RAU_inter_inter            "  ,"011_RAU_inter_inter_RNC_CHOAN"       ,  110344 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   5 ,"012_RAU_inter_intra            "  ,"012_RAU_inter_intra_RNC_CHOAN"       ,  110344 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,   6 ,"020_Active_imode               "  ,"020_Active_imode_RNC"                ,  195931 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,   7 ,"021_Active_mopera              "  ,"021_Active_mopera_RNC"               ,    3912 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,   8 ,"022_Active_spmode              "  ,"022_Active_spmode_RNC"               ,    7645 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,   9 ,"023_Active_imode_SG            "  ,"023_Active_imode_SG_SGSN"            ,   34138 ,"ATTEMPT_C_P_C_REQUEST"                  ,"RCV_C_P_C_RESPONSE"           ,  1 ,  "" , "" , ""

     ,  10 ,"030_Term_imode_1               "  ,"030_Term_imode_NWMP"                 ,   52751 ,"ATTEMPT_TERMINATING_INFORMATION"        ,"SND_RELEASE_INFORMATION_RSP"  ,  1 ,  "" , "" , ""
     ,  11 ,"030_Term_imode_2               "  ,"030_Term_imode_NWMP_1"               ,   52751 ,"ATTEMPT_TERMINATING_INFORMATION"        ,"SND_RELEASE_INFORMATION_RSP"  ,  1 ,  "" , "" , ""

     ,  12 ,"032_Term_mopera                "  ,"032_Term_mopera_RNC"                 ,      -1 ,"SND_SERVICE_REQUEST"                    ,"RCV_IPCP_CONFIGURE_ACK"       ,  1 ,  "" , "" , ""

     ,  13 ,"033_Term_imode_SG_1            "  ,"033_Term_imode_SG_NWMP"              ,    9191 ,"ATTEMPT_TERMINATING_INFORMATION"        ,"SND_RELEASE_INFORMATION_RSP"  ,  1 ,  "" , "" , ""
     ,  14 ,"033_Term_imode_SG_2            "  ,"033_Term_imode_SG_NWMP_1"            ,    9191 ,"ATTEMPT_TERMINATING_INFORMATION"        ,"SND_RELEASE_INFORMATION_RSP"  ,  1 ,  "" , "" , ""

     ,  15 ,"040_Relocation_intra_imode_REC "  ,"040_Relocation_intra_imode_RNC_rec"  ,   57011 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""
     ,  16 ,"040_Relocation_intra_imode_SND "  ,"040_Relocation_intra_imode_RNC_send" ,   57011 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""

     ,  17 ,"041_Relocation_inter_imode_IN  "  ,"041_Relocation_inter_imode_RNC"      ,   28505 ,"RCV_RELOCATION_REQUEST"                 ,"SND_RELOCATION_COMPLETE"      ,  1 ,  "" , "" , ""
     ,  18 ,"041_Relocation_inter_imode_OUT "  ,"041_Relocation_inter_imode_SGSN"     ,      -1 ,"RCV_FORWARD_RELOCATION_REQUEST"         ,"RCV_FORWARD_RELOCATION_COMPLETE_ACKNOWLEDGE"       ,  1 ,  "" , "" , ""

     ,  19 ,"050_Preservation_UE            "  ,"050_Preservation_UE_RNC_CHOAN"       ,  345951 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  20 ,"052_Preservation_UP            "  ,"052_Preservation_UP_RNC"             ,      -1 ,"RCV_PAGING"                             ,"RCV_IU_RELEASE_COMMAND"       ,  1 ,  "" , "" , ""

     ,  21 ,"055_Preservation_UE_SG         "  ,"055_Preservation_UE_SG_SGSN"         ,   66049 ,"SND_CONNECTION_STATUS_RECOVER"          ,"SND_CONNECTION_STATUS"        ,  1 ,  "" , "" , ""

     ,  22 ,"056_Preservation_UP_SG         "  ,"056_Preservation_UP_SG_SGSN"         ,   16512 ,"SND_CONNECTION_STATUS"                  ,"RCV_ISC_SYNCHRO_3"            ,  1 ,  "" , "" , ""

     ,  23 ,"060_SMS-MO                     "  ,"060_SMS-MO_RNC"                      ,    2983 ,"SND_SERVICE_REQUEST"                    ,"RCV_IU_RELEASE_COMMAND"       ,  1 ,  "" , "" , ""

     ,  24 ,"061_SMS-MT                     "  ,"061_SMS-MT_ASN"                      ,  143213 ,"ATTEMPT_MT_F_S_REQUEST"                 ,"RCV_MT_F_S_RESPONSE"          ,  1 ,  "" , "" , ""

     ,  25 ,"062_SMS-Push_GG                "  ,"062_SMS-Push_GG_NWMP"                ,   16700 ,"ATTEMPT_SMSINFO_IND"                    ,"RCV_SMSINFO_RSLT"             ,  1 ,  "" , "" , ""

     ,  26 ,"070_MTLR                       "  ,"070_MTLR_MSA"                        ,     355 ,"ATTEMPT_LCS_SERVICE_REQ"                ,"RCV_LCS_SERVICE_RES"          ,  1 ,  "" , "" , ""

     ,  27 ,"071_02B_LCS                    "  ,"071_02B_MSA"                         ,   22821 ,"ATTEMPT_LCS_SERVICE_REQ"                ,"RCV_LCS_SERVICE_RES"          ,  1 ,  "" , "" , ""

     ,  28 ,"072_MOLR                       "  ,"072_MOLR_ASN"                        ,    5234 ,"ATTEMPT_SLR"                            ,"RCV_SLR"                      ,  1 ,  "" , "" , ""

     ,  29 ,"080_CS_term                    "  ,"COMMON_SIN_28"                       ,   65758 ,"SND_PAGING_REQ"                         ,"PAGING_RCV_at_RNC"            ,  1 ,  "" , "" , ""

     ,  30 ,"                               "  ,"dummy"                               ,      -1 ,"dummy"                                   ,"dummy"                       ,  1 ,  "" , "" , ""

     ,  31 ,"100_AtDt_intra_LTE             "  ,"100_AtDt_intra_LTE_RNC"              ,    2863 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,  32 ,"101_AtDt_inter_sg_LTE          "  ,"101_AtDt_inter_sg_LTE_RNC"           ,     954 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,  33 ,"102_AtDt_inter_mm_LTE          "  ,"102_AtDt_inter_mm_LTE_RNC"           ,     954 ,"ATTEMPT_ATTACH_REQUEST"                 ,"SND_ATTACH_COMPLETE"          ,  1 ,  "" , "" , ""

     ,  34 ,"110_RAU_intra_LTE_RNC_send     "  ,"110_RAU_intra_LTE_RNC_send"          ,   44853 ,"ATTEMPT_RA_UPDATE_REQUEST"              ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""
     ,  35 ,"110_RAU_intra_LTE_RNC_receive  "  ,"110_RAU_intra_LTE_RNC_receive"       ,      -1 ,"SND_RA_UPDATE_REQUEST"                  ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,  36 ,"111_RAU_inter_sg_LTE           "  ,"111_RAU_inter_sg_LTE_RNC"            ,   29902 ,"ATTEMPT_RA_UPDATE_REQUEST"              ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

     ,  37 ,"113_TAU                        "  ,"113_TAU_RNC"                         ,   58444 ,"SND_ISC_FORWARD_PTMSI_1_ptmsi_sig_toMME"   ,"RCV_ISC_SYNCHRO_10"        ,  1 ,  "" , "" , ""

     ,  38 ,"114_TAU_chgsg                  "  ,"114_TAU_chgsg_RNC"                   ,   14951 ,"SND_ISC_FORWARD_PTMSI_1_ptmsi_sig_toMME"   ,"RCV_ISC_SYNCHRO_10"        ,  1 ,  "" , "" , ""

     ,  39 ,"120_Active_spmode_LTE          "  ,"120_Active_spmode_LTE_RNC"           ,    2742 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  40 ,"121_Active_mopera_LTE          "  ,"121_Active_mopera_LTE_RNC"           ,    2159 ,"ATTEMPT_SERVICE_REQUEST"                ,"RCV_D_P_C_ACCEPT"             ,  1 ,  "" , "" , ""

     ,  41 ,"140_Relocation_intra_REC       "  ,"140_Relocation_intra_RNC_receive"    ,    1086 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""
     ,  42 ,"140_Relocation_intra_SND       "  ,"140_Relocation_intra_RNC_send"       ,    1086 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"RCV_RELOCATION_COMMAND"       ,  1 ,  "" , "" , ""

     ,  43 ,"141_Relocation_inter_RNC       "  ,"141_Relocation_inter_RNC"            ,     271 ,"ATTEMPT_RELOCATION_REQUIRED"            ,"SND_RELOCATION_COMPLETE"      ,  1 ,  "" , "" , ""

     ,  44 ,"142_HO                         "  ,"142_HO_RNC"                          ,     246 ,"RCV_ISC_FORWARD_PDPADDR_0"              ,"SND_RELOCATION_COMPLETE"      ,  1 ,  "" , "" , ""

     ,  45 ,"150_Preservation_UE            "  ,"150_Preservation_UE_RNC"             ,   10049 ,"ATTEMPT_SERVICE_REQUEST"                ,"SND_IU_RELEASE_COMPLETE_fuka" ,  1 ,  "" , "" , ""

     ,  46 ,"151_Preservation_UP            "  ,"151_Preservation_UP_S-GW"            ,    2521 ,"ATTEMPT_D_D_N"                          ,"SND_R_A_B_RES"                ,  1 ,  "" , "" , ""

     ,  47 ,"161_SMS-MT_LTE                 "  ,"161_SMS-MT_LTE_MME"                  ,   89794 ,"SND_CS_PAGING"                          ,"PAGING_RCV_at_RNC"            ,  1 ,  "" , "" , ""

     ,  48 ,"180_CS_Active_ISRact           "  ,"180_CS_Active_ISRact_RNC"            ,   43492 ,"ATTEMPT_RA_UPDATE"                      ,"COMPLETE_RA_UPDATE"           ,  1 ,  "" , "" , ""

     ,  49 ,"181_CS_Term_ISRdeact           "  ,"181_CS_Term_ISRdeact_RNC"            ,   32810 ,"ATTEMPT_RA_UPDATE_REQUEST"              ,"SND_RA_UPDATE_COMPLETE"       ,  1 ,  "" , "" , ""

  );


sub get_procedure
{
        return @Procedure;
}

