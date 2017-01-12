
#include "calljava.h"

extern "C"{
	JNIEnv *Android_JNI_GetEnv(void);
}

namespace bbJNI{

	jclass FindClass( const char *name ){
	
		JNIEnv *env=Android_JNI_GetEnv();
		
		return env->FindClass( name );
	}
	
}
