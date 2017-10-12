
#include "libc.h"

#if _WIN32
#include <windows.h>
#include <bbstring.h>
#if _MSC_VER
#include <stdint.h>
#endif
#elif __APPLE__
#include <TargetConditionals.h>
#endif

void setenv_( const char *name,const char *value,int overwrite ){

#if _WIN32

	if( !overwrite && getenv( name ) ) return;

	bbString tmp=bbString( name )+BB_T( "=" )+bbString( value );
	putenv( tmp.c_str() );

#else
	setenv( name,value,overwrite );
#endif
}

int system_( const char *cmd ){

#if _WIN32

	bool inherit=false;
	DWORD flags=CREATE_NO_WINDOW;
	STARTUPINFOA si={sizeof(si)};
	PROCESS_INFORMATION pi={0};
	
	bbString tmp=BB_T( "cmd /S /C\"" )+BB_T( cmd )+BB_T( "\"" );
	
	if( GetStdHandle( STD_OUTPUT_HANDLE ) ){
	
		inherit=true;
		si.dwFlags=STARTF_USESTDHANDLES;
		si.hStdInput=GetStdHandle( STD_INPUT_HANDLE );
		si.hStdOutput=GetStdHandle( STD_OUTPUT_HANDLE );
		si.hStdError=GetStdHandle( STD_ERROR_HANDLE );
	}
	
	if( GetConsoleWindow() ){

		flags=0;
	}
	
	if( !CreateProcessA( 0,(LPSTR)tmp.c_str(),0,0,inherit,flags,0,0,&si,&pi ) ) return -1;

	WaitForSingleObject( pi.hProcess,INFINITE );
	
	int res=GetExitCodeProcess( pi.hProcess,(DWORD*)&res ) ? res : -1;
	
	CloseHandle( pi.hProcess );
	CloseHandle( pi.hThread );

	return res;
	
#elif __APPLE__

#if !TARGET_OS_IPHONE
	return system( cmd );
#endif

#else

	return system( cmd );

#endif

	return -1;

}

int mkdir_( const char *path,int mode ){
#if _WIN32

	return mkdir( path );
	
#else

	return mkdir( path,0777 );
	
#endif
}

int gettimeofday_( timeval *tv ){
#if _MSC_VER
	
	// https://stackoverflow.com/questions/10905892/equivalent-of-gettimeday-for-windows

    // Note: some broken versions only have 8 trailing zero's, the correct epoch has 9 trailing zero's
    // This magic number is the number of 100 nanosecond intervals since January 1, 1601 (UTC)
    // until 00:00:00 January 1, 1970 
    static const uint64_t EPOCH = ((uint64_t) 116444736000000000ULL);

    SYSTEMTIME  system_time;
    FILETIME    file_time;
    uint64_t    time;

    GetSystemTime( &system_time );
    SystemTimeToFileTime( &system_time, &file_time );
    time =  ((uint64_t)file_time.dwLowDateTime )      ;
    time += ((uint64_t)file_time.dwHighDateTime) << 32;

    tv->tv_sec  = (long) ((time - EPOCH) / 10000000L);
    tv->tv_usec = (long) (system_time.wMilliseconds * 1000);
    return 0;
    
#else

	return gettimeofday( tv,0 );
	
#endif
}