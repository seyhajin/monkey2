
#include "httprequest.h"

#include "../../std/async/native/async.h"

extern "C" JNIEnv *Android_JNI_GetEnv();	//SDL2

namespace bbHttpRequest{

	bbFunction<void( jobject,bbInt )> onReadyStateChanged;

	bbFunction<void( jobject,bbString,bbInt,bbInt )> onResponseReceived;
}

namespace{

	struct ReadyStateChangedEvent : public bbAsync::Event{
		
		jobject obj;
		int state;
		
		ReadyStateChangedEvent( jobject obj,int state ):obj( obj ),state( state ){
		}
		
		void dispatch(){
		
			bbHttpRequest::onReadyStateChanged( obj,state );
			
			JNIEnv *env=Android_JNI_GetEnv();
			
			env->DeleteGlobalRef( obj );
			
			delete this;
		}
	};

	struct ResponseReceivedEvent : public bbAsync::Event{
		
		jobject obj;
		jstring response;
		int status;
		int state;
		
		ResponseReceivedEvent( jobject obj,jstring response,int status,int state ):obj( obj ),response( response ),status( status ),state( state ){
		}
		
		void dispatch(){
		
			JNIEnv *env=Android_JNI_GetEnv();
			
			const char *cstr=env->GetStringUTFChars( response,0 );
		
			bbString str=bbString::fromCString( cstr );
		
			env->ReleaseStringUTFChars( response,cstr );
		
			bbHttpRequest::onResponseReceived( obj,str,status,state );
			
			env->DeleteGlobalRef( response );
			
			env->DeleteGlobalRef( obj );
			
			delete this;
		}
	};
}

extern "C"{

JNIEXPORT void JNICALL Java_com_monkey2_lib_Monkey2HttpRequest_onNativeReadyStateChanged( JNIEnv *env,jobject obj,int state ){

	obj=env->NewGlobalRef( obj );

	ReadyStateChangedEvent *ev=new ReadyStateChangedEvent( obj,state );
	
	ev->post();
}

JNIEXPORT void JNICALL Java_com_monkey2_lib_Monkey2HttpRequest_onNativeResponseReceived( JNIEnv *env,jobject obj,jstring response,int status,int state ){

	obj=env->NewGlobalRef( obj );
	
	response=(jstring)env->NewGlobalRef( response );
	
	ResponseReceivedEvent *ev=new ResponseReceivedEvent( obj,response,status,state );
	
	ev->post();
}

}
