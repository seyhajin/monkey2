
#ifndef BB_GC_H
#define BB_GC_H

#include "bbstd.h"
#include "bbtypes.h"
#include "bbmemory.h"
#include "bbfunction.h"

//check for use of deleted objects, MUCH leakier...
//#define BBGC_DEBUG 1

#if BBGC_DEBUG
#define BBGC_VALIDATE( P ) \
	if( (P) && (P)->state==3 ){ \
		printf( "Attempt to use deleted object %p of type '%s'\n",(P),(P)->typeName() ); \
		fflush( stdout ); \
		abort(); \
	}
#else
#define BBGC_VALIDATE( P )
#endif

struct bbGCNode;
struct bbGCFiber;
struct bbGCFrame;
struct bbGCRoot;
struct bbGCTmp;

namespace bbGC{

	extern int markedBit;
	extern int unmarkedBit;
	
	extern bbGCRoot *roots;
	
	extern bbGCTmp *freeTmps;

	extern bbGCNode *markQueue;
	extern bbGCNode *unmarkedList;
	
	extern bbGCFiber *fibers;
	extern bbGCFiber *currentFiber;

	void init();
	
	void suspend();
	
	void resume();
	
	void retain( bbGCNode *p );
	
	void release( bbGCNode *p );
	
	void setDebug( bool debug );

	void setTrigger( size_t trigger );

	void *malloc( size_t size );
	
	size_t mallocSize( void *p );

	void free( void *p );

	void collect();

	bbGCNode *alloc( size_t size );
}

struct bbGCNode{
	bbGCNode *succ;
	bbGCNode *pred;
	char pad[2];
	char state;		//0=lonely, 1/2=marked/unmarked; 3=destroyed
	char flags;		//1=finalize

	bbGCNode(){
	}
	
	void gcNeedsFinalize(){
		flags|=1;
	}
	
	virtual ~bbGCNode(){
	}
	
	virtual void gcFinalize(){
	}

	virtual void gcMark(){
	}
	
	virtual void dbEmit(){
	}
	
	virtual const char *typeName()const{
		return "bbGCNode";
	}
};

struct bbGCFiber{

	bbGCFiber *succ;
	bbGCFiber *pred;
	bbGCFrame *frames;
	bbGCNode *ctoring;
	bbGCTmp *tmps;
	bbFunction<void()> entry;
	
	bbGCFiber():succ( this ),pred( this ),frames( nullptr ),ctoring( nullptr ),tmps( nullptr ){
	}
	
	void link(){
		succ=bbGC::fibers;
		pred=bbGC::fibers->pred;
		bbGC::fibers->pred=this;
		pred->succ=this;
	}
	
	void unlink(){
		pred->succ=succ;
		succ->pred=pred;
	}
};

struct bbGCFrame{
	bbGCFrame *succ;
	
	bbGCFrame():succ( bbGC::currentFiber->frames ){
		bbGC::currentFiber->frames=this;
	}
	
	~bbGCFrame(){
		bbGC::currentFiber->frames=succ;
	}

	virtual void gcMark(){
	}
};

struct bbGCRoot{
	bbGCRoot *succ;
	
	bbGCRoot():succ( bbGC::roots ){
		bbGC::roots=this;
	}
	
	virtual void gcMark(){
	}
};

struct bbGCTmp{
	bbGCTmp *succ;
	bbGCNode *node;
};

namespace bbGC{

	inline void insert( bbGCNode *p,bbGCNode *succ ){
		p->succ=succ;
		p->pred=succ->pred;
		p->pred->succ=p;
		succ->pred=p;
	}

	inline void remove( bbGCNode *p ){	
		p->pred->succ=p->succ;
		p->succ->pred=p->pred;
	}

	inline void enqueue( bbGCNode *p ){
		BBGC_VALIDATE( p )

		if( !p || p->state!=unmarkedBit ) return;
		
		remove( p );
		p->succ=markQueue;
		markQueue=p;
		
		p->state=markedBit;
	}
	
	inline void pushTmp( bbGCNode *p ){
		bbGCTmp *tmp=freeTmps;
		if( !tmp ) tmp=new bbGCTmp;
		tmp->node=p;
		tmp->succ=currentFiber->tmps;
		currentFiber->tmps=tmp;
	}
	
	inline void popTmps( int n ){
		while( n-- ){
			bbGCTmp *tmp=currentFiber->tmps;
			currentFiber->tmps=tmp->succ;
			tmp->succ=freeTmps;
			freeTmps=tmp;
		}
	}
	
	template<class T> T *tmp( T *p ){
		pushTmp( p );
		return p;
	}
	
	inline void beginCtor( bbGCNode *p ){
		p->succ=currentFiber->ctoring;
		currentFiber->ctoring=p;
	}
	
	inline void endCtor( bbGCNode *p ){
		currentFiber->ctoring=p->succ;
		p->succ=markQueue;
		markQueue=p;
		p->state=markedBit;
	}
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

template<class T> void bbGCMark( T const& ){
}

template<class T> void bbGCMark( const bbGCVar<T> &v ){
	bbGCMark( v._ptr );
}

#endif
