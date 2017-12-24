
#include "collisiondetect.h"

namespace{

	void *_colls[65536];
	
	void **_collp=_colls;
}

void collisionCallback( btDynamicsWorld *world,btScalar timeStep ){

	int numManifolds=world->getDispatcher()->getNumManifolds();
	
	for( int i=0;i<numManifolds;++i ){

		btPersistentManifold *manifold=world->getDispatcher()->getManifoldByIndexInternal( i );
        
		const btCollisionObject *body0=manifold->getBody0();
		const btCollisionObject *body1=manifold->getBody1();
       
//		printf( "Collision! body0=%p body1=%p\n",body0,body1 );fflush( stdout );
		
		*_collp++=body0->getUserPointer();
		*_collp++=body1->getUserPointer();
	}
}

bool contactAddedCallback( btManifoldPoint &cp,const btCollisionObjectWrapper *colObj0,int partId0,int index0,const btCollisionObjectWrapper *colObj1,int partId1,int index1 ){

	printf( "contact added!\n" );fflush( stdout );
	return true;
}

bool contactProcessedCallback( btManifoldPoint &cp,void *body0,void *body1 ){

	//printf( "contact processed!\n" );fflush( stdout );
	return true;
}

bool contactDestroyedCallback( void *userPersistentData ){

	printf( "contact destroyed!\n" );fflush( stdout );
	return true;
}

/*
void collisionCallback( btDynamicsWorld *world,btScalar timeStep )
{
	int numManifolds = world->getDispatcher()->getNumManifolds();
    for (int i = 0; i < numManifolds; i++)
    {
        btPersistentManifold* contactManifold =  world->getDispatcher()->getManifoldByIndexInternal(i);
        const btCollisionObject* obA = contactManifold->getBody0();
        const btCollisionObject* obB = contactManifold->getBody1();

        int numContacts = contactManifold->getNumContacts();
        for (int j = 0; j < numContacts; j++)
        {
            btManifoldPoint& pt = contactManifold->getContactPoint(j);
            if (pt.getDistance() < 0.f)
            {
                const btVector3& ptA = pt.getPositionWorldOnA();
                const btVector3& ptB = pt.getPositionWorldOnB();
                const btVector3& normalOnB = pt.m_normalWorldOnB;
                
                printf( "Collision!\n" );fflush( stdout );
            }
        }
    }
}
*/

void initCollisions( btDynamicsWorld *world ){

	world->setInternalTickCallback( &collisionCallback,0,false );
	
	gContactAddedCallback=&contactAddedCallback;
//	gContactProcessedCallback=&contactProcessedCallback;
//	gContactDestroyedCallback=&contactDestroyedCallback;
}

void resetCollisions(){
	
	_collp=_colls;
}

int getNumCollisions(){

	return (_collp-_colls)/2;
}

void **getCollisions(){

	return _colls;
}

