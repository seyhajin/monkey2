Namespace mojo3d

Class Constraint Extends Component
	
	Const Type:=New ComponentType( "Constraint",-20,ComponentTypeFlags.Singleton )
	
	Method New( entity:Entity )
		
		Super.New( entity,Type )
	End
	
	Method New( entity:Entity,constraint:Constraint )
		
		Super.New( entity,Type )
	End
	
Protected

	Field _rvisible:Bool

	Field _btconstraint:btTypedConstraint
	
	Method OnCreate() Abstract
	
	Method OnBeginUpdate() Override
		
		Validate()
	End

	Method OnDestroy() Override
		
		If Not _btconstraint Return
		
		Entity.Scene.World.btWorld.removeConstraint( _btconstraint )
		_btconstraint.destroy()
		_btconstraint=Null
	End
	
	Method Validate()

		Local rvisible:=Entity.ReallyVisible
		
		If rvisible=_rvisible Return
		
		If rvisible
			If Not _btconstraint OnCreate()
			Entity.Scene.World.btWorld.addConstraint( _btconstraint )
		Else
			If _btconstraint Entity.Scene.World.btWorld.removeConstraint( _btconstraint )
		Endif
		
		_rvisible=rvisible
	End
	
End

Class PointToPointConstraint Extends Constraint
	
	Method New( entity:Entity )
		
		Super.New( entity )
		
		AddInstance()
	End
	
	Method New( entity:Entity,constraint:PointToPointConstraint )
		
		Super.New( entity,constraint )
		
		Pivot=constraint.Pivot
		ConnectedBody=constraint.ConnectedBody
		ConnectedPivot=constraint.ConnectedPivot
		
		AddInstance( constraint )
	End
	
	[jsonify=1]
	Property Pivot:Vec3f()
		
		Return _pivot1
		
	Setter( pivot:Vec3f )
		
		_pivot1=pivot
	End
	
	[jsonify=1]
	Property ConnectedBody:RigidBody()
		
		Return _connected
		
	Setter( body:RigidBody )
		
		_connected=body
	End
	
	[jsonify=1]
	Property ConnectedPivot:Vec3f()
	
		Return _pivot2
	
	Setter( pivot:Vec3f )
		
		_pivot2=pivot
	End
	
	Protected
	
	Field _connected:RigidBody
	Field _pivot1:Vec3f
	Field _pivot2:Vec3f
	
	Method OnCreate() Override
		
		Local btBody1:=Entity.GetComponent<RigidBody>().btBody
		Assert( btBody1,"PointToPointConstraint: No rigid body" )
		
		If _connected
			Local btBody2:=_connected.btBody
			Assert( btBody2,"PointToPointConstraint: No rigid body" )
			_btconstraint=New btPoint2PointConstraint( btBody1,btBody2,_pivot1,_pivot2 )
		Else
			_btconstraint=New btPoint2PointConstraint( btBody1,_pivot1 )
		End
	End
		
End
