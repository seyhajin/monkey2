
#include "bullet_glue.h"

namespace bbBullet{

	btVector3 calculateLocalInertia( btCollisionShape *self,btScalar mass ){
		btVector3 v( 0,0,0 );
		self->calculateLocalInertia( mass,v );
		return v;
	}
	
	btTransform getWorldTransform( btMotionState *self ){
		btTransform t;
		self->getWorldTransform( t );
		return t;
	}
}
