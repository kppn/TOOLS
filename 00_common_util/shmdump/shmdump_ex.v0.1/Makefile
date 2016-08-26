
shmdump_ex: shmdump_ex.c
	gcc -Wall -o shmdump_ex shmdump_ex.c

cshm: cshm.c
	gcc -Wall -o cshm cshm.c

test:
	gcc -Wall -DTEST -o shmdump_ex shmdump_ex.c
	./shmdump_ex 2> /dev/null
