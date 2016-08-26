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
 * バッファサイズは16の倍数とすること。
 * サイズ指定、且つテキスト出力の場合は、16バイト毎にオフセットを出力
 * する (shmdumpに合わせた仕様)仕様のため、一度の読み込みを16の倍数に
 * しなければ処理が無用に複雑になる。
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



#define NumSegmentSlot	64			/* セグメント指定オプションの最大数 */

struct dump_attribute {
	key_t shmkey;
		/* e.g.) -M 0xAAAA						*/
		/* 対象のshmkey。複数指定は不可。shmidと同時に指定は不可	*/
		/* shmkey_specified == 0 のとき、内容は不定			*/
	int shmkey_specified;
		/* 0: shmkey指定なし, 非0: shmkey指定あり			*/
	
	
	int shmid;
		/* e.g.) -m 1234						*/
		/* 対象のshmid。複数指定は不可。shmkeyと同時に指定は不可	*/
		/* shmid_specified == 0 のとき、内容は不定			*/
	int shmid_specified;
		/* 0: shmid指定なし, 非0: shmid指定あり				*/
	
	
	/*
	 * サイズ、またはブロックのどちらも指定されなければエラー。
	 * 『両者とも省略した場合は全領域』という仕様にも出来るが、共有メモリ
	 * のサイズが大きいと *不意に* マシンへ負荷を掛けてしまうかもしれない。
	 */
	unsigned long dump_size;
		/* e.g.) -s 1234						*/
		/* ダンプサイズ。64ビットの場合、最大は128GiBに制限する		*/
		/* dump_size_specified == 0 のとき、内容は不定			*/
		/* blockと同時に指定は不可					*/
	int dump_size_specified;
		/* 0: dump_size指定なし, 非0: dump_size指定あり			*/
	
	
	unsigned long block_size;
		/* e.g.) -b 1234						*/
		/* ブロックサイズ。64ビットの場合、最大は128GiBに制限する	*/
		/* block_size_specified == 0 のとき、内容は不定			*/
		/* dump_sizeと同時に指定は不可					*/
	int block_size_specified;
		/* 0: block_size指定なし, 非0: block_size指定あり		*/
	
	
	/* 
	 * block_count と segment 指定は、block_sizeが指定されていなければ
	 * 指定できない
	 */
	unsigned long block_count;
		/* e.g.) -c 1234						*/
		/* ブロックの数。64ビットの場合、128Giに制限する		*/
		/* block_count_specified == 0 のとき、内容は不定		*/
	int block_count_specified;
		/* 0: block_count指定なし, 非0: block_count指定あり		*/
	
	
	struct segment seg[NumSegmentSlot];
		/* e.g.) -S 16:12 -S 32:1					*/
		/* 配列の内容は 0 〜 segment_num - 1 の範囲で有効値、それ以外は	*/
		/* 不定								*/
	
	unsigned long segment_num;
		/* segment指定の数。-S オプション毎にインクリメント		*/
		/* 初期化関数で 0 に初期化する					*/
		/* ブロック指定ありでセグメント指定無し の場合、ダンプ処理を	*/
		/* 共通化するため、次のようにブロックと同じサイズのセグメントを	*/
		/* ツール自身が作成する						*/
		/*     segment_num   = 1					*/
		/*     seg[0].offset = 0					*/
		/*     seg[0].size   = block_size				*/
	
	
	struct speed_treatment treat;
		/* e.g.) -d 1024:500						*/
		/* 負荷軽減のための遅延。複数指定は不可				*/
		/* treat_specified == 0 のとき、内容は不定			*/
	int treat_specified;
		/* 0: treat指定なし, 非0: treat指定あり */
	
	
	char filename[256];
		/* e.g.) -f hoge.bin						*/
		/* filename[0] == '\0' : 標準出力へテキスト吐き出し    		*/
		/* filename[0] != '\0' : ファイルへバイナリで吐き出し  		*/
		/* 								*/
		/* 安全性のため、バイナリを標準出力に出力する手段は設けない	*/
	
	
	int input_stdin;
		/* 非0:標準入力から読む、0:共有メモリから読む 			*/
};




/* 
 * 共有メモリのアドレスと読み込み済みサイズ(オフセット)
 * 標準入力と共有メモリの読み込みの処理を共通化するため、共有メモリからの
 * コピーをバイトストリームへ抽象化する。
 */
static void * shmaddr = NULL;
static unsigned long nread_shm = 0;


/* 
 * 実際にアロケートされているshmのサイズ。
 * 共有メモリの範囲外アクセスを防止するために使う。
 * shmctl(da.shmid, IPC_STAT, &shmds)で取得する。
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
	"       shmdump_exはshmdumpの拡張版である。"						"\n"
	""											"\n"
	"  Options"										"\n"
	"      "										"\n"
	"      -M shmkey"									"\n"
	"          対象のshmkey。"								"\n"
	"          複数指定は不可。shmkeyと同時に指定は不可。"					"\n"
	"      "										"\n"
	"      -m shmid"									"\n"
	"          対象のshmid"									"\n"
	"          複数指定は不可。shmkeyと同時に指定は不可。"					"\n"
	"      "										"\n"
	"      -s dump_size"									"\n"
	"          ダンプサイズ。"								"\n"
	"          出力形式は旧shmdumpと同じ。"							"\n"
	"          -b block_sizeと同時に指定は不可。64ビットの場合、最大は128GiB。"		"\n"
	"      "										"\n"
	"      -b block_size"									"\n"
	"          ブロックサイズ。"								"\n"
	"          ブロックごとに1行の出力形式となる。行頭にオフセットは付かない"		"\n"
	"          -s dump_sizeと同時に指定は不可。64ビットの場合、最大は128GiB。"		"\n"
	"      "										"\n"
	"      -S offset:size"									"\n"
	"          各ブロックの特定領域(セグメント)だけダンプする。"				"\n"
	"          64個まで指定可能。ブロックと同じ形式で出力するが、各セグメントは一個"	"\n"
	"          のスペースで区切られる。"							"\n"
	"          ブロックサイズが指定されていなければ指定不可。セグメントはブロックの"	"\n"
	"          境界を跨いではならず、また各セグメントの領域が重複してはならない。"		"\n"
	"      "										"\n"
	"      -c block_count"									"\n"
	"          指定したブロック数だけダンプする。"						"\n"
	"          ブロックサイズが指定されていなければ指定不可。"				"\n"
	"      "										"\n"
	"      -d byte:delay_ms"								"\n"
	"          遅延指定。byteをダンプする毎にdelay_msだけsleepする。"			"\n"
	"          巨大なサイズをダンプする際、実行マシンへの負荷を調整するため。"		"\n"
	"      "										"\n"
	"      -f filename"									"\n"
	"          標準出力ではなく、指定したファイルにバイナリでダンプする。"			"\n"
	"          ブロック指定と同時に指定できるが、バイナリデータでは各ブロックの"		"\n"
	"          境界を判断できない事に注意。"						"\n"
	"      "										"\n"
	"      -"										"\n"
	"          共有メモリではなく、標準入力から読み込む。"					"\n"
	"          このオプションが指定されていた場合、-M, -mは無視される。"			"\n"
	""											"\n"
	""											"\n"
	"  Exsample"										"\n"
	"  "											"\n"
	"      実行例を示す。一部の例では出力の例も付ける。"					"\n"
	"      共有メモリ中のデータは何れの例でも同一である。"					"\n"
	"      "										"\n"
	"      (1) 旧shmdumpと同じ使い方"							"\n"
	"                $ shmdump_ex 0x00001234 32"						"\n"
	"                          offset: +0+1+2+3 +4+5+6+7 +8+9+a+b +c+d+e+f"			"\n"
	"                0000000000000000: 00010203 04050607 08090a0b 0c0d0e0f"			"\n"
	"                0000000000000010: 10111213 14151617 18191a1b 1c1d1e1f"			"\n"
	"      "										"\n"
	"      (2) 旧shmdumpと同じ。オプションを明示"						"\n"
	"                $ ./shmdump_ex -M 0x00001234 -s 32"					"\n"
	"      "										"\n"
	"      (3) shmid指定"									"\n"
	"                $ ./shmdump_ex -m 360449 -s 32"					"\n"
	"      "										"\n"
	"      (4) ブロック指定"								"\n"
	"                $ ./shmdump_ex -M 0x00001234 -b 8"					"\n"
	"                0001020304050607"							"\n"
	"                08090a0b0c0d0e0f"							"\n"
	"                1011121314151617"							"\n"
	"                18191a1b1c1d1e1f"							"\n"
	"      "										"\n"
	"      (5) ブロックカウント指定"							"\n"
	"                $ ./shmdump_ex -M 0x00001234 -b 8 -c 2"				"\n"
	"                0001020304050607"							"\n"
	"                08090a0b0c0d0e0f"							"\n"
	"      "										"\n"
	"      (6) ブロック、セグメント指定"							"\n"
	"                $ ./shmdump_ex -M 0x00001234 -b 8 -S 0:2 -S 4:4"			"\n"
	"                0001 04050607"								"\n"
	"                0809 0c0d0e0f"								"\n"
	"                1011 14151617"								"\n"
	"                1819 1c1d1e1f"								"\n"
	"      "										"\n"
	"      (7) 遅延指定。16byte出力する毎に500msスリープする"				"\n"
	"                $ ./shmdump_ex -M 0x00001234 -s 32 -d 16:500"				"\n"
	"      "										"\n"
	"      (8) バイナリでファイルへ出力"							"\n"
	"                $ ./shmdump_ex -M 0x00001234 -s 32 -f tofile"				"\n"
	"      "										"\n"
	"      (9) 標準入力から読み込み。"							"\n"
	"                $ cat tofile | ./shmdump_ex -M 0x00001234 -b 8 -S 0:2 -S 4:4"		"\n"
	"                0001 04050607"								"\n"
	"                0809 0c0d0e0f"								"\n"
	"                1011 14151617"								"\n"
	"                1819 1c1d1e1f"								"\n"
	""											"\n"
	""											"\n"
	"  Other Topics"									"\n"
	"  "											"\n"
	"      (1) ファイルを指定した場合はバイナリで出力される。バイナリであるため、ブロ"	"\n"
	"          ック/セグメントを指定した場合でもそれらの境界についての情報は残らない。"	"\n"
	"          出力時のコマンドから境界を復旧してテキストでダンプする事ができる。"		"\n"
	"          "										"\n"
	"             $ ./shmdump_ex -M 0x00001234 -b 16 -S 0:2 -S 4:4 -S 12:1 -c 2 -f tofile"	"\n"
	"          "										"\n"
	"             $ xxd tofile"								"\n"
	"             0000000: 0001 0405 0607 0c10 1114 1516 171c       .............."		"\n"
	"          "										"\n"
	"          復元にはセグメントオフセットが連続となるよう指定する事に注意。"		"\n"
	"             "										"\n"
	"             $ cat tofile | ./shmdump_ex -b 16 -S 0:2 -S 2:4 -S 6:1 -c 2"		"\n"
	"             0001 02030405 06"								"\n"
	"             1011 12131415 16"								"\n"
	""											"\n"
	"      (2) 上記を応用すると、任意のファイルに対して簡易なデコーダとして利用する"	"\n"
	"          事ができる。"								"\n"
	""											"\n"
	"      (3) 旧shmdumpは割り当て済みの共有メモリのサイズをチェックしていないため、"	"\n"
	"          サイズの指定を誤るとsegmentation faultとなる。"				"\n"
	"          shmdump_exは共有メモリのサイズをチェックしている。割り当てサイズを"		"\n"
	"          超える指定がされても、割り当てサイズ分しか出力しない。"			"\n"
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
 *	デリミタで分割された数字の並びをパースして可変引数変数(unsigned long
 *	へのポインタ)の指す領域に格納する。
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
 *	この関数は strtok() を使っている。
 *
 *    tips
 *	この関数はsscanf/strtokの特別バージョンである。
 *	もし拡張したくなったらそれらが使えないかを先ず検討すること。
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
	
	/* この時点でsにはデリミタ又は数字しか含まれていない */
	
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
 *	共有メモリからのコピーと標準入力からの読み込みの違いを隠蔽する
 *	(抽象化)ためのWrapper関数
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
 *	共有メモリからのコピーと標準入力からの読み込みの違いを隠蔽する
 *	(抽象化)ためのWrapper関数
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
	unsigned long lefttodelay;	/* usleepを入れるまでの残り出力バイト。減算カウンタ */
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
		 * このプログラムのホットスポット。
		 * 
		 * バイト単位の計測でsleepを入れるため、ループアンローリングは
		 * しない。
		 * 
		 * 16進文字列への変換はDIY。実測したところpritnf("%02x")だと2倍
		 * 以上遅くなるため。但し、更なる高速化を狙って分岐を排除しても
		 * 意味は無い。
		 *     * 最近のx86プロセッサは分岐予測が優秀。この処理のテスト
		 *       プログラムで測ったところ、分岐予測ミスの頻度は3%以下。
		 *     * また、分岐予測が外れてもパイプラインハザードは起きない
		 *       (ROBからRetirementされないだけ)。
		 *     * このループの処理は全てI-TLBに載る
		 *     * 算術式に置き換えて分岐を排除した場合、IPCはわずか
		 *       (0.04〜0.12/Cycle)に向上するが、命令数の増分によって
		 *       相殺され遅くなる。
		 * 詳しくはIntel最適化マニュアルを参照。
		 */
		for(i = 0; i < nread; i++) {
			if(i % 16 == 0)
				fprintf(fp, "%016lx: ", i);
			
			unsigned char num_hi = buf[i] / 16;
			unsigned char num_lo = buf[i] % 16;
			hexbuf[0] = (num_hi < 10) ? (num_hi + '0') : (num_hi - 10 + 'a');
			hexbuf[1] = (num_lo < 10) ? (num_lo + '0') : (num_lo - 10 + 'a');
			/* hexbuf[2]は常に'\0' */
			fputs(hexbuf, fp);
			
			nwrite++;
			
			if (i % 4 == 3)
				fprintf(fp, " ");
			if (i % 16 == 15)
				fprintf(fp, "\n");
			
			/* 
			 * da->treat.byte毎にsleep。
			 * nwrite % da->treat.byte として倍数か判定する手もあるが、除算は
			 * 遅い。演算数が変数であるため逆数の乗算(コンパイラの教科書を参
			 * 照)への変換もされない。カウンタにする。
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
	unsigned long ncount = 0;	/* ブロックの出力回数					*/
	unsigned long lefttodelay;	/* usleepを入れるまでの残り出力バイト。減算カウンタ	*/
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
		 * 1つのブロックを次の形で出力 "HHHHHHHH HHHH HHHHHHHH HH\n"
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
				/* hexbuf[2]は常に'\0' */
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
	unsigned long lefttodelay;	/* usleepを入れるまでの残り出力バイト。減算カウンタ */
	
	
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
	unsigned long ncount = 0;	/* ブロックの出力回数					*/
	unsigned long lefttodelay;	/* usleepを入れるまでの残り出力バイト。減算カウンタ	*/
	
	
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
	
	
	/* -M,-m指定(共有メモリ)よりも、'-'指定(標準入力から読み込み)が優先 */
	if (da->input_stdin)
		readfunc = read_fromstdin;
	else
		readfunc = read_fromshm;
	
	
	if (da->filename[0] == '\0') {
		/* ASCIIで標準出力へ */
		
		fp = stdout;
		
		if (da->dump_size_specified)
			dumped = write_ascii_bysize(fp, da, readfunc);
		else
			dumped = write_ascii_byblock(fp, da, readfunc);
	}
	else {
		/* Binaryでファイルへ */
		
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
 *    unsigned型での加算がオーバフローするか。signed型では使えないので注意。
 *    
 *    参照) 『hacker's delight』 Henry S. Warren  ISBN-13: 978-0201914658
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
		 * offset + size が ブロックの範囲を超えていたらエラー。
		 * offsetは巨大な数を指定されているかもしれないため、
		 * 加算のオーバーフローもチェックする。
		 */
		if (ISOVERFLOW_ADD_UNSIGNED(seg->size, seg->offset))
			return 0;
		if (seg->offset + seg->size > da->block_size)
			return 0;
	}
	
	/*
	 * segment の範囲が重複していたらエラー。
	 * XXX. このアルゴリズムは遅い。O(n^2)
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
				 * 「範囲が重複」のロジックは難しいが、「範囲が重複していない」の
				 *  ロジックは簡単  ⇒ 「not 範囲が重複していない」にする。
				 */
				if ( ! ((seg_west_end < seg_east_start) || (seg_east_end < seg_west_start)) ) 
					return 0;
			}
		}
	}
	
	
	/* 全てのチェックにパス */
	return 1;
}




/*-----------------------------------------------------------------------*/
static
int interpret_non_hyphen_options(int argc, char ** argv, struct dump_attribute * da)
{
	int i;
	char * endp;
	
	for (i = 0; i < argc; i++) {
		/* 生のハイフン('-') は 標準入力からの読み込み指定 */
		if (strcmp(argv[i], "-") == 0) {
			if (da->input_stdin) {
				fprintf(stderr, "duplicate stdin specified\n");
				return -1;
			}
			
			da->input_stdin = 1;
			
			continue;
		}
		
		
		/*
		 * shmdumpは次のようなコマンド形式だった。
		 *      $ shmdump 0x1234 1024
		 *
		 * 過去互換性のため、オプション文字が無い数字列は次のように看做す。
		 *    * shmkeyがまだ指定されておらず、0x(数字列)の形式 ⇒ shmkey
		 *    * 全て数字 ⇒ dump_size
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
		 * 不明オプションはコマンドエラー。
		 * オプション間違いやtypoを気付かせるため無視にはしない。
		 * shmdumpは実施者とデータ確認者が別であるケース、また時間
		 * 的に離れているケースが多いため、誤った実行はその場で判っ
		 * た方が良い。
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
				 * shmkey指定で 0x 無しの数値(10進数)は、意図が誤っている
				 * 可能性が高いため、エラーとする。
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
			 * 不明オプションはコマンドエラー。
			 * オプション間違いやtypoを気付かせるため、無視の仕様にはしない。
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
	
	
	/* '-' 付き引数、及び'-' 無し引数の解釈と格納 */
	if (interpret_hyphen_options(argc, argv, da) == -1)
		return -1;
	if (interpret_non_hyphen_options(argc - optind, &argv[optind], da) == -1)
		return -1;
	
	
	/* 整合チェック */
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
	/*	split_num(s,delim,n)がresult(想定する結果)と			*/
	/*      異なれば表示							*/
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
	 * 注意: ~0 は初期値を意味する (i.e. 指定した箇所の変数はsplit_num()に
	 *       よって評価・格納されていない事を表す)
	 *
	 *              入力					想定される正常出力
	 *              s               delim    n   		戻り値	 評価・格納された数値
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
	/*	option 文字列を argv 形式にパース。					*/
	/*	get_option(argv形式のoption)でresult(想定する結果)と異なれば表示	*/
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
	 * 	byte と delay_ms の関係に制約は無い。
	 *	よって、小さなbyte且つ大きなdelay でコマンドを実行すると終わらなくなる。
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
	/*	option 文字列を argv 形式にパース。			*/
	/*	get_option へ掛けてresult(想定する結果)と異なれば表示	*/
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
	 *	shmkeyとshmidは同時指定不可
	 *	shmkeyの -M、dump_sizeの -s は省略可能。裸の数値が表れた場合、
	 * 		shmkey と shmid がまだ指定されていないなら、それを shmkey と看做す
	 * 		shmkey 又は shmid が指定済みなら、
	 *			dump_size が指定されていないなら、それを dump_size と看做す
	 * 			dump_size が指定済みならNG。
	 */
	RELATION_TEST("0x0 1",						0)	/* 裸のshmkey、裸のdump_size */
	RELATION_TEST("0x0 1 1",					-1)	/* 裸のshmkey、裸のdump_size、unknown */
	RELATION_TEST("0x0 1 0x1",					-1)	/* 裸のshmkey、裸のdump_size、unknown */
	RELATION_TEST("0x0 0x1 1",					-1)	/* 裸のshmkey、裸のdump_size、unknown */
	RELATION_TEST("-M 0x0 1",					0)	
	RELATION_TEST("-M 0x0 -s 1",					0)	
	RELATION_TEST("-m 1 1",						0)	
	RELATION_TEST("-m 1 -m 1 1",					-1)	/* 重複指定 */
	RELATION_TEST("-M 0x0 -M 0x1 1",				-1)	/* 重複指定 */
	RELATION_TEST("-M 0x0 -m 0 -s 1",				-1)	/* shmkey と shmid の同時指定 */
	
	RELATION_TEST("0x0",						-1)	/* 裸のshmkey、dump_size も block_sizeも指定なし*/
	RELATION_TEST("-M 0x0",						-1)	/* オプション文字shmkey、dump_size も block_sizeも指定なし*/
	RELATION_TEST("-m 0",						-1)	/* オプション文字shmid、dump_size も block_sizeも指定なし*/
	RELATION_TEST("-M 0x0 -m 0",					-1)	/* shmkey と shmid の同時指定。dump_size も block_sizeも指定なし */
	
	RELATION_TEST("-M 0x0 -b 1",					0)
	RELATION_TEST("-M 0x0 -b 1 -b 2",				-1)	/* 重複指定 */
	RELATION_TEST("-M 0x0 -s 1 -b 1",				-1)
	RELATION_TEST("-M 0x0 -s 2 -b 1",				-1)
	RELATION_TEST("-M 0x0 -s 1 -b 2",				-1)
	
	/*
	 *	segmentはblockの中に収まっている必要あり。
	 *	segment間で範囲の重複は不可
	 *	segmentを指定するときはblock_sizeが必須
	 */
	RELATION_TEST("-M 0x0 -b 4 -S 0:1",				0)
	RELATION_TEST("-M 0x0 -b 4 -S 0:1 -S 1:1",			0)
	RELATION_TEST("-M 0x0 -b 4 -S 0:1 -S 2:2",			0)
	RELATION_TEST("-M 0x0 -b 4 -S 0:2 -S 1:1",			-1)	/* segment の範囲重複 */
	RELATION_TEST("-M 0x0 -b 4 -S 0:2 -S 1:2",			-1)	/* segment の範囲重複 */
	RELATION_TEST("-M 0x0 -b 4 -S 1:1 -S 1:2",			-1)	/* segment の範囲重複 */
	RELATION_TEST("-M 0x0 -b 4 -S 2:1 -S 1:2",			-1)	/* segment の範囲重複 */
	RELATION_TEST("-M 0x0 -b 4 -S 2:2 -S 1:2",			-1)	/* segment の範囲重複 */
	RELATION_TEST("-M 0x0 -b 4 -S 3:1 -S 1:2",			0)
	RELATION_TEST("-M 0x0 -b 4 -S 0:4",				0)
	RELATION_TEST("-M 0x0 -b 4 -S 0:5",				-1)	/* segmentがblock境界越え */
	RELATION_TEST("-M 0x0 -b 4 -S 3:1",				0)
	RELATION_TEST("-M 0x0 -b 4 -S 4:1",				-1)	/* segmentがblock境界越え */
	RELATION_TEST("-M 0x0 -b 4 -S 5:1",				-1)	/* segmentがblock境界越え */
	RELATION_TEST("-M 0x0 -s 1 -S 0:1",				-1)	/* block_sizeの指定が無い */
	
	
	
	/*
	 *	block_countを指定するときはblock_sizeが必須
	 */
	RELATION_TEST("-M 0x0 -b 4 -c 1",				0)	
	RELATION_TEST("-M 0x0 -b 4 -c 2",				0)	
	RELATION_TEST("-M 0x0 -c 2",					-1)	/* block_sizeの指定が無い */
	RELATION_TEST("-M 0x0 -s 1 -S 0:1 -c 1",			-1)	/* block_sizeの指定が無い */
	RELATION_TEST("-M 0x0 -b 4 -c 2 -c 3",				-1)	/* 重複指定 */
	
	/*
	 *	delayは他のオプションと相関なしで指定が可能。但し重複指定だけは不可。
	 */
	RELATION_TEST("-M 0x0 -s 1 -d 1:1",				0)
	RELATION_TEST("-M 0x0 -b 1 -S 0:1 -d 1:1",			0)
	RELATION_TEST("-M 0x0 -b 1 -S 0:1 -c 1 -d 1:1",			0)
	RELATION_TEST("-M 0x0 -b 1 -S 0:1 -c 1 -d 1:1",			0)
	RELATION_TEST("-M 0x0 -b 1 -S 0:1 -c 1 -d 1:1 -d 2:1",		-1)	/* 重複指定 */
	
	/*
	 *	fileは他のオプションと相関なしで指定が可能。但し重複指定だけは不可。
	 */
	RELATION_TEST("-M 0x0 -s 1 -f test_file",			0)
	RELATION_TEST("-M 0x0 -b 1 -S 0:1 -c 1 -d 1:1 -f test_file",	0)
	RELATION_TEST("-M 0x0 -f test_file1 -f test_file2",		-1)	/* 重複指定 */
	
	/*
	 *	標準入力読み込みは任意に指定が可能。但し重複だけは不可。
	 *	
	 *	標準入力読み込みが指定されている場合はshmkey, shmidが
	 *	無くとも良い。あった場合は標準入力読み込みが優先される。
	 *	(共有メモリからの読み込みとファイルからの読み込みで、
	 *	オプション形式が大きく変らないほうが便利であるため)。
	 */
	RELATION_TEST("-s 1 -",						0)
	RELATION_TEST("-M 0x0 -s 1 -",					0)	/* 標準入力からの読み込みが優先 */
	RELATION_TEST("-b 1024 -S 0:2 -",				0)
	RELATION_TEST("-M 0x0 -s 1 - -",				-1)	/* 重複指定 */
	RELATION_TEST("-M 0x0 - -s 1 -",				-1)	/* 重複指定 */
	RELATION_TEST("-",						-1)	/* dump_sizeもblock_sizeも無い */
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



