
Namespace jni

#If __TARGET__="android"

#Import "native/jni_glue.cpp"
#Import "native/jni_glue.h"

Extern

Struct _jclass
End

Alias jclass:_jclass Ptr

Struct _jobject
End

Alias jobject:_jobject Ptr

Struct _jstring
End

Alias jstring:_jstring Ptr

Struct _jfieldID
End

Alias jfieldID:_jfieldID Ptr

Struct _jmethodID
End

Alias jmethodID:_jmethodID Ptr

Class JNIEnv Extends Void

	Method FindClass:jclass( name:CString )

	'fields...
	'
	Method GetFieldID:jfieldID( clazz:jclass,name:CString,sig:CString )
	
	Method GetObjectField:jobject( obj:jobject,fieldID:jfieldID )
	
	'static fields...
	
	Method GetStaticFieldID:jfieldID( clazz:jclass,name:CString,sig:CString )
	
	Method GetStaticObjectField:jobject( clazz:jclass,fieldID:jfieldID )
	
	'methods...
	'
	Method GetMethodID:jmethodID( clazz:jclass,name:CString,sig:CString )

	Method CallVoidMethod:Void( obj:jobject,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallVoidMethod"
	
	'static methods...
	'
	Method GetStaticMethodID:jmethodID( clazz:jclass,name:CString,sig:CString )
	
	Method CallStaticVoidMethod:Void( clazz:jclass,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallStaticVoidMethod"
	
	
End

#End
