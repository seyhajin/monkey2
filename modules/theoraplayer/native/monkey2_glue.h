
#ifndef BB_THEORAPLAYER_GLUE_H
#define BB_THEORAPLAYER_GLUE_H

#include <bbmonkey.h>

namespace theoraplayer{
	class Manager;
	class VideoClip;
	class MemoryDataSource;
}

theoraplayer::Manager *bb_theoraplayer_getManager();

theoraplayer::VideoClip *bb_theoraplayer_createVideoClip( theoraplayer::Manager *self,const char *filename );

theoraplayer::VideoClip *bb_theoraplayer_createVideoClip( theoraplayer::Manager *self,const void *data,int length );

theoraplayer::MemoryDataSource *bb_theoraplayer_createMemoryDataSource( const void *data,int length,const char *formatName );

#endif
