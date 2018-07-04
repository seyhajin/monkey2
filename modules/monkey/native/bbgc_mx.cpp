
#ifdef BB_THREADS

#include "bbmonkey.h"
//#include "bbgc_mx.h"
#include "bbweakref.h"

#include <mutex>
#include <condition_variable>

#ifdef _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#include <signal.h>
#endif

namespace bbDB{

	void stop();
	
	void stopped();
	
	void error( bbString err );
}

namespace{

	typedef std::chrono::duration<double> Duration;
	typedef std::chrono::high_resolution_clock Clock;
	
	double now(){
	
		static Clock::time_point start=Clock::now();
		
		auto elapsed=(Clock::now()-start).count();
	
		return elapsed * ((double)Clock::period::num/(double)Clock::period::den);
	}
}

namespace bbGC{

	size_t trigger=4*1024*1024;
	int suspended=1;
	
	size_t memused;
	size_t malloced;

	bbGCThread *threads;
	thread_local bbGCThread *currentThread;
	thread_local bbGCFiber *currentFiber;

	std::atomic_char markedBit;
	std::atomic_char unmarkedBit;
	std::atomic<bbGCNode*> markQueue;
	
	std::mutex collectorMutex;
	
	bbGCRoot *roots;
	bbGCTmp *retained;
	bbGCNode *markedList;
	bbGCNode *unmarkedList;
	bbGCNode markLists[2];
	bbGCNode freeList;
	
	size_t markedBytes;
	size_t unmarkedBytes;
	size_t allocedBytes;
	
	void *pools[32];
	unsigned char *poolBuf;
	size_t poolBufSize;
	std::mutex poolsMutex;
	
	void suspendSigHandler( int sig );
	
	bool inited;
	
	void finit(){
	
		suspended=INT_MAX;
		
		inited=false;
	}
	
	void init(){

		if( inited ) return;
		inited=true;
		
		printf( "sizeof( std::atomic_char )=%i\n",sizeof( std::atomic_char ) );
		printf( "std::atomic_char().is_lock_free()=%i\n",std::atomic_char().is_lock_free() );
		fflush( stdout );
		
		markedBit=1;
		markedList=&markLists[0];
		markedList->succ=markedList->pred=markedList;
		
		unmarkedBit=2;
		unmarkedList=&markLists[1];
		unmarkedList->succ=unmarkedList->pred=unmarkedList;
		
		freeList.succ=freeList.pred=&freeList;
		
		threads=new bbGCThread;
		
		currentThread=threads;
		
		currentFiber=currentThread->fibers;
		
#ifndef _WIN32
		struct sigaction action;
		memset( &action,0,sizeof(action) );
		action.sa_handler=suspendSigHandler;
		action.sa_flags=SA_RESTART;
			
		if( sigaction( SIGUSR2,&action,0 )<0 ) exit(-1);
#endif
		suspended=0;
		
		atexit( finit );
	}
	
	void setTrigger( size_t size ){
	
		trigger=size;
	}
	
	void suspend(){
	
		++suspended;
	}
	
	void resume(){
	
		--suspended;
	}
	
	__forceinline void insert( bbGCNode *p,bbGCNode *succ ){
		p->succ=succ;
		p->pred=succ->pred;
		p->pred->succ=p;
		succ->pred=p;
	}

	__forceinline void remove( bbGCNode *p ){	
		p->pred->succ=p->succ;
		p->succ->pred=p->pred;
	}
	
	void lockCollector(){
	
//		printf( "lockCollector\n" );fflush( stdout );
	
		if( inited ) collectorMutex.lock();
	}
	
	void unlockCollector(){
	
//		printf( "unlockCollector\n" );fflush( stdout );
	
		if( inited ) collectorMutex.unlock();
	}
	

#ifdef _WIN32

	//collectorMutex locked.
	//
	void suspendThreads(){
	
		bbGCThread *thread=threads;
		
		for( ;; ){
		
			if( thread!=currentThread ){

				int n=(int)SuspendThread( thread->handle );
						
				if( n<0 ){ printf( "SuspendThread failed! n=%i\n",n );fflush( stdout );exit( -1 ); }
			
				CONTEXT context={0};//CONTEXT_CONTROL};
						
				if( !GetThreadContext( thread->handle,&context ) ){ printf( "GetThreadContext failed\n" );fflush( stdout );exit( -1 ); }
			}
			
			thread=thread->succ;
			
			if( thread==threads ) break;
		}
	}
	
	//collectorMutex locked.
	//
	void resumeThreads(){
	
		bbGCThread *thread=threads;
		
		for( ;; ){
		
			if( thread!=currentThread ){
				
				ResumeThread( thread->handle );
			}

			thread=thread->succ;
			
			if( thread==threads ) break;
		}
	}

#else

	std::atomic_int resumeCount{0};
	std::atomic_bool threadSuspended{false};
	
	std::mutex suspendMutex;
	std::condition_variable_any suspendCondvar;
	
	std::mutex resumeMutex;
	std::condition_variable_any resumeCondvar;
	
	void suspendSigHandler( int sig ){
	
		int resume=resumeCount+1;
	
		//signal suspended
		suspendMutex.lock();
		threadSuspended=true;
		suspendMutex.unlock();
		suspendCondvar.notify_one();
		
		//wait for resume
		resumeMutex.lock();
		while( resumeCount!=resume ) resumeCondvar.wait( resumeMutex );
		resumeMutex.unlock();
	}
	
	//collectorMutex locked.
	//
	void suspendThreads(){
	
		bbGCThread *thread=threads;
		
		suspendMutex.lock();
		for( ;; ){
		
			if( thread!=currentThread ){
				
				threadSuspended=false;
				suspendMutex.unlock();
				
				pthread_kill( (pthread_t)thread->handle,SIGUSR2 );

				suspendMutex.lock();
				while( !threadSuspended ) suspendCondvar.wait( suspendMutex );
			}
			
			thread=thread->succ;
			
			if( thread==threads ) break;
		}
		suspendMutex.unlock();
	}
	
	//collectorMutex locked.
	//
	void resumeThreads(){
	
		//signal resume
		resumeMutex.lock();
		resumeCount+=1;
		resumeMutex.unlock();
		resumeCondvar.notify_all();
	}

#endif
	
	//collectorMutex locked.
	//
	void reclaim( size_t size ){
	
		size_t freed=0;
	
		while( freeList.succ!=&freeList && freed<size ){
		
			bbGCNode *p=freeList.succ;
			
			freed+=mallocSize( p );
			
			remove( p );
			
			if( p->flags & 2 ){

				//printf( "deleting weak refs for: %s %p\n",p->typeName(),p );fflush( stdout );
				
				bbGCWeakRef **pred=&bbGC::weakRefs,*curr;
				
				while( curr=*pred ){
					if( curr->target==p ){
						curr->target=0;
						*pred=curr->succ;
					}else{
						pred=&curr->succ;
					}
				}
			}
			
			if( p->flags & 1 ){
				
				//printf( "finalizing: %s %p\n",p->typeName(),p );fflush( stdout );
				
				++suspended;
				
				p->state=char(unmarkedBit);
				
				p->gcFinalize();
				
				if( p->state==markedBit ) bbRuntimeError( "Object resurrected in finalizer" );
					
				--suspended;
			}
			
			p->~bbGCNode();
			
			bbGC::free( p );
		}
	}
	
	//collectorMutex locked.
	//
	void markRoots(){
	
		for( bbGCRoot *root=roots;root;root=root->succ ){
		
			root->gcMark();
		}
	}
	
	//collectorMutex locked + threads suspended.
	//
	void markRetained(){
	
		for( bbGCTmp *tmp=retained;tmp;tmp=tmp->succ ){
		
			enqueue( tmp->node );
		}
	}
	
	//collectorMutex locked + threads suspended.
	//
	void markFibers(){
	
		bbGCThread *thread=threads;
		
		for(;;){
		
			bbGCMark( thread->entry );
		
			bbGCFiber *fiber=thread->fibers;
		
			for(;;){
			
				bbGCMark( fiber->entry );
	
				for( bbGCFrame *frame=fiber->frames;frame;frame=frame->succ ){
				
					frame->gcMark();
				}
				
				for( bbGCNode *node=fiber->ctoring;node;node=node->qsucc ){
				
					node->gcMark();
				}
				
				for( bbGCTmp *tmp=fiber->tmps;tmp;tmp=tmp->succ ){
				
					enqueue( tmp->node );
				}
				
				fiber=fiber->succ;
				
				if( fiber==thread->fibers ) break; 
			}
			
			thread=thread->succ;
			
			if( thread==threads ) break;
		}
	}
	
	//collectorMutex locked.
	//
	void markQueued( size_t tomark ){
	
		while( markQueue && markedBytes<tomark ){
			
			bbGCNode *p=markQueue;
			while( !markQueue.compare_exchange_weak( p,p->qsucc ) ){}
				
			remove( p );
			
			p->gcMark();
			
			insert( p,markedList );
			
			p->state=char(markedBit);

			markedBytes+=mallocSize( p );
		}
	}

	//collectorMutex locked.
	//
	void sweep(){
	
		double start=now();
		
//		printf( "GC info: sweeping...\n" );fflush( stdout );
		
		suspendThreads();
		
		markRetained();
		
		markFibers();
	
		markQueued( SIZE_MAX );
		
		if( unmarkedList->succ!=unmarkedList ){
			
			//append unmarked to end of free queue
			unmarkedList->succ->pred=freeList.pred;
			unmarkedList->pred->succ=&freeList;
			freeList.pred->succ=unmarkedList->succ;
			freeList.pred=unmarkedList->pred;
			
			//clear unmarked
			unmarkedList->succ=unmarkedList->pred=unmarkedList;
		}

		//swap mark/unmarked lists
		
		auto tmp1=markedList;markedList=unmarkedList;unmarkedList=tmp1;
		auto tmp2=char(markedBit);markedBit=char(unmarkedBit);unmarkedBit=tmp2;
		unmarkedBytes=markedBytes;
		markedBytes=0;

		//start new sweep phase
		allocedBytes=0;

		resumeThreads();
		
		markRoots();
		
		double elapsed=now()-start;
		
//		bb_printf( "sweep=%g (%ims)\n",elapsed,int(elapsed*1000+0.5) );fflush( stdout );
		
//		printf( "end sweep\n" );fflush( stdout );
	}
	
	void retain( bbGCNode *node ){
		
		if( !node ) return;
		
		bbGCTmp *tmp=currentFiber->freeTmps;
		if( tmp ) currentFiber->freeTmps=tmp->succ; else tmp=new bbGCTmp;
		tmp->node=node;
		
		lockCollector();
		
		tmp->succ=retained;
		retained=tmp;
		
		unlockCollector();
	}
	
	void release( bbGCNode *node ){
		if( !node ) return;
		
		lockCollector();
		
		bbGCTmp **p=&retained;
		while( bbGCTmp *tmp=*p ){
			if( tmp->node!=node ){
				p=&tmp->succ;
				continue;
			}
			*p=tmp->succ;
			tmp->succ=currentFiber->freeTmps;
			currentFiber->freeTmps=tmp;
			break;
		}
		
		unlockCollector();
	}
	
	void *malloc( size_t size ){
	
//		printf( "malloc %u\n",size );fflush( stdout );
	
		size=(size+8+7) & ~7;
		
		memused+=size;
		
		if( !suspended ){
			
			lockCollector();

			if( allocedBytes+size>=trigger ){
				
				sweep();
				
			}else{
			
				markQueued( double( allocedBytes+size ) / double( trigger ) * double( unmarkedBytes + trigger ) );
			}
			
			reclaim( size );
			
			unlockCollector();
		}
		
		void *p;
		
		if( size<256 ){
			
			if( inited ) poolsMutex.lock();
			
			if( pools[size>>3] ){
				
				p=pools[size>>3];
				pools[size>>3]=*(void**)p;
				
			}else{
			
				if( size>poolBufSize ){
					if( poolBufSize ){
						*(void**)poolBuf=pools[poolBufSize>>3];
						pools[poolBufSize>>3]=poolBuf;
					}
					poolBufSize=65536;
					poolBuf=(unsigned char*)::malloc( poolBufSize );
					malloced+=poolBufSize;
				}
				p=poolBuf;
				poolBuf+=size;
				poolBufSize-=size;
			}
			
			if( inited ) poolsMutex.unlock();
			
		}else{
			p=::malloc( size );
			malloced+=size;
		}
		
		allocedBytes+=size;
		size_t *q=(size_t*)p;
		if( sizeof(size_t)==4 ) ++q;
		*q++=size;

//		printf( "end malloc %u\n",size );fflush( stdout );
	
		return q;
	}
	
	size_t mallocSize( void *p ){
	
		if( p ) return *((size_t*)p-1);
		
		return 0;
	}
	
	void free( void *p ){
	
		if( !p ) return;
		
		size_t *q=(size_t*)p;
		size_t size=*--q;
		if( sizeof(size_t)==4 ) --q;
		
#ifndef NDEBUG
		memset( q,0xa5,size );
#endif
		
		memused-=size;
		
		if( size<256 ){

			if( inited ) poolsMutex.lock();
			
			*(void**)q=pools[size>>3];
			pools[size>>3]=q;

			if( inited ) poolsMutex.unlock();
			
		}else{
			malloced-=size;
			::free( q );
		}
	}
	
	void collect(){
	
		if( !inited ) return;
		
		static size_t maxused;
		
		lockCollector();
	
		sweep();
		
		reclaim( SIZE_MAX );

		unlockCollector();
		
		if( memused>maxused ) maxused=memused;
		
//		printf( "Collect complete: memused=%i max memused=%i\n",memused,maxused );fflush( stdout );
	}

#ifndef NDEBUG	
	void qinsert( bbGCNode *p ){

		static int max_n;
		
		int n=0;
		
		p->qsucc=markQueue;
		while( !markQueue.compare_exchange_weak( p->qsucc,p ) ){ ++n; }
			
		if( n>max_n ){ max_n=n;printf( "GC info: max spins=%i\n",max_n );fflush( stdout ); }			
	}
	
	void enqueue( bbGCNode *p ){
		
		if( !p || p->state.load()!=unmarkedBit ) return;
		
		char oldstate=p->state.exchange( 4 );
		
		if( oldstate==4 ) return;
		
		if( oldstate!=unmarkedBit ){ printf( "GC info: redundant enqueue\n" );fflush( stdout ); }
		
		qinsert( p );
	}
	
	void beginCtor( bbGCNode *p ){
		p->state=4;
		p->flags=0;
		p->qsucc=currentFiber->ctoring;
		currentFiber->ctoring=p;
	}
	
	void endCtor( bbGCNode *p ){
		currentFiber->ctoring=p->qsucc;
		p->succ=p->pred=p;
		qinsert( p );
	}
#endif
}

// ***** bbGCNode *****

void bbGCNode::gcNeedsFinalize(){
	flags|=1;
}

void bbGCNode::gcFinalize(){
}

void bbGCNode::gcMark(){
}

void bbGCNode::dbEmit(){
}

const char *bbGCNode::typeName()const{

	return "bbGCNode";
}

// ***** bbGCThread *****

bbGCThread::bbGCThread():succ( this ),pred( this ),fibers( new bbGCFiber ){

#if _WIN32
	handle=OpenThread( THREAD_ALL_ACCESS,FALSE,GetCurrentThreadId() );
#else
	handle=(void*)pthread_self();
#endif

}

bbGCThread::~bbGCThread(){

#ifdef _WIN32
	CloseHandle( handle );
#endif
}

void bbGCThread::link(){

	bbGC::lockCollector();
	
	succ=bbGC::threads;
	pred=bbGC::threads->pred;
	bbGC::threads->pred=this;
	pred->succ=this;
	
	bbGC::currentThread=this;
	bbGC::currentFiber=fibers;
	
	bbGC::unlockCollector();
}

void bbGCThread::unlink(){

	bbGC::lockCollector();
	
	pred->succ=succ;
	succ->pred=pred;
	
	bbGC::currentThread=0;
	bbGC::currentFiber=0;
	
	bbGC::unlockCollector();
}

// ***** bbGCFiber *****

bbGCFiber::bbGCFiber():succ( this ),pred( this ),frames( nullptr ),tmps( nullptr ),freeTmps( nullptr ),ctoring( nullptr ){
}
	
void bbGCFiber::link(){

	succ=bbGC::currentThread->fibers;
	pred=bbGC::currentThread->fibers->pred;
	bbGC::currentThread->fibers->pred=this;
	pred->succ=this;
}

void bbGCFiber::unlink(){

	pred->succ=succ;
	succ->pred=pred;
}

// ***** bbGCFrame *****

void bbGCFrame::gcMark(){
}

// ***** bbGCRoot *****

bbGCRoot::bbGCRoot(){

	bbGC::lockCollector();
	
	succ=bbGC::roots;
	bbGC::roots=this;
	
	bbGC::unlockCollector();
}

void bbGCRoot::gcMark(){
}

#endif
