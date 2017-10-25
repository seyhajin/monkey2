
#include "bbmusic.h"

#include "../../../openal/native/bbopenal.h"

#include "../../../std/async/native/async.h"
#include "../../../std/async/native/async_cb.h"

#include "../../../stb-vorbis/native/stb-vorbis.h"

namespace bbMusic{

	bool playMusic( const char *path,int callback,int alsource ){
	
		int error=0;
		stb_vorbis *vorbis=stb_vorbis_open_filename( path,&error,0 );
		if( !vorbis ) return false;
		
		std::thread thread( [=](){
		
			ALuint source=alsource;
	
			stb_vorbis_info info=stb_vorbis_get_info( vorbis );

			int length=stb_vorbis_stream_length_in_samples( vorbis );
			
			float duration=stb_vorbis_stream_length_in_seconds( vorbis );
			
//			printf( "vorbis length=%i, duration=%f, info.sample_rate=%i, info.channels=%i\n",length,duration,info.sample_rate,info.channels );fflush( stdout );

			const int BUFFER_SIZE=2048;
			int nsamples=(info.channels==2 ? BUFFER_SIZE/4 : BUFFER_SIZE/2);
			ALenum format=(info.channels==2 ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO8);
			
			//how long a buffer takes to play?
			int buffer_ms=nsamples*1000/info.sample_rate;
			
			//polling for paused occasionally fails with only 2 buffers
			ALuint buffers[3];
			alGenBuffers( 3,buffers );
			
			alBufferData( buffers[0],format,0,BUFFER_SIZE,info.sample_rate );
			alBufferData( buffers[1],format,0,BUFFER_SIZE,info.sample_rate );
			alBufferData( buffers[2],format,0,BUFFER_SIZE,info.sample_rate );
			
			alSourceQueueBuffers( source,3,buffers );
			
			short *vorbis_data=new short[BUFFER_SIZE/2];
			
			alSourcePlay( source );
			
//			printf( "Playing music...\n" );fflush( stdout );
			
			for(;;){

				int n=stb_vorbis_get_samples_short_interleaved( vorbis,info.channels,vorbis_data,BUFFER_SIZE/2 );
				if( !n ) break;
				
				ALenum state;
				
				for(;;){
					alGetSourcei( source,AL_SOURCE_STATE,&state );
					if( state==AL_STOPPED ) break;

					ALint processed;
					alGetSourcei( source,AL_BUFFERS_PROCESSED,&processed );
					
//					if( state!=AL_PLAYING ){
//						printf( "state=%i\n",state );fflush( stdout );
//					}
					
					if( state==AL_PLAYING && processed ) break;
				        
					std::this_thread::sleep_for( std::chrono::milliseconds( buffer_ms ) );
				}
				if( state==AL_STOPPED ) break;
				
				ALuint buffer;
				alSourceUnqueueBuffers( source,1,&buffer );
					
				alBufferData( buffer,format,vorbis_data,BUFFER_SIZE,info.sample_rate );
				
				alSourceQueueBuffers( source,1,&buffer );
			}

//			printf( "Music done.\n" );fflush( stdout );
			
			alSourceStop( source );
			
			delete[] vorbis_data;
			
			alDeleteBuffers( 2,buffers );
			
//			alDeleteSources( 1,&source );
			
			stb_vorbis_close( vorbis );
			
			bbAsync::invokeAsyncCallback( callback );
		} );
		
		thread.detach();

		return true;
	}
}

