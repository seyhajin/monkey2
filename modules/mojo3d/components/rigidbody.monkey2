
Namespace mojo3d

Private

Class MotionState Extends btMotionState
	
	Method New( entity:Entity )
		
		_entity=entity
	End
	
	Method getWorldTransform( tform:btTransform Ptr ) Override
		
'		If Not _entity.RigidBody.Kinematic Print "Dynamic getWorldTransform! Position="+_entity.Position

		tform->setOrigin( _entity.Position )
		
		tform->setBasis( _entity.Basis )
	End
	
	Method setWorldTransform( tform:btTransform Ptr ) Override
		
'		If _entity.RigidBody.Kinematic Print "Kinematic setWorldTransform!"
		
		_entity.Position=tform->getOrigin()
		
		_entity.Basis=tform->getBasis()
	End
	
	Private
	
	Field _entity:Entity
End

Public

Class Entity Extension
	
	Property RigidBody:RigidBody()
		
		Return Cast<RigidBody>( GetComponent( RigidBody.Type ) )
	End
	
End

Class RigidBody Extends Component
	
	Const Type:=New ComponentType( "RigidBody",-10,ComponentTypeFlags.Singleton )
	
	Method New( entity:Entity )
		
		Super.New( entity,Type )
		
		_btmotion=New MotionState( entity )
		
		Local collider:=entity.Collider
		Local inertia:btVector3=collider?.CalculateLocalInertia( _mass )
		
		_btbody=New btRigidBody( _mass,_btmotion,collider?.Validate(),inertia )
		
		Restitution=0
		RollingFriction=0
		Friction=1
		CollisionGroup=1
		CollisionMask=1
	End
	
	Method New( entity:Entity,body:RigidBody )
		
		Self.New( entity )
		
		Kinematic=body.Kinematic
		Mass=body.Mass
		Restitution=body.Restitution
		Friction=body.Friction
		RollingFriction=body.RollingFriction
		CollisionGroup=body.CollisionGroup
		CollisionMask=body.CollisionMask
	End

	Property Kinematic:Bool()
		
		Return _kinematic
	
	Setter( kinematic:Bool )
		
		If kinematic=_kinematic Return
		
		_kinematic=kinematic
		
		If _kinematic
			_btbody.setCollisionFlags( _btbody.getCollisionFlags() | btCollisionObject.CF_KINEMATIC_OBJECT )
			_btbody.setActivationState( DISABLE_DEACTIVATION )
		Else
			_btbody.setCollisionFlags( _btbody.getCollisionFlags() & ~btCollisionObject.CF_KINEMATIC_OBJECT )
			_btbody.forceActivationState( ACTIVE_TAG )
		Endif
	End
	
	Property Mass:Float()
		
		Return _mass
		
	Setter( mass:Float )
		
		If mass=_mass Return
		
		_mass=mass
		
		Local collider:=Entity.Collider
		Local inertia:=collider?.CalculateLocalInertia( _mass )
		
		_btbody.setMassProps( _mass,inertia )
	End

	Property Restitution:Float()
		
		Return _btbody.getRestitution()
		
	Setter( restitution:Float )
		
		_btbody.setRestitution( restitution )
	End
	
	Property Friction:Float()
		
		Return _btbody.getFriction()
	
	Setter( friction:Float )
		
		_btbody.setFriction( friction )
	End
	
	Property RollingFriction:Float()
		
		Return _btbody.getRollingFriction()
	
	Setter( friction:Float )
		
		_btbody.setRollingFriction( friction )
	End
	
	Property LinearVelocity:Vec3f()
		
		Return _btbody.getLinearVelocity()
		
	Setter( velocity:Vec3f )
		
		_btbody.setLinearVelocity( velocity )
	End
	
	Property AngularVelocity:Vec3f()
		
		Return _btbody.getAngularVelocity()
	
	Setter( avelocity:Vec3f )
		
		_btbody.setAngularVelocity( avelocity )
	End

	Property CollisionGroup:Short()
		
		Return _collGroup
		
	Setter( collGroup:Short )
		
		_collGroup=collGroup
		
		_dirty|=Dirty.Collisions
	End
	
	Property CollisionMask:Short()
		
		Return _collMask
		
	Setter( collMask:Short )
		
		_collMask=collMask
		
		_dirty|=Dirty.Collisions
	End
	
	Property btBody:btRigidBody()
	
		Return _btbody
	End
	
	Method ClearForces()

		_btbody.clearForces()
	End

	Method ApplyForce( force:Vec3f )
		
		_btbody.applyCentralForce( force )
	End
	
	Method ApplyForce( force:Vec3f,offset:Vec3f )
		
		_btbody.applyForce( force,offset )
	End
	
	Method ApplyImpulse( impulse:Vec3f )
		
		_btbody.applyCentralImpulse( impulse )
	End
	
	Method ApplyImpulse( impulse:Vec3f,offset:Vec3f )
		
		_btbody.applyForce( impulse,offset )
	End
	
	Method ApplyTorque( torque:Vec3f )
		
		_btbody.applyTorque( torque )
	End
		
	Method ApplyTorqueImpulse( torque:Vec3f )

		_btbody.applyTorqueImpulse( torque )
	End
	
	Protected
	
	Method OnCopy:RigidBody( entity:Entity ) Override
		
		Return New RigidBody( entity,Self )
	End

	Method OnBeginUpdate() Override
		
		Validate()
		
		If Not _kinematic And Entity.Seq<>_seq 
			
			_btbody.setWorldTransform( Entity.Matrix )
		Endif
		
	End
	
	Method OnUpdate( elapsed:Float ) Override
		
		_seq=Entity.Seq
	End
	
	Method OnDestroy() Override
		
		If Not _rvisible Return
		
		World.Remove( Self )
		
		_rvisible=False
	End
	
	Internal
	
	Method ColliderInvalidated()
		
		_dirty|=Dirty.Collider
	End
	
	Property World:World()
		
		Return Entity.Scene.World
	End
	
	Private
	
	Enum Dirty
		Collider=1
		Collisions=2
	End
	
	Field _mass:Float=1
	Field _kinematic:Bool=False
	Field _collGroup:Short=1
	Field _collMask:Short=1

	Field _btmotion:MotionState
	Field _btbody:btRigidBody
	Field _dirty:Dirty=Null
	
	Field _colliderseq:Int
	Field _rvisible:Bool
	Field _seq:Int

	Method Validate()
		
		Local rvisible:=Entity.ReallyVisible
		
		If rvisible=_rvisible And Not _dirty Return
		
		If Not rvisible Return
		
		'Have to remove/add bodies from world if collision shape changes. http://bulletphysics.org/Bullet/phpBB3/viewtopic.php?t=5194
		'
		If _rvisible
			
			World.Remove( Self )
			
			_rvisible=False
		Endif
		
		If _dirty & Dirty.Collider
			
			Local collider:=Entity.Collider
			
			_btbody.setCollisionShape( collider?.Validate() )
			
			Local inertia:btVector3=collider?.CalculateLocalInertia( _mass )
			
			_btbody.setMassProps( _mass,inertia )
		Endif
	
		If _rvisible<>rvisible
			
			If rvisible World.Add( Self ) Else World.Remove( Self )
				
			_rvisible=rvisible
		Endif
	
		_dirty=Null
	End
	
End
