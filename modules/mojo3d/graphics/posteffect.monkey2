
Namespace mojo3d.graphics

#rem monkeydoc The PostEffect class.
#end
Class PostEffect

	#rem monkeydoc Enabled state.
	
	Set to true to enable this effect and false to disable.
	
	#end
	Property Enabled:Bool()
		
		Return _enabled
	
	Setter( enabled:Bool )
		
		_enabled=enabled
	End

	#rem monkeydoc @hidden
	#end	
	Method Render( device:GraphicsDevice ) Virtual
		
		_device=device
		
		OnRender()
	End

	Protected
	
	#rem monkeydoc @hidden
	#end	
	Method OnRender() Virtual
	End
	
	#rem monkeydoc @hidden
	#end	
	Property Device:GraphicsDevice()
		
		Return _device
	End
	
	#rem monkeydoc @hidden
	#end	
	Property SourceRect:Recti()
		
		Return _device.Viewport
	End
	
	#rem monkeydoc @hidden
	#end	
	Property SourceTexture:Texture()
		
		Return _device.RenderTarget.GetColorTexture( 0 )
	End
	
	#rem monkeydoc @hidden
	#end	
	Method RenderQuad()
		
		_device.Render( 4,1,0 )
	End
		
	Private
	
	Global _device:GraphicsDevice
	
	Field _enabled:Bool=True
	
End
