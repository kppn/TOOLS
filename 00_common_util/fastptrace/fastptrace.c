#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <errno.h>
#include <stdint.h>


void print_usage(void)
{
	printf(
"fastptrace pid addr byte"			"\n"
"     e.g.  ./fastptrace 4091 0x00123481 30"	"\n"
""						"\n"
	);

	return;
}


uint32_t bswap32(uint32_t x)
{
	x = (x >>  8 & 0x00ff00ff) | (x <<  8 & 0xff00ff00);
	x = (x >> 16 & 0x0000ffff) | (x << 16 & 0xffff0000);
	
	return x;
}


uint64_t bswap64(uint64_t x)
{
	x = (x >>  8 & 0x00ff00ff00ff00ffL) | (x <<  8 & 0xff00ff00ff00ff00L);
	x = (x >> 16 & 0x0000ffff0000ffffL) | (x << 16 & 0xffff0000ffff0000L);
	x = (x >> 32 & 0x00000000ffffffffL) | (x << 32 & 0xffffffff00000000L);
	
	return x;
}



int main(int argc, char ** argv)
{
	pid_t pid;
	void * addr;
	long data;
	unsigned long len;
	int status;
	int i = 0;
	
	if (argc < 4) {
		print_usage();
		exit(1);
	}
	pid  = (pid_t)strtol(argv[1], NULL, 10);
	addr = (void *)strtoul(argv[2], NULL, 0);
	len  = strtoul(argv[3], NULL, 0);
	
	for (i = 0; i < len; i += sizeof(long)) {
		if (ptrace(PTRACE_ATTACH, pid, NULL, NULL) == -1) {
			perror("ptrace(PTRACE_ATTACH, %d) error ");
			exit(1);
		}
		waitpid(pid, &status, 0);
		
		errno = 0;
		data = ptrace(PTRACE_PEEKDATA, pid, addr + i, NULL);
		if ( data == -1 && errno != 0) {
			perror("ptrace(PTRACE_PEEKDATA) error ");
		}
		else {
			if (sizeof(long) == 4) {
				data = bswap32(data);
				printf("%p: %08x\n", addr + i, data);
			}
			else {
				data = bswap64(data);
				printf("%p: %016lx\n", addr + i, data);
			}
		}
		
		if (ptrace(PTRACE_DETACH, pid, NULL, NULL) == -1) {
			perror("ptrace(PTRACE_DETACH, %d) error ");
		}
		
		if (i != 0) 
			usleep(20000);
	}
	
	return 0;
}

