OBJS    = test.o common.o

test: $(OBJS)
	gcc -Wall -o test $(OBJS)

common.o: common.c
	gcc -Wall -c -o common.o common.c

test.o: test.c
	gcc -Wall -c -o test.o test.c

clean:
	rm gut

