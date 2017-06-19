
#include "bullet_glue.h"

namespace{

	bool kludge1Callback(
		btManifoldPoint& cp,
		const btCollisionObjectWrapper* colObj0Wrap,
		int partId0,
		int index0,
		const btCollisionObjectWrapper* colObj1Wrap,
		int partId1,
		int index1
	){
	
//		auto n=cp.m_normalWorldOnB;
//		printf( "%f %f %f\n",n.x(),n.y(),n.z() );
		
//		cp.m_normalWorldOnA=btVector3( 0,1,0 );
	
	/*
		// one-sided triangles
		if (colObj1Wrap->getCollisionShape()->getShapeType() == TRIANGLE_SHAPE_PROXYTYPE)
		{
			auto triShape = static_cast<const btTriangleShape*>( colObj1Wrap->getCollisionShape() );
			const btVector3* v = triShape->m_vertices1;
			btVector3 faceNormalLs = btCross(v[1] - v[0], v[2] - v[0]);
			faceNormalLs.normalize();
			btVector3 faceNormalWs = colObj1Wrap->getWorldTransform().getBasis() * faceNormalLs;
			float nDotF = btDot( faceNormalWs, cp.m_normalWorldOnB );
			if ( nDotF <= 0.0f )
			{
				// flip the contact normal to be aligned with the face normal
				cp.m_normalWorldOnB += -2.0f * nDotF * faceNormalWs;
			}
		}
	*/
	
		//this return value is currently ignored, but to be on the safe side: return false if you don't calculate friction
		return false;
	}
}

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
	
	void bulletKludge1( btCollisionObject *obj ){
	
		static bool done;
		if( !done ){
		    gContactAddedCallback = kludge1Callback;
		    done=true;
		}
	
		obj->setCollisionFlags( obj->getCollisionFlags() | btCollisionObject::CF_CUSTOM_MATERIAL_CALLBACK );
	}
	
}
