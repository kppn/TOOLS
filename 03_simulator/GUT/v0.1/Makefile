OBJS	= gut_main.o gtp.o common.o


gut : $(OBJS)
	gcc -Wall -o gut $(OBJS)

common.o: common.c
	gcc -Wall -c -o common.o common.c

gtp.o: gtp.c
	gcc -Wall -c -o gtp.o gtp.c

gut_main.o: gut_main.c
	gcc -Wall -c -o gut_main.o gut_main.c


clean:
	rm gut


