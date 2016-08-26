/************************************************************************/
/* shmdump_ex -- shared memory dump tool, extended
/* 
/* This program is free software, under GPLv2.
/* Copyleft (C)  T.Kondoh, 2013
/************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <unistd.h>
#include <limits.h>
#include <errno.h>
#include <stdarg.h>

#include <sys/ipc.h>
#include <sys/shm.h>




/************************************************************************/
/* 									*/
/* Const Value Definition / Structure Declaration			*/
/* 									*/
/************************************************************************/

/* 
 * �Хåե���������16���ܿ��Ȥ��뤳�ȡ�
 * ���������ꡢ��ĥƥ����Ƚ��Ϥξ��ϡ�16�Х�����˥��ե��åȤ����
 * ���� (shmdump�˹�碌������)���ͤΤ��ᡢ���٤��ɤ߹��ߤ�16���ܿ���
 * ���ʤ���н�����̵�Ѥ�ʣ���ˤʤ롣
 */
#define	DUMP_BUFSIZE	8192



struct segment {
	unsigned long offset;
	unsigned long size;
};


struct speed_treatment{
	unsigned long byte;
	unsigned long delay_ms;
};



#define NumSegmentSlot	64			/* �������Ȼ��ꥪ�ץ����κ���� */

struct dump_attribute {
	key_t shmkey;
		/* e.g.) -M 0xAAAA						*/
		/* �оݤ�shmkey��ʣ��������Բġ�shmid��Ʊ���˻�����Բ�	*/
		/* shmkey_specified == 0 �ΤȤ������Ƥ�����			*/
	int shmkey_specified;
		/* 0: shmkey����ʤ�, ��0: shmkey���ꤢ��			*/
	
	
	int shmid;
		/* e.g.) -m 1234						*/
		/* �оݤ�shmid��ʣ��������Բġ�shmkey��Ʊ���˻�����Բ�	*/
		/* shmid_specified == 0 �ΤȤ������Ƥ�����			*/
	int shmid_specified;
		/* 0: shmid����ʤ�, ��0: shmid���ꤢ��				*/
	
	
	/*
	 * ���������ޤ��ϥ֥�å��Τɤ������ꤵ��ʤ���Х��顼��
	 * ��ξ�ԤȤ��ά�����������ΰ�٤Ȥ������ͤˤ����뤬����ͭ����
	 * �Υ��������礭���� *�԰դ�* �ޥ������٤�ݤ��Ƥ��ޤ����⤷��ʤ���
	 */
	unsigned long dump_size;
		/* e.g.) -s 1234						*/
		/* ����ץ�������64�ӥåȤξ�硢�����128GiB�����¤���		*/
		/* dump_size_specified == 0 �ΤȤ������Ƥ�����			*/
		/* block��Ʊ���˻�����Բ�					*/
	int dump_size_specified;
		/* 0: dump_size����ʤ�, ��0: dump_size���ꤢ��			*/
	
	
	unsigned long block_size;
		/* e.g.) -b 1234						*/
		/* �֥�å���������64�ӥåȤξ�硢�����128GiB�����¤���	*/
		/* block_size_specified == 0 �ΤȤ������Ƥ�����			*/
		/* dump_size��Ʊ���˻�����Բ�					*/
	int block_size_specified;
		/* 0: block_size����ʤ�, ��0: block_size���ꤢ��		*/
	
	
	/* 
	 * block_count �� segment ����ϡ�block_size�����ꤵ��Ƥ��ʤ����
	 * ����Ǥ��ʤ�
	 */
	unsigned long block_count;
		/* e.g.) -c 1234						*/
		/* �֥�å��ο���64�ӥåȤξ�硢128Gi�����¤���		*/
		/* block_count_specified == 0 �ΤȤ������Ƥ�����		*/
	int block_count_specified;
		/* 0: block_count����ʤ�, ��0: block_count���ꤢ��		*/
	
	
	struct segment seg[NumSegmentSlot];
		/* e.g.) -S 16:12 -S 32:1					*/
		/* ��������Ƥ� 0 �� segment_num - 1 ���ϰϤ�ͭ���͡�����ʳ���	*/
		/* ����								*/
	
	unsigned long segment_num;
		/* segment����ο���-S ���ץ������˥��󥯥����		*/
		/* ������ؿ��� 0 �˽��������					*/
		/* �֥�å����ꤢ��ǥ������Ȼ���̵�� �ξ�硢����׽�����	*/
		/* ���̲����뤿�ᡢ���Τ褦�˥֥�å���Ʊ���������Υ������Ȥ�	*/
		/* �ġ��뼫�Ȥ���������						*/
		/*     segment_num   = 1					*/
		/*     seg[0].offset = 0					*/
		/*     seg[0].size   = block_size				*/
	
	
	struct speed_treatment treat;
		/* e.g.) -d 1024:500						*/
		/* ��ٷڸ��Τ�����ٱ䡣ʣ��������Բ�				*/
		/* treat_specified == 0 �ΤȤ������Ƥ�����			*/
	int treat_specified;
		/* 0: treat����ʤ�, ��0: treat���ꤢ�� */
	
	
	char filename[256];
		/* e.g.) -f hoge.bin						*/
		/* filename[0] == '\0' : ɸ����Ϥإƥ������Ǥ��Ф�    		*/
		/* filename[0] != '\0' : �ե�����إХ��ʥ���Ǥ��Ф�  		*/
		/* 								*/
		/* �������Τ��ᡢ�Х��ʥ��ɸ����Ϥ˽��Ϥ�����ʤ��ߤ��ʤ�	*/
	
	
	int input_stdin;
		/* ��0:ɸ�����Ϥ����ɤࡢ0:��ͭ���꤫���ɤ� 			*/
};




/* 
 * ��ͭ����Υ��ɥ쥹���ɤ߹��ߺѤߥ�����(���ե��å�)
 * ɸ�����Ϥȶ�ͭ������ɤ߹��ߤν������̲����뤿�ᡢ��ͭ���꤫���
 * ���ԡ���Х��ȥ��ȥ꡼�����ݲ����롣
 */
static void * shmaddr = NULL;
static unsigned long nread_shm = 0;


/* 
 * �ºݤ˥������Ȥ���Ƥ���shm�Υ�������
 * ��ͭ������ϰϳ������������ɻߤ��뤿��˻Ȥ���
 * shmctl(da.shmid, IPC_STAT, &shmds)�Ǽ������롣
 */
static size_t shm_segsz = 0;	




/************************************************************************/
/* 									*/
/* Function Definition							*/
/* 									*/
/************************************************************************/



static
void usage()
{
	printf(
	""											"\n"
	"NAME"											"\n"
	"       shmdump_ex  - extended shared memory dump"					"\n"
	""											"\n"
	"SYNOPSIS"										"\n"
	"       shmdump_ex [options]"								"\n"
	"       shmdump_ex -M shmkey -s size"							"\n"
	"       shmdump_ex -m shmid -s size"							"\n"
	""											"\n"
	"DESCRIPTION"										"\n"
	"       shmdump_ex��shmdump�γ�ĥ�ǤǤ��롣"						"\n"
	""											"\n"
	"  Options"										"\n"
	"      "										"\n"
	"      -M shmkey"									"\n"
	"          �оݤ�shmkey��"								"\n"
	"          ʣ��������Բġ�shmkey��Ʊ���˻�����Բġ�"					"\n"
	"      "										"\n"
	"      -m shmid"									"\n"
	"          �оݤ�shmid"									"\n"
	"          ʣ��������Բġ�shmkey��Ʊ���˻�����Բġ�"					"\n"
	"      "										"\n"
	"      -s dump_size"									"\n"
	"          ����ץ�������"								"\n"
	"          ���Ϸ����ϵ�shmdump��Ʊ����"							"\n"
	"          -b block_size��Ʊ���˻�����Բġ�64�ӥåȤξ�硢�����128GiB��"		"\n"
	"      "										"\n"
	"      -b block_size"									"\n"
	"          �֥�å���������"								"\n"
	"          �֥�å����Ȥ�1�Ԥν��Ϸ����Ȥʤ롣��Ƭ�˥��ե��åȤ��դ��ʤ�"		"\n"
	"          -s dump_size��Ʊ���˻�����Բġ�64�ӥåȤξ�硢�����128GiB��"		"\n"
	"      "										"\n"
	"      -S offset:size"									"\n"
	"          �ƥ֥�å��������ΰ�(��������)��������פ��롣"				"\n"
	"          64�Ĥޤǻ����ǽ���֥�å���Ʊ�������ǽ��Ϥ��뤬���ƥ������Ȥϰ��"	"\n"
	"          �Υ��ڡ����Ƕ��ڤ��롣"							"\n"
	"          �֥�å������������ꤵ��Ƥ��ʤ���л����Բġ��������Ȥϥ֥�å���"	"\n"
	"          ������٤��ǤϤʤ餺���ޤ��ƥ������Ȥ��ΰ褬��ʣ���ƤϤʤ�ʤ���"		"\n"
	"      "										"\n"
	"      -c block_count"									"\n"
	"          ���ꤷ���֥�å�����������פ��롣"						"\n"
	"          �֥�å������������ꤵ��Ƥ��ʤ���л����Բġ�"				"\n"
	"      "										"\n"
	"      -d byte:delay_ms"								"\n"
	"          �ٱ���ꡣbyte�����פ������delay_ms����sleep���롣"			"\n"
	"          ����ʥ����������פ���ݡ��¹ԥޥ���ؤ���٤�Ĵ�����뤿�ᡣ"		"\n"
	"      "										"\n"
	"      -f filename"									"\n"
	"          ɸ����ϤǤϤʤ������ꤷ���ե�����˥Х��ʥ�ǥ���פ��롣"			"\n"
	"          �֥�å������Ʊ���˻���Ǥ��뤬���Х��ʥ�ǡ����Ǥϳƥ֥�å���"		"\n"
	"          ������Ƚ�ǤǤ��ʤ�������ա�"						"\n"
	"      "										"\n"
	"      -"										"\n"
	"          ��ͭ����ǤϤʤ���ɸ�����Ϥ����ɤ߹��ࡣ"					"\n"
	"          ���Υ��ץ���󤬻��ꤵ��Ƥ�����硢-M, -m��̵�뤵��롣"			"\n"
	""											"\n"
	""											"\n"
	"  Exsample"										"\n"
	"  "											"\n"
	"      �¹���򼨤�����������ǤϽ��Ϥ�����դ��롣"					"\n"
	"      ��ͭ������Υǡ����ϲ������Ǥ�Ʊ��Ǥ��롣"					"\n"
	"      "										"\n"
	"      (1) ��shmdump��Ʊ���Ȥ���"							"\n"
	"                $ shmdump_ex 0x00001234 32"						"\n"
	"                          offset: +0+1+2+3 +4+5+6+7 +8+9+a+b +c+d+e+f"			"\n"
	"                0000000000000000: 00010203 04050607 08090a0b 0c0d0e0f"			"\n"
	"                0000000000000010: 10111213 14151617 18191a1b 1c1d1e1f"			"\n"
	"      "										"\n"
	"      (2) ��shmdump��Ʊ�������ץ���������"						"\n"
	"                $ ./shmdump_ex -M 0x00001234 -s 32"					"\n"
	"      "										"\n"
	"      (3) shmid����"									"\n"
	"                $ ./shmdump_ex -m 360449 -s 32"					"\n"
	"      "										"\n"
	"      (4) �֥�å�����"								"\n"
	"                $ ./shmdump_ex -M 0x00001234 -b 8"					"\n"
	"                0001020304050607"							"\n"
	"                08090a0b0c0d0e0f"							"\n"
	"                1011121314151617"							"\n"
	"                18191a1b1c1d1e1f"							"\n"
	"      "										"\n"
	"      (5) �֥�å�������Ȼ���"							"\n"
	"                $ ./shmdump_ex -M 0x00001234 -b 8 -c 2"				"\n"
	"                0001020304050607"							"\n"
	"                08090a0b0c0d0e0f"							"\n"
	"      "										"\n"
	"      (6) �֥�å����������Ȼ���"							"\n"
	"                $ ./shmdump_ex -M 0x00001234 -b 8 -S 0:2 -S 4:4"			"\n"
	"                0001 04050607"								"\n"
	"                0809 0c0d0e0f"								"\n"
	"                1011 14151617"								"\n"
	"                1819 1c1d1e1f"								"\n"
	"      "										"\n"
	"      (7) �ٱ���ꡣ16byte���Ϥ������500ms���꡼�פ���"				"\n"
	"                $ ./shmdump_ex -M 0x00001234 -s 32 -d 16:500"				"\n"
	"      "										"\n"
	"      (8) �Х��ʥ�ǥե�����ؽ���"							"\n"
	"                $ ./shmdump_ex -M 0x00001234 -s 32 -f tofile"				"\n"
	"      "										"\n"
	"      (9) ɸ�����Ϥ����ɤ߹��ߡ�"							"\n"
	"                $ cat tofile | ./shmdump_ex -M 0x00001234 -b 8 -S 0:2 -S 4:4"		"\n"
	"                0001 04050607"								"\n"
	"                0809 0c0d0e0f"								"\n"
	"                1011 14151617"								"\n"
	"                1819 1c1d1e1f"								"\n"
	""											"\n"
	""											"\n"
	"  Other Topics"									"\n"
	"  "											"\n"
	"      (1) �ե��������ꤷ�����ϥХ��ʥ�ǽ��Ϥ���롣�Х��ʥ�Ǥ��뤿�ᡢ�֥�"	"\n"
	"          �å�/�������Ȥ���ꤷ�����Ǥ⤽���ζ����ˤĤ��Ƥξ���ϻĤ�ʤ���"	"\n"
	"          ���ϻ��Υ��ޥ�ɤ��鶭�������줷�ƥƥ����Ȥǥ���פ�������Ǥ��롣"		"\n"
	"          "										"\n"
	"             $ ./shmdump_ex -M 0x00001234 -b 16 -S 0:2 -S 4:4 -S 12:1 -c 2 -f tofile"	"\n"
	"          "										"\n"
	"             $ xxd tofile"								"\n"
	"             0000000: 0001 0405 0607 0c10 1114 1516 171c       .............."		"\n"
	"          "										"\n"
	"          �����ˤϥ������ȥ��ե��åȤ�Ϣ³�Ȥʤ�褦���ꤹ�������ա�"		"\n"
	"             "										"\n"
	"             $ cat tofile | ./shmdump_ex -b 16 -S 0:2 -S 2:4 -S 6:1 -c 2"		"\n"
	"             0001 02030405 06"								"\n"
	"             1011 12131415 16"								"\n"
	""											"\n"
	"      (2) �嵭����Ѥ���ȡ�Ǥ�դΥե�������Ф��ƴʰפʥǥ������Ȥ������Ѥ���"	"\n"
	"          �����Ǥ��롣"								"\n"
	""											"\n"
	"      (3) ��shmdump�ϳ�����ƺѤߤζ�ͭ����Υ�����������å����Ƥ��ʤ����ᡢ"	"\n"
	"          �������λ�������segmentation fault�Ȥʤ롣"				"\n"
	"          shmdump_ex�϶�ͭ����Υ�����������å����Ƥ��롣������ƥ�������"		"\n"
	"          Ķ������꤬����Ƥ⡢������ƥ�����ʬ�������Ϥ��ʤ���"			"\n"
	""											"\n"
	);

	return;
}




/*----------------------------------------------------------------------*/
/* 									*/
/* Utility Function							*/
/* 									*/
/*----------------------------------------------------------------------*/

/*-----------------------------------------------------------------------*/
unsigned long long max(unsigned long long a, unsigned long long b)
{
	return (a > b) ? a : b;
}





/*-----------------------------------------------------------------------*/
unsigned long long min(unsigned long long a, unsigned long long b)
{
	return (a < b) ? a : b;
}





/*-----------------------------------------------------------------------*/
int isalldigits(const char * s)
{
	while (*s) {
		if (! isdigit(*s))
			return 0;
		s++;
	}
	
	return 1;
}





/*-----------------------------------------------------------------------*/
char * strapbrk(const char *s, const char *accept)
{
	int i;
	size_t s_len = strlen(s);

	if (s == NULL || accept == NULL)
		return NULL;

	for (i = 0; i < s_len; i++) {
		if (strchr(accept, s[i]) == NULL)
			return (char *)&s[i];
	}

	return NULL;
}





/*-----------------------------------------------------------------------*/
/*
 * split_num
 *
 *    description
 *	�ǥ�ߥ���ʬ�䤵�줿�������¤Ӥ�ѡ������Ʋ��Ѱ����ѿ�(unsigned long
 *	�ؤΥݥ���)�λؤ��ΰ�˳�Ǽ���롣
 *
 *    exsample1
 *	nsplit = split_num("123:456:789", ":", 2, &a, &b);
 *	--- result, nsplit = 2, a = 123, b = 456
 *
 *    exsample2
 *	nsplit = split_num("123", ":", 2, &a, &b);
 *	--- result, nsplit = 1, a = 123, b = no change
 *
 *    caution!
 *	���δؿ��� strtok() ��ȤäƤ��롣
 *
 *    tips
 *	���δؿ���sscanf/strtok�����̥С������Ǥ��롣
 *	�⤷��ĥ�������ʤä��餽��餬�Ȥ��ʤ������褺��Ƥ���뤳�ȡ�
 */
int split_num(char * s, const char * delim, int n, ...)
{
	int nsplit = 0;
	char * p;
	unsigned long * nump;
	va_list list;
	char accept[1024] = "0123456789";
	
	
	if (s == NULL || delim == NULL || n < 0)
		return -1;
	
	strcat(accept, delim);
	if (strapbrk(s, accept) != NULL)
		return -1;
	
	/* ���λ�����s�ˤϥǥ�ߥ����Ͽ��������ޤޤ�Ƥ��ʤ� */
	
	va_start(list, n);
	
	do {
		errno = 0;
		p = strtok(s, delim);
		if (p == NULL)
			break;
		
		nump = va_arg(list, unsigned long *);
		if (nump == NULL)
			return -1;
		*nump = strtoul(p, NULL, 10);
		
		if (errno == ERANGE)
			return -1;
		
		s = NULL;
		nsplit++;
		
		if (nsplit == n)
			break;
	} while (1);
	
	va_end(list);
	
	return nsplit;
}





/*----------------------------------------------------------------------*/
/* 									*/
/* Application Domain Function						*/
/* 									*/
/*----------------------------------------------------------------------*/


/*-----------------------------------------------------------------------*/
static 
int get_shmid(key_t key)
{
	return shmget(key, 0, 0);
}





/*-----------------------------------------------------------------------*/
static
void * attach_shmid(int shmid)
{
	shmaddr = shmat(shmid, NULL, 0);
	if (shmaddr == (void *)-1)
		return NULL;
	
	return shmaddr;
}





/*-----------------------------------------------------------------------*/
static
void * attach_shm(struct dump_attribute * da)
{
	int shmid;
	
	if (da->shmkey_specified) {
		shmid = get_shmid(da->shmkey);
		if (shmid == -1)
			return NULL;
		da->shmid = shmid;
	}
	
	return attach_shmid(da->shmid);
}





/*-----------------------------------------------------------------------*/
/* 
 * read_fromstdin
 *
 *	��ͭ���꤫��Υ��ԡ���ɸ�����Ϥ�����ɤ߹��ߤΰ㤤���ä���
 *	(��ݲ�)�����Wrapper�ؿ�
 */
static
size_t read_fromstdin(unsigned char * buf, size_t size)
{
	size_t nread;

	nread = fread(buf, size, 1, stdin);

	return nread * size;
}





/*-----------------------------------------------------------------------*/
/* 
 * read_fromshm
 *
 *	��ͭ���꤫��Υ��ԡ���ɸ�����Ϥ�����ɤ߹��ߤΰ㤤���ä���
 *	(��ݲ�)�����Wrapper�ؿ�
 */
static
size_t read_fromshm(unsigned char * buf, size_t size)
{
	size_t inh_readsize;
	
	if (nread_shm >= shm_segsz)
		return 0;
	
	if ((nread_shm + size) > shm_segsz)
		inh_readsize = shm_segsz - nread_shm;
	else
		inh_readsize = size;
	
	memcpy(buf, shmaddr + nread_shm, inh_readsize);
	nread_shm += inh_readsize;
	
	return inh_readsize;
}





/*-----------------------------------------------------------------------*/
static
size_t write_ascii_bysize(FILE * fp, struct dump_attribute * da,
			  size_t (*readfunc)(unsigned char *, size_t)
			 )
{
	unsigned char buf[DUMP_BUFSIZE];
	unsigned long i;
	unsigned long read_size = 0;
	unsigned long nread = 0;
	unsigned long nwrite = 0;
	unsigned long lefttodelay;	/* usleep�������ޤǤλĤ���ϥХ��ȡ����������� */
	char hexbuf[3] = {0, 0, 0};
	
	
	if (da->treat_specified) {
		lefttodelay = da->treat.byte;
	}
	else {
		da->treat.delay_ms = 0;
		lefttodelay = ULONG_MAX;
	}
	
	fprintf(fp, "          offset: +0+1+2+3 +4+5+6+7 +8+9+a+b +c+d+e+f\n");
	
	while (1) {
		if (nwrite >= da->dump_size)
			break;
		read_size = min(da->dump_size, DUMP_BUFSIZE);
		if ((nread = readfunc(buf, read_size)) <= 0)
			break;
	
		/* 
		 * ���Υץ����Υۥåȥ��ݥåȡ�
		 * 
		 * �Х���ñ�̤η�¬��sleep������뤿�ᡢ�롼�ץ������󥰤�
		 * ���ʤ���
		 * 
		 * 16��ʸ����ؤ��Ѵ���DIY����¬�����Ȥ���pritnf("%02x")����2��
		 * �ʾ��٤��ʤ뤿�ᡣâ�������ʤ��®�������ä�ʬ�����ӽ����Ƥ�
		 * ��̣��̵����
		 *     * �Ƕ��x86�ץ��å���ʬ��ͽ¬��ͥ�������ν����Υƥ���
		 *       �ץ�����¬�ä��Ȥ���ʬ��ͽ¬�ߥ������٤�3%�ʲ���
		 *     * �ޤ���ʬ��ͽ¬������Ƥ�ѥ��ץ饤��ϥ����ɤϵ����ʤ�
		 *       (ROB����Retirement����ʤ�����)��
		 *     * ���Υ롼�פν���������I-TLB�˺ܤ�
		 *     * ���Ѽ����֤�������ʬ�����ӽ�������硢IPC�Ϥ鷺��
		 *       (0.04��0.12/Cycle)�˸��夹�뤬��̿�������ʬ�ˤ�ä�
		 *       �껦�����٤��ʤ롣
		 * �ܤ�����Intel��Ŭ���ޥ˥奢��򻲾ȡ�
		 */
		for(i = 0; i < nread; i++) {
			if(i % 16 == 0)
				fprintf(fp, "%016lx: ", i);
			
			unsigned char num_hi = buf[i] / 16;
			unsigned char num_lo = buf[i] % 16;
			hexbuf[0] = (num_hi < 10) ? (num_hi + '0') : (num_hi - 10 + 'a');
			hexbuf[1] = (num_lo < 10) ? (num_lo + '0') : (num_lo - 10 + 'a');
			/* hexbuf[2]�Ͼ��'\0' */
			fputs(hexbuf, fp);
			
			nwrite++;
			
			if (i % 4 == 3)
				fprintf(fp, " ");
			if (i % 16 == 15)
				fprintf(fp, "\n");
			
			/* 
			 * da->treat.byte���sleep��
			 * nwrite % da->treat.byte �Ȥ����ܿ���Ƚ�ꤹ���⤢�뤬��������
			 * �٤����黻�����ѿ��Ǥ��뤿��տ��ξ軻(����ѥ���ζ��ʽ��
			 * ��)�ؤ��Ѵ��⤵��ʤ��������󥿤ˤ��롣
			 */
			lefttodelay--;
			if (lefttodelay == 0) {
				fflush(stdout);
				usleep(da->treat.delay_ms * 1000);
				lefttodelay = da->treat.byte;
			}
		}
	}
	fprintf(fp, "\n");
	
	return (size_t)nwrite;
}



/*-----------------------------------------------------------------------*/
static
size_t write_ascii_byblock(FILE * fp, struct dump_attribute * da,
		  	   size_t (*readfunc)(unsigned char *, size_t)
		  	  )
{
	unsigned char buf[DUMP_BUFSIZE];
	unsigned long si;
	unsigned long bi;
	unsigned long nread = 0;
	unsigned long nwrite = 0;
	unsigned long ncount = 0;	/* �֥�å��ν��ϲ��					*/
	unsigned long lefttodelay;	/* usleep�������ޤǤλĤ���ϥХ��ȡ�����������	*/
	char hexbuf[3] = {0, 0, 0};
	
	
	if (da->treat_specified) {
		lefttodelay = da->treat.byte;
	}
	else {
		da->treat.delay_ms = 0;
		lefttodelay = ULONG_MAX;
	}
	
	
	while ((nread = readfunc(buf, da->block_size))) {
		if (nread < da->block_size)
			break;
		if (da->block_count_specified && (ncount >= da->block_count))
			break;
		
		/* 
		 * 1�ĤΥ֥�å��򼡤η��ǽ��� "HHHHHHHH HHHH HHHHHHHH HH\n"
		 *                              ^^^^^^^^ ^^^^ ^^^^^^^^ ^^
		 *                              seg[0]   seg[1] set[2] seg[3]
		 */
		for (si = 0; si < da->segment_num; si++) {
			struct segment * seg = &da->seg[si];

			for (bi = seg->offset; bi < (seg->offset + seg->size); bi++) {
				unsigned char num_hi = buf[bi] / 16;
				unsigned char num_lo = buf[bi] % 16;
				hexbuf[0] = (num_hi < 10) ? (num_hi + '0') : (num_hi - 10 + 'a');
				hexbuf[1] = (num_lo < 10) ? (num_lo + '0') : (num_lo - 10 + 'a');
				/* hexbuf[2]�Ͼ��'\0' */
				fputs(hexbuf, fp);
				
				nwrite++;
				
				lefttodelay--;
				if (lefttodelay == 0) {
					fflush(stdout);
					usleep(da->treat.delay_ms * 1000);
					lefttodelay = da->treat.byte;
				}
			}
			fprintf(fp, " ");
		}
		
		fprintf(fp, "\n");
		
		ncount++;
	}
	fprintf(fp, "\n");
	
	
	return nwrite;
}





/*-----------------------------------------------------------------------*/
static
size_t write_binary_bysize(FILE * fp, struct dump_attribute * da,
			   size_t (*readfunc)(unsigned char *, size_t)
			  )
{
	unsigned char buf[DUMP_BUFSIZE];
	unsigned long i;
	unsigned long read_size = 0;
	unsigned long nread = 0;
	unsigned long nwrite = 0;
	unsigned long lefttodelay;	/* usleep�������ޤǤλĤ���ϥХ��ȡ����������� */
	
	
	if (da->treat_specified) {
		lefttodelay = da->treat.byte;
	}
	else {
		da->treat.delay_ms = 0;
		lefttodelay = ULONG_MAX;
	}
	
	while (1) {
		if (nwrite >= da->dump_size)
			break;
		read_size = min(da->dump_size, DUMP_BUFSIZE);
		if ((nread = readfunc(buf, read_size)) <= 0)
			break;
	
		for(i = 0; i < nread; i++) {
			fwrite(&buf[i], 1, 1, fp);
			
			nwrite++;
			
			lefttodelay--;
			if (lefttodelay == 0) {
				fflush(fp);
				usleep(da->treat.delay_ms * 1000);
				lefttodelay = da->treat.byte;
			}
		}
	}
	
	return (size_t)nwrite;
}





/*-----------------------------------------------------------------------*/
static
size_t write_binary_byblock(FILE * fp, struct dump_attribute * da,
		  	   size_t (*readfunc)(unsigned char *, size_t)
		  	  )
{
	unsigned char buf[DUMP_BUFSIZE];
	unsigned long si;
	unsigned long bi;
	unsigned long nread = 0;
	unsigned long nwrite = 0;
	unsigned long ncount = 0;	/* �֥�å��ν��ϲ��					*/
	unsigned long lefttodelay;	/* usleep�������ޤǤλĤ���ϥХ��ȡ�����������	*/
	
	
	if (da->treat_specified) {
		lefttodelay = da->treat.byte;
	}
	else {
		da->treat.delay_ms = 0;
		lefttodelay = ULONG_MAX;
	}
	
	
	while ((nread = readfunc(buf, da->block_size))) {
		if (nread < da->block_size)
			break;
		if (da->block_count_specified && (ncount >= da->block_count))
			break;
		
		for (si = 0; si < da->segment_num; si++) {
			struct segment * seg = &da->seg[si];

			for (bi = seg->offset; bi < (seg->offset + seg->size); bi++) {
				fwrite(&buf[bi], 1, 1, fp);
				
				nwrite++;
				
				lefttodelay--;
				if (lefttodelay == 0) {
					fflush(stdout);
					usleep(da->treat.delay_ms * 1000);
					lefttodelay = da->treat.byte;
				}
			}
		}
		
		ncount++;
	}
	
	
	return nwrite;
}





/*-----------------------------------------------------------------------*/
static
size_t dump(struct dump_attribute * da)
{
	FILE * fp;
	size_t (*readfunc)(unsigned char *, size_t);
	unsigned long dumped;
	
	
	if (da->block_size_specified && da->segment_num == 0) {
		da->segment_num   = 1;
		da->seg[0].offset = 0;
		da->seg[0].size   = da->block_size;
	}
	
	
	/* -M,-m����(��ͭ����)���⡢'-'����(ɸ�����Ϥ����ɤ߹���)��ͥ�� */
	if (da->input_stdin)
		readfunc = read_fromstdin;
	else
		readfunc = read_fromshm;
	
	
	if (da->filename[0] == '\0') {
		/* ASCII��ɸ����Ϥ� */
		
		fp = stdout;
		
		if (da->dump_size_specified)
			dumped = write_ascii_bysize(fp, da, readfunc);
		else
			dumped = write_ascii_byblock(fp, da, readfunc);
	}
	else {
		/* Binary�ǥե������ */
		
		if ((fp = fopen(da->filename, "wb")) == NULL) {
			fprintf(stderr, "file %s open fail\n\n", da->filename);
			exit(1);
		}
		
		if (da->dump_size_specified)
			dumped = write_binary_bysize(fp, da, readfunc);
		else
			dumped = write_binary_byblock(fp, da, readfunc);
	}
	
	
	return dumped;
}





/*-----------------------------------------------------------------------*/
static 
int isvalid_range(struct dump_attribute * da)
{
	int i;
	unsigned long size_max = 4294967295UL;
	
	
	if (sizeof(long) > 4)
		size_max *= 32;	/* Max on 64 bit system. 128Giga */
	
	
	if (da->dump_size_specified) {
		if ((da->dump_size == 0) || (da->dump_size > size_max)) {
			fprintf(stderr, "Dump  size  : 1 to %lu\n", size_max);
			goto INVALID;
		}
	}
	
	if (da->block_size_specified) {
		if ((da->block_size == 0) || (da->block_size > DUMP_BUFSIZE)) {
			fprintf(stderr, "Block size  : 1 to %d\n", DUMP_BUFSIZE);
			goto INVALID;
		}
	}
	
	if (da->block_count_specified) {
		if ((da->block_count == 0) || (da->block_count > size_max)) {
			fprintf(stderr, "Block count : 1 to %lu\n", size_max);
			goto INVALID;
		}
	
	}
	
	for (i = 0; i < da->segment_num; i++) {
		if ((da->seg[i].offset > (size_max - 1)) ||
		    (da->seg[i].size   > DUMP_BUFSIZE)   ||
		    (da->seg[i].size   == 0)               ) 
		{
			fprintf(stderr, "segment -- offset : 0 to %lu, size : 1 to %u\n",
					 size_max - 1, DUMP_BUFSIZE);
			goto INVALID;
		}
	}
	
	if (da->treat_specified) {
		struct speed_treatment * treat = &da->treat;
		if ((treat->byte == 0)       || 
		    (treat->byte > size_max) || 
		    (treat->delay_ms > 20000)   )
		{
			fprintf(stderr, "byte: 1 to %lu, delay(ms): 0 to %d\n", size_max, 20000);
			goto INVALID;
		}
	}
	
	
	return 1;


    INVALID:
	return 0;
}





/*-----------------------------------------------------------------------*/
static
int get_segment(const char * optarg, struct dump_attribute * da) 
{
	struct segment * seg;
	char buf[1024];
	int nparsed;
	
	
	seg = &da->seg[da->segment_num];
	
	if (da->segment_num >= NumSegmentSlot)
		goto ERROR;
	
	if (strlen(optarg) + 1 >= sizeof(buf))
		goto ERROR;
	
	strcpy(buf, optarg);
	nparsed = split_num(buf, ":", 2, &seg->offset, &seg->size);
	if (nparsed != 2)
		goto ERROR;
	
	
	da->segment_num++;
	
	return da->segment_num;
	
	
    ERROR:
	seg->offset = 0;
	seg->size   = 0;
	
	return -1;
}





/*-----------------------------------------------------------------------*/
static
int get_delay(const char * optarg, struct dump_attribute * da)
{
	struct speed_treatment * treat;
	char buf[1024];
	int nparsed;
	
	
	treat = &da->treat;
	
	if (strlen(optarg) + 1 >= sizeof(buf))
		goto ERROR;
	
	strcpy(buf, optarg);
	nparsed = split_num(buf, ":", 2, &treat->byte, &treat->delay_ms);
	if (nparsed != 2)
		goto ERROR;
	
	return 0;
	
	
    ERROR:
	treat->byte     = 0;
	treat->delay_ms = 0;
	
	return -1;
}





/*-----------------------------------------------------------------------*/
static 
void init_option(struct dump_attribute * da)
{
	int i;
	struct segment seg_init = {0, 0};
	
	da->shmkey			= 0;
	da->shmkey_specified		= 0;
	
	da->shmid			= 0;
	da->shmid_specified		= 0;
	
	da->dump_size			= 0;
	da->dump_size_specified		= 0;
	
	da->block_size			= 0;
	da->block_size_specified	= 0;
	
	da->block_count			= 0;
	da->block_count_specified	= 0;
	
	for (i = 0; i < NumSegmentSlot; i++)
		da->seg[i] = seg_init;
	da->segment_num = 0;
	
	da->treat.byte			= 0;
	da->treat.delay_ms		= 0;
	da->treat_specified		= 0;
	
	da->filename[0] 		= '\0';
	
	da->input_stdin 		= 0;
	
	return;
}





/* 
 * ISOVERFLOW_ADD_UNSIGNED
 *    unsigned���Ǥβû��������Хե����뤫��signed���ǤϻȤ��ʤ��Τ���ա�
 *    
 *    ����) ��hacker's delight�� Henry S. Warren  ISBN-13: 978-0201914658
 *              chapter 2-13 Overflow Detection
 */
#define ISOVERFLOW_ADD_UNSIGNED(x, y)	(~(x) < (y))




/*-----------------------------------------------------------------------*/
static
int isvalid_relation(struct dump_attribute * da)
{
	int i, j;
	
	if ((! da->input_stdin )                             && 
	    (! da->shmkey_specified && ! da->shmid_specified)  )
	{
		return 0;
	}
	if (! da->dump_size_specified && ! da->block_size_specified)
		return 0;
	if (da->dump_size_specified && da->block_size_specified)
		return 0;
	
	if ((da->segment_num > 0) && (da->block_size == 0))
		return 0;
	if ((da->block_count > 0) && (da->block_size == 0))
		return 0;
	
	for (i = 0; i < da->segment_num; i++) {
		struct segment * seg = &da->seg[i];
		
		if ((seg->offset >= da->block_size) ||
		    (seg->size   >  da->block_size)   )
			return 0;
		/* 
		 * offset + size �� �֥�å����ϰϤ�Ķ���Ƥ����饨�顼��
		 * offset�ϵ���ʿ�����ꤵ��Ƥ��뤫�⤷��ʤ����ᡢ
		 * �û��Υ����С��ե�������å����롣
		 */
		if (ISOVERFLOW_ADD_UNSIGNED(seg->size, seg->offset))
			return 0;
		if (seg->offset + seg->size > da->block_size)
			return 0;
	}
	
	/*
	 * segment ���ϰϤ���ʣ���Ƥ����饨�顼��
	 * XXX. ���Υ��르�ꥺ����٤���O(n^2)
	 */
	if (da->segment_num > 0) {
		for (i = 0; i < da->segment_num - 1; i++) {
			for (j = i + 1; j < da->segment_num; j++) {
				struct segment * seg_east = &da->seg[i];
				struct segment * seg_west = &da->seg[j];
				
				unsigned long seg_east_start = seg_east->offset;
				unsigned long seg_east_end   = seg_east->offset + seg_east->size - 1;
				unsigned long seg_west_start = seg_west->offset;
				unsigned long seg_west_end   = seg_west->offset + seg_west->size - 1;
				
				/* 
				 * ���ϰϤ���ʣ�פΥ��å����񤷤��������ϰϤ���ʣ���Ƥ��ʤ��פ�
				 *  ���å��ϴ�ñ  �� ��not �ϰϤ���ʣ���Ƥ��ʤ��פˤ��롣
				 */
				if ( ! ((seg_west_end < seg_east_start) || (seg_east_end < seg_west_start)) ) 
					return 0;
			}
		}
	}
	
	
	/* ���ƤΥ����å��˥ѥ� */
	return 1;
}




/*-----------------------------------------------------------------------*/
static
int interpret_non_hyphen_options(int argc, char ** argv, struct dump_attribute * da)
{
	int i;
	char * endp;
	
	for (i = 0; i < argc; i++) {
		/* ���Υϥ��ե�('-') �� ɸ�����Ϥ�����ɤ߹��߻��� */
		if (strcmp(argv[i], "-") == 0) {
			if (da->input_stdin) {
				fprintf(stderr, "duplicate stdin specified\n");
				return -1;
			}
			
			da->input_stdin = 1;
			
			continue;
		}
		
		
		/*
		 * shmdump�ϼ��Τ褦�ʥ��ޥ�ɷ������ä���
		 *      $ shmdump 0x1234 1024
		 *
		 * ���ߴ����Τ��ᡢ���ץ����ʸ����̵��������ϼ��Τ褦�˴�������
		 *    * shmkey���ޤ����ꤵ��Ƥ��餺��0x(������)�η��� �� shmkey
		 *    * ���ƿ��� �� dump_size
		 */
		
		if (strncmp(argv[i], "0x", 2) == 0) {
			if (da->shmkey_specified || da->shmid_specified) {
				fprintf(stderr, "duplicate options shmkey / shmid. \n");
				return -1;
			}
			da->shmkey = strtoul(argv[i], &endp, 16);
			if ((*endp != '\0') || (errno == ERANGE)) {
				fprintf(stderr, "Invalid shmkey\n");
				return -1;
			}
			
			da->shmkey_specified = 1;
			
			continue;
		}
		
		if (isalldigits(argv[i])) {
			if (da->dump_size_specified) {
				fprintf(stderr, "duplicate dump size. \n");
				return -1;
			}
			
			da->dump_size = strtoul(argv[i], &endp, 10);
			if ((*endp != '\0') || (errno == ERANGE)) {
				fprintf(stderr, "Invalid dump size\n");
				return -1;
			}
			
			if (da->dump_size == 0) {
				return -1;
			}
			da->dump_size_specified = 1;
			
			continue;
		}
		
		
		/*
		 * �������ץ����ϥ��ޥ�ɥ��顼��
		 * ���ץ����ְ㤤��typo���դ����뤿��̵��ˤϤ��ʤ���
		 * shmdump�ϼ»ܼԤȥǡ�����ǧ�Ԥ��̤Ǥ��륱�������ޤ�����
		 * Ū��Υ��Ƥ��륱������¿�����ᡢ��ä��¹ԤϤ��ξ��Ƚ��
		 * �������ɤ���
		 */
		
		return -1;
	}
	
	return 0;
}




/*-----------------------------------------------------------------------*/
static
int interpret_hyphen_options(int argc, char ** argv, struct dump_attribute * da)
{
	char ** args = argv;
	char * endp;
	int c;
	
	
	while ( (c = getopt(argc, args, "M:m:s:b:S:c:f:d:")) != -1) {
		switch(c) {
		case 'M':
			if (da->shmkey_specified || da->shmid_specified) {
				fprintf(stderr, "duplicate shmkey / shmid. \n");
				goto ERROR;
			}
			
			if (strncmp(optarg, "0x", 2) != 0) {
				/* 
				 * shmkey����� 0x ̵���ο���(10�ʿ�)�ϡ��տޤ���äƤ���
				 * ��ǽ�����⤤���ᡢ���顼�Ȥ��롣
				 */
				fprintf(stderr, "shmkey must be hexadecimal number. \n");
				goto ERROR;
			}
			
			da->shmkey = strtoul(optarg, &endp, 16);
			if ((*endp != '\0') || (errno == ERANGE)) {
				fprintf(stderr, "Invalid shmkey\n");
				goto ERROR;
			}
			
			da->shmkey_specified = 1;
			
			break;
			
		case 'm':
			if (da->shmkey_specified || da->shmid_specified) {
				fprintf(stderr, "duplicate shmkey / shmid. \n");
				goto ERROR;
			}
			
			da->shmid = strtol(optarg, &endp, 10);
			if ((*endp != '\0') || (errno == ERANGE) || da->shmid < 0) {
				fprintf(stderr, "Invalid shmid\n");
				goto ERROR;
			}
			
			da->shmid_specified = 1;
			
			break;
			
		case 's':
			if (da->dump_size_specified) {
				fprintf(stderr, "duplicate dump size. \n");
				goto ERROR;
			}
			
			da->dump_size = strtoul(optarg, &endp, 10);
			if ((*endp != '\0') || (errno == ERANGE) || !isalldigits(optarg)) {
				fprintf(stderr, "Invalid dump size\n");
				goto ERROR;
			}
			da->dump_size_specified = 1;
			
			break;
			
		case 'b':
			if (da->block_size_specified) {
				fprintf(stderr, "duplicate block size. \n");
				goto ERROR;
			}
			
			da->block_size = strtoul(optarg, &endp, 10);
			if ((*endp != '\0') || (errno == ERANGE) || !isalldigits(optarg)) {
				fprintf(stderr, "Invalid block size\n");
				goto ERROR;
			}
			da->block_size_specified = 1;
			
			break;
			
		case 'S':
			if (get_segment(optarg, da) < 0) {
				fprintf(stderr, "Invalid segment specified\n");
				goto ERROR;
			}
			
			break;
			
		case 'c':
			if (da->block_count_specified) {
				fprintf(stderr, "duplicate block count. \n");
				goto ERROR;
			}
			
			da->block_count = strtoul(optarg, &endp, 10);
			if ((*endp != '\0') || (errno == ERANGE) || !isalldigits(optarg)) {
				fprintf(stderr, "Invalid block count\n");
				goto ERROR;
			}
			
			da->block_count_specified = 1;
			
			break;
			
		case 'f':
			if (da->filename[0] != '\0') {
				fprintf(stderr, "duplicate output file\n");
				goto ERROR;
			}
			if (strlen(optarg) > 255) {
				fprintf(stderr, "file name must be less than or equal 255\n");
				goto ERROR;
			}
			strcpy(da->filename, optarg);
			
			break;
			
		case 'd':
			if (da->treat_specified) {
				fprintf(stderr, "duplicate delay. \n");
				goto ERROR;
			}
			
			if (get_delay(optarg, da) < 0) {
				fprintf(stderr, "Imvalid delay specified\n");
				goto ERROR;
			}
			
			da->treat_specified= 1;
			
			break;
			
		case '?':
			/*
			 * �������ץ����ϥ��ޥ�ɥ��顼��
			 * ���ץ����ְ㤤��typo���դ����뤿�ᡢ̵��λ��ͤˤϤ��ʤ���
			 */
			goto ERROR;
			
			break;
			
		default:
			break;
		}
		
		errno = 0;
	}
	
	return 0;


    ERROR:
	errno = 0;
	return -1;
}





/*-----------------------------------------------------------------------*/
void print_argv(int argc, char ** argv)
{
	int i;
	printf("%d  : ", argc);
	for (i = 0; i < argc; i++)
		printf("%s, ", argv[i]);
	printf("\n");
}





/*-----------------------------------------------------------------------*/
static
int get_option(int argc, char ** argv, struct dump_attribute * da)
{
	da->seg[0].size = 0;
	
	
	/* '-' �դ��������ڤ�'-' ̵�������β��ȳ�Ǽ */
	if (interpret_hyphen_options(argc, argv, da) == -1)
		return -1;
	if (interpret_non_hyphen_options(argc - optind, &argv[optind], da) == -1)
		return -1;
	
	
	/* ��������å� */
	if (! isvalid_range(da)) {
		return -1;
	}
	if (! isvalid_relation(da)) {
		// print_argv(argc, argv);
		return -1;
	}
	
	
	return 0;
}






/*--------------------------------------------------------------------------*/
#ifndef TEST

int main(int argc, char ** argv)
{
	struct dump_attribute da;
	struct shmid_ds shmds;
	
	
	init_option(&da);
	if (get_option(argc, argv, &da) == -1) {
		usage();
		exit(-1);
	}
	
	if (! da.input_stdin) {
		if (attach_shm(&da) == NULL) {
			fprintf(stderr, "shm attach fail\n\n");
			usage();
			exit(-1);
		}
		if (shmctl(da.shmid, IPC_STAT, &shmds) == -1) {
			fprintf(stderr, "shmctl(IPC_STAT) fail\n\n");
			exit(-1);
		}
		shm_segsz = shmds.shm_segsz;
	}
	
	dump(&da);
	
	return 0;
}





#else /* TEST */
/************************************************************************/
/* 									*/
/* Unit Test								*/
/* 									*/
/************************************************************************/

/**** support function for test macro ****/
int split_arg(char * s, char ** argv)
{
	int argc = 1;
	char * p;
	
	p = strtok(s, " ");

	while (p != NULL) {
		argv[argc] = p;
		argc++;
		p = strtok(NULL, " ");
	}
	argv[argc] = NULL;
	
	return argc;
}



/*----------------------------------------------------------------------*/
/* test split_num()							*/
/*----------------------------------------------------------------------*/
void split_num_test()
{
	/**** test macro ****/
	/*	split_num(s,delim,n)��result(���ꤹ����)��			*/
	/*      �ۤʤ��ɽ��							*/
#define SPLIT_NUM_TEST(s, delim, n, nsplit, reta, retb, retc)					\
	{											\
		unsigned long a, b, c;								\
		int nsplit_result;								\
		char buf[1024];									\
												\
		a = ~0; b = ~0, c = ~0;								\
		strcpy(buf, s);									\
		nsplit_result = split_num(buf, delim, n, &a, &b, &c);				\
												\
		if ((nsplit_result != (nsplit))  ||						\
		    (a != (reta))                || 						\
		    (b != (retb))                || 						\
		    (c != (retc))								\
		   ) 										\
		{										\
			printf("s:\"%s\", delim:\"%s\", n:%d, nsplit:%d, nsplit_result:%d, "	\
				"a:%lu, b:%lu, c:%lu\n",					\
				s, delim, n, nsplit, nsplit_result, a, b, c);			\
		}										\
	}
	
	printf("UNITTEST ----- split_num_test start\n");
	
	/*
	 * Test Items
	 *
	 * ���: ~0 �Ͻ���ͤ��̣���� (i.e. ���ꤷ���ս���ѿ���split_num()��
	 *       ��ä�ɾ������Ǽ����Ƥ��ʤ�����ɽ��)
	 *
	 *              ����					���ꤵ����������
	 *              s               delim    n   		�����	 ɾ������Ǽ���줿����
	 *
	 */
	SPLIT_NUM_TEST("123",		":",	 1, 		1,	 123ul, ~0,    ~0)
	SPLIT_NUM_TEST("123:456",	":",	 2, 		2,	 123ul, 456ul, ~0)
	SPLIT_NUM_TEST("123:456:789",	":",	 3, 		3,	 123ul, 456ul, 789ul)
	
	SPLIT_NUM_TEST("123:456",	":",	 1, 		1,	 123ul, ~0,    ~0)
	SPLIT_NUM_TEST("123:456:789",	":",	 2, 		2,	 123ul, 456ul, ~0)
	SPLIT_NUM_TEST("123",		":",	 2, 		1,	 123ul, ~0,    ~0)
	
	SPLIT_NUM_TEST("",		":",	 2, 		0,	 ~0   , ~0,    ~0)
	SPLIT_NUM_TEST("123:456",	"",	 2, 		-1,	 ~0   , ~0,    ~0)
	
	
	SPLIT_NUM_TEST("123",		"-",	 1, 		1,	 123ul, ~0,    ~0)
	SPLIT_NUM_TEST("123-456",	"-",	 2, 		2,	 123ul, 456ul, ~0)
	SPLIT_NUM_TEST("123-456-",	"-",	 2, 		2,	 123ul, 456ul, ~0)
	
	SPLIT_NUM_TEST("123--456",	"-",	 2, 		2,	 123ul, 456ul, ~0)
	SPLIT_NUM_TEST("123-456",	"--",	 2, 		2,	 123ul, 456ul, ~0)
	
	SPLIT_NUM_TEST("123--456",	"-",	 1, 		1,	 123ul, ~0,    ~0)
	SPLIT_NUM_TEST("123--456--789",	"-",	 2, 		2,	 123ul, 456ul, ~0)
	
	
	SPLIT_NUM_TEST("123<>456",	"<>",	 2, 		2,	 123ul, 456,    ~0)
	SPLIT_NUM_TEST("123<>456<>789",	"<>",	 3, 		3,	 123ul, 456,    789)
	SPLIT_NUM_TEST("123<>456<>789",	"<",	 3, 		-1,	 ~0,   ~0,     ~0)
	SPLIT_NUM_TEST("123<456>789",	"<>",	 3, 		3,	 123ul, 456ul, 789ul)
	
	SPLIT_NUM_TEST("123,456,789",	",",	 3, 		3,	 123ul, 456ul, 789ul)
	SPLIT_NUM_TEST("123,456,789",	"<",	 3, 		-1,	 ~0,   ~0,     ~0)
	
	
	printf("UNITTEST ----- split_num_test end\n");
	printf("\n");

#undef SPLIT_NUM_TEST
}





/*----------------------------------------------------------------------*/
/* test get_option()							*/
/*----------------------------------------------------------------------*/
void get_option_test_value_range()
{

	/**** test macro ****/
	/*	option ʸ����� argv �����˥ѡ�����					*/
	/*	get_option(argv������option)��result(���ꤹ����)�Ȱۤʤ��ɽ��	*/
#define	VALUE_RANGE_TEST(option, st_elem, result)						\
	{											\
		struct dump_attribute da;							\
		int get_option_result = 0;							\
		int argc = 0;									\
		char * argv_array[128];								\
		char ** argv = argv_array;							\
		char buf[1024];									\
		char dummy_buf[16] = "dummy";							\
												\
		argv_array[0] = dummy_buf;							\
												\
		init_option(&da);								\
												\
		memset(buf, 0, 1024);								\
		strcpy(buf, option);								\
		argc = split_arg(buf, argv);							\
												\
		get_option_result = get_option(argc, argv, &da);				\
												\
		if (get_option_result != result)						\
			printf("%s : right ans = %d, but result = %d\n\n", 			\
					option, result, get_option_result);			\
												\
		optind = 1;	/* reset getopt scan vector */					\
	}
	
	
	printf("UNITTEST ----- get_option_test_value_range start\n");
	
	/*
	 * Test Items
	 *
	 *  option						structure elem	valid  :0
	 * 							for store	invalid:-1
	 */
	 
	/*** test shmkey ***/
	/* 
	 * 	"0x[0-9a-fA-F]{1,8}"
	 * 	valid value range: unsigned 0x0 to 0xffffffff
	 */ 
	VALUE_RANGE_TEST("-M 0x0 -s 1",				shmkey, 	0)
	VALUE_RANGE_TEST("-M -s 1",				shmkey, 	-1)
	VALUE_RANGE_TEST("-M 0xdeadbeaf -s 1",			shmkey,		0)
	VALUE_RANGE_TEST("-M 0xffffffff -s 1",			shmkey, 	0)
	VALUE_RANGE_TEST("-M 0x -s 1",				shmkey, 	-1)
	VALUE_RANGE_TEST("-M -0x0 -s 1",			shmkey, 	-1)
	VALUE_RANGE_TEST("-M 12345 -s 1",			shmkey,	 	-1)
	VALUE_RANGE_TEST("-M -12345 -s 1",			shmkey, 	-1)
	VALUE_RANGE_TEST("-M hoge -s 1",			shmkey,		-1)
	VALUE_RANGE_TEST("-M -s 1",				shmkey,		-1)
	
	
	/*** test shmid ***/
	/* 
	 * 	"[0-9]+"
	 * 	value range: signed, positive 0 to 2147483647
	 */ 
	VALUE_RANGE_TEST("-m 0 -s 1",				shmid,		0)
	VALUE_RANGE_TEST("-m -s 1",				shmid,		-1)
	VALUE_RANGE_TEST("-m 1 -s 1",				shmid,		0)
	VALUE_RANGE_TEST("-m 12345 -s 1",			shmid,		0)
	VALUE_RANGE_TEST("-m 2147483647 -s 1",			shmid,		0)
	VALUE_RANGE_TEST("-m 4294967295 -s 1",			shmid,		-1)
	VALUE_RANGE_TEST("-m -12345 -s 1",			shmid,		-1)
	VALUE_RANGE_TEST("-m 0x -s 1",				shmid,		-1)
	VALUE_RANGE_TEST("-m 0x12345 -s 1",			shmid,		-1)
	VALUE_RANGE_TEST("-m hoge -s 1",			shmid,		-1)
	VALUE_RANGE_TEST("-m  -s 1",				shmid,		-1)
	
	
	/*** test dump size ***/
	/* 
	 * 	"[0-9]+"
	 * 	value range: unsigned, 1 to   4294967295 (32bit) or
	 * 	                       1 to 137438953471 (64bit)
	 */ 
	VALUE_RANGE_TEST("-M 0x0 -s 1",				dump_size,	0)
	VALUE_RANGE_TEST("-M 0x0 -s 123",			dump_size,	0)
	VALUE_RANGE_TEST("-M 0x0 -s 4294967295",		dump_size,	0)

	if (sizeof(long) == 4) {
	/* 32 bit */
	VALUE_RANGE_TEST("-M 0x0 -s 4294967296",		dump_size,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s 137438953471",		dump_size,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s 137438953472",		dump_size,	-1)
	} else {
	/* 64 bit */
	VALUE_RANGE_TEST("-M 0x0 -s 4294967296",		dump_size,	0)
	VALUE_RANGE_TEST("-M 0x0 -s 137438953471",		dump_size,	0)
	VALUE_RANGE_TEST("-M 0x0 -s 137438953472",		dump_size,	-1)
	}

	VALUE_RANGE_TEST("-M 0x0 -s 0",				dump_size,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s 0x12345",			dump_size,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s -1",			dump_size,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s hoge",			dump_size,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s ",				dump_size,	-1)
	
	
	/*** test block size ***/
	/* 
	 * 	"[0-9]+"
	 * 	value range: unsigned, 1 to DUMP_BUFSIZE
	 */ 
	VALUE_RANGE_TEST("-M 0x0 -b 1",				block_size,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 1234",			block_size,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 8192",			block_size,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 8193",			block_size,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 0x1234",			block_size,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 0",				block_size,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b -1",			block_size,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b hoge",			block_size,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b ",				block_size,	-1)
	
	
	/*** test block count ***/
	/* 
	 * 	"[0-9]+"
	 * 	value range: unsigned, 1 to   4294967295 (32bit) or
	 * 	                       1 to 137438953471 (64bit)
	 */ 
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c 1",			block_count,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c 12345",		block_count,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c 4294967295",	block_count,	0)

	if (sizeof(long) == 4) {
	/* 32 bit */
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c 4294967296",	block_count,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c 137438953471",	block_count,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c 137438953472",	block_count,	-1)
	} else {
	/* 64 bit */
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c 4294967296",	block_count,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c 137438953471",	block_count,	0)	
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c 137438953472",	block_count,	-1)
	}

	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c 0x12345",		block_count,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c 0",			block_count,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c -1",		block_count,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c hoge",		block_count,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -c ",			block_count,	-1)
	
	
	/*** test segment ***/
	
	/* simple value range  */
	/* 
	 *    offset
	 * 	"[0-9]+"
	 * 	value range: unsigned, 0 to DUMP_BUFSIZE - 1
	 *    size
	 * 	"[0-9]+"
	 * 	value range: unsigned, 1 to DUMP_BUFSIZE
	 */ 
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 0:1",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 1:1",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 8191:1",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 8192:1",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 0x123:1",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 0:-1",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S -1:1",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S hoge:1",		segment,	-1)
	
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 8191:0x123",	segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 8191:0",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 8191:-1",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 8191:hoge",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 8191:",		segment,	-1)

	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 8191:1",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 0:8192",		segment,	0)
	
	VALUE_RANGE_TEST("-M 0x0 -b 4294967295 -S :1",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 4294967295 -S 1:",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 4294967295 -S ",		segment,	-1)
	
	/*
	 *	0 <= segment.offset < block_size
	 *		e.g.) if block size < 512, valid range is 0 to 511
	 */
	VALUE_RANGE_TEST("-M 0x0 -b 512 -S 510:1",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 512 -S 511:1",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 512 -S 512:1",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -b 512 -S 513:1",		segment,	-1)
	
	/*
	 *	0 < segment.size <= block_size
	 */
	VALUE_RANGE_TEST("-M 0x0 -b 512 -S 0:511",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 512 -S 0:512",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 512 -S 0:513",		segment,	-1)
	
	/*
	 *	error if (offset + size) is cross the block bound
	 */
	VALUE_RANGE_TEST("-M 0x0 -b 1 -S 0:1",			segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 1 -S 0:2",			segment,	-1)	/* out of bounds */
	VALUE_RANGE_TEST("-M 0x0 -b 512 -S 510:1",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 512 -S 510:2",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -b 512 -S 510:3",		segment,	-1)	/* out of bounds */
	VALUE_RANGE_TEST("-M 0x0 -b 512 -S 510:4",		segment,	-1)	/* out of bounds */
	VALUE_RANGE_TEST("-M 0x0 -b 13 -S 14:1",		segment,	-1)	/* out of bounds */
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 8191:2",		segment,	-1)	/* out of bounds */
	VALUE_RANGE_TEST("-M 0x0 -b 8192 -S 1:8192",		segment,	-1)	/* out of bounds */
	
	
	/*** test delay ***/
	/* 
	 *    byte
	 * 	"[0-9]+"
	 * 	value range: unsigned, 1 to   4294967295 (32bit) or
	 * 	                       1 to 137438953471 (64bit)
	 *
	 *    delay(ms)
	 * 	"[0-9]+"
	 * 	value range: unsigned, 0 to 20000
	 * 
	 * 	byte �� delay_ms �δط��������̵����
	 *	��äơ�������byte����礭��delay �ǥ��ޥ�ɤ�¹Ԥ���Ƚ����ʤ��ʤ롣
	 */
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 1:1",			segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 12345:1",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 0:1",			segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 4294967295:1",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d ",			segment,	-1)
	
	if (sizeof(long) == 4) {
	/* 32 bit */
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 4294967296:1",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 137438953471:1",	segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 137438953472:1",	segment,	-1)
	} else {
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 4294967296:1",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 137438953471:1",	segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 137438953472:1",	segment,	-1)
	}
	
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 0x12345:1",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 0:1",			segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d -1:1",			segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d hoge:1",		segment,	-1)
	
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 1:0",			segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 1:12345",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 1:20000",		segment,	0)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 1:20001",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 1:0x12345",		segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 1:-1",			segment,	-1)
	VALUE_RANGE_TEST("-M 0x0 -s 1 -d 1:hoge",		segment,	-1)
	
	
	printf("UNITTEST ----- get_option_test_value_range end\n");
	printf("\n");

#undef	VALUE_RANGE_TEST
}





void get_option_test_options_relation()
{
	/**** test macro ****/
	/*	option ʸ����� argv �����˥ѡ�����			*/
	/*	get_option �سݤ���result(���ꤹ����)�Ȱۤʤ��ɽ��	*/
#define	RELATION_TEST(option, result)								\
	{											\
		struct dump_attribute da;							\
		int get_option_result = 0;							\
		int argc = 0;									\
		char * argv_array[128];								\
		char ** argv = argv_array;							\
		char buf[1024];									\
		char dummy_buf[16] = "dummy";							\
												\
		argv_array[0] = dummy_buf;							\
												\
		init_option(&da);								\
												\
		memset(buf, 0, 1024);								\
		strcpy(buf, option);								\
		argc = split_arg(buf, argv);							\
												\
		get_option_result = get_option(argc, argv, &da);				\
												\
		if (get_option_result != result)						\
			printf("%s : right ans = %d, but result = %d\n\n", 			\
					option, result, get_option_result);			\
												\
		optind = 1;	/* reset getopt scan vector */					\
	}
	
	
	printf("UNITTEST ----- get_option_test_options_relation start\n");
	
	/*
	 * Test Items
	 *
	 *  		option						valid  :0
	 * 								invalid:-1
	 */
	
	RELATION_TEST("",						-1)
	
	/*
	 *	shmkey��shmid��Ʊ�������Բ�
	 *	shmkey�� -M��dump_size�� -s �Ͼ�ά��ǽ����ο��ͤ�ɽ�줿��硢
	 * 		shmkey �� shmid ���ޤ����ꤵ��Ƥ��ʤ��ʤ顢����� shmkey �ȴ�����
	 * 		shmkey ���� shmid ������Ѥߤʤ顢
	 *			dump_size �����ꤵ��Ƥ��ʤ��ʤ顢����� dump_size �ȴ�����
	 * 			dump_size ������Ѥߤʤ�NG��
	 */
	RELATION_TEST("0x0 1",						0)	/* ���shmkey�����dump_size */
	RELATION_TEST("0x0 1 1",					-1)	/* ���shmkey�����dump_size��unknown */
	RELATION_TEST("0x0 1 0x1",					-1)	/* ���shmkey�����dump_size��unknown */
	RELATION_TEST("0x0 0x1 1",					-1)	/* ���shmkey�����dump_size��unknown */
	RELATION_TEST("-M 0x0 1",					0)	
	RELATION_TEST("-M 0x0 -s 1",					0)	
	RELATION_TEST("-m 1 1",						0)	
	RELATION_TEST("-m 1 -m 1 1",					-1)	/* ��ʣ���� */
	RELATION_TEST("-M 0x0 -M 0x1 1",				-1)	/* ��ʣ���� */
	RELATION_TEST("-M 0x0 -m 0 -s 1",				-1)	/* shmkey �� shmid ��Ʊ������ */
	
	RELATION_TEST("0x0",						-1)	/* ���shmkey��dump_size �� block_size�����ʤ�*/
	RELATION_TEST("-M 0x0",						-1)	/* ���ץ����ʸ��shmkey��dump_size �� block_size�����ʤ�*/
	RELATION_TEST("-m 0",						-1)	/* ���ץ����ʸ��shmid��dump_size �� block_size�����ʤ�*/
	RELATION_TEST("-M 0x0 -m 0",					-1)	/* shmkey �� shmid ��Ʊ�����ꡣdump_size �� block_size�����ʤ� */
	
	RELATION_TEST("-M 0x0 -b 1",					0)
	RELATION_TEST("-M 0x0 -b 1 -b 2",				-1)	/* ��ʣ���� */
	RELATION_TEST("-M 0x0 -s 1 -b 1",				-1)
	RELATION_TEST("-M 0x0 -s 2 -b 1",				-1)
	RELATION_TEST("-M 0x0 -s 1 -b 2",				-1)
	
	/*
	 *	segment��block����˼��ޤäƤ���ɬ�פ��ꡣ
	 *	segment�֤��ϰϤν�ʣ���Բ�
	 *	segment����ꤹ��Ȥ���block_size��ɬ��
	 */
	RELATION_TEST("-M 0x0 -b 4 -S 0:1",				0)
	RELATION_TEST("-M 0x0 -b 4 -S 0:1 -S 1:1",			0)
	RELATION_TEST("-M 0x0 -b 4 -S 0:1 -S 2:2",			0)
	RELATION_TEST("-M 0x0 -b 4 -S 0:2 -S 1:1",			-1)	/* segment ���ϰϽ�ʣ */
	RELATION_TEST("-M 0x0 -b 4 -S 0:2 -S 1:2",			-1)	/* segment ���ϰϽ�ʣ */
	RELATION_TEST("-M 0x0 -b 4 -S 1:1 -S 1:2",			-1)	/* segment ���ϰϽ�ʣ */
	RELATION_TEST("-M 0x0 -b 4 -S 2:1 -S 1:2",			-1)	/* segment ���ϰϽ�ʣ */
	RELATION_TEST("-M 0x0 -b 4 -S 2:2 -S 1:2",			-1)	/* segment ���ϰϽ�ʣ */
	RELATION_TEST("-M 0x0 -b 4 -S 3:1 -S 1:2",			0)
	RELATION_TEST("-M 0x0 -b 4 -S 0:4",				0)
	RELATION_TEST("-M 0x0 -b 4 -S 0:5",				-1)	/* segment��block�����ۤ� */
	RELATION_TEST("-M 0x0 -b 4 -S 3:1",				0)
	RELATION_TEST("-M 0x0 -b 4 -S 4:1",				-1)	/* segment��block�����ۤ� */
	RELATION_TEST("-M 0x0 -b 4 -S 5:1",				-1)	/* segment��block�����ۤ� */
	RELATION_TEST("-M 0x0 -s 1 -S 0:1",				-1)	/* block_size�λ��̵꤬�� */
	
	
	
	/*
	 *	block_count����ꤹ��Ȥ���block_size��ɬ��
	 */
	RELATION_TEST("-M 0x0 -b 4 -c 1",				0)	
	RELATION_TEST("-M 0x0 -b 4 -c 2",				0)	
	RELATION_TEST("-M 0x0 -c 2",					-1)	/* block_size�λ��̵꤬�� */
	RELATION_TEST("-M 0x0 -s 1 -S 0:1 -c 1",			-1)	/* block_size�λ��̵꤬�� */
	RELATION_TEST("-M 0x0 -b 4 -c 2 -c 3",				-1)	/* ��ʣ���� */
	
	/*
	 *	delay��¾�Υ��ץ�������ؤʤ��ǻ��꤬��ǽ��â����ʣ����������Բġ�
	 */
	RELATION_TEST("-M 0x0 -s 1 -d 1:1",				0)
	RELATION_TEST("-M 0x0 -b 1 -S 0:1 -d 1:1",			0)
	RELATION_TEST("-M 0x0 -b 1 -S 0:1 -c 1 -d 1:1",			0)
	RELATION_TEST("-M 0x0 -b 1 -S 0:1 -c 1 -d 1:1",			0)
	RELATION_TEST("-M 0x0 -b 1 -S 0:1 -c 1 -d 1:1 -d 2:1",		-1)	/* ��ʣ���� */
	
	/*
	 *	file��¾�Υ��ץ�������ؤʤ��ǻ��꤬��ǽ��â����ʣ����������Բġ�
	 */
	RELATION_TEST("-M 0x0 -s 1 -f test_file",			0)
	RELATION_TEST("-M 0x0 -b 1 -S 0:1 -c 1 -d 1:1 -f test_file",	0)
	RELATION_TEST("-M 0x0 -f test_file1 -f test_file2",		-1)	/* ��ʣ���� */
	
	/*
	 *	ɸ�������ɤ߹��ߤ�Ǥ�դ˻��꤬��ǽ��â����ʣ�������Բġ�
	 *	
	 *	ɸ�������ɤ߹��ߤ����ꤵ��Ƥ������shmkey, shmid��
	 *	̵���Ȥ��ɤ������ä�����ɸ�������ɤ߹��ߤ�ͥ�褵��롣
	 *	(��ͭ���꤫����ɤ߹��ߤȥե����뤫����ɤ߹��ߤǡ�
	 *	���ץ����������礭���Ѥ�ʤ��ۤ��������Ǥ��뤿��)��
	 */
	RELATION_TEST("-s 1 -",						0)
	RELATION_TEST("-M 0x0 -s 1 -",					0)	/* ɸ�����Ϥ�����ɤ߹��ߤ�ͥ�� */
	RELATION_TEST("-b 1024 -S 0:2 -",				0)
	RELATION_TEST("-M 0x0 -s 1 - -",				-1)	/* ��ʣ���� */
	RELATION_TEST("-M 0x0 - -s 1 -",				-1)	/* ��ʣ���� */
	RELATION_TEST("-",						-1)	/* dump_size��block_size��̵�� */
	RELATION_TEST("-b 8 -S 0:8 -c 4 -",				0)
	
	
	printf("UNITTEST ----- get_option_test_options_relation end\n");
	printf("\n");

#undef	RELATION_TEST
}




int main(int argc, char ** argv)
{
	split_num_test();
	get_option_test_value_range();
	get_option_test_options_relation();

	return 0;
}


#endif /* TEST */



