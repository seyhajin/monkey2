
Namespace mojo3d

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
	Method Render()
		
		OnRender()
	End
	
	Function BeginRendering( device:GraphicsDevice,renderer:Renderer )
		_device=device
		_renderer=renderer
	End
	
	Function EndRendering()
	End

	Protected
	
	#rem monkeydoc @hidden
	#end	
	Method OnRender() Abstract
	
	Property Device:GraphicsDevice()
		
		Return _device
	End
	
	Method Flip()
		
		_renderer.FlipEffectBuffers()
	End
	
	Method RenderQuad()

		Global _vertices:VertexBuffer
	
		If Not _vertices
			_vertices=New VertexBuffer( New Vertex3f[](
			New Vertex3f( 0,1,0 ),
			New Vertex3f( 1,1,0 ),
			New Vertex3f( 1,0,0 ),
			New Vertex3f( 0,0,0 ) ) )
		Endif
			
		_device.VertexBuffer=_vertices
		
		_device.Render( 4,1 )
	End
	
	#rem monkeydoc @hidden
	#end	
	Private
	
	Global _device:GraphicsDevice
	Global _renderer:Renderer
	
	Field _enabled:Bool=True
	
End
