
Namespace mojo3d.physics

#Import "native/objecthandle.h"

Extern

Function object_to_handle:Void Ptr( obj:Object )="bb_object_to_handle"

Function handle_to_object:Object( handle:Void Ptr )="bb_handle_to_object"

Public

Class Scene Extension

	Property World:World()
	
		Local world:=GetDynamicProperty<World>( "$world" )
		If Not world
			world=New World( Self )
			SetDynamicProperty( "$world",world )
		Endif
		Return world
	End

End

Class RaycastResult

	Field time:Float
	Field body:RigidBody
	Field point:Vec3f
	Field normal:Vec3f
	
	Method New()
	End
	
	Method New( btresult:btCollisionWorld.ClosestRayResultCallback Ptr )
		time=btresult->m_closestHitFraction
		body=Cast<RigidBody>( handle_to_object( btresult->m_collisionObject.getUserPointer() ) )
		point=btresult->m_hitPointWorld
		normal=btresult->m_hitNormalWorld
	End
	
	Method New( btresult:btCollisionWorld.ClosestConvexResultCallback Ptr )
		
		Local castFrom:=Cast<Vec3f>( btresult->m_convexFromWorld )
		Local castTo:=Cast<Vec3f>( btresult->m_convexToWorld )
		
		time=btresult->m_closestHitFraction
		body=Cast<RigidBody>( handle_to_object( btresult->m_hitCollisionObject.getUserPointer() ) )
		point=(castTo-castFrom) * btresult->m_closestHitFraction + castFrom
		normal=btresult->m_hitNormalWorld
	End
	
End

Class World
	
	Method New( scene:Scene )
	
		_scene=scene
		
		Local broadphase:=New btDbvtBroadphase()
		
		Local config:=New btDefaultCollisionConfiguration()

		Local dispatcher:=New btCollisionDispatcher( config )
		
		Local solver:=New btSequentialImpulseConstraintSolver()
		
		_btworld=New btDiscreteDynamicsWorld( dispatcher,broadphase,solver,config )

		Gravity=New Vec3f( 0,-9.81,0 )
		
	End
	
	Property Scene:Scene()
	
		Return _scene
	End

	Property Gravity:Vec3f()
	
		Return _btworld.getGravity()
		
	Setter( gravity:Vec3f )
	
		_btworld.setGravity( gravity )
	End
	
	Method Update()

		For Local body:=Eachin _bodies
		
			body.Validate()
		Next
		
		_btworld.stepSimulation( 1.0/60.0 )
		
		For Local body:=Eachin _bodies
		
			body.Update()
		Next
		
	End
	
	Method RayCast:RaycastResult( rayFrom:Vec3f,rayTo:Vec3f )
		
		Local btresult:=New btCollisionWorld.ClosestRayResultCallback( rayFrom,rayTo )
		
		_btworld.rayTest( rayFrom,rayTo,Cast<btCollisionWorld.RayResultCallback Ptr>( Varptr btresult ) )
		
		If Not btresult.hasHit() Return Null
		
		Return New RaycastResult( Varptr btresult )
	End
	
	Method ConvexSweep:RaycastResult( collider:ConvexCollider,castFrom:AffineMat4f,castTo:AffineMat4f )
		
		Local btresult:=New btCollisionWorld.ClosestConvexResultCallback( castFrom.t,castTo.t )
		
		_btworld.convexSweepTest( Cast<btConvexShape>( collider.btShape ),castFrom,castTo,Cast<btCollisionWorld.ConvexResultCallback Ptr>( Varptr btresult ),0 )
		
		If Not btresult.hasHit() Return Null
		
		Return New RaycastResult( Varptr btresult )
	End
	
	Method ConvexSweep:RaycastResult( collider:ConvexCollider,castFrom:Vec3f,castTo:Vec3f )
		
		Return ConvexSweep( collider,AffineMat4f.Translation( castFrom ),AffineMat4f.Translation( castTo ) )
	End
	
	Internal
	
	Method Add( body:RigidBody )
		
		_bodies.Add( body )
		
		_btworld.addRigidBody( body.btBody,body.CollisionGroup,body.CollisionMask )
		
		body.btBody.setUserPointer( object_to_handle( body ) )
	End
	
	Method Remove( body:RigidBody )
		
		_bodies.Remove( body )

		_btworld.removeRigidBody( body.btBody )

		body.btBody.setUserPointer( Null )
	End
	
	Private
	
	Field _scene:Scene
	
	Field _btworld:btDynamicsWorld
	
	Field _newBodies:=New Stack<RigidBody>
	
	Field _bodies:=New Stack<RigidBody>
	
End
