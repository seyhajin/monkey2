
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

	'utils
	'
	Method JStringToString:String( jstr:jstring ) Extension="bbJNI::JStringToString"
	
	Method StringToJString:jstring( str:String ) Extension="bbJNI::StringToJString"
		
	'classes
	'
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
	
	Method CallBooleanMethod:Bool( obj:jobject,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallBooleanMethod"
	
	'static methods...
	'
	Method GetStaticMethodID:jmethodID( clazz:jclass,name:CString,sig:CString )
	
	Method CallStaticVoidMethod:Void( clazz:jclass,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallStaticVoidMethod"
	
	Method CallStaticBooleanMethod:Bool( clazz:jclass,methodID:jmethodID,args:Variant[] ) Extension="bbJNI::CallStaticBooleanMethod"

	'ctors...
	'
	Method AllocObject:jobject( clazz:jclass )
		
	Method NewObject:jobject( clazz:jclass,methodID:jmethodID )
		
	'refs...
	'
	Method NewGlobalRef:jobject( obj:jobject )
		
	Method DeleteGlobalRef( obj:jobject )
		
	Method IsSameObject:Bool( obj1:jobject,obj2:jobject )
		
End

#End
