
#include "bbstring.h"
#include "bbarray.h"
#include "bbplatform.h"
#include "bbmonkey.h"

#include <cwctype>
#include <clocale>

bbString::Rep bbString::_nullRep;

#if BB_ANDROID

#include <jni.h>

//FIXME: SDL2 dependancy!
extern "C" void *SDL_AndroidGetJNIEnv();

#endif

namespace{

#if BB_ANDROID
	jclass jclass_lang;
	
	jmethodID jmethod_toUpper;
	jmethodID jmethod_toLower;
	jmethodID jmethod_capitalize;

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
#endif
	
	void initLocale(){
	
		static bool inited;
		if( inited ) return;
		inited=true;
		
#if BB_ANDROID
		JNIEnv *env=(JNIEnv*)SDL_AndroidGetJNIEnv();
		jclass_lang=env->FindClass( "com/monkey2/lib/Monkey2Lang" );
		jmethod_toUpper=env->GetStaticMethodID( jclass_lang,"toUpper","(Ljava/lang/String;)Ljava/lang/String;" );
		jmethod_toLower=env->GetStaticMethodID( jclass_lang,"toLower","(Ljava/lang/String;)Ljava/lang/String;" );
		jmethod_capitalize=env->GetStaticMethodID( jclass_lang,"capitalize","(Ljava/lang/String;)Ljava/lang/String;" );
		bb_printf( "initLocale: env=%p\n",env );
#elif BB_WINDOWS
		std::setlocale( LC_ALL,"English" );
//		std::setlocale( LC_CTYPE,"English" );
#else
		std::setlocale( LC_CTYPE,"en_US.UTF-8" );
#endif
	}
	
	template<class C> int t_memcmp( const C *p1,const C *p2,int count ){
		return memcmp( p1,p2,count*sizeof(C) );
	}

	//returns END of dst!	
	template<class C> C *t_memcpy( C *dst,const C *src,int count ){
		return (C*)memcpy( dst,src,count*sizeof(C) )+count;
	}

	int countUtf8Chars( const char *p,int sz ){
	
		const char *e=p+sz;
	
		int n=0;
	
		while( p!=e ){
			int c=*p++;
			
			if( c & 0x80 ){
				if( (c & 0xe0)==0xc0 ){
					if( p==e || (p[0] & 0xc0)!=0x80 ) return -1;
					p+=1;
				}else if( (c & 0xf0)==0xe0 ){
					if( p==e || p+1==e || (p[0] & 0xc0)!=0x80 || (p[1] & 0xc0)!=0x80 ) return -1;
					p+=2;
				}else{
					return -1;
				}
			}
			n+=1;
		}
		return n;
	}
	
	int countNullTerminatedUtf8Chars( const char *p,int sz ){
	
		const char *e=p+sz;
	
		int n=0;
	
		while( p!=e && *p ){
			int c=*p++;
			
			if( c & 0x80 ){
				if( (c & 0xe0)==0xc0 ){
					if( p==e || (p[0] & 0xc0)!=0x80 ) return -1;
					p+=1;
				}else if( (c & 0xf0)==0xe0 ){
					if( p==e || p+1==e || (p[0] & 0xc0)!=0x80 || (p[1] & 0xc0)!=0x80 ) return -1;
					p+=2;
				}else{
					return -1;
				}
			}
			n+=1;
		}
		return n;
	}
	
	void charsToUtf8( const bbChar *p,int n,char *dst,int size ){
	
		char *end=dst+size;
		
		const bbChar *e=p+n;
		
		while( p<e && dst<end ){
			bbChar c=*p++;
			if( c<0x80 ){
				*dst++=c;
			}else if( c<0x800 ){
				if( dst+2>end ) break;
				*dst++=0xc0 | (c>>6);
				*dst++=0x80 | (c & 0x3f);
			}else{
				if( dst+3>end ) break;
				*dst++=0xe0 | (c>>12);
				*dst++=0x80 | ((c>>6) & 0x3f);
				*dst++=0x80 | (c & 0x3f);
			}
		}
		if( dst<end ) *dst++=0;
	}
	
	void utf8ToChars( const char *p,bbChar *dst,int n ){
	
		while( n-- ){
			int c=*p++;
			
			if( c & 0x80 ){
				if( (c & 0xe0)==0xc0 ){
					c=((c & 0x1f)<<6) | (p[0] & 0x3f);
					p+=1;
				}else if( (c & 0xf0)==0xe0 ){
					c=((c & 0x0f)<<12) | ((p[0] & 0x3f)<<6) | (p[1] & 0x3f);
					p+=2;
				}
			}
			*dst++=c;
		}

	}
	
}

// ***** bbString::Rep *****

bbString::Rep *bbString::Rep::alloc( int length ){
	if( !length ) return &_nullRep;
	Rep *rep=(Rep*)bbGC::malloc( sizeof(Rep)+length*sizeof(bbChar) );
	rep->refs=1;
	rep->length=length;
	return rep;
}

// ***** bbString *****

bbString::bbString( const void *p ){

	const char *cp=(const char*)p;

	if( !cp ){
		_rep=&_nullRep;
		return;
	}

	int sz=strlen( cp );

	int n=countNullTerminatedUtf8Chars( cp,sz );

	if( n==-1 || n==sz ){
		_rep=Rep::create( cp,sz );
		return;
	}
	_rep=Rep::alloc( n );
	utf8ToChars( cp,_rep->data,n );
}

bbString::bbString( const void *p,int sz ){

	const char *cp=(const char*)p;

	if( !cp ){
		_rep=&_nullRep;
		return;
	}

	int n=countUtf8Chars( cp,sz );

	if( n==-1 || n==sz ){
		_rep=Rep::create( cp,sz );
		return;
	}
	_rep=Rep::alloc( n );
	utf8ToChars( cp,_rep->data,n );
}

bbString::bbString( const bbChar *data ):_rep( Rep::create( data ) ){
}

bbString::bbString( const bbChar *data,int length ):_rep( Rep::create( data,length ) ){
}

bbString::bbString( const wchar_t *data ):_rep( Rep::create( data ) ){
}

bbString::bbString( const wchar_t *data,int length ):_rep( Rep::create( data,length ) ){
}

int bbString::utf8Length()const{

	const bbChar *p=data();
	const bbChar *e=p+length();
	
	int n=0;
	
	while( p<e ){
		bbChar c=*p++;
		if( c<0x80 ){
			n+=1;
		}else if( c<0x800 ){
			n+=2;
		}else{
			n+=3;
		}
	}

	return n;
}

bbString::bbString( bool b ){

	_rep=Rep::create( b ? "True" : "False" );
}

bbString::bbString( int n ){

	char data[64];
	sprintf( data,"%d",n );
	_rep=Rep::create( data );
}

bbString::bbString( unsigned int n ){

	char data[64];
	sprintf( data,"%u",n );
	_rep=Rep::create( data );
}

bbString::bbString( long n ){

	char data[64];
	sprintf( data,"%ld",n );
	_rep=Rep::create( data );
}

bbString::bbString( unsigned long n ){

	char data[64];
	sprintf( data,"%lu",n );
	_rep=Rep::create( data );
}

bbString::bbString( long long n ){

	char data[64];
	sprintf( data,"%lld",n );
	_rep=Rep::create( data );
}

bbString::bbString( unsigned long long n ){

	char data[64];
	sprintf( data,"%llu",n );
	_rep=Rep::create( data );
}

bbString::bbString( float n ){

	char data[64];
	sprintf( data,"%.9g",n );
	_rep=Rep::create( data );
}

bbString::bbString( double n ){

	char data[64];
	sprintf( data,"%.17g",n );
	_rep=Rep::create( data );
}

void bbString::toCString( void *buf,int size )const{

	charsToUtf8( _rep->data,_rep->length,(char*)buf,size );
}

void bbString::toWString( void *buf,int size )const{

	size=size/sizeof(wchar_t);
	if( size<=0 ) return;
	
	int sz=length();
	if( sz>size ) sz=size;
	
	for( int i=0;i<sz;++i ) ((wchar_t*)buf)[i]=data()[i];
	
	if( sz<size ) ((wchar_t*)buf)[sz]=0;
}

const char *bbString::c_str()const{

	static int _sz;
	static char *_tmp;
	
	int sz=utf8Length()+1;
	if( sz>_sz ){
		::free( _tmp );
		_tmp=(char*)::malloc( _sz=sz );
	}
	toCString( _tmp,sz );
	return _tmp;
}

bool bbString::startsWith( const bbString &str )const{
	if( str.length()>length() ) return false;
	return t_memcmp( data(),str.data(),str.length() )==0;
}

bool bbString::endsWith( const bbString &str )const{
	if( str.length()>length() ) return false;
	return t_memcmp( data()+(length()-str.length()),str.data(),str.length() )==0;
}
	
bbString bbString::fromChar( int chr ){
	wchar_t chrs[]={ wchar_t(chr) };
	return bbString( chrs,1 );
}

bbArray<bbString> bbString::split( bbString sep )const{

	if( !sep.length() ){
		
		bbArray<bbString> bits=bbArray<bbString>( length() );
		
		bits.retain();
		
		for( int i=0;i<length();++i ){
			bits[i]=bbString( &data()[i],1 );
		}
		
		bits.release();
		
		return bits;
	}
	
	int i=0,i2,n=1;
	while( (i2=find( sep,i ))!=-1 ){
		++n;
		i=i2+sep.length();
	}
	
	bbArray<bbString> bits=bbArray<bbString>( n );
	
	bits.retain();
	
	if( n==1 ){
		bits[0]=*this;
	}else{
		i=0;n=0;
		while( (i2=find( sep,i ))!=-1 ){
			bits[n++]=slice( i,i2 );
			i=i2+sep.length();
		}
		bits[n]=slice( i );
	}
	
	bits.release();
	
	return bits;
}

bbString bbString::join( bbArray<bbString> bits )const{

	if( bits.length()==0 ) return bbString();
	if( bits.length()==1 ) return bits[0];
	
	int len=length() * (bits.length()-1);
	for( int i=0;i<bits.length();++i ) len+=bits[i].length();
	
	Rep *rep=Rep::alloc( len );
	bbChar *p=rep->data;

	p=t_memcpy( p,bits[0].data(),bits[0].length() );
	
	for( int i=1;i<bits.length();++i ){
		p=t_memcpy( p,data(),length() );
		p=t_memcpy( p,bits[i].data(),bits[i].length() );
	}
	
	return rep;
}

bbString bbString::fromChars( bbArray<int> chrs ){ 
	return Rep::create( chrs.data(),chrs.length() ); 
}

bbString bbString::operator-()const{
	Rep *rep=Rep::alloc( length() );
	const bbChar *p=data()+length();
	for( int i=0;i<rep->length;++i ) rep->data[i]=*--p;
	return rep;
}

bbString bbString::operator+( const bbString &str )const{

	if( !length() ) return str;
	if( !str.length() ) return *this;
	
	Rep *rep=Rep::alloc( length()+str.length() );
	t_memcpy( rep->data,data(),length() );
	t_memcpy( rep->data+length(),str.data(),str.length() );

	return rep;
}

bbString bbString::operator*( int n )const{
	Rep *rep=Rep::alloc( length()*n );
	bbChar *p=rep->data;
	for( int j=0;j<n;++j ){
		for( int i=0;i<_rep->length;++i ) *p++=data()[i];
	}
	return rep;
}

int bbString::find( bbString str,int from )const{
	if( from<0 ) from=0;
	for( int i=from;i<=length()-str.length();++i ){
		if( !t_memcmp( data()+i,str.data(),str.length() ) ) return i;
	}
	return -1;
}

int bbString::findLast( const bbString &str,int from )const{
	if( from<0 ) from=0;
	for( int i=length()-str.length();i>=from;--i ){
		if( !t_memcmp( data()+i,str.data(),str.length() ) ) return i;
	}
	return -1;
}

bbString bbString::slice( int from )const{
	int length=this->length();
	if( from<0 ){
		from+=length;
		if( from<0 ) from=0;
	}else if( from>length ){
		from=length;
	}
	if( !from ) return *this;
	return bbString( data()+from,length-from );
}

bbString bbString::slice( int from,int term )const{
	int length=this->length();
	if( from<0 ){
		from+=length;
		if( from<0 ) from=0;
	}else if( from>length ){
		from=length;
	}
	if( term<0 ){
		term+=length;
		if( term<from ) term=from;
	}else if( term<from ){
		term=from;
	}else if( term>length ){
		term=length;
	}
	if( !from && term==length ) return *this;
	return bbString( data()+from,term-from );
}

bbString bbString::toUpper()const{
	initLocale();
#if BB_ANDROID
	JNIEnv *env=(JNIEnv*)SDL_AndroidGetJNIEnv();
	return JStringToString( env,(jstring)env->CallStaticObjectMethod( jclass_lang,jmethod_toUpper,StringToJString( env,*this ) ) );
#else
	Rep *rep=Rep::alloc( length() );
	for( int i=0;i<length();++i ) rep->data[i]=::towupper( data()[i] );
	return rep;
#endif
}

bbString bbString::toLower()const{
	initLocale();
#if BB_ANDROID
	JNIEnv *env=(JNIEnv*)SDL_AndroidGetJNIEnv();
	return JStringToString( env,(jstring)env->CallStaticObjectMethod( jclass_lang,jmethod_toLower,StringToJString( env,*this ) ) );
#else
	Rep *rep=Rep::alloc( length() );
	for( int i=0;i<length();++i ) rep->data[i]=::towlower( data()[i] );
	return rep;
#endif
}

bbString bbString::capitalize()const{
	initLocale();
#if BB_ANDROID
	JNIEnv *env=(JNIEnv*)SDL_AndroidGetJNIEnv();
	return JStringToString( env,(jstring)env->CallStaticObjectMethod( jclass_lang,jmethod_capitalize,StringToJString( env,*this ) ) );
#else
	if( !length() ) return &_nullRep;
	Rep *rep=Rep::alloc( length() );
	rep->data[0]=::towupper( data()[0] );
	for( int i=1;i<length();++i ) rep->data[i]=data()[i];
	return rep;
#endif
}

bbString bbString::trim()const{
	const bbChar *beg=data();
	const bbChar *end=data()+length();
	while( beg!=end && *beg<=32 ) ++beg;
	while( beg!=end && *(end-1)<=32 ) --end;
	if( end-beg==length() ) return *this;
	return bbString( beg,end-beg );
}

bbString bbString::trimStart()const{
	const bbChar *beg=data();
	const bbChar *end=data()+length();
	while( beg!=end && *beg<=32 ) ++beg;
	if( end-beg==length() ) return *this;
	return bbString( beg,end-beg );
}

bbString bbString::trimEnd()const{
	const bbChar *beg=data();
	const bbChar *end=data()+length();
	while( beg!=end && *(end-1)<=32 ) --end;
	if( end-beg==length() ) return *this;
	return bbString( beg,end-beg );
}

bbString bbString::dup( int n )const{
	Rep *rep=Rep::alloc( length()*n );
	bbChar *p=rep->data;
	for( int j=0;j<n;++j ){
		for( int i=0;i<_rep->length;++i ) *p++=data()[i];
	}
	return rep;
}

bbString bbString::replace( const bbString &str,const bbString &repl )const{

	int n=0;
	for( int i=0;; ){
		i=find( str,i );
		if( i==-1 ) break;
		i+=str.length();
		++n;
	}
	if( !n ) return *this;
	
	Rep *rep=Rep::alloc( length()+n*(repl.length()-str.length()) );
	
	bbChar *dst=rep->data;
	
	for( int i=0;; ){
	
		int i2=find( str,i );
		if( i2==-1 ){
			t_memcpy( dst,data()+i,(length()-i) );
			break;
		}
		
		t_memcpy( dst,data()+i,(i2-i) );
		dst+=(i2-i);
		
		t_memcpy( dst,repl.data(),repl.length() );
		dst+=repl.length();
		
		i=i2+str.length();
	}
	return rep;
}

int bbString::compare( const bbString &t )const{
	int len=length()<t.length() ? length() : t.length();
	for( int i=0;i<len;++i ){
		if( int n=data()[i]-t.data()[i] ) return n;
	}
	return length()-t.length();
}

bbString::operator bbInt()const{
	return std::atoi( c_str() );
}

bbString::operator bbByte()const{
	return operator bbInt() & 0xff;
}

bbString::operator bbUByte()const{
	return operator bbInt() & 0xffu;
}

bbString::operator bbShort()const{
	return operator bbInt() & 0xffff;
}

bbString::operator bbUShort()const{
	return operator bbInt() & 0xffffu;
}

bbString::operator bbUInt()const{
	bbUInt n=0;
	sscanf( c_str(),"%u",&n );
	return n;
}

bbString::operator bbLong()const{
	bbLong n=0;
	sscanf( c_str(),"%lld",&n );
	return n;
}

bbString::operator bbULong()const{
	bbULong n=0;
	sscanf( c_str(),"%llu",&n );
	return n;
}

bbString::operator float()const{
	return std::atof( c_str() );
}

bbString::operator double()const{
	return std::atof( c_str() );
}

// ***** CString *****

bbCString::bbCString( const bbString &str ){
	int size=str.utf8Length()+1;
	_data=(char*)bbGC::malloc( size );
	str.toCString( _data,size );
}

bbCString::~bbCString(){
	bbGC::free( _data );
}

bbCString::operator char*()const{
	return _data;
}

bbCString::operator signed char*()const{
	return (signed char*)_data;
}

bbCString::operator unsigned char*()const{
	return (unsigned char*)_data;
}

// ***** WString *****

bbWString::bbWString( const bbString &str ){
	int size=(str.length()+1)*sizeof(wchar_t);
	_data=(wchar_t*)bbGC::malloc( size );
	str.toWString( _data,size );
}

bbWString::~bbWString(){
	bbGC::free( _data );
}

bbWString::operator wchar_t*()const{
	return _data;
}
