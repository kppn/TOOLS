OBJS	= gut_main.o gtp.o init.o common.o command.o interface.o 


gut : $(OBJS)
	gcc -Wall -o ./gut $(OBJS)
	chmod +x ./gut

init.o: init.c init.h global.h
	gcc -Wall -c -o init.o init.c

common.o: common.c common.h init.h global.h
	gcc -Wall -c -o common.o common.c

command.o: command.c command.h common.h global.h
	gcc -Wall -c -o command.o command.c

interface.o: interface.c interface.h global.h
	gcc -Wall -c -o interface.o interface.c

gtp.o: gtp.c gtp.h global.h
	gcc -Wall -c -o gtp.o gtp.c

gut_main.o: gut_main.c init.h common.h command.h interface.h global.h
	gcc -Wall -c -o gut_main.o gut_main.c


clean:
	rm ./gut *.o


