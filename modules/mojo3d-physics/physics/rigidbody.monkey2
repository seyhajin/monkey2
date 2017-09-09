
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
		
		Return _entity.Matrix
	End
	
Private
	
	Field _entity:Entity
End

Class Entity Extension

	Property RigidBody:RigidBody()
	
		Return GetDynamicProperty<RigidBody>( "$rigidBody" )
	End
	
End

#rem monkeydoc The RigidBody class.
#end
Class RigidBody
	
	Method Init( collider:Collider,entity:Entity,mass:Float,collGroup:Int,collMask:Int,btmotion:btMotionState )
	
		Local inertia:btVector3=collider ? collider.CalculateLocalInertia( mass ) Else Null

		_collider=collider
		_entity=entity
		_mass=mass
		_collGroup=collGroup
		_collMask=collMask
		_btmotion=btmotion

		_btbody=New btRigidBody( mass,btmotion,collider.btShape,inertia )
		
		_btbody.setFriction( 1 )
		_btbody.setRollingFriction( 1 )
		_btbody.setRestitution( 0 )

		'If Cast<MeshCollider>( _collider ) _btbody.setCollisionFlags( _btbody.getCollisionFlags() | btCollisionObject.CF_CUSTOM_MATERIAL_CALLBACK )
			
		If Not _entity Return
		
		_entity.SetDynamicProperty( "$rigidBody",Self )

		Local world:=entity.Scene.World
		
		_entity.Shown+=Lambda()
		
			world.Add( Self )
		End
		
		_entity.Hidden+=Lambda()
		
			world.Remove( Self )
		End
		
		If _entity.Visible world.Add( Self )
	End

	Property Collider:Collider()
		
		Return _collider
	End
	
	Property Entity:Entity()
	
		Return _entity
	End
	
	Property CollisionGroup:Short()
		
		Return _collGroup
	End
	
	Property CollisionMask:Short()
		
		Return _collMask
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
	
	Property btBody:btRigidBody()
	
		Return _btbody
	End
	
Protected

	Field _mass:Float	
	Field _collider:Collider
	Field _entity:Entity
	Field _collGroup:Int
	Field _collMask:Int
	
	Field _btmotion:btMotionState
	Field _btbody:btRigidBody
	Field _seq:Int
	
	Method OnValidate() Virtual
	End
	
	Method OnUpdate() Virtual
	End
	
Internal
		
	Method Validate()
		
		If _entity OnValidate()
	End
	
	Method Update()
		
		If _entity OnUpdate()
	End
	
End

Class StaticBody Extends RigidBody
	
	Method New( collider:Collider,entity:Entity,collGroup:Int=1,collMask:Int=1 )
		
		Init( collider,entity,0,collGroup,collMask,Null )
		
		If entity entity.Copied+=Lambda( copy:Entity )
		
			Local body:=New StaticBody( collider,copy,collGroup,collMask )
			
			body.Friction=Friction
			body.RollingFriction=RollingFriction
			body.Restitution=Restitution
		End
		
	End
	
Protected
	
	Method OnValidate() Override
		
		If _seq=_entity.Seq Return
		
		_btbody.setWorldTransform( _entity.Matrix )
	End
	
	Method OnUpdate() Override
		
		_seq=_entity.Seq
	End

End

Class KinematicBody Extends RigidBody
	
	Method New( collider:Collider,entity:Entity,collGroup:Int=1,collMask:Int=1 )

		Init( collider,entity,0,collGroup,collMask,entity ? New KinematicMotionState( entity ) Else Null )

		_btbody.setCollisionFlags( _btbody.getCollisionFlags() | btCollisionObject.CF_KINEMATIC_OBJECT )
		_btbody.setActivationState( DISABLE_DEACTIVATION )
		
		If entity entity.Copied+=Lambda( copy:Entity )
		
			Local body:=New KinematicBody( collider,copy,collGroup,collMask )

			body.Friction=Friction
			body.RollingFriction=RollingFriction
			body.Restitution=Restitution
		End

	End
	
Protected
	
	Method OnValidate() Override
	End
	
	Method OnUpdate() Override
	End
	
End

Class DynamicBody Extends RigidBody

	Method New( collider:Collider,entity:Entity,mass:Float=1,collGroup:Int=1,collMask:Int=1 )
		
		Init( collider,entity,mass,collGroup,collMask,entity ? New btDefaultMotionState( entity.Matrix ) Else null )
			
		If entity entity.Copied+=Lambda( copy:Entity )
		
			Local body:=New DynamicBody( collider,copy,mass,collGroup,collMask )

			body.Gravity=Gravity
			body.Friction=Friction
			body.RollingFriction=RollingFriction
			body.Restitution=Restitution
		End
	End
	
	Property Mass:Float()
		
		Return _mass
	End
	
	Property Gravity:Vec3f()
		
		Return _btbody.getGravity()
	
	Setter( gravity:Vec3f )
		
		_btbody.setGravity( gravity )
	End
	
	Property LinearVelocity:Vec3f()
	
		Return _btbody.getLinearVelocity()
	
	Setter( velocity:Vec3f )
	
		_btbody.setLinearVelocity( velocity )
	End
	
	Property AngularVelocity:Vec3f()
		
		Return _btbody.getAngularVelocity()
	
	Setter( velocity:Vec3f )
		
		_btbody.setAngularVelocity( velocity )
	End
	
	Method ApplyForce( force:Vec3f,relativePos:Vec3f )
		
		_btbody.applyForce( force,relativePos )
	End
	
	Method ApplyCentralForce( force:Vec3f )
		
		_btbody.applyCentralForce( force )
	End
	
	Method ApplyTorque( torque:Vec3f )
		
		_btbody.applyTorque( torque )
	End
	
	Method ApplyImpulse( impulse:Vec3f,relativePos:Vec3f )
		
		_btbody.applyImpulse( impulse,relativePos )
	End
	
	Method ApplyCentralImpulse( impulse:Vec3f )
		
		_btbody.applyCentralImpulse( impulse )
	End
	
	Method ApplyTorqueImpulse( torque:Vec3f )
		
		_btbody.applyTorqueImpulse( torque )
	End
	
Protected
	
	Method OnValidate() Override
		
		If _seq=_entity.Seq Return
		
		_btbody.clearForces()
		
		_btbody.setLinearVelocity( New Vec3f( 0 ) )
		
		_btbody.setAngularVelocity( New Vec3f( 0 ) )
		
		_btbody.setWorldTransform( _entity.Matrix )
		
		_btmotion.setWorldTransform( _entity.Matrix )
	End
	
	Method OnUpdate() Override
		
		Local tform:=_btmotion.getWorldTransform()
		
		_entity.Position=tform.getOrigin()
		
		_entity.Basis=tform.getBasis()
		
		_seq=_entity.Seq
	End

End
