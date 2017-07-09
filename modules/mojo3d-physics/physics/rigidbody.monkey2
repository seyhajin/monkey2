
Namespace mojo3d.physics

#Import "native/kinematicmotionstate.h"

Extern

Class bbKinematicMotionState Extends btMotionState
	
	Method GetWorldTransform:btTransform() Abstract="getWorldTransform"
	
End

Public

Class KinematicMotionState Extends bbKinematicMotionState
	
	Method New( entity:Entity )
		
		_entity=entity
	End
	
	Method GetWorldTransform:btTransform() Override
		
		Return _entity.WorldMatrix
	End
	
	Private
	
	Field _entity:Entity
End

#rem monkeydoc The RigidBody class.
#end
Class RigidBody
	
	#rem monkeydoc Creates a new rigid body.
	#end
	Method New( mass:Float,collider:Collider,entity:Entity,kinematic:Bool=False )
		
		_mass=mass
		_collider=collider
		_entity=entity
		_kinematic=kinematic
		_world=World.GetDefault()
		
		If _kinematic
			_btmotion=New KinematicMotionState( _entity )
		Else
			_btmotion=New btDefaultMotionState( _entity.WorldMatrix )
		Endif

		Local inertia:btVector3=_collider ? _collider.btShape.calculateLocalInertia( _mass ) Else New btVector3( 0,0,0 )
		
		_btbody=New btRigidBody( _mass,_btmotion,_collider.btShape,inertia )
			
		If _kinematic 
			_btbody.setCollisionFlags( _btbody.getCollisionFlags() | btCollisionObject.CF_KINEMATIC_OBJECT )
			_btbody.setActivationState( DISABLE_DEACTIVATION )
		Endif
		
		If Cast<MeshCollider>( _collider ) _btbody.setCollisionFlags( _btbody.getCollisionFlags() | btCollisionObject.CF_CUSTOM_MATERIAL_CALLBACK )

		_entity.Shown+=Lambda()
		
			_world.Add( Self )
		End
		
		_entity.Hidden+=Lambda()
		
			_world.Remove( Self )
		End
		
		_entity.Copied+=Lambda( copy:Entity )
		
			Local body:=New RigidBody( Mass,Collider,copy )
			
			body.LinearVelocity=LinearVelocity
			body.Restitution=Restitution
			body.Friction=Friction
			body.RollingFriction=RollingFriction
		End
		
		If _entity.Visible _world.Add( Self )
			
		Restitution=0
		Friction=1
		RollingFriction=0
	End

	Property Mass:Float()
		
		Return _mass
	End
	
	Property Collider:Collider()
		
		Return _collider
	End
	
	Property Entity:Entity()
	
		Return _entity
	End
	
	Property LinearVelocity:Vec3f()
	
		Return _btbody.getLinearVelocity()
	
	Setter( velocity:Vec3f )
	
		_btbody.setLinearVelocity( velocity )
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
	
	'***** INTERNAL *****
	
	Property btBody:btRigidBody()
	
		Return _btbody
	End
	
	Method Validate()
		
		If _kinematic Or _seq=_entity.Seq Return
		
		_btbody.setWorldTransform( _entity.WorldMatrix )
		
		_btmotion.setWorldTransform( _entity.WorldMatrix )
	End
	
	Method Update()
		
		If _kinematic Return
	
		Local tform:=_btmotion.getWorldTransform()
		
		_entity.WorldPosition=tform.getOrigin()
		
		_entity.WorldBasis=tform.getBasis()
		
		_seq=_entity.Seq
	End

Private

	Field _mass:Float	
	Field _collider:Collider
	Field _entity:Entity
	Field _kinematic:Bool
	Field _world:World
	Field _seq:Int
	
	Field _btmotion:btMotionState
	Field _btbody:btRigidBody
	
End

