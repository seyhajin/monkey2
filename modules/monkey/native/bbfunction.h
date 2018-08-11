
#ifndef BB_FUNCTION_H
#define BB_FUNCTION_H

#include "bbtypes.h"
#include "bbdebug.h"

namespace bbGC{
	void *malloc( size_t size );
	void free( void *p );
}

template<class T> class bbFunction;

template<class R,class...A> struct bbFunction<R(A...)>{

	typedef R(*F)(A...);
	
	struct FunctionRep;
	struct SequenceRep;

	template<class C> struct MethodRep;
	
	static R castErr( A... ){
		puts( "Null Function Error" );
		exit( -1 );
		return R();
	}
	
	struct Rep{
		
#ifdef BB_THREADS
		std::atomic_int refs{0};
#else
		int refs{0};
#endif

		virtual ~Rep(){
		}
		
		virtual R invoke( A... ){
			return R();
		}
		
		virtual bool equals( Rep *rep ){
			return rep==this;
		}
		
		virtual int compare( Rep *rhs ){
			if( this<rhs ) return -1;
			if( this>rhs ) return 1;
			return 0;
		}
		
		virtual Rep *remove( Rep *rep ){
			if( equals( rep ) ) return &_nullRep;
			return this;
		}
		
		virtual void gcMark(){
		}
		
		void *operator new( size_t size ){
			return bbGC::malloc( size );
		}
		
		void operator delete( void *p ){
			bbGC::free( p );
		}
	};
	
	struct FunctionRep : public Rep{
	
		F p;
		
		FunctionRep( F p ):p( p ){
		}
		
		virtual R invoke( A...a ){
			return p( a... );
		}
		
		virtual bool equals( Rep *rhs ){
			FunctionRep *t=dynamic_cast<FunctionRep*>( rhs );
			return t && p==t->p;
		}
		
		virtual int compare( Rep *rhs ){
			FunctionRep *t=dynamic_cast<FunctionRep*>( rhs );
			if( t && p==t->p ) return 0;
			return Rep::compare( rhs );
		}
		
		virtual F Cast(){
			return p;
		}
	};
	
	template<class C> struct MethodRep : public Rep{
	
		typedef R(C::*T)(A...);
		C *c;
		T p;
		
		MethodRep( C *c,T p ):c(c),p(p){
		}
		
		virtual R invoke( A...a ){
			return (c->*p)( a... );
		}
		
		virtual bool equals( Rep *rhs ){
			MethodRep *t=dynamic_cast<MethodRep*>( rhs );
			return t && c==t->c && p==t->p;
		}

		virtual int compare( Rep *rhs ){
			MethodRep *t=dynamic_cast<MethodRep*>( rhs );
			if( t && c==t->c && p==t->p ) return 0;
			return Rep::compare( rhs );
		}
		
		virtual void gcMark(){
			bbGCMark( c );
		}
		
	};
	
	template<class C> struct ExtMethodRep : public Rep{
	
		typedef R(*T)(C*,A...);
		C *c;
		T p;
		
		ExtMethodRep( C *c,T p ):c(c),p(p){
		}
		
		virtual R invoke( A...a ){
			return (*p)( c,a... );
		}
		
		virtual bool equals( Rep *rhs ){
			ExtMethodRep *t=dynamic_cast<ExtMethodRep*>( rhs );
			return t && c==t->c && p==t->p;
		}

		virtual int compare( Rep *rhs ){
			ExtMethodRep *t=dynamic_cast<ExtMethodRep*>( rhs );
			if( t && c==t->c && p==t->p ) return 0;
			return Rep::compare( rhs );
		}
		
		virtual void gcMark(){
			bbGCMark( c );
		}
		
	};
	
	struct SequenceRep : public Rep{
	
		bbFunction lhs,rhs;
		
		SequenceRep( const bbFunction &lhs,const bbFunction &rhs ):lhs( lhs ),rhs( rhs ){
		}
		
		virtual R invoke( A...a ){
			lhs( a... );
			return rhs( a... );
		}
		
#ifdef BB_THREADS
		virtual Rep *remove( Rep *rep ){
		
			if( rep==this ) return &_nullRep;
			
			Rep *lhs2=lhs._rep.load()->remove( rep );
			Rep *rhs2=rhs._rep.load()->remove( rep );
			
			if( lhs2==lhs._rep && rhs2==rhs._rep ) return this;
			
			if( lhs2==&_nullRep ) return rhs2;
			if( rhs2==&_nullRep ) return lhs2;
			
			return new SequenceRep( lhs2,rhs2 );
		}
		
		virtual void gcMark(){
			lhs._rep.load()->gcMark();
			rhs._rep.load()->gcMark();
		}
#else
		virtual Rep *remove( Rep *rep ){
		
			if( rep==this ) return &_nullRep;
			
			Rep *lhs2=lhs._rep->remove( rep );
			Rep *rhs2=rhs._rep->remove( rep );
			
			if( lhs2==lhs._rep && rhs2==rhs._rep ) return this;
			if( lhs2!=&_nullRep && rhs2 !=&_nullRep ) return new SequenceRep( lhs2,rhs2 );
			if( lhs2!=&_nullRep ) return lhs2;
			if( rhs2!=&_nullRep ) return rhs2;

			return &_nullRep;
		}
		
		virtual void gcMark(){
			lhs._rep->gcMark();
			rhs._rep->gcMark();
		}
#endif
	};

	static Rep _nullRep;
	
#ifdef BB_THREADS
	std::atomic<Rep*> _rep;
	
	void retain()const{
		++_rep.load()->refs;
	}
	
	void release(){
		Rep *rep=_rep.load();
		if( !--rep->refs && rep!=&_nullRep ) delete rep;
	}
#else
	Rep *_rep;
	
	void retain()const{
		++_rep->refs;
	}
	
	void release(){
		if( !--_rep->refs && _rep!=&_nullRep ) delete _rep;
	}
#endif
	
	bbFunction( Rep *rep ):_rep( rep ){
		retain();
	}
	
	public:
	
	bbFunction():_rep( &_nullRep ){
	}

#ifdef BB_THREADS
	bbFunction( const bbFunction &p ):_rep( p._rep.load() ){
		retain();
	}
#else
	bbFunction( const bbFunction &p ):_rep( p._rep ){
		retain();
	}
#endif
	
	template<class C> bbFunction( C *c,typename MethodRep<C>::T p ):_rep( new MethodRep<C>(c,p) ){
		retain();
	}
	
	template<class C> bbFunction( C *c,typename ExtMethodRep<C>::T p ):_rep( new ExtMethodRep<C>(c,p) ){
		retain();
	}
	
	bbFunction( F p ):_rep( new FunctionRep( p ) ){
		retain();
	}
	
	~bbFunction(){
		release();
	}
	
#ifdef BB_THREADS
	bbFunction &operator=( const bbFunction &p ){
		Rep *oldrep=_rep,*newrep=p._rep;
		if( _rep.compare_exchange_strong( oldrep,newrep ) ){
			++newrep->refs;
			if( !--oldrep->refs && oldrep!=&_nullRep ) delete oldrep;
		}
		return *this;
	}

	bbFunction operator+( const bbFunction &rhs )const{
		Rep *tlhs=_rep,*trhs=rhs._rep;
		if( tlhs==&_nullRep ) return trhs;
		if( trhs==&_nullRep ) return tlhs;
		return new SequenceRep( tlhs,trhs );
	}
	
	bbFunction operator-( const bbFunction &rhs )const{
		return _rep.load()->remove( rhs._rep );
	}
	
	bbBool operator==( const bbFunction &rhs )const{
		return _rep.load()->equals( rhs._rep );
	}
	
	bbBool operator!=( const bbFunction &rhs )const{
		return !_rep.load()->equals( rhs._rep );
	}

	operator bbBool()const{
		return _rep.load()==&_nullRep;
	}
	
	R operator()( A...a )const{
		return _rep.load()->invoke( a... );
	}

	operator F()const{	//cast to simple static function ptr
		FunctionRep *t=dynamic_cast<FunctionRep*>( _rep.load() );
		if( t ) return t->p;
		return castErr;
	}
#else
	bbFunction &operator=( const bbFunction &p ){
		p.retain();
		release();
		_rep=p._rep;
		return *this;
	}
	
	bbFunction operator+( const bbFunction &rhs )const{
		if( _rep==&_nullRep ) return rhs;
		if( rhs._rep==&_nullRep ) return *this;
		return new SequenceRep( *this,rhs );
	}

	bbFunction operator-( const bbFunction &rhs )const{
		return _rep->remove( rhs._rep );
	}

	bbBool operator==( const bbFunction &rhs )const{
		return _rep->equals( rhs._rep );
	}
	
	bbBool operator!=( const bbFunction &rhs )const{
		return !_rep->equals( rhs._rep );
	}

	operator bbBool()const{
		return _rep==&_nullRep;
	}

	R operator()( A...a )const{
		return _rep->invoke( a... );
	}
	
	operator F()const{	//cast to simple static function ptr
		FunctionRep *t=dynamic_cast<FunctionRep*>( _rep );
		if( t ) return t->p;
		return castErr;
	}
#endif

	bbFunction &operator+=( const bbFunction &rhs ){
		*this=*this+rhs;
		return *this;
	}
	
	bbFunction &operator-=( const bbFunction &rhs ){
		*this=*this-rhs;
		return *this;
	}
};

template<class R,class...A> typename bbFunction<R(A...)>::Rep bbFunction<R(A...)>::_nullRep;

template<class C,class R,class...A> bbFunction<R(A...)> bbMethod( C *c,R(C::*p)(A...) ){
	return bbFunction<R(A...)>( c,p );
}

template<class C,class R,class...A> bbFunction<R(A...)> bbMethod( const bbGCVar<C> &c,R(C::*p)(A...) ){
	return bbFunction<R(A...)>( c.get(),p );
}

template<class C,class R,class...A> bbFunction<R(A...)> bbExtMethod( C *c,R(*p)(C*,A...) ){
	return bbFunction<R(A...)>( c,p );
}

template<class C,class R,class...A> bbFunction<R(A...)> bbExtMethod( const bbGCVar<C> &c,R(*p)(C*,A...) ){
	return bbFunction<R(A...)>( c.get(),p );
}

template<class R,class...A> bbFunction<R(A...)> bbMakefunc( R(*p)(A...) ){
	return bbFunction<R(A...)>( p );
}

#if BB_THREADS
template<class R,class...A> void bbGCMark( const bbFunction<R(A...)> &t ){
	t._rep.load()->gcMark();
}

template<class R,class...A> int bbCompare( const bbFunction<R(A...)> &x,const bbFunction<R(A...)> &y ){
	return x._rep.load()->compare( y._rep.load() );
}
#else
template<class R,class...A> void bbGCMark( const bbFunction<R(A...)> &t ){
	t._rep->gcMark();
}

template<class R,class...A> int bbCompare( const bbFunction<R(A...)> &x,const bbFunction<R(A...)> &y ){
	return x._rep->compare( y._rep );
}
#endif

template<class R,class...A> bbString bbDBType( bbFunction<R(A...)> *p ){
	return bbDBType<R>()+"()";
}

template<class R,class...A> bbString bbDBValue( bbFunction<R(A...)> *p ){
	return "function?????";
}

#endif
