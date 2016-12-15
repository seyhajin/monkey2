
Namespace theoraplayer

#If __TARGET__<>"emscripten"

#Import "<openal>"

#Import "makefile.monkey2"

#Import "native/ogg/include/*.h"

#Import "native/vorbis/lib/*.h"
#Import "native/vorbis/include/*.h"

#Import "native/theora/include/*.h"

#Import "native/theoraplayer/include/*.h"
#Import "native/theoraplayer/include/theoraplayer/*.h"
#Import "native/theoraplayer/src/*.h"
#Import "native/theoraplayer/src/formats/*.h"
#Import "native/theoraplayer/src/YUV/*.h"
#Import "native/theoraplayer/src/YUV/libyuv/include/*.h"

#Import "<theoraplayer.h>"
#Import "<theoraplayer/Manager.h>"
#Import "<theoraplayer/VideoClip.h>"
#Import "<theoraplayer/VideoFrame.h>"

#Import "native/OpenAL_AudioInterface.cpp"
#Import "native/OpenAL_AudioInterface.h"

#Import "native/monkey2_glue.cpp"
#Import "native/monkey2_glue.h"

Extern

Class VideoManager Extends Void="theoraplayer::Manager" 

	Method setAudioInterfaceFactory( audioFactory:AudioInterfaceFactory )

	Method createVideoClip:VideoClip( filename:CString ) Extension="bb_theoraplayer_createVideoClip"
 
 	Method update( time_increase:Float )
 	
 	Function getInstance:VideoManager()="bb_theoraplayer_getManager"
 	
End

Class VideoClip Extends Void="theoraplayer::VideoClip"

	Method getWidth:Int()
	
	Method getHeight:Int()
	
	Method getStride:Int()
	
	Method updateTimerToNextFrame:Float()

	Method fetchNextFrame:VideoFrame()
	
	Method popFrame()
	
	Method getReadyFramesCount:Int()
	
	Method play()
	
End

Class VideoFrame Extends Void="theoraplayer::VideoFrame" 

	Method getFrameNumber:Int()
	
	Method getBuffer:UByte Ptr()
	
	Method getWidth:Int()
	
	Method getHeight:Int()

	Method getStride:Int()
End

Class AudioInterfaceFactory Extends Void="theoraplayer::AudioInterfaceFactory"

End

Class OpenAL_AudioInterfaceFactory Extends AudioInterfaceFactory

End

#End
