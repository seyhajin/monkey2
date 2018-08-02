
#include "bbmonkey.h"
#include "bbplatform.h"

#if BB_IOS

void bb_print( bbString str ){

	NSLog( @"MX2: %@",[NSString stringWithUTF8String:str.c_str() ] );
}

void bb_printf( const char *fmt,...){

    va_list args;
    
    va_start( args,fmt );
    
    NSLog( @"MX2: %@",[[NSString alloc] initWithFormat:[NSString stringWithUTF8String:fmt] arguments:args] );
    
    va_end(args);
}

#endif
