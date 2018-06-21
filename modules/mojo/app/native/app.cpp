
#include "app.h"

#include "../../../std/async/native/async.h"

#include <SDL.h>

#include <thread>

namespace bbApp{

	bool swapThread;
	bbAsync::Semaphore swapSema;

	void postEventFilter( bbAsync::Event *event ){

		SDL_UserEvent uevent;
		uevent.type=SDL_USEREVENT;
		uevent.code=0;
		uevent.data1=event;
		uevent.data2=0;
	
		if( SDL_PeepEvents( (SDL_Event*)&uevent,1,SDL_ADDEVENT,SDL_FIRSTEVENT,SDL_LASTEVENT )!=1 ){
			printf( "SDL_PeepEvents error: %s\n",SDL_GetError() );fflush( stdout );
		}
	}

	void init(){

		bbAsync::setPostEventFilter( postEventFilter );
	}
	
	void swapBuffers( void *window,void *context ){
	
		if( !swapThread ){
			
			swapThread=true;
	
			SDL_Window *sdlwindow=(SDL_Window*)window;
			SDL_GLContext sdlcontext=(SDL_GLContext)context;
			
			std::thread( [=](){
			
				SDL_GL_MakeCurrent( sdlwindow,sdlcontext );
				
				SDL_UserEvent uevent;
				uevent.type=SDL_USEREVENT;
				uevent.windowID=SDL_GetWindowID( sdlwindow );
				uevent.code=1;
		
				for(;;){
				
					swapSema.wait();
			
					SDL_GL_SwapWindow( sdlwindow );
		
					if( SDL_PeepEvents( (SDL_Event*)&uevent,1,SDL_ADDEVENT,SDL_FIRSTEVENT,SDL_LASTEVENT )!=1 ){
						printf( "SDL_PeepEvents error: %s\n",SDL_GetError() );fflush( stdout );
					}
				}
	
			} ).detach();
		}
		swapSema.signal();
	}
}
