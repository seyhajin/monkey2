
#include "bbmonkey.h"

#include "bbplatform.h"

#include <stdarg.h>

int bb_argc;
char **bb_argv;

void bbMain();

#if BB_ANDROID

#include <android/log.h>

void bb_print( bbString str ){
	__android_log_write( ANDROID_LOG_INFO,"MX2",str.c_str() );
}

void bb_printf( const char *fmt,... ){
	va_list args;
	va_start( args,fmt );
	__android_log_vprint( ANDROID_LOG_INFO,"MX2",fmt,args );
	va_end( args );
}

#elif !BB_IOS

void bb_print( bbString str ){
	puts( str.c_str() );fflush( stdout );
}

void bb_printf( const char *fmt,... ){
	va_list args;
	va_start( args,fmt );
	vprintf( fmt,args );
	va_end( args );
	fflush( stdout );
}

#endif

#if BB_ANDROID || BB_IOS

extern "C" int SDL_main( int argc,char *argv[] ){

#else

int main( int argc,char **argv ){

#endif

	bbGC::init();
	bbDB::init();

	bb_argc=argc;
	bb_argv=argv;
	
	try{
	
		bbMain();
	
	}catch( bbThrowable *t ){
	
		printf( "\n***** Uncaught Monkey 2 Throwable *****\n\n" );

	}catch(...){
	
		printf( "***** Uncaught Native Exception *****\n" );fflush( stdout );
		throw;
	}
	
	return 0;
}
