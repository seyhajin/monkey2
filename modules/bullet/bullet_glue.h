
#ifndef BB_BULLET_H
#define BB_BULLET_H

#include "btBulletDynamicsCommon.h"

namespace bbBullet{

	btVector3 calculateLocalInertia( btCollisionShape *self,btScalar mass );
	
	btTransform getWorldTransform( btMotionState *self );
	
	void rayTest( btCollisionWorld *self,
		const btVector3 &rayFromWorld,
		const btVector3 &rayToWorld,
		btCollisionWorld::RayResultCallback *result );

	void convexSweepTest( btCollisionWorld *self,
		const btConvexShape *castShape,
		const btTransform &castFrom,
		const btTransform &castTo,
		btCollisionWorld::ConvexResultCallback *result,
		btScalar allowedCcdPenetration );
}

#endif
