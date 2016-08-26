/**************************************************************************
 *
 * stc3    SEB M3UA message tps counter (mark 3)
 *
 *
 *    2014/12/19   v0.0 release
 *                        t.kondoh
 *
 *                                    Original version written by t.kondoh
 *                                    Copyleft -- all rights reserved   
 *
 *************************************************************************/


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <signal.h>
#include <pthread.h>
#include <pcap/pcap.h>




useconds_t sleeptime = 999999;	/* micro seconds */
int buffer_size = 134217728;    /* byte */




pcap_t *pd;
unsigned long long packet_count = 0;
unsigned long long packet_byte  = 0;
char device[2048];
char expression[4096];


#ifdef DEBUG
#	define  DEBUGPRINTF	printf
#	define	DEBUGDUMP	dump
#else
#	define  DEBUGPRINTF
#	define  DEBUGDUMP
#endif



void handle_sig(int sig)
{
	struct pcap_stat stat;
	
	if (pcap_stats(pd, &stat) < 0) {
		(void)fprintf(stderr, "pcap_stats: %s\n", pcap_geterr(pd));
	}
	else {
		(void)printf("\n");
		(void)printf("%u packet received\n", stat.ps_recv);
		(void)printf("%u packet dropped by interface\n", stat.ps_ifdrop);
		(void)printf("%u packet dropped by kernel\n", stat.ps_drop);
		
		fflush (stdout);
	}

	exit(1);
}




void pcap_open(void)
{
	int snaplen = 84;
	int pflag = 0;
	int timeout = 0;	/* never timeout */
	char ebuf[PCAP_ERRBUF_SIZE];
	struct bpf_program fcode;

	if ((pd = pcap_open_live(device, snaplen, !pflag, timeout, ebuf)) == NULL) {
		printf("pcap_open_live fail\n");
		exit(1);
	}
	pcap_set_buffer_size(pd, buffer_size);

	if (pcap_compile(pd, &fcode, expression, 1, 0) < 0) {
		printf("pcap_compile fail\n");
		exit(1);
	}
	if (pcap_setfilter(pd, &fcode) < 0) {
		printf("pcap_setfilter fail\n");
		exit(1);
	}
}




void pcap_count(void)
{
	struct pcap_pkthdr *pkt_header;
	const u_char *pkt_data;
	
	while (1) {
		int nextret;
		
		nextret = pcap_next_ex(pd, &pkt_header, &pkt_data);
		if (nextret == 1) {
			packet_count++;
			packet_byte += pkt_header->caplen;
		}
		else if (nextret == 0) {
			/* timeout */
			/* do nothing */
		}
		else if (nextret == -1) {
			fprintf(stderr, "pcap_next_ex error occured\n");
			exit(1);
		}
		else {
			fprintf(stderr, "pcap_next_ex unknown error occured\n");
			exit(1);
		}
	}
}



void *pcap_exec(void *p)
{
	
	pcap_open();
	pcap_count();
	
	return NULL;
}






void * tps_measuament(void *p)
{
	unsigned long long packet_count_old  = 0;
	unsigned long long packet_count_diff = 0;
	unsigned long long packet_byte_old   = 0;
	unsigned long long packet_byte_diff  = 0;
	struct timeval cur;
	struct timeval old;
	struct tm * tm;

	gettimeofday(&old, NULL);
	while (1) {
		usleep(sleeptime);
		
		
		packet_count_diff = packet_count - packet_count_old;
		if (packet_count_old > packet_count)
			packet_count_diff = packet_count_old - packet_count;
		
		packet_byte_diff = packet_byte - packet_byte_old;
		if (packet_byte_old > packet_byte)
			packet_byte_diff = packet_byte_old - packet_byte;


		gettimeofday(&cur, NULL);
		tm = localtime(&cur.tv_sec);
		
		printf("%04d/%02d/%02d %02d:%02d:%02d.%06d : ",
				tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
				tm->tm_hour, tm->tm_min, tm->tm_sec,
				cur.tv_usec);
		printf("%10d, %16d\n", 
				packet_count_diff,
				packet_byte_diff);
		
		fflush (stdout);
		
		packet_count_old = packet_count;
		packet_byte_old = packet_byte;
	}
	
	return NULL;
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




int main(int argc, char ** argv)
{
	if (argc < 2) {
		printf("stc interface [expression]\n");
		printf("\n");
		printf("	expression : man tcpdump\n");
		exit(1);
	}
	strcpy(device, argv[1]);

	expression[0] = '\0';
	if (argc >= 3) {
		join_blank(expression, &argv[2]);
	}
	else {
		expression[0] = '\0';
	}
	printf("expression : %s\n", expression);
	
	signal(SIGHUP, handle_sig);
	signal(SIGINT, handle_sig);
	signal(SIGQUIT, handle_sig);
	signal(SIGKILL, handle_sig);
	signal(SIGSEGV, handle_sig);
	signal(SIGTERM, handle_sig);
	signal(SIGSTOP, handle_sig);
	signal(SIGTSTP, handle_sig);
	
	
	pthread_t th_pcap;
	pthread_t th_disp;
	if (pthread_create(&th_pcap, NULL, pcap_exec, NULL) != 0) {
		fprintf(stderr, "pthread_create(.. pcap_exec ..) error\n");
		exit(1);
	}
	if (pthread_create(&th_disp, NULL, tps_measuament, NULL) != 0) {
		fprintf(stderr, "pthread_create(.. pcap_exec ..) error\n");
		exit(1);
	}
	pthread_join(th_pcap, NULL);
	pthread_join(th_disp, NULL);
	
	
	return 0;
}



