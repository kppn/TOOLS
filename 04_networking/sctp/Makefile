
includes = -I/home/kppn/program/c/test/head/
#linkobj = ../utils/string_util.o
linkobj = 
options =  $(includes) -O2 

all: server.c client.c $(linkobj)
	gcc $(options) -lsctp -o server $(linkobj) server.c
	gcc $(options) -lsctp -o client $(linkobj) client.c

opt0:
	gcc $(options) -O0 -lsctp -o server $(linkobj) server.c

opt1:
	gcc $(options) -O1 -lsctp -o server $(linkobj) server.c

opt2:
	gcc $(options) -O2 -lsctp -o server $(linkobj) server.c

opt3:
	gcc $(options) -O3 -lsctp -o server $(linkobj) server.c

