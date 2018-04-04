
#ifndef BB_TYPEINFO_T_H
#define BB_TYPEINFO_T_H

#include "bbtypeinfo.h"

template<class T> struct bbBaseTypeInfo : public bbTypeInfo{

	bbVariant nullValue(){
		return bbVariant( T{} );
	}

	bbVariant newArray( int length ){
		return bbVariant( bbArray<T>( length ) );
	}
};

template<class T> struct bbPrimTypeInfo : public bbBaseTypeInfo<T>{

	bbPrimTypeInfo( bbString name ){
		this->name=name;
		this->kind="Primitive";
	}
/*
	bbVariant nullValue(){
		return bbVariant( T{} );
	}

	bbVariant newArray( int length ){
		return bbVariant( bbArray<T>{ length } );
	}
*/
};

template<class T> struct bbPointerTypeInfo : public bbBaseTypeInfo<T*>{

	bbPointerTypeInfo(){
		this->name=bbGetType<T>()->name+" Ptr";
		this->kind="Pointer";
	}

	bbTypeInfo *pointeeType(){
		return bbGetType<T>();
	}
/*	
	bbVariant nullValue(){
		return bbVariant( (T*)0 );
	}
	
	bbVariant newArray( int length ){
		return bbVariant( bbArray<T*>{ length } );
	}
*/
};

template<class T,int D> struct bbArrayTypeInfo : public bbTypeInfo{	//bbBaseTypeInfo<bbArray<T,D>>{

	bbArrayTypeInfo(){
		this->name=bbGetType<T>()->name+"["+BB_T(",").dup(D-1)+"]";
		this->kind="Array";
	}
	
	bbTypeInfo *elementType(){
		return bbGetType<T>();
	}
	
	int arrayRank(){
		return D;
	}

	bbVariant nullValue(){
		return bbVariant( bbArray<T,D>{} );
	}
/*
	bbVariant newArray( int length )
		return bbVariant( bbArray<T>{ length } );
	}
*/
};

template<class R,class...A> struct bbFunctionTypeInfo : public bbTypeInfo{	//bbBaseTypeInfo<bbFunction<R(A...)>>{

	bbFunctionTypeInfo(){
		this->name=bbGetType<R>()->name+"("+BB_T(",").join( bbArray<bbString>( { bbGetType<A>()->name... },int(sizeof...(A)) ) )+")";
		this->kind="Function";
	}
	
	bbTypeInfo *returnType(){
		return bbGetType<R>();
	}
	
	bbArray<bbTypeInfo*> paramTypes(){
		return bbArray<bbTypeInfo*>( { bbGetType<A>()... },int(sizeof...(A)) );
	}

	bbVariant nullValue(){
		return bbVariant( bbFunction<R(A...)>{} );
	}
/*
	bbVariant newArray( int length ){
		return bbVariant( bbArray<bbFunction<R(A...)>>{ length } );
	}
*/
};

template<class...A> struct bbFunctionTypeInfo<void,A...> : public bbTypeInfo{	//bbBaseTypeInfo<bbFunction<void(A...)>>{

	bbFunctionTypeInfo(){
		this->name=BB_T("Void(")+BB_T(",").join( bbArray<bbString>( { bbGetType<A>()->name... },int(sizeof...(A)) ) )+")";
		this->kind="Function";
	}
	
	bbTypeInfo *returnType(){
		return &bbVoidTypeInfo::instance;
	}
	
	bbArray<bbTypeInfo*> paramTypes(){
		return bbArray<bbTypeInfo*>( { bbGetType<A>()... },int(sizeof...(A)) );
	}

	bbVariant nullValue(){
		return bbVariant( bbFunction<void(A...)>{} );
	}
/*
	bbVariant newArray( int length ){
		return bbVariant( bbArray<bbFunction<void(A...)>>{ length } );
	}	
*/
};

inline bbTypeInfo *bbGetType( bbObject* const& ){
	return &bbObjectTypeInfo::instance;
}

template<class T> bbTypeInfo *bbGetUnknownType( const char *name=0 ){
 	static bbUnknownTypeInfo info( name );
	
	return &info;
}

template<class T> bbTypeInfo *bbGetType( T const& ){
	return bbGetUnknownType<T>();
}

template<class T> bbTypeInfo *bbGetType( T* const& ){
	static bbPointerTypeInfo<T> info;
	
	return &info;
}

template<class T,int D> bbTypeInfo *bbGetType( bbArray<T,D> const& ){
	static bbArrayTypeInfo<T,D> info;
	
	return &info;
}

template<class R,class...A> bbTypeInfo *bbGetFuncType(){
	static bbFunctionTypeInfo<R,A...> info;
	
	return &info;
}

template<class R,class...A> bbTypeInfo *bbGetType( R(*)(A...) ){
	return bbGetFuncType<R,A...>();
}

template<class R,class...A> bbTypeInfo *bbGetType( bbFunction<R(A...)> const& ){
	return bbGetFuncType<R,A...>();
}

template<class T> bbTypeInfo *bbGetType( bbGCVar<T> const& ){
	return bbGetType<T*>();
}

template<> inline bbTypeInfo *bbGetType<void>(){
	return &bbVoidTypeInfo::instance;
}

#endif
