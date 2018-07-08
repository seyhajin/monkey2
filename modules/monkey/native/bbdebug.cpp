
#include "bbdebug.h"
#include "bbarray.h"
#include <bbmonkey.h>

#if _WIN32
#include <windows.h>
#include <thread>
#endif

#include <signal.h>

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

typedef void(*dbEmit_t)(void*);

#if BB_THREADS
namespace bbGC{
	extern const char *state;
	void suspendThreads();
	void resumeThreads();
}
#endif

namespace bbDB{

#if BB_THREADS	
	std::atomic_int nextSeq;
	thread_local bbDBContext *currentContext;
#else
	int nextSeq;
	bbDBContext *currentContext;
#endif

	bbDBContext mainContext;
	
#if !_WIN32
	void breakHandler( int sig ){
	
		currentContext->stopped=1;
	}
#endif

	//Note: doesn't work on non-mainthread on at least windows.
	//
	void sighandler( int sig  ){
	
		const char *err="SIGNAL: Unknown signal";
		
		switch( sig ){
		case SIGSEGV:err="SIGNAL: Memory access violation";break;
		case SIGILL:err= "SIGNAL: Illegal instruction";break;
		case SIGFPE:err= "SIGNAL: Floating point exception";break;
#if !_WIN32
		case SIGBUS:err= "SIGNAL: Bus error";break;
#endif	
		}
		
		char buf[160];
#ifdef BB_THREADS		
		sprintf( buf,"Monkey 2 Runtime error: %s\nGC state=%s\n",err,bbGC::state );
#else
		sprintf( buf,"Monkey 2 Runtime error: %s\n",err );
#endif
		bb_printf( buf );

#ifdef NDEBUG
#ifdef _WIN32
 		MessageBoxA( 0,buf,"Monkey 2 Runtime Error",MB_OK );
#endif
		exit( -1 );
#endif
		stopped();
	}
	
	void init(){
	
		mainContext.init();
		
		currentContext=&mainContext;
	
		signal( SIGSEGV,sighandler );
		signal( SIGILL,sighandler );
		signal( SIGFPE,sighandler );
#if !_WIN32
		signal( SIGBUS,sighandler );
#endif		

#ifndef NDEBUG
		
#if _WIN32
		if( HANDLE breakEvent=OpenEvent( EVENT_ALL_ACCESS,false,"MX2_BREAK_EVENT" ) ){
//			bb_printf( "Found BREAK_EVENT!\n" );fflush( stdout );
		    std::thread( [=](){
		    	for( ;; ){
		    		WaitForSingleObject( breakEvent,INFINITE );
//	    			bb_printf( "received Break event!\n" );fflush( stdout );
					currentContext->stopped=1;
		    	}
		    } ).detach();
		}
#else		
		signal( SIGTSTP,breakHandler );
#endif
#endif
	}
	
	void emit( const char *e ){
	
		if( const char *p=strchr( e,':' ) ){
			dbEmit_t dbEmit=(dbEmit_t)( strtol( p+1,0,16 ) );
			dbEmit( (void*)strtol( e,0,16 ) );
		}else{
			bbGCNode *node=(bbGCNode*)strtoll( e,0,16 );
			node->dbEmit();
		}
		
		puts( "" );
		fflush( stdout );
	}
	
	void emitVar( bbDBVar *v ){
		bbString id=v->name;
		bbString type=v->type->type();
		bbString value=v->type->value( v->var );
		bbString t=id+":"+type+"="+value+"\n";
		bb_printf( "%s",t.c_str() );
	}
	
	void emitStack(){
		bbDBVar *ev=currentContext->locals;
		
		for( bbDBFrame *f=currentContext->frames;f;f=f->succ ){

			bb_printf( ">%s;%s;%i;%i\n",f->decl,f->srcFile,f->srcPos>>12,f->seq );
			
			for( bbDBVar *v=f->locals;v!=ev;++v ){
				emitVar( v );
			}

			ev=f->locals;
		}
	}
	
	void error( bbString msg ){
#if _WIN32
		MessageBoxW( 0,bbWString( msg ),L"Monkey 2 Runtime Error",MB_OK );
#else
		bb_print( msg );
#endif
		stopped();
	}
	
	void stopped(){
	
#ifdef NDEBUG
		exit( -1 );
#endif

#ifdef BB_THREADS
		bbGC::suspendThreads();
#endif

#ifdef __EMSCRIPTEN__
		emscripten_pause_main_loop();
#endif

		bb_printf( "{{!DEBUG!}}\n" );
		emitStack();
		bb_printf( "\n" );
		
		fflush( stdout );
		
		for(;;){
		
			char buf[256];
			char *e=fgets( buf,256,stdin );
			if( !e ) exit( -1 );
			
#ifdef BB_THREADS
			bbGC::resumeThreads();
#endif

#ifdef __EMSCRIPTEN__
			emscripten_resume_main_loop();
#endif
			switch( e[0] ){
			case 'r':currentContext->stopped=0;currentContext->stepMode=0;break;
			case 'e':currentContext->stopped=1;currentContext->stepMode=0;break;
			case 's':currentContext->stopped=1;currentContext->stepMode='s';break;
			case 'l':currentContext->stopped=0;currentContext->stepMode='l';break;
			case '@':emit( e+1 );continue;
			case 'q':exit( 0 );break;
			default:
				bb_printf( "Unrecognized debug cmd: %s\n",buf );fflush( stdout );
				exit( -1 );
			}
			return;
		}
	}
	
	bbArray<bbString> stack(){
	
		int n=0;
		for( bbDBFrame *frame=currentContext->frames;frame;frame=frame->succ ) ++n;
		
		//TODO: Fix GC issues! Can't have a free local like this in case bbString ctors cause gc sweep!!!!
		bbArray<bbString> st=bbArray<bbString>( n );
		
		int i=0;
		for( bbDBFrame *frame=currentContext->frames;frame;frame=frame->succ ){
			st[i++]=BB_T( frame->srcFile )+" ["+bbString( frame->srcPos>>12 )+"] "+frame->decl;
		}
		
		return st;
	}
	
	void stop(){
	
		//currentContext->stopped=1;	//stop on *next* stmt.
		
		stopped();						//stop on DebugStop() stmt.
	}
	
}

void bbDBContext::init(){
	if( !localsBuf ) localsBuf=new bbDBVar[16384];
	locals=localsBuf;
	frames=nullptr;
	stepMode=0;
	stopped=0;
}

bbDBContext::~bbDBContext(){
	delete[] localsBuf;
}

bbString bbDBValue( bbString *p ){
	bbString t=*p,dd="";
	if( t.length()>100 ){
		t=t.slice( 0,100 );
		dd="...";
	}
	t=t.replace( "\"","~q" );
	t=t.replace( "\n","~n" );
	t=t.replace( "\r","~r" );
	t=t.replace( "\t","~t" );
	return BB_T("\"")+t+"\""+dd;
}
