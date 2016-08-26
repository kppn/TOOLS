#ifndef __GTP
#define __GTP

#include "common.h"


#define	GTP_HFLAG_N_PDU		0x01
#define	GTP_HFLAG_SEQ_NUM	0x02
#define	GTP_HFLAG_EXT_HDR	0x04

#define GTP_MSGTYPE_ECHO_REQ	0x01
#define GTP_MSGTYPE_ECHO_RES	0x02
#define GTP_MSGTYPE_ERR_IND	0x1a
#define GTP_MSGTYPE_END_MARKER	0xfe
#define GTP_MSGTYPE_N_PDU	0xff


uchar * encap_gtp_header(uchar * buf, ssize_t packsize, uint8_t msg_type, 
			 uint32_t teid, uint16_t seq, uint32_t flags);
uchar * decap_gtp_header(uchar * buf, uint8_t * msg_type, uint32_t * teid, uint16_t * seq);
uchar get_gtp_msgtype(uchar * buf);


#endif	/* __GTP */

