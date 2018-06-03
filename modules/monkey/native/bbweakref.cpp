
#include "bbweakref.h"

bbGCWeakRef *bbGC::weakRefs;

bbGCWeakRef::bbGCWeakRef( bbObject *target ):target( target ){

	if( !target) return;
	
	succ=bbGC::weakRefs;
	bbGC::weakRefs=this;
	target->flags|=2;
}

bbGCWeakRef::~bbGCWeakRef(){

	if( !target ) return;
	
	bbAssert( target->flags & 2,"internal bbGCWeakRef error 1" );
	
	bbGCWeakRef **pred=&bbGC::weakRefs,*curr;
	
	target->flags&=~2;

	while( curr=*pred ){
		
		if( curr==this ){
			
			*pred=succ;
			
			if( target->flags & 2 ) return;
			
			while( curr=*pred ){
				if( curr->target==target ){
					target->flags|=2;
					return;
				}
				pred=&curr->succ;
			}
			return;
		}
		
		if( curr->target==target ) target->flags|=2;
			
		pred=&curr->succ;
	}
		
}

bbObject *bbGCWeakRef::getTarget(){

	return target;
}

