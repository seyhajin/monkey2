
Namespace mojo3d

Enum ComponentTypeFlags
	
	Singleton=1
End

Class ComponentType
	
	Method New( name:String,priority:int,flags:ComponentTypeFlags )
		
		_name=name
		
		_priority=priority
		
		_flags=flags
	End
	
	Property Name:String()
		
		Return _name
	End
	
	Property Priority:Int()
		
		Return _priority
	End
	
	Property Flags:ComponentTypeFlags()
		
		Return _flags
	End
	
	Private
	
	Field _name:String
	
	Field _priority:Int
	
	Field _flags:ComponentTypeFlags
End

Class Component
	
	Method New( entity:Entity,type:ComponentType )
		
		_entity=entity
		_type=type
		_entity.AddComponent( Self )
	End
	
	Property Entity:Entity()
		
		Return _entity
	End
	
	Property Type:ComponentType()
		
		Return _type
	End
	
Internal

	Method OnCopy:Component( entity:Entity ) Virtual

		RuntimeError( "Don't know how to copy component of type "+Type.Name )
		
		Return Null
	End
	
	Method OnShow() virtual
	End
	
	Method OnHide() Virtual
	End
	
	Method OnBeginUpdate() Virtual
	End
	
	Method OnUpdate( elapsed:Float ) Virtual
	End
	
	Method OnDestroy() Virtual
	End
	
	Method OnCollide( body:RigidBody ) virtual
	End
	
	Private
	
	Field _entity:Entity
	Field _type:ComponentType
End



