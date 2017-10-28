
#ifndef BB_STD_ASYNC_CB_H
#define BB_STD_ASYNC_CB_H

#include <bbmonkey.h>

#include "async.h"

namespace bbAsync{

	int createAsyncCallback( bbFunction<void()> func,bool oneshot );
	
	void destroyAsyncCallback( int callback );
	
	void invokeAsyncCallback( int callback );
}

#endif
