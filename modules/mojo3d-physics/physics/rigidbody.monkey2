
Namespace mojo3d.physics

#Import "native/kinematicmotionstate.h"

Extern Private

Class bbKinematicMotionState Extends btMotionState
	
	Method GetWorldTransform:btTransform() Abstract="getWorldTransform"
	
End

Private

Class KinematicMotionState Extends bbKinematicMotionState
	
	Method New( entity:Entity )
		
		_entity=entity
	End
	
	Method GetWorldTransform:btTransform() Override
		
		Return _entity.Matrix
	End
	
Private
	
	Field _entity:Entity
End

Public

Class RigidBody Extends Component
	
	Const Type:=New ComponentType( "RigidBody",1,ComponentTypeFlags.Singleton )
	
	Method New( entity:Entity )
		
		Super.New( entity,Type )
	End
	
	Property World:World()
		
		Return World.GetWorld( Entity.Scene )
	End
	
	Property Kinematic:Bool()
		
		Return _kinematic
	
	Setter( kinematic:Bool )
		
		_kinematic=kinematic
	End
	
	Property Mass:Float()
		
		Return _mass
		
	Setter( mass:Float )
		
		_mass=mass
	End

	Property Friction:Float()
		
		Return _friction
	
	Setter( friction:Float )
		
		_friction=friction
	End
	
	Property RollingFriction:Float()
		
		Return _rfriction
	
	Setter( friction:Float )
		
		_rfriction=friction
	End
	
	Property Restitution:Float()
	
		Return _restitution
		
	Setter( restitution:Float )
		
		_restitution=restitution
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
	
	Method OnCopy:RigidBody( entity:Entity ) Override
		
		Local body:=New RigidBody( entity )
		
		body.Kinematic=Kinematic
		body.Mass=Mass
		body.Friction=Friction
		body.RollingFriction=RollingFriction
		body.Restitution=Restitution
		body.CollisionGroup=CollisionGroup
		body.CollisionMask=CollisionMask
		
		Return body
	End

	Method OnBeginUpdate() Override
		
		If Not _btbody
			Validate()
			Return
		End
		
		If _kinematic Return
	
		If _seq=Entity.Seq Return

		_btbody.clearForces()
		_btbody.setLinearVelocity( New Vec3f( 0 ) )
		_btbody.setAngularVelocity( New Vec3f( 0 ) )
		_btbody.setWorldTransform( Entity.Matrix )
		_btmotion.setWorldTransform( Entity.Matrix )
	End
	
	Method OnUpdate( elapsed:Float ) Override
		
		If _kinematic Return
		
		Local tform:=_btmotion.getWorldTransform()
		
		Entity.Position=tform.getOrigin()
		
		Entity.Basis=tform.getBasis()
		
		_seq=Entity.Seq
	End
	
	Method OnDestroy() Override
		
		If Not _btbody Return
		
		World.GetCurrent().Remove( Self )
		
		_btbody=Null
	End
	
	Internal
	
	Method Validate:btRigidBody()
		
		If _btbody Return _btbody

		If _kinematic		
			_btmotion=New KinematicMotionState( Entity )
		Else
			_btmotion=New btDefaultMotionState( Entity.Matrix )
		Endif
		
		Local collider:=Entity.GetComponent<Collider>()
		
		Local inertia:btVector3=collider ? collider.CalculateLocalInertia( _mass ) Else Null
		
		_btbody=New btRigidBody( _mass,_btmotion,collider.btShape,inertia )

		If _kinematic
			_btbody.setCollisionFlags( _btbody.getCollisionFlags() | btCollisionObject.CF_KINEMATIC_OBJECT )
			_btbody.setActivationState( DISABLE_DEACTIVATION )
		Endif
		
		_btbody.setFriction( _friction )
		_btbody.setRollingFriction( _rfriction )
		_btbody.setRestitution( _restitution )
		
		World.Add( Self )
		
		Return _btbody
	End
	
	Private

	Field _kinematic:Bool=False
	Field _mass:Float=1
	Field _friction:Float=1
	Field _rfriction:Float=1
	Field _restitution:Float=0
	Field _collGroup:Short=1
	Field _collMask:Short=1
	
	Field _btmotion:btMotionState
	Field _btbody:btRigidBody
	Field _seq:Int

End
