
#ifndef BB_THEORAPLAYER_GLUE_H
#define BB_THEORAPLAYER_GLUE_H

#include <bbmonkey.h>

namespace theoraplayer{
	class Manager;
	class VideoClip;
}

theoraplayer::VideoClip *bb_theoraplayer_createVideoClip( theoraplayer::Manager *self,const char *filename );

theoraplayer::Manager *bb_theoraplayer_getManager();

#endif
