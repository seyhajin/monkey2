
Namespace mojo3d.graphics

#rem monkeydoc The LightType enumeration.

Note: Only directional lights are currently fully supported.

| LightType		| Description
|:--------------|:-----------
| `Directional`	| Light at infinity.
| `Point`		| Point light.
| `Spot`		| Spot light.
#end
Enum LightType
	Directional=1
	Point=2
	Spot=3
End

#rem monkeydoc The Light class.
#end
Class Light Extends Entity

	#rem monkeydoc Creates a new light.
	#end
	Method New( parent:Entity=Null )
		Super.New( parent )
		
		Type=LightType.Directional
		Color=Color.White
		Range=10
		CastsShadow=False
		
		Show()
	End
	
	#rem monkeydoc Copies the light.
	#end
	Method Copy:Light( parent:Entity=Null ) Override
		
		Local copy:=New Light( Self,parent )
		
		CopyComplete( copy )
		
		Return copy
	End
	
	#rem monkeydoc Light shadows enabled flag.
	#end
	Property CastsShadow:Bool()
		
		Return _castsShadow
		
	Setter( shadows:Bool )
		
		_castsShadow=shadows
	End
	
	#rem monkeydoc The light type.
	#end
	Property Type:LightType()
		
		Return _type
	
	Setter( type:LightType )
		
		_type=type
	End
	
	#rem monkeydoc The light color.
	#end
	Property Color:Color()
	
		Return _color
	
	Setter( color:Color )
	
		_color=color
	End
	
	#rem monkeydoc The light range.
	#end
	Property Range:Float()
	
		Return _range
	
	Setter( range:Float )
	
		_range=range
	End
	
	Protected

	#rem monkeydoc @hidden
	#end	
	Method New( light:Light,parent:Entity )
		Super.New( light,parent )
		
		Type=light.Type
		Color=light.Color
		Range=light.Range
		
		Show()
	End
	
	#rem monkeydoc @hidden
	#end	
	Method OnShow() Override
		Scene.Lights.Add( Self )
	End
	
	#rem monkeydoc @hidden
	#end	
	Method OnHide() Override
		Scene.Lights.Remove( Self )
	End

	Private
	
	Field _type:LightType
	
	Field _color:Color
	
	Field _range:Float
	
	Field _castsShadow:bool

End
