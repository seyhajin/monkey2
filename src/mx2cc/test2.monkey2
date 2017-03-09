Namespace bullet

#Import "<libc>"
#Import "<std>"

Using std.geom

Extern

Struct btVector3
	
	Field x:Float="m_floats[0]"
	Field y:Float="m_floats[1]"
	Field z:Float="m_floats[2]"
	
	Method New()
	
	Method New( x:Float,y:Float,z:Float )
	
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
End
Class btDiscreteDynamicsWorld Extends btDynamicsWorld
	
	Method New( dispatcher:btDispatcher,pairCache:btBroadphaseInterface,contraintSolver:btConstraintSolver,collisionConfiguration:btCollisionConfiguration )
		
End

Public

Struct Vec3<T> Extension
	
	Operator To:btVector3()
		Return New btVector3( x,y,z )
	End

End
