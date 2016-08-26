#ifndef __INIT
#define __INIT

#include <sys/types.h>
#include <sys/stat.h>

#include "common.h"


int init_environ(Environ * env, char * filename);
void disp_environ(Environ * env);

int alloc_tundev(char * tun_dev, int tundev_env_max);
void free_tundev(char * tun_dev, int tundev_env_max);

#endif /* __INIT */


