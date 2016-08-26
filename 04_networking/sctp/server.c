#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <netinet/sctp.h>




int main(int argc, char ** argv)
{
	int sock;
	struct sockaddr_in ownaddr;
	struct sockaddr_in ownaddr_add[16];
	int i;

	if ((sock = socket(AF_INET, SOCK_SEQPACKET, IPPROTO_SCTP)) < 0) {
		perror("socket error");
		exit(1);
	}


	/* Bind address */
	memset(&ownaddr, 0, sizeof(ownaddr));
	for (i = 0; i < 16; i++) 
		memset(&ownaddr_add[i], 0, sizeof(ownaddr_add[i]));
	
	

	/* own address */
	ownaddr.sin_addr.s_addr        = inet_addr("127.0.0.1");
	ownaddr.sin_port = htons(2000);
	ownaddr_add[0].sin_addr.s_addr = inet_addr("127.0.0.2");
	ownaddr_add[1].sin_addr.s_addr = inet_addr("127.0.0.3");

	

	
	ownaddr.sin_family = PF_INET;
	if (bind(sock, (struct sockaddr *)&ownaddr, sizeof(struct sockaddr_in)) < 0) {
		perror("bind error\n");
		exit(1);
	}
	
	i = 0;
	while (ownaddr_add[i].sin_addr.s_addr != 0) {
		ownaddr_add[i].sin_family = PF_INET;
		ownaddr_add[i].sin_port = htons(2000);

 		if (sctp_bindx(sock, (struct sockaddr *)&ownaddr_add[i], 1, SCTP_BINDX_ADD_ADDR)) {
			perror("bind secondary.. addr error\n");
			fprintf(stderr, "continue\n");
		}
		i++;
	}

	
	struct sctp_event_subscribe events;
	memset(&events, 0, sizeof(events));
	events.sctp_data_io_event = 1;
	if (setsockopt(sock, SOL_SCTP, SCTP_EVENTS, &events, sizeof(events)) < 0) {
		printf("setsockopt error()\n");
	}


	if (listen(sock, 1) < 0) {
		perror("listen error");
		exit(1);
	}

        fd_set fds;
        int maxfd_num;
        struct timeval sel_wait = {0, 50000};   /* sec, usec */

        maxfd_num = sock;


	char peermsg[2048];
	while(1) {
		/*
		int sctp_recvmsg(int sd, void * msg, size_t len,
				struct sockaddr * from, socklen_t * fromlen,
				struct sctp_sndrcvinfo * sinfo, int * msg_flags);
		*/

                FD_ZERO(&fds);
                FD_SET(0, &fds);
                FD_SET(sock, &fds);

                if (select(maxfd_num + 1, &fds, NULL, NULL, &sel_wait) < 0) {
                        perror("select() error\n");
                        exit(1);
                }	


                if (FD_ISSET(sock, &fds)) {
			int nrecv;
			struct sctp_sndrcvinfo sinfo = {0};

			nrecv = sctp_recvmsg(sock, peermsg, 2048,
						NULL, NULL, &sinfo, NULL);
			if (nrecv < 0) {
				perror("sctp_recvmsg error");
				exit(1);
			}
			peermsg[nrecv] = '\0';
			printf("sid:%-2u  ssn:%-8u  : %s\n", sinfo.sinfo_stream, 
						sinfo.sinfo_ssn,
						peermsg);
		}
                if (FD_ISSET(0, &fds)) {        /* stdin */
                        char buf[1024];
                        char additional_ip[1024];
                        struct sockaddr_in additional_addr;

                        fgets(buf, 1024, stdin);
                        if (strncmp(buf, "bindx", 5) == 0) {
                                char * p = strchr(buf, ' ');
                                if (p != NULL) {
                                        strcpy(additional_ip, p+1);


                                        memset(&additional_addr, 0, sizeof(additional_addr));
                                        additional_addr.sin_addr.s_addr = inet_addr(additional_ip);
                                        additional_addr.sin_family = PF_INET;
                                        additional_addr.sin_port = htons(2000);

                                        if (sctp_bindx(sock, (struct sockaddr *)&additional_addr, 1, SCTP_BINDX_ADD_ADDR)) {
                                                perror("bindx() error\n");
                                                fprintf(stderr, "continue\n");
                                        }
                                        else {
                                                printf("bindx() success\n", additional_ip);
                                        }
                                }
                        }
		}
	}

	return 0;
}




