
#rem

Notes:

* Have to remove/add bodies from world if collision shape changes. http://bulletphysics.org/Bullet/phpBB3/viewtopic.php?t=5194

* default btCollsionObject activationState=ACTIVE_TAG (1)?

#end

Namespace mojo3d

Private

Class MotionState Extends btMotionState
	
	Method New( entity:Entity )
		
		_entity=entity
	End
	
	Method getWorldTransform( tform:btTransform Ptr ) Override
		
		If Not _entity.RigidBody.Kinematic Print "Dynamic getWorldTransform! Position="+_entity.Position

		tform->setOrigin( _entity.Position )
		
		tform->setBasis( _entity.Basis )
	End
	
	Method setWorldTransform( tform:btTransform Ptr ) Override
		
		If _entity.RigidBody.Kinematic Print "Kinematic setWorldTransform!"
		
		_entity.Position=tform->getOrigin()
		
		_entity.Basis=tform->getBasis()
	End
	
	Private
	
	Field _entity:Entity
End

Public

Class Entity Extension
	
	Property RigidBody:RigidBody()
		
		Return GetComponent<RigidBody>()
	End
	
End

Class RigidBody Extends Component
	
	Const Type:=New ComponentType( "RigidBody",1,ComponentTypeFlags.Singleton )
	
	Method New( entity:Entity )
		
		Super.New( entity,Type )
		
		Local collider:=entity.Collider
		Local inertia:btVector3=collider?.CalculateLocalInertia( _mass )
		
		_btmotion=New MotionState( entity )
		
		_btbody=New btRigidBody( _mass,_btmotion,collider.btShape,inertia )
		
		Kinematic=False
		Mass=1
		Friction=1
		RollingFriction=1
		Restitution=0
		CollisionGroup=1
		CollisionMask=1
	End
	
	Method New( entity:Entity,body:RigidBody )
		
		Self.New( entity )
		
		Kinematic=body.Kinematic
		Mass=body.Mass
		Friction=body.Friction
		RollingFriction=body.RollingFriction
		Restitution=body.Restitution
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
			
'		_dirty|=Dirty.Kinematic
	End
	
	Property Mass:Float()
		
		Return _mass
		
	Setter( mass:Float )
		
		If mass=_mass Return
		
		_mass=mass
		
		Local collider:=Entity.Collider
		Local inertia:=collider?.CalculateLocalInertia( _mass )
		_btbody.setMassProps( _mass,inertia )
		
'		_dirty|=Dirty.Mass
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
	
	Property Restitution:Float()
		
		Return _btbody.getRestitution()
		
	Setter( restitution:Float )
		
		_btbody.setRestitution( restitution )
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
	End
	
	Property CollisionMask:Short()
		
		Return _collMask
		
	Setter( collMask:Short )
		
		_collMask=collMask
	End
	
	Property btBody:btRigidBody()
	
		Return _btbody
	End
	
	Method ClearForces()

		_btbody.clearForces()
	End

	Protected
	
	Method OnCopy:RigidBody( entity:Entity ) Override
		
		Return New RigidBody( entity,Self )
	End

	Method OnBeginUpdate() Override
		
'		Validate()
		
		Local collider:=Entity.Collider
		
		Local seq:=collider?.Seq
		
		If seq<>_colliderseq
			
			If _rvisible
				If Entity.ReallyVisible 
					World.btWorld.removeRigidBody( _btbody )
				Else
					_rvisible=False
					World.Remove( Self )
				Endif
			Endif
			
			_btbody.setCollisionShape( collider?.btShape )
			Local inertia:btVector3=collider?.CalculateLocalInertia( _mass )
			_btbody.setMassProps( _mass,inertia )
			
			If _rvisible World.btWorld.addRigidBody( _btbody )
			
			_colliderseq=seq
			
		Endif
			
		If Entity.ReallyVisible<>_rvisible
			
			_rvisible=Entity.ReallyVisible

			If _rvisible World.Add( Self ) Else World.Remove( Self )
				
		Endif

		If Not _kinematic And Entity.Seq<>_seq 
			
			_btbody.setWorldTransform( Entity.Matrix )
		Endif
		
	End
	
	Method OnUpdate( elapsed:Float ) Override
		
'		If _kinematic Return
		
'		Local tform:=_btbody.getWorldTransform()
		
'		Entity.Position=tform.getOrigin()
		
'		Entity.Basis=tform.getBasis()
		
		_seq=Entity.Seq
	End
	
	Method OnDestroy() Override
		
		If Not _rvisible Return
		
		_rvisible=False
		
		World.Remove( Self )
	End
	
	Internal
	
	Property World:World()
		
		Return Entity.Scene.World
	End
	
	Private
	
	Enum Dirty
		Mass=1
		Kinematic=2
	End
	
	Field _kinematic:Bool=False
	Field _mass:Float=1
	Field _collGroup:Short=1
	Field _collMask:Short=1

	Field _btmotion:MotionState
	Field _btbody:btRigidBody
	Field _dirty:Dirty=Null
	
	Field _colliderseq:Int
	Field _rvisible:Bool
	Field _seq:Int
	
	Method Validate()
		
		If Not _dirty Return
		
		If _dirty & Dirty.Mass

			Local collider:=Entity.Collider
			Local inertia:btVector3=collider?.CalculateLocalInertia( _mass )
			_btbody.setMassProps( _mass,inertia )
		Endif
		
		If _dirty & Dirty.Kinematic
			
			If _kinematic
				_btbody.setCollisionFlags( _btbody.getCollisionFlags() | btCollisionObject.CF_KINEMATIC_OBJECT )
				_btbody.setActivationState( DISABLE_DEACTIVATION )
			Else
				_btbody.setCollisionFlags( _btbody.getCollisionFlags() & ~btCollisionObject.CF_KINEMATIC_OBJECT )
				_btbody.forceActivationState( ACTIVE_TAG )
			Endif
		Endif
		
		_dirty=Null
	End
End
