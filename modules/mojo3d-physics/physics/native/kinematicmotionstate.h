
#ifndef BB_KINEMATICMOTIONSTATE_H
#define BB_KINEMATICMOTIONSTATE_H

#include "btBulletDynamicsCommon.h"

class bbKinematicMotionState : public btMotionState{
	
	virtual btTransform getWorldTransform()=0;
	
	virtual void setWorldTransform( const btTransform &tform ){}
	
	virtual void getWorldTransform( btTransform &tform )const{ tform=const_cast<bbKinematicMotionState*>( this )->getWorldTransform(); }
};

#endif
