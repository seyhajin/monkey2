
Namespace std.async

#import "native/async.cpp"
#import "native/async_cb.cpp"

#import "native/async.h"
#import "native/async_cb.h"

#If __TARGET__="android"
#Import "native/Monkey2Async.java"
#Endif

#If __TARGET__="raspbian" Or __TARGET__="linux"
#Import "<libpthread.a>"	'WTH? Didn't used to need this!
#Endif

Extern

#rem monkeydoc @hidden

Internal struct used to deliver events from remote threads.

Probably best to just forget you even saw this...

#end
Struct AsyncEvent="bbAsync::Event"

	Method Post()="post"

	Method Dispatch() Virtual="dispatch"

End

'Should be invoked on mx2 thread.
#rem monkeydoc @hidden
#end
Function CreateAsyncCallback:Int( func:Void(),oneshot:bool )="bbAsync::createAsyncCallback"

'Should be invoked on mx2 thread. No effect if callback has been posted.
#rem monkeydoc @hidden
#end
Function DestroyAsyncCallback:Int( callback:Int )="bbAsync::destroyAsyncCallback"

'Can be invoked on any thread.
#rem monkeydoc @hidden
#end
Function InvokeAsyncCallback( callback:Int )="bbAsync::invokeAsyncCallback"

Public
