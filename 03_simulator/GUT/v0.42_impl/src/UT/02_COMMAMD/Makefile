
all: test_sgets01 test_session_add_request

test_sgets01 : test_sgets01.c ../../*.c ../../*.h
	gcc -Wall -o test_sgets01 test_sgets01.c


test_session_add_request: test_session_add_request.c ../../common.o ../../init.o ../../command.o ../../interface.o
	gcc -Wall -I../../ -o test_session_add_request test_session_add_request.c ../../common.o ../../init.o ../../command.o ../../interface.o

test_session_delete_request: test_session_delete_request.c ../../common.o ../../init.o ../../command.o ../../interface.o
	gcc -Wall -I../../ -o test_session_delete_request test_session_delete_request.c ../../common.o ../../init.o ../../command.o ../../interface.o
	
test_session_flush_request: test_session_flush_request.c ../../common.o ../../init.o ../../command.o ../../interface.o
	gcc -Wall -I../../ -o test_session_flush_request test_session_flush_request.c ../../common.o ../../init.o ../../command.o ../../interface.o


test_exec_command: test_exec_command.c ../../common.o ../../init.o ../../command.o ../../interface.o
	gcc -Wall -I../../ -o test_exec_command test_exec_command.c ../../common.o ../../init.o ../../command.o ../../interface.o


