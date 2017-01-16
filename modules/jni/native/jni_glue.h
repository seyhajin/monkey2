
#include <jni.h>

#include <bbmonkey.h>

namespace bbJNI{

	void CallVoidMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args );

}
