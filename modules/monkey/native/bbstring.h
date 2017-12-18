
#ifndef BB_STRING_H
#define BB_STRING_H

#include "bbtypes.h"
#include "bbassert.h"

namespace bbGC{
	void *malloc( size_t size );
	void free( void *p );
}

class bbCString;

class bbString{

	struct Rep{
		int refs;
		int length;
		bbChar data[0];
		
		static Rep *alloc( int length );
		
		template<class C> static Rep *create( const C *p,int length ){
			Rep *rep=alloc( length );
			for( int i=0;i<length;++i ) rep->data[i]=p[i];
			return rep;
		}
		
		template<class C> static Rep *create( const C *p ){
			const C *e=p;
			while( *e ) ++e;
			return create( p,e-p );
		}

	};
	
	Rep *_rep;

	static Rep _nullRep;
	
	void retain()const{
		++_rep->refs;
	}
	
	void release(){
		if( !--_rep->refs && _rep!=&_nullRep ) bbGC::free( _rep );
	}
	
	bbString( Rep *rep ):_rep( rep ){
	}
	
	public:
	
	const char *c_str()const;
	
	bbString():_rep( &_nullRep ){
	}
	
	bbString( const bbString &s ):_rep( s._rep ){
		retain();
	}
	
	bbString( const void *data );
	
	bbString( const void *data,int length );
	
	bbString( const bbChar *data );
	
	bbString( const bbChar *data,int length );

	bbString( const wchar_t *data );
	
	bbString( const wchar_t *data,int length );
	
#if __OBJC__
	bbString( const NSString *str );
#endif

	explicit bbString( bool b );

	explicit bbString( int n );
	
	explicit bbString( unsigned int n );
	
	explicit bbString( long n );
	
	explicit bbString( unsigned long n );

	explicit bbString( long long n );
	
	explicit bbString( unsigned long long n );
	
	explicit bbString( float n );
	
	explicit bbString( double n );
	
	~bbString(){
		release();
	}
	
	const bbChar *data()const{
		return _rep->data;
	}
	
	int length()const{
		return _rep->length;
	}
	
	bbChar operator[]( int index )const{
		bbDebugAssert( index>=0 && index<length(),"String character index out of range" );
		return data()[index];
	}
	
	bbString operator+()const{
		return *this;
	}
	
	bbString operator-()const;
	
	bbString operator+( const bbString &str )const;
	
	bbString operator+( const char *str )const{
		return operator+( bbString( str ) );
	}
	
	bbString operator*( int n )const;
	
	bbString &operator=( const bbString &str ){
		str.retain();
		release();
		_rep=str._rep;
		return *this;
	}
	
	template<class C> bbString &operator=( const C *data ){
		release();
		_rep=Rep::create( data );
		return *this;
	}
	
	bbString &operator+=( const bbString &str ){
		*this=*this+str;
		return *this;
	}
	
	bbString &operator+=( const char *str ){
		return operator+=( bbString( str ) );
	}
	
	int find( bbString str,int from=0 )const;
	
	int findLast( const bbString &str,int from=0 )const;
	
	bool contains( const bbString &str )const{
		return find( str )!=-1;
	}
	
	bbString slice( int from )const;
	
	bbString slice( int from,int term )const;

	bbString left( int count )const{
		return slice( 0,count );
	}
	
	bbString right( int count )const{
		return slice( -count );
	}
	
	bbString mid( int from,int count )const{
		return slice( from,from+count );
	}
	
	bool startsWith( const bbString &str )const;
	
	bool endsWith( const bbString &str )const;
	
	bbString toUpper()const;
	
	bbString toLower()const;
	
	bbString capitalize()const;
	
	bbString trim()const;
	
	bbString trimStart()const;
	
	bbString trimEnd()const;
	
	bbString dup( int n )const;
	
	bbString replace( const bbString &str,const bbString &repl )const;
	
	bbArray<bbString> split( bbString sep )const;
	
	bbString join( bbArray<bbString> bits )const;
	
	int compare( const bbString &t )const;
	
	bool operator<( const bbString &t )const{
		return compare( t )<0;
	}
	
	bool operator>( const bbString &t )const{
		return compare( t )>0;
	}
	
	bool operator<=( const bbString &t )const{
		return compare( t )<=0;
	}
	
	bool operator>=( const bbString &t )const{
		return compare( t )>=0;
	}
	
	bool operator==( const bbString &t )const{
		return compare( t )==0;
	}
	
	bool operator!=( const bbString &t )const{
		return compare( t )!=0;
	}
	
	operator bbBool()const{
		return length()!=0;
	}
	
	operator bbInt()const;
	
	operator bbByte()const;
	
	operator bbUByte()const;
	
	operator bbShort()const;
	
	operator bbUShort()const;
	
	operator bbUInt()const;
	
	operator bbLong()const;
	
	operator bbULong()const;
	
	operator float()const;
	
	operator double()const;
	
	int utf8Length()const;
	
	void toCString( void *buf,int size )const;

	void toWString( void *buf,int size )const;
	
#if __OBJC__	
	NSString *ToNSString()const;
#endif
	
	static bbString fromChar( int chr );
	
	static bbString fromChars( bbArray<int> chrs );
	
	static bbString fromCString( const void *data ){ return bbString( data ); }
	
	static bbString fromCString( const void *data,int size ){ return bbString( data,size ); }
	
	static bbString fromWString( const void *data ){ return bbString( (const wchar_t*)data ); }
	
	static bbString fromWString( const void *data,int size ){ return bbString( (const wchar_t*)data,size ); }
};

class bbCString{
	
	char *_data;
	
	public:

	bbCString( const bbString &str );
	
	~bbCString();
	
	operator char*()const;
	
	operator signed char*()const;
	
	operator unsigned char*()const;
};

class bbWString{
	wchar_t *_data;
	
	public:
	
	bbWString( const bbString &str );
	
	~bbWString();
	
	operator wchar_t*()const;
};

template<class C> bbString operator+( const C *str,const bbString &str2 ){
	return bbString::fromCString( str )+str2;
}

inline bbString BB_T( const char *p ){
	return bbString::fromCString( p );
}

#endif

