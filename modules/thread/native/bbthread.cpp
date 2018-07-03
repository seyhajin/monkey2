
#include "bbthread.h"

std::atomic_int bbThread::next_id{1};

thread_local int bbThread::current_id{1};

int bbThread::start( bbFunction<void()> entry ){

	int id=++next_id;
	
	running=true;
	
	thread=std::thread( [=](){
	
		bbGCThread gcThread;
		gcThread.link();
		
		bbDBContext dbContext;
		dbContext.init();
		
		bbDB::currentContext=&dbContext;
		
		current_id=id;
		
		entry();
		
		running=false;
		
		bbDB::currentContext=nullptr;
		
		gcThread.unlink();
	} );
	
	return id;
}

void bbThread::detach(){

	thread.detach();
}

void bbThread::join(){

	thread.join();
}
