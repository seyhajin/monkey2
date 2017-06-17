
Namespace monkey.gc

Extern

#rem monkeydoc @hidden
#end
Function GCSetDebug( debug:Bool )="bbGC::setDebug"

#rem monkeydoc Sets garbage collection trigger value.

The GC trigger is the number of bytes of memory that must be allocated before a garbage collection is automatically performed.

By default, the GC trigger is set to 4 megabytes.

#end
Function GCSetTrigger:Void( trigger:ULong )="bbGC::setTrigger"

#rem monkeydoc Performs a garbage collection.

Marks all unused memory as 'garbage' and makes it available for reuse in the future.

You should not generally need to use this method as garbage collection is performed automatically.

However, it can be useful when debugging a program for memory leaks to force a garbage collection to run.

#end
Function GCCollect:Void()="bbGC::collect"
	
#rem monkeydoc Suspends garbage collection.

Causes garbage collection to be suspended.

The number of GCSuspends and GCResumes executed must match for garbage collection to be enabled.

#end
Function GCSuspend:Void()="bbGC::suspend"
	
#rem monkeydoc Resumes garbagecollection.

Causes garbage collection to be resumed.

The number of GCSuspends and GCResumes executed must match for garbage collection to be enabled.

#end
Function GCResume:Void()="bbGC::resume"
	

#rem monkeydoc Allocates GC aware memory.

If the requested size is large enough, it may trigger a garbage collection.
	
#end
Function GCMalloc:Void Ptr( size:UInt )="bbGC::malloc"
	
#rem monkeydoc Frees GC aware memory.

Frees memory allocated with GCMalloc.

#end
Function GCFree( p:Void Ptr )="bbGC::free"
		
