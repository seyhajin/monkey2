

#ifndef BB_WEAKREF_H
#define BB_WEAKREF_H

#include "bbobject.h"

struct bbGCWeakRef;

namespace bbGC{

	extern bbGCWeakRef *weakRefs;
}

struct bbGCWeakRef : public bbObject{

	bbGCWeakRef *succ;	
	bbObject *target;
	
	bbGCWeakRef( bbObject *target );
	~bbGCWeakRef();
	
	bbObject *getTarget();
};

#endif
