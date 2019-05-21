
#ifndef BB_GC_H
#define BB_GC_H

#ifndef BB_THREADS
#error "Wrong gc header"
#endif

#include "bbtypes.h"
#include "bbfunction.h"

struct bbGCNode;
struct bbGCThread;
struct bbGCFiber;
struct bbGCFrame;
struct bbGCRoot;
struct bbGCTmp;
	
namespace bbGC{

	extern bbGCThread *threads;
	extern thread_local bbGCThread *currentThread;
	extern thread_local bbGCFiber *currentFiber;
	
	extern std::atomic_char markedBit;
	extern std::atomic_char unmarkedBit;
	extern std::atomic<bbGCNode*> markQueue;
}

struct bbGCNode{
	
	bbGCNode *succ;
	bbGCNode *pred;
	bbGCNode *qsucc;
	std::atomic_char state;
	char flags;		//1=finalize
	char pad[2];

	bbGCNode(){}
	virtual ~bbGCNode(){}
	
	void gcNeedsFinalize();
	
	virtual void gcFinalize();
	virtual void gcMark();
	virtual void dbEmit();
	virtual const char *typeName()const;
};

struct bbGCThread{
	
	bbGCThread *succ,*pred;
	bbGCFiber *fibers;
	void *handle;

	bbFunction<void()> entry;
	
	bbGCThread();
	~bbGCThread();
	
	void link();
	void unlink();
};

struct bbGCFiber{

	bbGCFiber *succ;
	bbGCFiber *pred;
	bbGCFrame *frames;
	bbGCTmp *tmps;
	bbGCTmp *freeTmps;
	bbGCNode *ctoring;
	
	bbFunction<void()> entry;
	
	bbGCFiber();
	
	void link();
	void unlink();
};

struct bbGCFrame{
	
	bbGCFrame *succ;
	
	bbGCFrame():succ( bbGC::currentFiber->frames ){
		bbGC::currentFiber->frames=this;
	}
	
	~bbGCFrame(){
		bbGC::currentFiber->frames=succ;
	}
	
	virtual void gcMark();
};

struct bbGCRoot{
	
	bbGCRoot *succ;
	
	bbGCRoot();
	
	virtual void gcMark();
};

struct bbGCTmp{
	bbGCTmp *succ;
	bbGCNode *node;
};

namespace bbGC{

	void init();
	void setTrigger( size_t trigger );
	void suspend();
	void resume();
	void retain( bbGCNode *p );
	void release( bbGCNode *p );
	void setDebug( bool debug );
	void *malloc( size_t size );
	size_t mallocSize( void *p );
	void free( void *p );
	void collect();
	
	inline void pushTmp( bbGCNode *p ){
		bbGCTmp *tmp=currentFiber->freeTmps;
		if( tmp ) currentFiber->freeTmps=tmp->succ; else tmp=new bbGCTmp;
		tmp->succ=currentFiber->tmps;
		tmp->node=p;
		currentFiber->tmps=tmp;
	}
	
	inline void popTmps( int n ){
		while( n-- ){
			bbGCTmp *tmp=currentFiber->tmps;
			currentFiber->tmps=tmp->succ;
			tmp->succ=currentFiber->freeTmps;
			currentFiber->freeTmps=tmp;
		}
	}

	template<class T, int D> bbArray<T, D> tmp(const bbArray<T, D> &arr) {
		pushTmp(arr._rep);
		return arr;
	}

	template<class T> T *tmp( T *p ){
		pushTmp( p );
		return p;
	}
	
#ifdef NDEBUG
	__forceinline void enqueue( bbGCNode *p ){
		if( !p || p->state.load()!=unmarkedBit ) return;
		if( p->state.exchange( 4 )==4 ) return;
		p->qsucc=markQueue;
		while( !markQueue.compare_exchange_weak( p->qsucc,p ) ){}
	}

	inline void beginCtor( bbGCNode *p ){
		p->state=4;
		p->flags=0;
		p->qsucc=currentFiber->ctoring;
		currentFiber->ctoring=p;
	}
	
	inline void endCtor( bbGCNode *p ){
		currentFiber->ctoring=p->qsucc;
		p->succ=p->pred=p;
		p->qsucc=markQueue;
		while( !markQueue.compare_exchange_weak( p->qsucc,p ) ){}
	}
#else
	void enqueue( bbGCNode *p );
	void beginCtor( bbGCNode *p );
	void endCtor( bbGCNode *p );
#endif

}

template<class T> void bbGCMark( T const& ){
}

#endif
