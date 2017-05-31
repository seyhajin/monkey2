
#ifndef BB_STD_PROCUTIL_H
#define BB_STD_PROCUTIL_H

#if _WIN32

#include <windows.h>
#include <tlhelp32.h>

#if !_MSC_VER
extern "C" WINBASEAPI WINBOOL WINAPI CancelIoEx( HANDLE hFile,LPOVERLAPPED lpOverlapped );
#endif

namespace bbProcUtil{

	int TerminateProcessGroup( HANDLE prochandle,int exitCode );
}

#else

#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/wait.h>
#include <signal.h>

namespace bbProcUtil{

	char **makeargv( const char *cmd );

}

#endif

#endif

