
#include "monkey2_glue.h"

#include "theoraplayer.h"
#include "Manager.h"

theoraplayer::VideoClip *bb_theoraplayer_createVideoClip( theoraplayer::Manager *self,const char *filename ){
	return self->createVideoClip( filename );
}

theoraplayer::Manager *bb_theoraplayer_getManager(){

	if( !theoraplayer::manager ) theoraplayer::init();
	
	return theoraplayer::manager;
}


