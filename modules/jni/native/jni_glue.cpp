
#include "jni_glue.h"

namespace bbJNI{

	jvalue *makeArgs( JNIEnv *env,bbArray<bbVariant> args ){
	
		jvalue *jargs=new jvalue[args.length()];
		
		memset( jargs,0,sizeof( jvalue ) * args.length() );
		
		jvalue *jarg=jargs;
		
		for( int i=0;i<args.length();++i ){
		
			bbVariant arg=args[i];
			
			bbTypeInfo *type=arg.getType();
			
			if( type==bbGetType<bbBool>() ){
			
				bbBool val=arg.get<bbBool>();
				
				jarg->z=val;
				
			}else if( type==bbGetType<bbInt>() ){
			
				bbInt val=arg.get<bbInt>();
				
				jarg->i=val;
			
			}else if( type==bbGetType<jobject>() ){
			
				jobject jobj=arg.get<jobject>();
			
				jarg->l=jobj;
			
			}else if( type==bbGetType<bbString>() ){
			
				bbString str=arg.get<bbString>();
				
				int n=str.utf8Length()+1;
				
				char *buf=new char[n];
				
				str.toCString( buf,n );
				
				jstring jstr=env->NewStringUTF( buf );
				
				jarg->l=jstr;
/*				
			}else if( type==bbGetType<bbArray<bbBool>>() ){
			
				bbArray<bbBool> arr=arg.get<bbArray<bbBool>>();
				
				jbooleanArray jarr=env->NewBooleanArray( arr.length() );
				
				jboolean *jdata=env->GetBooleanArrayElements( jarr,0 );
				
				memcpy( jdata,arr.data(),arr.length()*sizeof(bbBool) );
				
				env->ReleaseBooleanArrayElements( jarr,jdata,0 );
				
				jarg->l=(jobject)jarr;
				
			}else if( type==bbGetType<bbArray<bbInt>>() ){

				bbArray<bbInt> arr=arg.get<bbArray<bbInt>>();
				
				jintArray jarr=env->NewIntArray( arr.length() );
				
				jint *jdata=env->GetIntArrayElements( jarr,0 );
				
				memcpy( jdata,arr.data(),arr.length()*sizeof(bbInt) );
				
				env->ReleaseIntArrayElements( jarr,jdata,0 );
				
				jarg->l=(jobject)jarr;
			
			}else if( type==bbGetType<bbArray<jobject>>() ){
			
			}else if( type==bbGetType<bbArray<bbString>>() ){
*/			
			}else{
			
				bbRuntimeError( "Can't evaluate JNI method param of typ:"+type->toString() );
			}
			
			++jarg;
		}
		
		return jargs;
	}
	
	bbString JStringToString( JNIEnv *env,jstring jstr ){
	
		if( !jstr ) return "";
	
		const char *cstr=env->GetStringUTFChars( jstr,0 );
		
		bbString str=bbString::fromCString( cstr );
		
		env->ReleaseStringUTFChars( jstr,cstr );
		
		return str;
	}
	
	jstring StringToJString( JNIEnv *env,bbString str ){
	
		int n=str.utf8Length()+1;
		
		char *buf=new char[n];
		
		str.toCString( buf,n );
		
		jstring jstr=env->NewStringUTF( buf );
		
		return jstr;
	}
	
	bbString GetStringField( JNIEnv *env,jobject obj,jfieldID fieldID ){
	
		jstring jstr=(jstring)env->GetObjectField( obj,fieldID );
		
		return JStringToString( env,jstr );
	}

	void CallVoidMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		env->CallVoidMethodA( obj,methodID,jargs );
		
		delete[] jargs;
	}

	bbBool CallBooleanMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbBool r=env->CallBooleanMethodA( obj,methodID,jargs );
		
		delete[] jargs;
		
		return r;
	}

	bbInt CallIntMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbInt r=env->CallIntMethodA( obj,methodID,jargs );
		
		delete[] jargs;
		
		return r;
	}

	bbString CallStringMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbString r=JStringToString( env,(jstring)env->CallObjectMethodA( obj,methodID,jargs ) );
		
		delete[] jargs;
		
		return r;
	}

	jobject CallObjectMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		jobject r=env->CallObjectMethodA( obj,methodID,jargs );
		
		delete[] jargs;
		
		return r;
	}

	void CallStaticVoidMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		env->CallStaticVoidMethodA( clazz,methodID,jargs );
		
		delete[] jargs;
	}

	bbBool CallStaticBooleanMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbBool r=env->CallStaticBooleanMethodA( clazz,methodID,jargs );
		
		delete[] jargs;
		
		return r;
	}
	
	bbInt CallStaticIntMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbInt r=env->CallStaticIntMethodA( clazz,methodID,jargs );
		
		delete[] jargs;
		
		return r;
	}
	
	bbString CallStaticStringMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbString r=JStringToString( env,(jstring)env->CallStaticObjectMethodA( clazz,methodID,jargs ) );
		
		delete[] jargs;
		
		return r;
	}
	
	jobject CallStaticObjectMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		jobject r=env->CallStaticObjectMethodA( clazz,methodID,jargs );
		
		delete[] jargs;
		
		return r;
	}
	
	jobject NewObject( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){

		jvalue *jargs=makeArgs( env,args );
		
		jobject r=env->NewObjectA( clazz,methodID,jargs );
		
		delete[] jargs;
		
		return r;
	}
	
}
