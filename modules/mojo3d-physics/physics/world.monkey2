
Namespace mojo3d.physics

Class RaycastResult

	Field time:Float
	Field body:RigidBody
	Field point:Vec3f
	Field normal:Vec3f
	
	Method New()
	End
	
	Method New( btresult:btCollisionWorld.ClosestRayResultCallback Ptr )
		time=btresult->m_closestHitFraction
		body=Cast<RigidBody>( btresult->m_collisionObject.getUserPointer() )
		point=btresult->m_hitPointWorld
		normal=btresult->m_hitNormalWorld
	End
	
	Method New( btresult:btCollisionWorld.ClosestConvexResultCallback Ptr )
		
		Local castFrom:=Cast<Vec3f>( btresult->m_convexFromWorld )
		Local castTo:=Cast<Vec3f>( btresult->m_convexToWorld )
		
		time=btresult->m_closestHitFraction
		body=Cast<RigidBody>( btresult->m_hitCollisionObject.getUserPointer() )
		point=(castTo-castFrom) * btresult->m_closestHitFraction + castFrom
		normal=btresult->m_hitNormalWorld
	End
	
End

Class World
	
	Method New( scene:Scene )
		
		Assert( scene.GetDynamicProperty<World>( "$world" )=Null,"World already exists" )
	
		_scene=scene
		
		_scene.SetDynamicProperty( "$world",Self )
		
		Local broadphase:=New btDbvtBroadphase()
		
		Local config:=New btDefaultCollisionConfiguration()

		Local dispatcher:=New btCollisionDispatcher( config )
		
		Local solver:=New btSequentialImpulseConstraintSolver()
		
		_btworld=New btDiscreteDynamicsWorld( dispatcher,broadphase,solver,config )

		Gravity=New Vec3f( 0,-9.81,0 )
		
		_scene.Updating+=OnUpdate
	End
	
	Property Scene:Scene()
	
		Return _scene
	End

	Property Gravity:Vec3f()
	
		Return _btworld.getGravity()
		
	Setter( gravity:Vec3f )
	
		_btworld.setGravity( gravity )
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
	
	Function GetCurrent:World()
		
		Return GetWorld( mojo3d.Scene.GetCurrent() )
	End
	
	Internal
	
	Function GetWorld:World( scene:Scene )
		
		Local world:=scene.GetDynamicProperty<World>( "$world" )
		
		If Not world world=New World( scene )
			
		Return world
	End
	
	Method Add( body:RigidBody )
		
		_bodies.Add( body )
		
		Local btbody:=body.Validate()
		
		btbody.setUserPointer( Cast<Void Ptr>( body ) )
		
		_btworld.addRigidBody( btbody,body.CollisionGroup,body.CollisionMask )
	End
	
	Method Remove( body:RigidBody )
		
		Local btbody:=body.Validate()
		
		_btworld.removeRigidBody( btbody )
		
		body.btBody.setUserPointer( Null )

		_bodies.Remove( body )
	End
	
	Private
	
	Field _scene:Scene
	
	Field _btworld:btDynamicsWorld
	
	Field _newBodies:=New Stack<RigidBody>
	
	Field _bodies:=New Stack<RigidBody>

	Method OnUpdate( elapsed:Float )
		
		_btworld.stepSimulation( 1.0/60.0 )
		
	End
	
End
