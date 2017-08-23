
Namespace mojo3d.graphics

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
Class Sprite Extends Entity
	
	#rem monkeydoc Creates a new sprite.
	#end
	Method New( parent:Entity=Null )
		Super.New( parent )

		Show()
	End

	Method New( material:Material,parent:Entity=Null )
		Self.New( parent )
		
		_material=material
	End

	#rem monkeydoc Copies the sprite.
	#end	
	Method Copy:Sprite( parent:Entity=Null ) Override
		
		Local copy:=New Sprite( Self,parent )
		
		CopyComplete( copy )
		
		Return copy
	End

	#rem monkeydoc Material used to render the sprite.
	
	This must currently be an instance of a SpriteMaterial.
	
	#end	
	Property Material:Material()
		
		Return _material
	
	Setter( material:Material )
		
		_material=material
	End

	#rem monkeydoc Rect within texture to draw.
	
	#end	
	Property TextureRect:Rectf()
		
		Return _textureRect
	
	Setter( textureRect:Rectf )
		
		_textureRect=textureRect
	End
	
	#rem monkeydoc Sprite handle.
	
	Defaults to 0.5,0.5.
	
	#end
	Property Handle:Vec2f()
		
		Return _handle
	
	Setter( handle:Vec2f )
		
		_handle=handle
	End
	
	#rem monkeydoc Sprite mode.
	
	Defaults to SpriteMode.Billboard.
	
	#end
	Property Mode:SpriteMode()
		
		Return _mode
		
	Setter( mode:SpriteMode )
		
		_mode=mode
	End
	
	Protected

	#rem monkeydoc @hidden
	#End		
	Method New( sprite:Sprite,parent:Entity )
		Super.New( sprite,parent )
		
		_material=sprite._material
		_handle=sprite._handle
		_mode=sprite._mode
		
		Show()
	End
	
	#rem monkeydoc @hidden
	#End		
	Method OnShow() Override
		
		Scene.Sprites.Add( Self )
	End
	
	#rem monkeydoc @hidden
	#End		
	Method OnHide() Override
		
		Scene.Sprites.Remove( Self )
	End
	
	Private
	
	Field _material:Material
	Field _textureRect:=New Rectf( 0,0,1,1 )
	Field _handle:Vec2f=New Vec2f( .5,.5 )
	Field _mode:SpriteMode=Null
	
End
