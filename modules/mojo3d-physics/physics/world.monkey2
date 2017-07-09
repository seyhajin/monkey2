
Namespace mojo3d.physics

Class World
	
	Method New()
		
		Local broadphase:=New btDbvtBroadphase()
		
		Local config:=New btDefaultCollisionConfiguration()

		Local dispatcher:=New btCollisionDispatcher( config )
		
		Local solver:=New btSequentialImpulseConstraintSolver()
		
		_btworld=New btDiscreteDynamicsWorld( dispatcher,broadphase,solver,config )
		
		Gravity=New Vec3f( 0,-9.81,0 )
		
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
	
	Function GetDefault:World()
	
		Global _default:=New World
		
		Return _default
	End

	'***** INTERNAL *****
		
	Method Add( body:RigidBody )
		
		_bodies.Add( body )
		
		_btworld.addRigidBody( body.btBody )
	End
	
	Method Remove( body:RigidBody )
		
		_bodies.Remove( body )

		_btworld.removeRigidBody( body.btBody )
	End
		
	Private
	
	Field _btworld:btDynamicsWorld
	
	Field _newBodies:=New Stack<RigidBody>
	
	Field _bodies:=New Stack<RigidBody>
	
End
