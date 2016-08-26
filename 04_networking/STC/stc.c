/**************************************************************************
 *
 * stc    SEB M3UA message tps counter
 *
 *
 *    2012/12/07   v0.0 release
 *                        t.kondoh
 *
 *                                    Original version written by t.kondoh
 *                                    Copyleft -- all rights reserved                                
 *
 *************************************************************************/


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <pcap.h>


void tps_measuament(u_char * arg, const struct pcap_pkthdr * h, const u_char * p);
void dump(const u_char * p, int n);
char * join_blank(char * s, char ** arg);


#ifdef DEBUG
#	define  DEBUGPRINTF	printf
#	define	DEBUGDUMP	dump
#else
#	define  DEBUGPRINTF
#	define  DEBUGDUMP
#endif




int main(int argc, char ** argv)
{
	char * device;
	pcap_t *pd;
	char expression[2048];
	int snaplen = 512;
	int pflag = 0;
	int timeout = 1000;
	char ebuf[PCAP_ERRBUF_SIZE];
	bpf_u_int32 localnet, netmask;
	pcap_handler callback;
	struct bpf_program fcode;


	if (argc < 2) {
		printf("stc interface [expression]\n");
		printf("\n");
		printf("	expression : man tcpdump\n");
		exit(1);
	}
	device = argv[1];

	expression[0] = '\0';
	if (argc >= 3) {
		join_blank(expression, &argv[2]);
	}
	else {
		expression[0] = '\0';
	}
	printf("expression : %s\n", expression);

	if ((pd = pcap_open_live(device, snaplen, !pflag, timeout, ebuf)) == NULL) {
		printf("pcap_open_live fail\n");
		exit(1);
	}

	if (pcap_compile(pd, &fcode, expression, 1, netmask) < 0) {
		printf("pcap_compile fail\n");
		exit(1);
	}
	if (pcap_setfilter(pd, &fcode) < 0) {
		printf("pcap_setfilter fail\n");
		exit(1);
	}

	callback = tps_measuament;

	if (pcap_loop(pd, -1, callback, NULL) < 0) {
		printf("pcap_loop error occured\n");
		exit(1);
	}

	return 0;
}




struct timeval * calc_diff_time(const struct timeval * before, const struct timeval * after, struct timeval * diff)
{
	suseconds_t usec_before;
	suseconds_t usec_after;
	suseconds_t usec_diff;

	usec_after  = (after->tv_sec   & 0xff) * 1000000 + after->tv_usec;
	usec_before = (before->tv_sec  & 0xff) * 1000000 + before->tv_usec;

	usec_diff = usec_after - usec_before;
	diff->tv_sec  = usec_diff / 1000000;
	diff->tv_usec = usec_diff % 1000000;

	return diff;
}




void tps_measuament(u_char * arg, const struct pcap_pkthdr * h, const u_char * p)
{
	struct tm * s_time;
	static struct timeval previous_print_time;
	struct timeval diff_time;
	static unsigned long count;

	count++;


	calc_diff_time(&previous_print_time, &h->ts, &diff_time);

	if (diff_time.tv_sec >= 1) {
		time_t sec_now = h->ts.tv_sec;
		s_time = localtime(&sec_now);

		printf("%04d/%02d/%02d %02d:%02d:%02d.%08d   %8d packet send/receive\n",
			s_time->tm_year + 1900,
			s_time->tm_mon,
			s_time->tm_mday,
			s_time->tm_hour,
			s_time->tm_min,
			s_time->tm_sec,
			h->ts.tv_usec,
			count
		);

		previous_print_time = h->ts;
		count = 0;
	}

	DEBUGPRINTF("%04d/%02d/%02d %02d:%02d:%02d.%08d\n",
		s_time->tm_year + 1900,
		s_time->tm_mon,
		s_time->tm_mday,
		s_time->tm_hour,
		s_time->tm_min,
		s_time->tm_sec,
		h->ts.tv_usec,
		count
	);
	DEBUGDUMP(p, h->caplen);
	DEBUGPRINTF("\n\n");

}




void dump(const u_char * p, int n)
{
	int i;

	for (i = 0; i < n; i++) {
		printf("%02x ", p[i]);
		if (i % 16 == 15)
			printf("\n");
	}
	printf("\n");
}




char * join_blank(char * s, char ** arg)
{
	int i = 0;

	for (i = 0; arg[i] != NULL; i++) {
		strcat(s, arg[i]);
		strcat(s, " ");
	}

	return s;
}





