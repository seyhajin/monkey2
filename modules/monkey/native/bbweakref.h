

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
	
	bbGCWeakRef( bbObject *p ):succ( bbGC::weakRefs ),target( p ){
		bbGC::weakRefs=this;
		target->flags|=2;
	}
	
	bbObject *getTarget(){
		return target;
	}
	
};

#endif
