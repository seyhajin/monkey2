
#include "jni_glue.h"

namespace bbJNI{

	//64 params max
	const int MAX_LOCAL_REFS=64;

	jobject local_refs[MAX_LOCAL_REFS];
	
	int num_local_refs=0;
	
	void AddLocalRef( jobject jobj ){
	
		if( num_local_refs==MAX_LOCAL_REFS ) return;
	
		local_refs[num_local_refs++]=jobj;
	}
	
	void DeleteLocalRefs( JNIEnv *env ){
	
		while( num_local_refs ){
			
			jobject jobj=local_refs[--num_local_refs];
			
			env->DeleteLocalRef( jobj );
		}
	}
	
	// ***** Utility *****

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
			
			}else if( type==bbGetType<bbFloat>() ){
			
				bbFloat val=arg.get<bbFloat>();
				
				jarg->f=val;
			
			}else if( type==bbGetType<bbDouble>() ){
			
				bbDouble val=arg.get<bbDouble>();
				
				jarg->d=val;
			
			}else if( type==bbGetType<bbString>() ){
			
				bbString str=arg.get<bbString>();
				
				jstring jstr=StringToJString( env,str );
				
				AddLocalRef( (jobject)jstr );
				
				jarg->l=jstr;

			}else if( type==bbGetType<jobject>() ){
			
				jobject jobj=arg.get<jobject>();
			
				jarg->l=jobj;
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
	
	// ***** Instance fields *****
	
	bbString GetStringField( JNIEnv *env,jobject obj,jfieldID fieldID ){
	
		jstring jstr=(jstring)env->GetObjectField( obj,fieldID );
		
		bbString r=JStringToString( env,jstr );
		
		env->DeleteLocalRef( jstr );
		
		return r;
	}
	
	// ***** Static fields *****

	bbString GetStaticStringField( JNIEnv *env,jclass clazz,jfieldID fieldID ){
	
		jstring jstr=(jstring)env->GetStaticObjectField( clazz,fieldID );
		
		bbString r=JStringToString( env,jstr );
		
		env->DeleteLocalRef( jstr );
		
		return r;
	}
	
	// ***** Instance methods *****

	void CallVoidMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		env->CallVoidMethodA( obj,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
	}

	bbBool CallBooleanMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbBool r=env->CallBooleanMethodA( obj,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}

	bbInt CallIntMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbInt r=env->CallIntMethodA( obj,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}

	bbFloat CallFloatMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbFloat r=env->CallFloatMethodA( obj,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}

	bbDouble CallDoubleMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbDouble r=env->CallDoubleMethodA( obj,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}

	bbString CallStringMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		jstring jstr=(jstring)env->CallObjectMethodA( obj,methodID,jargs );
		
		bbString r=JStringToString( env,jstr );
		
		env->DeleteLocalRef( jstr );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}

	jobject CallObjectMethod( JNIEnv *env,jobject obj,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		jobject r=env->CallObjectMethodA( obj,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}
	
	// ***** Static methods *****

	void CallStaticVoidMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		env->CallStaticVoidMethodA( clazz,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
	}

	bbBool CallStaticBooleanMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbBool r=env->CallStaticBooleanMethodA( clazz,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}
	
	bbInt CallStaticIntMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbInt r=env->CallStaticIntMethodA( clazz,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}

	bbFloat CallStaticFloatMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbFloat r=env->CallStaticFloatMethodA( clazz,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}
	
	bbDouble CallStaticDoubleMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		bbDouble r=env->CallStaticDoubleMethodA( clazz,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}
	
	bbString CallStaticStringMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );

		jstring jstr=(jstring)env->CallStaticObjectMethodA( clazz,methodID,jargs );
		
		bbString r=JStringToString( env,jstr );
		
		env->DeleteLocalRef( jstr );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}
	
	jobject CallStaticObjectMethod( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){
		
		jvalue *jargs=makeArgs( env,args );
		
		jobject r=env->CallStaticObjectMethodA( clazz,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}
	
	// ***** ctors *****
	
	jobject NewObject( JNIEnv *env,jclass clazz,jmethodID methodID,bbArray<bbVariant> args ){

		jvalue *jargs=makeArgs( env,args );
		
		jobject r=env->NewObjectA( clazz,methodID,jargs );
		
		DeleteLocalRefs( env );
		
		delete[] jargs;
		
		return r;
	}
	
}
