
#ifndef BB_BULLET_H
#define BB_BULLET_H

//#include "bullet3-2.85.1/src/btBulletDynamicsCommon.h"
#include "btBulletDynamicsCommon.h"

namespace bbBullet{

	btVector3 calculateLocalInertia( btCollisionShape *self,btScalar mass );
	
	btTransform getWorldTransform( btMotionState *self );
}

#endif
