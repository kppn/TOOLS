#!/usr/bin/perl

%imsis = (
440101540100000 =>       [  148,    'GUTI Attach-Detach'  ],
440101540100148 =>       [  87,     '(VoLTE] GUTI Attach-Detach'  ],
440101540100235 =>       [  462,    'Multi PDN'  ],
440101540100697 =>       [  462,    'Dedicated Bearer'  ],
440101540101159 =>       [  22,     'inter Attach (3G]'  ],
440101540101181 =>       [  51,     'Detach (3G, ISR activate]'  ],
440101540101232 =>       [  267,    'PS Paging (3G, ISR activate]'  ],
440101540101499 =>       [  1681,   'RAU (3G, inter-SGSN, ISR activate]'  ],
440101540103180 =>       [  62,     'Relocation（3G, inter-SGSN, ISR activate）'  ],
440101540103242 =>       [  167,    'CS Paging (3G, MT-Call, ISR activate]'  ],
440101540103409 =>       [  487,    'CS Paging (3G, MT-SMS, ISR activate]'  ],
440101550100000 =>       [  7572,   'Service Request（UE initiated） 1'  ],
440101550107572 =>       [  188,    'Service Request（Network Triggered）'  ],
440101550107760 =>       [  42,     'EPC-MT-LR (Idle-mode)'  ],
440101550112145 =>       [  30,     '端末発信 in ActiveMode with PSHO'  ],
440101550112175 =>       [  749,    '端末発信 in IdleMode with PSHO'  ],
440101550112924 =>       [  30,     '端末着信 in ActiveMode with PSHO'  ],
440101550112954 =>       [  749,    '端末着信 in IdleMode with PSHO'  ],
440101550113703 =>       [  393,    'SMS発信 in IdleMode'  ],
440101550114096 =>       [  2272,   'SMS着信 in IdleMode 1'  ],
440101560100000 =>       [  8836,   'Intra TAU 1'  ],
440101560108836 =>       [  799,    'Inter TAU 1'  ],
440101560109635 =>       [  467,    '(VoLTE] Inter TAU'  ],
440101560100000 =>       [  8836,   'Intra TAU 2'  ],
440101560110102 =>       [  691,    'RAT TAU/RAU (GTP v2)'  ],
440101560110793 =>       [  692,    'RAT TAU/RAU (GTP v2)_2G'  ],
440101560111485 =>       [  407,    '（VoLTE）RAT TAU/RAU (GTP v2)'  ],
440101560111892 =>       [  406,    '（VoLTE）RAT TAU/RAU (GTP v2)_2G'  ],
440101560112298 =>       [  700,    'X2 HO new'  ],
440101560112998 =>       [  82,     'S1 HO'  ],
440101560113080 =>       [  66,     '(VoLTE] S1 HO'  ],
440101560112298 =>       [  700,    'X2 HO old'  ],
440101560113146 =>       [  45,     'RAT HO (GTP v2)'  ],
440101560113191 =>       [  46,     'RAT HO (GTP v2)_2G'  ],
440101560113237 =>       [  37,     '(VoLTE] RAT HO(GTP v2)'  ],
440101560113274 =>       [  36,     '(VoLTE] RAT HO(GTP v2)_2G'  ],
440101560113310 =>       [  17,     '（VoLTE） SRVCC FROM E-UTRAN TO UTRAN WITH PS HO (GTPv2)'  ],
440101560113327 =>       [  17,     '（VoLTE） SRVCC FROM E-UTRAN TO UTRAN WITHOUT PS HO (GTPv2)'  ],
440101560113344 =>       [  1009,   'RAT TAU/RAU (GTP v1)'  ],
440101560114353 =>       [  1010,   'RAT TAU/RAU (GTP v1)_2G'  ],
440101560115363 =>       [  46,     'RAT HO (GTP v1)'  ],
440101560115409 =>       [  45,     'RAT HO (GTP v1)_2G'  ],
440101560115454 =>       [  444,    '（VoLTE） VoLTE-SMS発信（Idle mode)'  ],
440101560115898 =>       [  4052,   '（VoLTE） Service Request（UE initiated）'  ],
440101560119950 =>       [  444,    '（VoLTE） VoLTE-SMS着信（Idle mode)'  ],
440101560120394 =>       [  1013,   '（VoLTE） Service Request（Network Triggered）'  ],
440101560121407 =>       [  25,     '（VoLTE） VoLTE発信（Active mode)'  ],
440101560121432 =>       [  444,    '（VoLTE） VoLTE発信（Idle mode)'  ],
440101560121876 =>       [  11,     '（VoLTE） VoLTE着信（Active mode)'  ],
440101560121887 =>       [  192,    '（VoLTE） VoLTE着信（Idle mode)'  ],
550101540100000 =>       [  1038,   'Roamer_Inter TAU'  ],
550101540101038 =>       [  612,    '（VoLTE） Roamer_Inter TAU'  ],
550101540101650 =>       [  252,    '（VoLTE） Roamer_VoLTE着信（Idle mode)'  ],
550101540101902 =>       [  14,     '（VoLTE） Roamer_VoLTE着信（Active mode)'  ],
550101540101916 =>       [  29,     'Roamer_inter Attach (3G]'  ],
550101540101945 =>       [  55,     'Roamer_EPC-MT-LR (Idle-mode)'  ],
);


$target_imsi = $ARGV[0] + 0;

foreach $item_imsi (keys %imsis) {
	$item_imsi_first = $item_imsi + 0;

	$kind_sub_num = $imsis{$item_imsi}->[0];
	$item_imsi_last  = $item_imsi + $kind_sub_num - 1;

	if ($item_imsi_first <= $target_imsi and $target_imsi <= $item_imsi_last) {
		print $target_imsi, ' :', "\t";
		print $item_imsi, "\t";
		print $kind_sub_num, "\t";
		print $imsis{$item_imsi}->[1];
		print "\n";
		
		last;
	}
}


