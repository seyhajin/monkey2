
#include "bbmusic.h"

#if __APPLE__
#include <OpenAL/al.h>
#include <OpenAL/alc.h>
#else
#include <AL/al.h>
#include <AL/alc.h>
#endif

#include "../../../std/async/native/async.h"
#include "../../../std/async/native/async_cb.h"
#include "../../../stb-vorbis/native/stb-vorbis.h"

#if __ANDROID__
#include "../../../sdl2/SDL/src/core/android/SDL_android.h"
#endif

namespace bbMusic{

#if __ANDROID__
	
	int android_read( void *cookie,char *buf,int size ){
	
	  return AAsset_read( (AAsset*)cookie,buf,size );
	}
	
	int android_write( void *cookie,const char* buf,int size ){
	
	  return EACCES; // can't provide write access to the apk
	}
	
	fpos_t android_seek( void *cookie,fpos_t offset,int whence ){
	
	  return AAsset_seek( (AAsset*)cookie,offset,whence );
	}
	
	int android_close(void* cookie) {
	
	  AAsset_close( (AAsset*)cookie );
	  return 0;
	}
	
#endif
	
	FILE *fopen( const char *path,const char *mode ){
	
#if __ANDROID__
		if( !strncmp( path,"asset::",7 ) ){
			
			AAssetManager *assetManager=Android_JNI_GetAssetManager();
			if( !assetManager ) return 0;
			
	  		AAsset* asset=AAssetManager_open( assetManager,path+7,0 );
			if( !asset ) return 0;
	
	  		return funopen( asset,android_read,android_write,android_seek,android_close );
		}
#endif
		return ::fopen( path,mode );
	}

	bool playMusic( const char *path,int callback,int alsource ){
	
		FILE *file=fopen( path,"rb" );
		if( !file ) return false;
	
		int error=0;
		stb_vorbis *vorbis=stb_vorbis_open_file( file,0,&error,0 );
		if( !vorbis ) return false;
		
		std::thread thread( [=](){
		
			ALuint source=alsource;
	
			stb_vorbis_info info=stb_vorbis_get_info( vorbis );
//			int length=stb_vorbis_stream_length_in_samples( vorbis );
//			float duration=stb_vorbis_stream_length_in_seconds( vorbis );
//			bb_printf( "vorbis length=%i, duration=%f, info.sample_rate=%i, info.channels=%i\n",length,duration,info.sample_rate,info.channels );

			ALenum format=(info.channels==2 ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16);

//			int buffer_size=8192;
//			int nsamples=buffer_size / (info.channels==2 ? 4 : 2);
//			int buffer_ms=nsamples*1000/info.sample_rate;
			
			int buffer_ms=50;
			int nsamples=buffer_ms*info.sample_rate/1000;
			int buffer_size=nsamples * (info.channels==2 ? 4 : 2);
			
//			bb_printf( "buffer_size=%i, buffer_ms=%i\n",buffer_size,buffer_ms );
			
			//polling for paused occasionally fails with only 2 buffers
			ALuint buffers[3];
			alGenBuffers( 3,buffers );
			
			short *vorbis_data=new short[buffer_size/2];
			
			for( int i=0;i<3;++i ){
				int n=stb_vorbis_get_samples_short_interleaved( vorbis,info.channels,vorbis_data,buffer_size/2 );
				alBufferData( buffers[i],format,vorbis_data,buffer_size,info.sample_rate );
			}
			
			alSourceQueueBuffers( source,3,buffers );
			
			alSourcePlay( source );
			
//			bb_printf( "Playing music...\n" );
			
			for(;;){

				ALenum state;
				
				int n=stb_vorbis_get_samples_short_interleaved( vorbis,info.channels,vorbis_data,buffer_size/2 );
				if( !n ){
					//no more data, wait for audio to stop...
					for(;;){
						alGetSourcei( source,AL_SOURCE_STATE,&state );
						if( state==AL_STOPPED ) break;
						std::this_thread::sleep_for( std::chrono::milliseconds( buffer_ms ) );
					}
					break;
				}
				
				for(;;){
					alGetSourcei( source,AL_SOURCE_STATE,&state );
					if( state==AL_STOPPED ) break;

					ALint processed;
					alGetSourcei( source,AL_BUFFERS_PROCESSED,&processed );
					
					if( state==AL_PLAYING && processed ) break;
						
					std::this_thread::sleep_for( std::chrono::milliseconds( buffer_ms ) );
				}
				if( state==AL_STOPPED ){
//					bb_printf( "AL_STOPPED\n" );
					break;
				}
				
				ALuint buffer;
				alSourceUnqueueBuffers( source,1,&buffer );
					
				alBufferData( buffer,format,vorbis_data,buffer_size,info.sample_rate );
				
				alSourceQueueBuffers( source,1,&buffer );
			}

//			bb_printf( "Music done.\n" );
			
			alSourceStop( source );
			
			alDeleteBuffers( 2,buffers );
			
			delete[] vorbis_data;
			
			stb_vorbis_close( vorbis );
			
			fclose( file );
			
			bbAsync::invokeAsyncCallback( callback );
		} );
		
		thread.detach();

		return true;
	}
}

