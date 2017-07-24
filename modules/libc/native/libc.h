
//Libc fudge, mainly for windows.

#ifndef BB_LIB_C_H
#define BB_LIB_C_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <limits.h>

#if _MSC_VER
#include <direct.h>
#include <winsock2.h>	//for struct timeval?!?
#include "dirent_msvc.h"
typedef int mode_t;
#else
#include <unistd.h>
#include <dirent.h>
#include <sys/time.h>
#endif

#if _WIN32
#define PATH_MAX 260
#define realpath(X,Y) _fullpath( (Y),(X),PATH_MAX )
#else
#include <limits.h>
#endif

typedef struct tm tm_t;

typedef struct stat stat_t;

int system_( const char *command );
void setenv_( const char *name,const char *value,int overwrite );
int mkdir_( const char *path,int mode );
int gettimeofday_( timeval *tv );

#endif
