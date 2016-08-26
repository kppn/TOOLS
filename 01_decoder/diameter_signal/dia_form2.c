#include <stdio.h>
#include <stdlib.h>



#define TABEDFORM	"%02X\t\t\t\t\t\t\t\t\n"

#define HEADERFLAGFORM	"%02X\t%d\t\t\t\t\t\t\t\t\n" \
       	  	       	"\t\t%d\t\t\t\t\t\t\t\n" \
       	       	  	"\t\t\t%d\t\t\t\t\t\t\n" \
                	"\t\t\t\t%d\t\t\t\t\t\n" \
                	"\t\t\t\t\t%d\t%d\t%d\t%d\t\t\n"

#define FLAGFORM	"%02X\t%d\t\t\t\t\t\t\t\t\n" \
			"\t\t%d\t\t\t\t\t\t\t\n" \
			"\t\t\t%d\t\t\t\t\t\t\n" \
			"\t\t\t\t%d\t%d\t%d\t%d\t%d\t\n";

typedef struct __avp {
	char * avpname;
	int code;
	char structure;
	char nulllen;
	int len;
	int avptotal;
	unsigned char data[256];
} AVP;



AVP value_table[64];



AVP avp_table[] = {
{"Session-Id", 263, 0, 1},
{"Auth-Application-Id", 258, 0},
{"Origin-Host", 264, 0, 1},
{"Origin-Realm", 296, 0,},
{"Destination-Realm", 283, 0},
{"CC-Request-Type", 416, 0},
{"CC-Request-Number", 415, 0},
{"Destination-Host", 293, 0, 1},
{"Origin-State-Id", 278, 0},
{"Subscription-Id", 443, 0, 0},
{"Subscription-Id-Type", 450, 0},
{"Subscription-Id-Data", 444, 0},
{"Supported-Features", 628, 0},
{"Vendor-Id", 266, 0},
{"Feature-List-ID", 629, 0},
{"Feature-List", 630, 0},
{"Network-Request-Support", 1024, 0},
{"Bearer-Identifier", 1020, 0},
{"Bearer-Operation", 1021, 0},
{"Framed-IP-Address", 8, 0},
{"-Prefix", 97, 0},
{"IP-CAN-Type", 1027, 0},
{"RAT-Type", 1032, 0},
{"Termination-Cause", 295, 0},
{"User-Equipment-Info", 458, 0},
{"User-Equipment-Info-Type", 459, 0},
{"User-Equipment-Info-Value", 460, 0},
{"QoS-Information", 1016, 0},
{"QoS-Class-Identifier", 1028, 0},
{"Max-Requested-Bandwidth-UL", 516, 0},
{"Max-Requested-Bandwidth-DL", 515, 0},
{"Guaranteed-Bitrate-UL", 1026, 0},
{"Guaranteed-Bitrate-DL", 1025, 0},
{"Allocation-Retention-Priority", 1034, 0},
{"Priority-Level", 1046, 0},
{"Pre-emption-Capability", 1047, 0},
{"Pre-emption-Vulnerability", 1048, 0},
{"APN-Aggregate-Max-Bitrate-UL", 1041, 0},
{"APN-Aggregate-Max-Bitrate-DL", 1040, 0},
{"QoS-Negotiation", 1029, 0},
{"QoS-Upgrade", 1030, 0},
{"Default-EPS-Bearer-QoS", 1049, 0},
{"AN-GW-Address", 1050, 0},
{"GPP-SGSN-MCC-MNC", 18, 0},
{"GPP-SGSN-Address", 6, 0},
{"-Address", 15, 0},
{"RAI", 909, 0},
{"GPP-User-Location-Info", 22, 0},
{"GPP-MS-TimeZone", 23, 0},
{"Called-Station-ID", 30, 0},
{"Bearer-Usage", 1000, 0},
{"Online", 1009, 0},
{"Offline", 1008, 0},
{"TFT-Packet-Filter-Information", 1013, 0},
{"Charging-Rule-Report", 1018, 0},
{"Charging-Rule-Name", 1005, 0},
{"Charging-Rule-Base-Name", 1004, 0},
{"PCC-Rule-Status", 1019, 0},
{"Rule-Failure-Code", 1031, 0},
{"Final-Unit-Indication", 430, 0},
{"QoS-Rule-Report", 1055, 0},
{"QoS-Rule-Name", 1054, 0},
{"Event-Trigger", 1006, 0},
{"Event-Report-Indication", 1033, 0},
{"Access-Network-Charging-Address", 501, 0},
{"Access-Network-Charging-Identifier-Gx", 1022, 0},
{"Access-Network-Charging-Identifier-Value", 503, 0},
{"CoA-Information", 1039, 0},
{"Tunnel-Information", 1038, 0},
{"Tunnel-Header-Length", 1037, 0},
{"Tunnel-Header-Filter", 1036, 0},
{"CoA-IP-Address", 1035, 0},
{"Proxy-Info", 284, 0},
{"Proxy-Host", 280, 0},
{"Proxy-State", 33, 0},
{"Route-Record", 282, 0},
{"Subscribed-Carrier-Name", 4864, 0},
{"CA-Code", 4873, 0},
{"DCM-Service-Flags", 4866, 0},
{"Fomalimitplus-Information", 4867, 0},
{"LTE-Low-Class-Type", 4869, 0},
{"Data-Volume", 4874, 0},
{"Protocol-Configuration-Options", 4875, 0},
{"MVNO-Identifier", 4870, 0},
{"MVNO-Plan", 4871, 0},
{"IP-Allocation", 4876, 0},
{"GPP-Selection-Mode", 12, 0},
{"Packet-Scheduling-Indicator", 4894, 0},
{"Result-Code", 268, 0},
{"Experimental-Result", 297, 0},
{"Experimental-Result-Code", 298, 0},
{"Bearer-Control-Mode", 1023, 0},
{"Charging-Rule-Remove", 1002, 0},
{"Charging-Rule-Install", 1001, 0},
{"Charging-Rule-Definition", 1003, 0},
{"Service-Identifier", 439, 0},
{"Rating-Group", 432, 0},
{"Flow-Description", 507, 0},
{"Flow-Status", 511, 0},
{"Reporting-Level", 1011, 0},
{"Metering-Method", 1007, 0},
{"Precedence", 1010, 0},
{"AF-Charging-Identifier", 505, 0},
{"Flows", 510, 0},
{"Rule-Activation-Time", 1043, 0},
{"Rule-Deactivation-Time", 1044, 0},
{"Resource-Allocation-Notification", 1051, 0},
{"Charging-Information", 618, 0},
{"Redirect-Host", 292, 0},
{"Redirect-Host-Usage", 261, 0},
{"Redirect-Max-Cache-Time", 262, 0},
{"QoS-Rule-Remove", 1052, 0},
{"QoS-Rule-Install", 1051, 0},
{"QoS-Rule-Definition", 1053, 0},
{"Revalidation-Time", 1042, 0},
{"Error-Message", 281, 0},
{"Error-Reporting-Host", 294, 0},
{"Failed-AVP", 279, 0},
{"MSISDN", 701, 0},
{"Charging-Target-Flag", 4880, 0},
{"Dedicated-Line-Service-Flag", 4881, 0},
{"Volume-Threshold", 4883, 0},
{"Authentication-Protocol", 4885, 0},
{"APN-Profile", 4886, 0},
{"UserID-Authentication", 4887, 0},
{"UserID-Authentication-Password", 4888, 0},
{"ID-Notification", 4889, 0},
{"APN-Service-Information", 4891, 0},
{"-Prefix", 97, 0},
{"Preservation-Allowed-Time", 4893, 0},
{NULL, 0, 0},

};



disp_v(unsigned char *  buf, int size)
{
	int i;

	for (i = 0; i < size; i++) {
		printf(TABEDFORM, buf[i]);
	}
}


disp_header_flag(unsigned char flag)
{

	char * format =  HEADERFLAGFORM;

	printf(format, flag,
			(flag & 0x80)!=0,
			(flag & 0x40)!=0,
			(flag & 0x20)!=0,
			(flag & 0x10)!=0,
			(flag & 0x08)!=0,
			(flag & 0x04)!=0,
			(flag & 0x02)!=0,
			(flag & 0x01)!=0
			);
	
}

disp_flag(unsigned char flag)
{

	char * format = FLAGFORM; 

	printf(format, flag,
			(flag & 0x80)!=0,
			(flag & 0x40)!=0,
			(flag & 0x20)!=0,
			(flag & 0x10)!=0,
			(flag & 0x08)!=0,
			(flag & 0x04)!=0,
			(flag & 0x02)!=0,
			(flag & 0x01)!=0
			);
	
}



void disp_header(unsigned char * buf)
{
	int i;

	disp_v(buf, 4);
/* これやめる
	disp_header_flag(buf[4]);
*/
        disp_v(&buf[4],4);
	disp_v(buf+5, 15);

}


int isvendor(unsigned char c)
{
	return c & 0x80;
}



int get_code(unsigned char * buf) 
{ 
	unsigned int code = 0; 
	int i;

	code = buf[1] * 0x10000 + buf[2] * 0x100 +  buf[3];

	return code;
}
		
int get_len(unsigned char * buf)
{
	int len = 0;
	int i;

	buf += 5;
	for (i = 0; i < 3; i++)
		len+= len * 256 + buf[i];

	return len;

}


void disp_avp(AVP avp, AVP table)
{
	int i;
	int off = 0;
	int padd;

	printf("%02X\t%s\n", avp.data[0], table.avpname);
	disp_v(avp.data+1, 3);
/* これやめる
	disp_flag(avp.data[4]);
*/
        disp_v(&avp.data[4],3);

	/* disp length bytes */
	disp_v(avp.data+5, 3);


	if (avp.structure) {
		disp_avp(avp, table);
		return;
	}

/* これやめる
	if (
		(strcmp(table.avpname,"Origin-Host") == 0) ||
		(strcmp(table.avpname,"Origin-Realm") == 0) ||
		(strcmp(table.avpname,"Destination-Realm") == 0) ||
		(strcmp(table.avpname,"Destination-Host") == 0)
	){
		for (i = 0; i < avp.avptotal; i++)
			printf("%02X ", avp.data[8+i]);
		printf("\n");
		for (i = 0; i < 28; i++) {
			printf("\n");
		}
		return;
	} else if  (avp.nulllen == 1) {
*/
        if  (avp.nulllen == 1) {
		for (i = 0; i < avp.avptotal; i++)
			printf("%02X ", avp.data[8+i]);
		printf("\n");
		for (i = 0; i < 11; i++) {
			printf("\n");
		}
		return;
	}

	/* disp value */
	for (i = 0; i < avp.len-8; i++)
		printf(TABEDFORM, avp.data[8+i]);
	padd = avp.avptotal - avp.len;
	/* disp padding */
	for (i = 0; i < padd; i++)
		printf(TABEDFORM, avp.data[avp.len+i]);
}




int main()
{
	unsigned char buf[4096];
	unsigned char tmp[8];
	int readsize;
	int i, j;

	int avplen;
	unsigned char flag;
	int code;
	int size;
	int len;
	int avptotal = 0;
	int paddlen;
	int datalen;
	
	/* print header */
	readsize = fread(buf, 1, 20, stdin);
	disp_header(buf);

	i = 0;
	do {
		readsize = fread(buf, 1, 8, stdin);
		if (readsize == 0) {
			break;
		}
		code = get_code(buf);
		len = get_len(buf);
		avptotal = ((len+3) / 4)*4;

		value_table[i].avptotal = avptotal;
		value_table[i].code = code;
		value_table[i].len = len;
		memmove(value_table[i].data, buf, 8);
		datalen = avptotal - 8;
		readsize = fread(buf, 1,datalen, stdin);
		if (readsize == 0) {
			printf("error\n");
			exit(1);
		}
		memmove(value_table[i].data+8, buf, avptotal - 8);

		i++;
	} while (1);
	value_table[i].len = 0;

	/*
	for (i = 0; value_table[i].len != 0; i++) {
		printf("%d\n", value_table[i].len);
	}
	*/


	for (i = 0;  avp_table[i].avpname != NULL; i++){
		for (j = 0; value_table[j].len != 0; j++) {
			if (avp_table[i].code == value_table[j].code) {
				if(avp_table[i].nulllen == 1) {
					value_table[j].nulllen = 1;
				}
				disp_avp(value_table[j], avp_table[i]);
			}
		}
	}

}



