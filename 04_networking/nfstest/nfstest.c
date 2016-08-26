#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>


int main(int argc, char ** argv)
{
        int size = 1024;
        int i;
        if (argc > 1) {
                size = strtol(argv[1], NULL, 10);
        }

        struct timeval tv_before;
        struct timeval tv_after;
        struct timeval tv_diff;
        struct timeval tv_total;

        FILE * fp;

        int fd = open("./hoge", O_RDWR | O_CREAT | O_TRUNC, S_IRWXU);
        if (fd == -1) {
                printf("file open fail\n");
                exit(1);
        }


        char * p = malloc(size);
        if (p == NULL) {
                printf("malloc fail\n");
                exit(1);
        }

        int nwrite;
        tv_total.tv_sec  = 0;
        tv_total.tv_usec = 0;
        for (i = 0; i < 10; i++) {
                gettimeofday(&tv_before, NULL);
                nwrite = write(fd, p, size);
                if (nwrite < size) {
                        perror("file write fail ");
                        printf("fd : %d\n", fd);
                        exit(1);
                }
                gettimeofday(&tv_after, NULL);

                tv_diff.tv_sec  = tv_after.tv_sec  - tv_before.tv_sec;
                tv_diff.tv_usec = tv_after.tv_usec - tv_before.tv_usec;
                printf("%d time : %ld.%06ld\n", i, tv_diff.tv_sec, tv_diff.tv_usec);

                tv_total.tv_sec  += tv_diff.tv_sec;
                tv_total.tv_usec += tv_diff.tv_usec;
        }

        printf("\n");
        printf("total   : %ld.%06ld\n", tv_total.tv_sec, tv_total.tv_usec);

        close(fd);

        return 0;
}

