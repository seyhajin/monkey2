
Namespace mojo3d

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
		
		Name="Light"
		Type=LightType.Directional
		Texture=Null
		Range=10
		InnerAngle=15
		OuterAngle=30
		CastsShadow=False
		
		Visible=True
		
		AddInstance()
	End
	
	#rem monkeydoc Copies the light.
	#end
	Method Copy:Light( parent:Entity=Null ) Override
		
		Local copy:=OnCopy( parent )
		
		CopyTo( copy )
		
		Return copy
	End
	
	#rem monkeydoc The light type.
	#end
	[jsonify=1]
	Property Type:LightType()
		
		Return _type
	
	Setter( type:LightType )
		
		_type=type
	End
	
	[jsonify=1]
	Property Texture:Texture()
		
		Return _texture
	
	Setter( texture:Texture )
		
		_texture=texture
	End
	
	#rem monkeydoc Light shadows enabled flag.
	#end
	[jsonify=1]
	Property CastsShadow:Bool()
		
		Return _castsShadow
		
	Setter( shadows:Bool )
		
		_castsShadow=shadows
	End
	
	#rem monkeydoc The light range.
	#end
	[jsonify=1]
	Property Range:Float()
	
		Return _range
	
	Setter( range:Float )
	
		_range=range
	End
	
	#rem monkeydoc The cone inner angle for spot lights, in degrees.
	
	Defaults to 0 degrees.
		
	#end
	[jsonify=1]
	Property InnerAngle:Float()
		
		Return _innerAngle
	
	Setter( angle:Float )
		
		_innerAngle=angle
	End
	
	#rem monkeydoc The cone outer angle for spot lights, in degrees.
	
	Defaults to 45 degrees.
		
	#end
	[jsonify=1]
	Property OuterAngle:Float()
		
		Return _outerAngle
	
	Setter( angle:Float )
		
		_outerAngle=angle
	End
	
	Protected

	Method New( light:Light,parent:Entity )
		
		Super.New( light,parent )
		
		Type=light.Type
		Texture=light.Texture
		CastsShadow=light.CastsShadow
		Range=light.Range
		InnerAngle=light.InnerAngle
		OuterAngle=light.OuterAngle
		
		AddInstance( light )
	End
	
	Method OnCopy:Light( parent:Entity ) Override
		
		Return New Light( Self,parent )
	End
	
	Method OnShow() Override
		
		Scene.Lights.Add( Self )
	End
	
	Method OnHide() Override
		
		Scene.Lights.Remove( Self )
	End

	Private
	
	Field _type:LightType
	Field _texture:Texture
	Field _color:Color
	Field _range:Float
	Field _innerAngle:Float
	Field _outerAngle:Float
	Field _castsShadow:bool

End
