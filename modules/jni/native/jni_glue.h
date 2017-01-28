
#include <jni.h>

#include <bbmonkey.h>

namespace bbJNI{

	void CallVoidMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args );
	
	bbBool CallBooleanMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args );

	void CallStaticVoidMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args );
	
	bbBool CallStaticBooleanMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args );
	
	bbString JStringToString( JNIEnv *env,jstring jstr );
	
	jstring StringToJString( JNIEnv *env,bbString str );

}
