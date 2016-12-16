
#include "monkey2_glue.h"

#include "theoraplayer.h"
#include "Manager.h"
#include "MemoryDataSource.h"

theoraplayer::Manager *bb_theoraplayer_getManager(){

	if( !theoraplayer::manager ) theoraplayer::init();
	
	return theoraplayer::manager;
}

theoraplayer::VideoClip *bb_theoraplayer_createVideoClip( theoraplayer::Manager *self,const char *filename ){

	return self->createVideoClip( filename );
}

//FIXME - leaks MemoryDataSource!
//
theoraplayer::VideoClip *bb_theoraplayer_createVideoClip( theoraplayer::Manager *self,const void *data,int length ){

	theoraplayer::MemoryDataSource *src=new theoraplayer::MemoryDataSource( (unsigned char*)data,length,"Theora" );
	
	return self->createVideoClip( src );
}

theoraplayer::MemoryDataSource *bb_theoraplayer_createMemoryDataSource( const void *data,int length,const char *formatName ){

	return new theoraplayer::MemoryDataSource( (unsigned char*)data,length,formatName );
}

