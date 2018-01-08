
#include "internaledges.h"

#include "BulletCollision/CollisionDispatch/btInternalEdgeUtility.h"

namespace{

	bool CustomMaterialCombinerCallback( btManifoldPoint& cp,const btCollisionObjectWrapper* colObj0Wrap,int partId0,int index0,const btCollisionObjectWrapper *colObj1Wrap,int partId1,int index1 ){
	
		btAdjustInternalEdgeContacts( cp,colObj1Wrap,colObj0Wrap,partId1,index1 );
		
//		cp.m_combinedRestitution=colObj0Wrap->getCollisionObject()->getRestitution() * colObj1Wrap->getCollisionObject()->getRestitution();
		
//		cp.m_combinedFriction=0;
		
		return false;
	}
}

namespace bbBullet{

	void createInternalEdgeInfo( btBvhTriangleMeshShape *mesh ){
	
		// enable callback
		gContactAddedCallback=CustomMaterialCombinerCallback;

		// create edge info
		btTriangleInfoMap *info=new btTriangleInfoMap();
		
		btGenerateInternalEdgeInfo( mesh,info );

		mesh->setTriangleInfoMap( info );
	}

}