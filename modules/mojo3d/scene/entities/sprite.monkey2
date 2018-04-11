
Namespace mojo3d

#rem monkeydoc SpriteMode enumeration.

| LightType		| Description
|:--------------|:-----------
| `Billboard`	| Sprite always faces the camera, eg: like a lens flare.
| `Upright`		| Sprite faces the camera but remains upright, eg: like a tree.

#end
Enum SpriteMode
	Billboard=1
	Upright=2
End

#rem monkeydoc The Sprite class.
#end
Class Sprite Extends Renderable
	
	#rem monkeydoc Creates a new sprite.
	#end
	Method New( parent:Entity=Null )
		
		Super.New( parent )
		
		Name="Sprite"
		
		AddInstance()
		
		Visible=True
	End

	Method New( material:Material,parent:Entity=Null )
		
		Super.New( parent )
		
		Name="Sprite"
		Material=material
		
		AddInstance( New Variant[]( material,parent ) )
		
		Visible=True
	End

	Method New( sprite:Sprite,parent:Entity )
		
		Super.New( sprite,parent )
		
		_material=sprite._material
		_handle=sprite._handle
		_mode=sprite._mode
		
		AddInstance( sprite )
	End
	
	#rem monkeydoc Copies the sprite.
	#end	
	Method Copy:Sprite( parent:Entity=Null ) Override
		
		Local copy:=New Sprite( Self,parent )
		
		CopyTo( copy )
		
		Return copy
	End

	#rem monkeydoc Material used to render the sprite.
	
	This must currently be an instance of a SpriteMaterial.
	
	#end	
	[jsonify=1]
	Property Material:Material()
		
		Return _material
	
	Setter( material:Material )
		
		_material=material
	End

	#rem monkeydoc Rect within texture to draw.
	
	#end	
	[jsonify=1]
	Property TextureRect:Rectf()
		
		Return _textureRect
	
	Setter( textureRect:Rectf )
		
		_textureRect=textureRect
	End
	
	#rem monkeydoc Sprite handle.
	
	Defaults to 0.5,0.5.
	
	#end
	[jsonify=1]
	Property Handle:Vec2f()
		
		Return _handle
	
	Setter( handle:Vec2f )
		
		_handle=handle
	End
	
	#rem monkeydoc Sprite mode.
	
	Defaults to SpriteMode.Billboard.
	
	#end
	[jsonify=1]
	Property Mode:SpriteMode()
		
		Return _mode
		
	Setter( mode:SpriteMode )
		
		_mode=mode
	End
	
	Protected

	Method OnRender( rq:RenderQueue ) Override
		
		rq.AddSpriteOp( Self )
	End
	
	Private
	
	Field _material:Material
	Field _textureRect:=New Rectf( 0,0,1,1 )
	Field _handle:Vec2f=New Vec2f( .5,.5 )
	Field _mode:SpriteMode=Null
	
End
