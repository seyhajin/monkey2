
#ifndef BB_THREAD_H
#define BB_THREAD_H

#include "bbmonkey.h"

#include <thread>
#include <atomic>
#include <mutex>
#include <condition_variable>

struct bbThread{

	static std::atomic_int next_id;
	
	static thread_local int current_id;
	
	std::thread thread;
	
	bool running=false;
	
	int  start( bbFunction<void()> entry );
	
	void detach();
	
	void join();
};

struct bbMutex : public std::mutex{
};

struct bbCondvar : public std::condition_variable_any{
};

#endif
