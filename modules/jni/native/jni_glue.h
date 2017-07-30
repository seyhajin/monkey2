
#include <jni.h>

#include <bbmonkey.h>

namespace bbJNI{

	bbString JStringToString( JNIEnv *env,jstring jstr );
	
	jstring StringToJString( JNIEnv *env,bbString str );
	
	
	bbString GetStringField( JNIEnv *env,jobject obj,jfieldID fieldID );


	void CallVoidMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args );
	
	bbBool CallBooleanMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args );

	bbInt CallIntMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args );

	bbString CallStringMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args );

	jobject CallObjectMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args );


	void CallStaticVoidMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args );
	
	bbBool CallStaticBooleanMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args );

	bbInt CallStaticIntMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args );

	bbString CallStaticStringMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args );

	jobject CallStaticObjectMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args );
	

	jobject NewObject( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args );
	

}
