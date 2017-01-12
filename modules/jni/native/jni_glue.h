
#include <jni.h>

namespace bbJNI{

	jclass FindClass( const char *name );
	
	jmethodID GetMethodID( jclass clazz,const char *name,const char *sig );
	
}
