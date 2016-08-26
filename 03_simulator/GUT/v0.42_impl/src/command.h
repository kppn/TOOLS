#ifndef __COMMAND
#define __COMMAND

#include <stddef.h>
#include "init.h"



int exec_command(uchar * buf, size_t size, Environ * env, struct sockaddr_in * msg_from);
int session_add_request(uchar * buf, size_t size, Environ * env, struct sockaddr_in * msg_from);
int session_delete_request(uchar * buf, size_t size, Environ * env, struct sockaddr_in * msg_from);
int session_flush_request(uchar * buf, size_t size, Environ * env, struct sockaddr_in * msg_from);
int session_display_request(uchar * buf, size_t size, Environ * env, struct sockaddr_in * msg_from);





#endif /* __COMMAND */

