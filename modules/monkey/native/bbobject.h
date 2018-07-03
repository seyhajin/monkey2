
#ifndef BB_OBJECT_H
#define BB_OBJECT_H

#ifdef BB_THREADS
#include "bbgc_mx.h"
#else
#include "bbgc.h"
#endif

//#include "bbstring.h"
#include "bbdebug.h"

struct bbObject : public bbGCNode{

	typedef bbObject *bb_object_type;

	bbObject(){
	
		bbGC::beginCtor( this );
	}
	
	virtual ~bbObject();

	//implemented in bbtypeinfo.h
	//	
	virtual bbTypeInfo *typeof()const;
	
	virtual const char *typeName()const;
	
	void *operator new( size_t size ){
	
		return bbGC::malloc( size );
	}
	
	//NOTE! We need this in case ctor throws an exception. delete never otherwise called...
	//
	void operator delete( void *p ){
	
		bbGC::endCtor( (bbObject*)(p) );
	}
};

struct bbThrowable : public bbObject{
};

struct bbInterface{

	typedef bbInterface *bb_object_type;

	virtual ~bbInterface();
};

struct bbNullCtor_t{
};

extern bbNullCtor_t bbNullCtor;

template<class T,class...A> T *bbGCNew( A...a ){
	T *p=new T( a... );
	bbGC::endCtor( p );
	return p;
}

template<class T,class R=typename T::bb_object_type> void bbGCMark( T *p ){
	bbGC::enqueue( dynamic_cast<bbObject*>( p ) );
}

template<class T,class C> T bb_object_cast( C *p ){
	return dynamic_cast<T>( p );
}

inline void bbDBAssertSelf( void *p ){
	bbDebugAssert( p,"Attempt to invoke method on null instance" );
}

inline bbString bbDBObjectValue( bbObject *p ){
	char buf[64];
	sprintf( buf,"@%p",p );
	return buf;
}

inline bbString bbDBInterfaceValue( bbInterface *p ){
	return bbDBObjectValue( dynamic_cast<bbObject*>( p ) );
}

template<class T> bbString bbDBStructValue( T *p ){
	char buf[64];
	sprintf( buf,"@%p:%p",p,&T::dbEmit );
	return buf;
}

inline bbString bbDBType( bbObject **p ){
	return "Object";
}

inline bbString bbDBValue( bbObject **p ){
	return bbDBObjectValue( *p );
}

template<class T> struct bbGCVar{

	public:
	
	T *_ptr;
	
	void enqueue(){
		bbGC::enqueue( dynamic_cast<bbGCNode*>( _ptr ) );
	}
	
	bbGCVar():_ptr( nullptr ){
	}
	
	bbGCVar( T *p ):_ptr( p ){
		enqueue();
	}
	
	bbGCVar( const bbGCVar &p ):_ptr( p._ptr ){
		enqueue();
	}
	
	bbGCVar &operator=( T *p ){
		_ptr=p;
		enqueue();
		return *this;
	}
	
	bbGCVar &operator=( const bbGCVar &p ){
		_ptr=p._ptr;
		enqueue();
		return *this;
	}
	void discard(){
		_ptr=nullptr;
	}
	
	T *get()const{
		return _ptr;
	}
	
	T *operator->()const{
		return _ptr;
	}
	
	operator T*()const{
		return _ptr;
	}
	
	T **operator&(){
		return &_ptr;
	}
};

template<class T,class C> T bb_object_cast( const bbGCVar<C> &v ){
	return dynamic_cast<T>( v._ptr );
}

template<class T> void bbGCMark( const bbGCVar<T> &v ){
	bbGCMark( v._ptr );
}

#endif
