
#ifndef BB_BULLET_H
#define BB_BULLET_H

#include "btBulletDynamicsCommon.h"

namespace bbBullet{

	btVector3 calculateLocalInertia( btCollisionShape *self,btScalar mass );
	
	btTransform getWorldTransform( btMotionState *self );
}

#endif
