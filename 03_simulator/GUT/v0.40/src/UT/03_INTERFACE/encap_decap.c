#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "interface.h"
#include "common.h"
#include "gtp.h"


int main(int argc, char ** argv)
{
	uchar buf[256];
	uchar * p;
	uchar * cap;
	p = buf + 32;

	memset(buf, 0xff, sizeof(buf));

	p[0] = 0x60;

	cap = NULL;
	printf("-------- before tunframe encap -------------------------\n");
	printf("p   :%p\n", p);
	printf("cap :%p\n", cap);
	printf("-------- after tunframe encap -------------------------\n");
	cap = encap_tunframe(p);
	dump(buf, sizeof(buf));
	printf("p   :%p\n", p);
	printf("cap :%p\n", cap);
	printf("---------------------------------------------------------\n");
	printf("\n\n");

	p = NULL;
	printf("-------- before tunframe decap -------------------------\n");
	printf("p   :%p\n", p);
	printf("cap :%p\n", cap);
	printf("-------- after tunframe encap -------------------------\n");
	p = decap_tunframe(cap);
	dump(buf, sizeof(buf));
	printf("p   :%p\n", p);
	printf("cap :%p\n", cap);
	printf("---------------------------------------------------------\n");
	printf("\n\n");


	uint8_t msg_type = 0xff;
	uint32_t teid    = 0xdeadbeaf;
	uint16_t seq     = 0xaabb; 

	memset(buf, 0x33, sizeof(buf));
	p[0] = 0x11;

	cap = NULL;
	printf("-------- before gtp encap -------------------------\n");
	printf("p   :%p\n", p);
	printf("cap :%p\n", cap);
	printf("-------- after gtp encap -------------------------\n");
	cap = encap_gtp_header(p, sizeof(buf), msg_type, teid, seq, GTP_HFLAG_SEQ_NUM);
	dump(buf, sizeof(buf));
	printf("p   :%p\n", p);
	printf("cap :%p\n", cap);
	printf("---------------------------------------------------------\n");
	printf("\n\n");

	p = NULL;
	printf("-------- before gtp decap -------------------------\n");
	printf("p   :%p\n", p);
	printf("cap :%p\n", cap);
	printf("-------- after gtp encap -------------------------\n");
	p = decap_gtp_header(cap, &msg_type, &teid, &seq);
	dump(buf, sizeof(buf));
	printf("p   :%p\n", p);
	printf("cap :%p\n", cap);
	printf("msgtype : %d\n", msg_type);
	printf("teid    : %08x\n", teid);
	printf("sequ    : %d\n", seq);
	printf("---------------------------------------------------------\n");
	printf("\n\n");



	return 0;
}


