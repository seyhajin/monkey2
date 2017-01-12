
#include "jni_glue.h"

extern "C"{
	JNIEnv *Android_JNI_GetEnv(void);
}

namespace bbJNI{

	jclass FindClass( const char *name ){
	
		JNIEnv *env=Android_JNI_GetEnv();
		
		return env->FindClass( name );
	}

	jmethodID GetMethodID( jclass clazz,const char *name,const char *sig ){
	
		JNIEnv *env=Android_JNI_GetEnv();
		
		return env->GetMethodID( clazz,name,sig );
	}
}
