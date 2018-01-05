
#ifndef BB_DECLINFO_R_H
#define BB_DECLINFO_R_H

#include "bbdeclinfo.h"

// ***** Global *****
//
template<class T> struct bbGlobalDeclInfo : public bbDeclInfo{

	T *ptr;
	
	bbGlobalDeclInfo( bbString name,T *ptr,bbString meta,bool isconst ):ptr( ptr ){
		this->name=name;
		this->meta=meta;
		this->kind=isconst ? "Const" : "Global";
		this->type=bbGetType<T>();
		this->flags=BB_DECL_GETTABLE|(isconst ? 0 : BB_DECL_SETTABLE);
	}
	
	bbVariant get( bbVariant instance ){
	
		return bbVariant( *ptr );
	}
	
	void set( bbVariant instance,bbVariant value ){
	
		*ptr=value.get<T>();
	}
};

template<class T> struct bbGlobalVarDeclInfo : public bbDeclInfo{

	bbGCVar<T> *ptr;
	
	bbGlobalVarDeclInfo( bbString name,bbGCVar<T> *ptr,bbString meta,bool isconst ):ptr( ptr ){
		this->name=name;
		this->meta=meta;
		this->kind=isconst ? "Const" : "Global";
		this->type=bbGetType<T>();
		this->flags=BB_DECL_GETTABLE|(isconst ? 0 : BB_DECL_SETTABLE);
	}
	
	bbVariant get( bbVariant instance ){
	
		return bbVariant( ptr->get() );
	}
	
	void set( bbVariant instance,bbVariant value ){
	
		*ptr=value.get<T*>();
	}
};


template<class T> bbDeclInfo *bbGlobalDecl( bbString name,T *ptr,bbString meta="" ){

	return new bbGlobalDeclInfo<T>( name,ptr,meta,false );
}

template<class T> bbDeclInfo *bbGlobalDecl( bbString name,bbGCVar<T> *ptr,bbString meta="" ){

	return new bbGlobalVarDeclInfo<T>( name,ptr,meta,false );
}

template<class T> bbDeclInfo *bbConstDecl( bbString name,T *ptr,bbString meta="" ){

	return new bbGlobalDeclInfo<T>( name,ptr,meta,true );
}

template<class T> bbDeclInfo *bbConstDecl( bbString name,bbGCVar<T> *ptr,bbString meta="" ){

	return new bbGlobalVarDeclInfo<T>( name,ptr,meta,true );
}

// ***** Field *****
//
template<class C,class T> struct bbFieldDeclInfo : public bbDeclInfo{

	T C::*ptr;
	
	bbFieldDeclInfo( bbString name,bbString meta,T C::*ptr ):ptr( ptr ){
		this->name=name;
		this->meta=meta;
		this->kind="Field";
		this->type=bbGetType<T>();
		this->flags=BB_DECL_GETTABLE|BB_DECL_SETTABLE;
	}
	
	bbVariant get( bbVariant instance ){
	
//		C *p=instance.get<C*>();
		C *p=instance.ref<C>();
		
		return bbVariant( p->*ptr );
	}
	
	void set( bbVariant instance,bbVariant value ){
	
//		C *p=instance.get<C*>();
		C *p=instance.ref<C>();
		
		p->*ptr=value.get<T>();
	}
};

template<class C,class T> struct bbFieldVarDeclInfo : public bbDeclInfo{

	bbGCVar<T> C::*ptr;
	
	bbFieldVarDeclInfo( bbString name,bbString meta,bbGCVar<T> C::*ptr ):ptr( ptr ){
		this->name=name;
		this->meta=meta;
		this->kind="Field";
		this->type=bbGetType<T*>();
		this->flags=BB_DECL_GETTABLE|BB_DECL_SETTABLE;
	}
	
	bbVariant get( bbVariant instance ){
	
//		C *p=instance.get<C*>();
		C *p=instance.ref<C>();
		
		return bbVariant( (p->*ptr).get() );
	}
	
	void set( bbVariant instance,bbVariant value ){
	
//		C *p=instance.get<C*>();
		C *p=instance.ref<C>();
		
		p->*ptr=value.get<T*>();
	}
};

template<class C,class T> bbDeclInfo *bbFieldDecl( bbString name,T C::*ptr,bbString meta="" ){

	return new bbFieldDeclInfo<C,T>( name,meta,ptr );
}

template<class C,class T> bbDeclInfo *bbFieldDecl( bbString name,bbGCVar<T> C::*ptr,bbString meta="" ){

	return new bbFieldVarDeclInfo<C,T>( name,meta,ptr );
}

// ***** Constructor *****
//
template<class C,class...A> struct bbCtorDeclInfo : public bbDeclInfo{

	bbCtorDeclInfo( bbString meta ){
		this->name="New";
		this->meta=meta;
		this->kind="Constructor";
		this->type=bbGetType<bbFunction<void(A...)>>();
		this->flags=BB_DECL_INVOKABLE;
	}
	
	template<int...I> C *invoke( bbArray<bbVariant> params,detail::seq<I...> ){
	
		return bbGCNew<C>( params[I].get<A>()... );
	}
	
	bbVariant invoke( bbVariant instance,bbArray<bbVariant> params ){
	
		return bbVariant( invoke( params,detail::gen_seq<sizeof...(A)>{} ) );
	}
};

template<class C,class...A> bbDeclInfo *bbCtorDecl( bbString meta="" ){

	return new bbCtorDeclInfo<C,A...>( meta );
}

// ***** Method *****
//
template<class C,class R,class...A> struct bbMethodDeclInfo : public bbDeclInfo{

	R (C::*ptr)(A...);
	
	bbMethodDeclInfo( bbString name,bbString meta,R (C::*ptr)(A...) ):ptr( ptr ){
		this->name=name;
		this->meta=meta;
		this->kind="Method";
		this->type=bbGetType<bbFunction<R(A...)>>();
		this->flags=BB_DECL_INVOKABLE;
	}
	
	template<int...I> R invoke( C *p,bbArray<bbVariant> params,detail::seq<I...> ){
	
		return (p->*ptr)( params[I].get<A>()... );
	}
	
	bbVariant invoke( bbVariant instance,bbArray<bbVariant> params ){
	
//		C *p=instance.get<C*>();
		C *p=instance.ref<C>();
		
		return bbVariant( invoke( p,params,detail::gen_seq<sizeof...(A)>{} ) );
	}
};

template<class C,class...A> struct bbMethodDeclInfo<C,void,A...> : public bbDeclInfo{

	typedef void R;

	R (C::*ptr)(A...);
	
	bbMethodDeclInfo( bbString name,bbString meta,R (C::*ptr)(A...) ):ptr( ptr ){
		this->name=name;
		this->meta=meta;
		this->kind="Method";
		this->type=bbGetType<bbFunction<R(A...)>>();
		this->flags=BB_DECL_INVOKABLE;
	}
	
	template<int...I> R invoke( C *p,bbArray<bbVariant> params,detail::seq<I...> ){
	
		return (p->*ptr)( params[I].get<A>()... );
	}

	bbVariant invoke( bbVariant instance,bbArray<bbVariant> params ){
	
//		C *p=instance.get<C*>();
		C *p=instance.ref<C>();
		
		invoke( p,params,detail::gen_seq<sizeof...(A)>{} );
		
		return {};
	}
};

template<class C,class R,class...A> bbDeclInfo *bbMethodDecl( bbString name,R (C::*ptr)(A...),bbString meta="" ){

	return new bbMethodDeclInfo<C,R,A...>( name,meta,ptr );
}

// ***** Extension Method *****
//
template<class C,class R,class...A> struct bbExtMethodDeclInfo : public bbDeclInfo{

	R (*ptr)(C*,A...);
	
	bbExtMethodDeclInfo( bbString name,bbString meta,R (*ptr)(C*,A...) ):ptr( ptr ){
		this->name=name;
		this->meta=meta;
		this->kind="Method";
		this->type=bbGetType<bbFunction<R(A...)>>();
		this->flags=BB_DECL_INVOKABLE;
	}
	
	template<int...I> R invoke( C *p,bbArray<bbVariant> params,detail::seq<I...> ){
	
		return ptr( p,params[I].get<A>()... );
	}
	
	bbVariant invoke( bbVariant instance,bbArray<bbVariant> params ){
	
//		C *p=instance.get<C*>();
		C *p=instance.ref<C>();
		
		return bbVariant( invoke( p,params,detail::gen_seq<sizeof...(A)>{} ) );
	}
};

template<class C,class...A> struct bbExtMethodDeclInfo<C,void,A...> : public bbDeclInfo{

	typedef void R;

	R (*ptr)(C*,A...);
	
	bbExtMethodDeclInfo( bbString name,bbString meta,R (*ptr)(C*,A...) ):ptr( ptr ){
		this->name=name;
		this->meta=meta;
		this->kind="Method";
		this->type=bbGetType<bbFunction<R(A...)>>();
		this->flags=BB_DECL_INVOKABLE;
	}
	
	template<int...I> R invoke( C *p,bbArray<bbVariant> params,detail::seq<I...> ){
	
		return ptr( p,params[I].get<A>()... );
	}

	bbVariant invoke( bbVariant instance,bbArray<bbVariant> params ){
	
//		C *p=instance.get<C*>();
		C *p=instance.ref<C>();
		
		invoke( p,params,detail::gen_seq<sizeof...(A)>{} );
		
		return {};
	}
};

template<class C,class R,class...A> bbDeclInfo *bbExtMethodDecl( bbString name,R (*ptr)(C*,A...),bbString meta="" ){

	return new bbExtMethodDeclInfo<C,R,A...>( name,meta,ptr );
}

// ***** Property *****
//
template<class C,class T> struct bbPropertyDeclInfo : public bbDeclInfo{

	T (C::*getter)();
	
	void (C::*setter)(T);
	
	bbPropertyDeclInfo( bbString name,bbString meta,T(C::*getter)(),void(C::*setter)(T) ):getter( getter ),setter( setter ){
		this->name=name;
		this->meta=meta;
		this->kind="Property";
		this->type=bbGetType<T>();
		this->flags=(getter ? BB_DECL_GETTABLE : 0) | (setter ? BB_DECL_SETTABLE : 0);
	}
	
	bbVariant get( bbVariant instance ){
		if( !getter ) bbRuntimeError( "Property has not getter" );

//		C *p=instance.get<C*>();
		C *p=instance.ref<C>();
		
		return bbVariant( (p->*getter)() );
	}
	
	void set( bbVariant instance,bbVariant value ){
		if( !setter ) bbRuntimeError( "Property has not setter" );
		
//		C *p=instance.get<C*>();
		C *p=instance.ref<C>();
		
		(p->*setter)( value.get<T>() );
	}
};

template<class C,class T> bbDeclInfo *bbPropertyDecl( bbString name,T(C::*getter)(),void(C::*setter)(T),bbString meta="" ){

	return new bbPropertyDeclInfo<C,T>( name,meta,getter,setter );
}

// ***** Extension Property *****
//
template<class C,class T> struct bbExtPropertyDeclInfo : public bbDeclInfo{

	T (*getter)(C*);
	
	void (*setter)(C*,T);
	
	bbExtPropertyDeclInfo( bbString name,bbString meta,T(*getter)(C*),void(*setter)(C*,T) ):getter( getter ),setter( setter ){
		this->name=name;
		this->meta=meta;
		this->kind="Property";
		this->type=bbGetType<T>();
		this->flags=(getter ? BB_DECL_GETTABLE : 0) | (setter ? BB_DECL_SETTABLE : 0);
	}
	
	bbVariant get( bbVariant instance ){
		if( !getter ) bbRuntimeError( "Property has no getter" );

		C *p=instance.ref<C>();
		
		return bbVariant( getter(p) );
	}
	
	void set( bbVariant instance,bbVariant value ){
		if( !setter ) bbRuntimeError( "Property has no setter" );
		
		C *p=instance.ref<C>();
		
		setter(p,value.get<T>() );
	}
};

template<class C,class T> bbDeclInfo *bbExtPropertyDecl( bbString name,T(*getter)(C*),void(*setter)(C*,T),bbString meta="" ){

	return new bbExtPropertyDeclInfo<C,T>( name,meta,getter,setter );
}

// ***** Function *****
//
template<class R,class...A> struct bbFunctionDeclInfo : public bbDeclInfo{

	R (*ptr)(A...);
	
	bbFunctionDeclInfo( bbString name,bbString meta,R (*ptr)(A...) ):ptr( ptr ){
		this->name=name;
		this->meta=meta;
		this->kind="Function";
		this->type=bbGetType<bbFunction<R(A...)>>();
		this->flags=BB_DECL_INVOKABLE;
	}
	
	template<int...I> R invoke( bbArray<bbVariant> params,detail::seq<I...> ){
	
		return (*ptr)( params[I].get<A>()... );
	}
	
	bbVariant invoke( bbVariant instance,bbArray<bbVariant> params ){
	
		return bbVariant( invoke( params,detail::gen_seq<sizeof...(A)>{} ) );
	}
};

template<class...A> struct bbFunctionDeclInfo<void,A...> : public bbDeclInfo{

	typedef void R;

	R (*ptr)(A...);
	
	bbFunctionDeclInfo( bbString name,bbString meta,R (*ptr)(A...) ):ptr( ptr ){
		this->name=name;
		this->meta=meta;
		this->kind="Function";
		this->type=bbGetType<bbFunction<R(A...)>>();
		this->flags=BB_DECL_INVOKABLE;
	}
	
	template<int...I> R invoke( bbArray<bbVariant> params,detail::seq<I...> ){
	
		return (*ptr)( params[I].get<A>()... );
	}
	
	bbVariant invoke( bbVariant instance,bbArray<bbVariant> params ){
	
		invoke( params,detail::gen_seq<sizeof...(A)>{} );
		
		return {};
	}
};

template<class R,class...A> bbDeclInfo *bbFunctionDecl( bbString name,R (*ptr)(A...),bbString meta="" ){

	return new bbFunctionDeclInfo<R,A...>( name,meta,ptr );
}

// ***** Literal *****
//
template<class T> struct bbLiteralDeclInfo : public bbDeclInfo{

	T value;
	
	bbLiteralDeclInfo( bbString name,bbString meta,T value ):value( value ){
		this->name=name;
		this->meta=meta;
		this->kind="Const";
		this->type=bbGetType<T>();
		this->flags=BB_DECL_GETTABLE;
	}
	
	bbVariant get( bbVariant instance ){
	
		return bbVariant( value );
	}
};

template<class T> bbDeclInfo *bbLiteralDecl( bbString name,T value,bbString meta="" ){

	return new bbLiteralDeclInfo<T>( name,meta,value );
}

template<class...Ds> bbDeclInfo **bbMembers( Ds...ds ){

	int n=sizeof...(Ds);
	bbDeclInfo *ts[]={ ds...,0 };
	bbDeclInfo **ps=new bbDeclInfo*[n+1];
	for( int i=0;i<n;++i ) ps[i]=ts[i];
	ps[n]=0;
	
	return ps;
}

#endif
