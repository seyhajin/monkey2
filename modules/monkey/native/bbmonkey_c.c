
#include "bbmonkey_c.h"

#if __ANDROID__

#include <android/log.h>

void bb_printf( const char *fmt,... ){
	va_list args;
	va_start( args,fmt );
	__android_log_vprint( ANDROID_LOG_INFO,"MX2",fmt,args );
	va_end( args );
}

#else

#include <stdio.h>
#include <stdarg.h>

void bb_printf( const char *fmt,... ){
	va_list args;
	va_start( args,fmt );
	vprintf( fmt,args );
	va_end( args );
	fflush( stdout );
}

#endif
