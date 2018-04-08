
#ifndef BB_VARIANT_H
#define BB_VARIANT_H

#include "bbtypeinfo.h"

struct bbVariant{
	
	template<class T> static bbObject *_getObject( T const& ){ bbRuntimeError( "Variant cast failed" );return 0; }
	template<class T,class R=typename T::bb_object_type> static bbObject *_getObject( T *p ){ return dynamic_cast<bbObject*>( p ); }
	
	template<class T> static int _getArrayLength( T const& ){ bbRuntimeError( "Variant is not an array" );return 0; }
	template<class T> static bbVariant _getArrayElement( T const&,int index ){ bbRuntimeError( "Variant is not an array" );return {}; }
	template<class T> static void _setArrayElement( T const&,int index,bbVariant value ){ bbRuntimeError( "Variant is not an array" ); }
	
	template<class T,int D> static int _getArrayLength( bbArray<T,D> v ){ return v.length(); }
	template<class T,int D> static bbVariant _getArrayElement( bbArray<T,D> v,int index );
	template<class T,int D> static void _setArrayElement( bbArray<T,D> v,int index,bbVariant value );
	template<class T,int D> static void _setArrayElement( bbArray<bbGCVar<T>,D> v,int index,bbVariant value );
 
	struct RepBase{
	
		int _refs=1;
	
		virtual ~RepBase(){
		}
		
		virtual void gcMark(){
		}
		
		virtual bbTypeInfo *getType(){
			return 0;
		}
		
		virtual bbObject *getObject(){
			return 0;
		}
		
		virtual int getArrayLength(){ 
			return 0; 
		}
		
		virtual bbVariant getArrayElement( int index ){
			return {}; 
		}
		
		virtual void setArrayElement( int index,bbVariant value ){
		}
		
		virtual bbVariant invoke( bbArray<bbVariant> params ){
			bbRuntimeError( "Variant is not invokable" );
			return {};
		}
		
	};
	
	template<class T> struct Rep : public RepBase{
	
		T value;
		
		Rep( const T &value ):value( value ){
		}
		
		virtual void gcMark(){
			bbGCMark( value );
		}
		
		virtual bbTypeInfo *getType(){
			return bbGetType<T>();
		}
		
		virtual bbObject *getObject(){
			return _getObject( value );
		}
		
		virtual int getArrayLength(){
			return _getArrayLength( value );
		}
		
		virtual bbVariant getArrayElement( int index ){
			return _getArrayElement( value,index );
		}
		
		virtual void setArrayElement( int index,bbVariant evalue ){
			_setArrayElement( value,index,evalue );
		}

	};
	
	static RepBase _null;
	
	RepBase *_rep;
	
	void retain()const{
		++_rep->_refs;
	}
	
	void release(){
		if( !--_rep->_refs && _rep!=&_null ) delete _rep;
	}
	
	// ***** public *****
	
	bbVariant():_rep( &_null ){
	}
	
	bbVariant( const bbVariant &v ):_rep( v._rep ){
		retain();
	}
	
	template<class T> explicit bbVariant( const T &t ):_rep( new Rep<T>( t ) ){
	}
	
	template<class T> explicit bbVariant( const bbGCVar<T> &t ):_rep( new Rep<T*>( t.get() ) ){
	}
	
	~bbVariant(){
		release();
	}
	
	bbVariant &operator=( const bbVariant &v ){
		v.retain();
		release();
		_rep=v._rep;
		return *this;
	}
	
	template<class T,class R=typename T::bb_object_type> T *_get( T* const& )const{
		bbObject *obj=_rep->getObject();
		return dynamic_cast<T*>( obj );
	}
	
	template<class T> T _get( T const& )const{
		bbRuntimeError( "Variant cast failed" );
		return {};
	}
	
	template<class T> T get()const{
		Rep<T> *r=dynamic_cast<Rep<T>*>( _rep );
		if( !r ) return _get( *(T*)0 );
		return r->value;
	}
	
	template<class T,class R=typename T::bb_object_type> T *_ref( T** )const{
		return get<T*>();
	}
	
	template<class T> T *_ref( T* )const{
		Rep<T> *r=dynamic_cast<Rep<T>*>( _rep );
		if( !r ) bbRuntimeError( "Variant cast failed" );
		return &r->value;
	}
	
	template<class T> T *ref()const{
		return _ref<T>( 0 );
	}

	bbTypeInfo *getType()const{
		return _rep->getType();
	}
	
	bbTypeInfo *getDynamicType()const{
		if( bbObject *obj=_rep->getObject() ) return obj->typeof();
		return _rep->getType();
	}
	
	operator bool()const{
		return _rep!=&_null;
	}
	
	int enumValue()const{
		return getType()->getEnum( *this );
	}

	int getArrayLength(){
		return _rep->getArrayLength();
	}
	
	bbVariant getArrayElement( int index ){
		return _rep->getArrayElement( index );
	}
	
	void setArrayElement( int index,bbVariant value ){
		_rep->setArrayElement( index,value );
	}
};

inline void bbGCMark( const bbVariant &v ){
	v._rep->gcMark();
}

inline int bbCompare( const bbVariant &x,const bbVariant &y ){
	return y._rep>x._rep ? -1 : x._rep>y._rep;
}

template<class T,int D> bbVariant bbVariant::_getArrayElement( bbArray<T,D> v,int index ){
	return bbVariant( v[index] );
}

template<class T,int D> void bbVariant::_setArrayElement( bbArray<T,D> v,int index,bbVariant value ){
	v[index]=value.get<T>();
}

template<class T,int D> void bbVariant::_setArrayElement( bbArray<bbGCVar<T>,D> v,int index,bbVariant value ){
	v[index]=value.get<T*>();
}

#endif
