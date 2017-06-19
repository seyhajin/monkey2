	
Namespace bullet

#Import "<libc>"
#Import "<std>"

#Import "bullet3-2.85.1/src/*.h"

#Import "makefile_linearmath"
#Import "makefile_collision"
#Import "makefile_dynamics"

#Import "bullet_glue.cpp"
#Import "bullet_glue.h"

Using std.geom

Alias btScalar:Float

Extern

Struct btVector3
	
	Field x:btScalar="m_floats[0]"
	Field y:btScalar="m_floats[1]"
	Field z:btScalar="m_floats[2]"
	
	Method New()
	
	Method New( x:btScalar,y:btScalar,z:btScalar )
	
End

Struct btVector4
	
	Field x:btScalar="m_floats[0]"
	Field y:btScalar="m_floats[1]"
	Field z:btScalar="m_floats[2]"
	Field w:btScalar="m_floats[3]"
	
	Method New()
		
	Method New( x:btScalar,y:btScalar,z:btScalar,w:btScalar )
	
End

Struct btMatrix3x3

	Method New()
		
	Method New( xx:btScalar,xy:btScalar,xz:btScalar,yx:btScalar,yy:btScalar,yz:btScalar,zx:btScalar,zy:btScalar,zz:btScalar )
	
	Method getRow:btVector3( i:Int )
	
End

Struct btQuaternion

	Field x:btScalar="m_floats[0]"
	Field y:btScalar="m_floats[1]"
	Field z:btScalar="m_floats[2]"
	Field w:btScalar="m_floats[3]"

	Method New()
		
	Method New( x:btScalar,y:btScalar,z:btScalar,w:btScalar )	
End

Struct btTransform
	
	Method New()
		
	Method New( q:btQuaternion,c:btVector3=New btVector3( 0,0,0 ) )

	Method New( b:btMatrix3x3,c:btVector3=New btVector3( 0,0,0 ) )
		
	Method setOrigin( origin:btVector3 )
	
	Method getOrigin:btVector3()
	
	Method setBasis( basis:btMatrix3x3 )
	
	Method getBasis:btMatrix3x3()
	
	Method setFromOpenGLMatrix( m:Float Ptr )
		
	Method getOpenGLMatrix( m:Float Ptr )
		
	Method getOpenGLMatrix2( m:Float Ptr )
		
	Function getIdentity:btTransform()
End


Class btObject Extends Void
	
	Method destroy() Extension="delete"
End

Class btBroadphaseInterface Extends btObject
End

Class btDbvtBroadphase Extends btBroadphaseInterface
End

Class btMultiSapBroadphase Extends btBroadphaseInterface
End

Class btSimpleBroadphase Extends btBroadphaseInterface
End

Class btCollisionConfiguration Extends btObject
End

Class btDefaultCollisionConfiguration Extends btCollisionConfiguration
End

Class btConstraintSolver Extends btObject
End

Class btSequentialImpulseConstraintSolver Extends btConstraintSolver
End

Class btDispatcher Extends btObject
End

Class btCollisionDispatcher Extends btDispatcher
	
	Method New( collisionConfiguration:btCollisionConfiguration )
End

Class btCollisionWorld Extends btObject
End

Class btDynamicsWorld Extends btCollisionWorld
	
	Method setGravity( gravity:btVector3 )
	
	Method getGravity:btVector3()
		
	Method stepSimulation( timeStep:btScalar,maxSubSteps:Int=1,fixedTimeStep:btScalar=1.0/60.0 ) Virtual
		
	Method addRigidBody( body:btRigidBody ) Virtual

	Method addRigidBody( body:btRigidBody,group:Short,mask:Short ) Virtual
		
	Method removeRigidBody( body:btRigidBody ) Virtual
		
End

Class btDiscreteDynamicsWorld Extends btDynamicsWorld
	
	Method New( dispatcher:btDispatcher,pairCache:btBroadphaseInterface,contraintSolver:btConstraintSolver,collisionConfiguration:btCollisionConfiguration )
		
End

Class btCollisionShape Extends btObject

	Method setLocalScaling( scaling:btVector3 )
	
	Method getLocalScaling:btVector3()
	
	Method calculateLocalInertia:btVector3( mass:btScalar ) Extension="bbBullet::calculateLocalInertia"
End

Class btCompoundShape Extends btCollisionShape

 	Method New( enableDynamicAabbTree:Bool=True,initialChildCapacity:int=0 )
 	
	Method addChildShape( localTransform:btTransform,shape:btCollisionShape )

End

Class btConcaveShape Extends btCollisionShape
End

Class btConvexShape Extends btCollisionShape
End

Class btConvexInternalShape Extends btConvexShape
End

Class btPolyhedralConvexShape Extends btConvexInternalShape
End

Class btBoxShape Extends btPolyhedralConvexShape
	
	Method New( boxHalfExtents:btVector3 )
End	

Class btStaticPlaneShape Extends btConcaveShape
	
	Method New( planeNormal:btVector3,planeConstant:btScalar )
End

Class btSphereShape Extends btConvexShape

	Method New( radius:btScalar )
End

Enum PHY_ScalarType
End

Const PHY_FLOAT:PHY_ScalarType
Const PHY_DOUBLE:PHY_ScalarType
Const PHY_INTEGER:PHY_ScalarType
Const PHY_SHORT:PHY_ScalarType
Const PHY_FIXEPOINT88:PHY_ScalarType
Const PHY_UCHAR:PHY_ScalarType

Class btHeightfieldTerrainShape Extends btConcaveShape

	Method New( heightStickWidth:Int,heightStickLength:Int,heightfieldData:Void Ptr,heightScale:btScalar,minHeight:btScalar,maxHeight:btScalar,upAxis:Int,heightDataType:PHY_ScalarType,flipQuadEdges:Bool )

	Method setUseDiamondSubdivision( useDiamondSubdivision:Bool=True )	

	Method setUseZigZagSubdivision( useZigZagSubdivision:Bool=True )	
End

Class btTriangleMeshShape Extends btConcaveShape

End

Class btBvhTriangleMeshShape Extends btTriangleMeshShape

	Method New( meshInterface:btStridingMeshInterface,useQuantizedAabbCompression:Bool,buildBvh:Bool=True )

End

Class btStridingMeshInterface Extends btObject

End

Class btTriangleIndexVertexArray Extends btStridingMeshInterface

	Method New( numTriangles:Int,triangleIndexBase:Int Ptr,triangleIndexStride:Int,numVertices:Int,vertexBase:btScalar Ptr,vertexStride:Int )
	

End

Class btMotionState Extends btObject
	
	Method setWorldTransform( worldTrans:btTransform )
		
	Method getWorldTransform:btTransform() Extension="bbBullet::getWorldTransform"
	
End

Class btDefaultMotionState Extends btMotionState

	Field m_graphicsWorldTrans:btTransform
 
	Field m_centerOfMassOffset:btTransform
 
	Field m_startWorldTrans:btTransform
	
	Field m_userPointer:Void Ptr
	
'	Method New()
	
 	Method New( startTrans:btTransform=btTransform.getIdentity(),centerOfMassOffset:btTransform=btTransform.getIdentity() )

End

Const CF_STATIC_OBJECT:Int
Const CF_KINEMATIC_OBJECT:Int
Const CF_NO_CONTACT_RESPONSE:Int
Const CF_CUSTOM_MATERIAL_CALLBACK:Int
Const CF_CHARACTER_OBJECT:Int
Const CF_DISABLE_VISUALIZE_OBJECT:Int
Const CF_DISABLE_SPU_COLLISION_PROCESSING:Int
 	
Class btCollisionObject Extends btObject

	Method setWorldTransform( transform:btTransform )
	
	Method getWorldTransform:btTransform()
	
	Method setRestitution( restitution:btScalar )
	
	Method getRestitution:btScalar()
	
	Method setFriction( friction:btScalar )
	
	Method getFriction:btScalar()
	
	Method setRollingFriction( friction:btScalar )
	
	Method getRollingFriction:btScalar()
	
	Method setCcdSweptSphereRadius( radius:btScalar )
	
	Method getCcdSweptSphereRadius:btScalar()
	
	Method setCcdMotionThreshold( ccdMotionTheshold:btScalar )
	
	Method getCcdMotionThreshold:btScalar()
	
	Method setCollisionFlags( flags:Int )
	
	Method getCollisionFlags:Int()
End

Struct btRigidBodyConstructionInfo
	
	Field m_mass:btScalar
	Field m_motionState:btMotionState
	Field m_startWorldTransform:btTransform
	Field m_collisionShape:btCollisionShape
	Field m_localInertia:btVector3
	Field m_linearDamping:btScalar
	Field m_angularDamping:btScalar
	Field m_friction:btScalar
	Field m_rollingFriction:btScalar
	Field m_restitution:btScalar

	Field m_linearSleepingThreshold:btScalar
	Field m_angularSleepingThreshold:btScalar
	Field m_additionalDamping:Bool
	Field m_additionalDampingFactor:btScalar
	Field m_additionalLinearDampingThresholdSqr:btScalar
	Field m_additionalAngularDampingThresholdSqr:btScalar
	Field m_additionalAngularDampingFactor:btScalar
	
	Method New( mass:btScalar,motionState:btMotionState,collisionShape:btCollisionShape,localInertia:btVector3=New btVector3( 0,0,0 ) )
End
	
Class btRigidBody Extends btCollisionObject

	Method New( constructionInfo:btRigidBodyConstructionInfo )

	Method New( mass:btScalar,motionState:btMotionState,collisionShape:btCollisionShape,localInertia:btVector3=New btVector3( 0,0,0 ) )
	
	Method setLinearVelocity( lin_vel:btVector3 )
	
	Method getLinearVelocity:btVector3()
End

Function BulletKludge1( obj:btCollisionObject )="bbBullet::bulletKludge1"

