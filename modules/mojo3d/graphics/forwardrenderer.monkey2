
Namespace mojo3d.graphics

Class ForwardRenderer Extends Renderer

	Method OnRender() Override
	
		_device.RenderTarget=_renderTarget
		_device.Resize( _renderTargetSize )
		
		For Local camera:=Eachin _scene.Cameras
		
			SetCamera( camera )
			
			Local viewport:=_camera.Viewport+_renderViewport.Origin
			Local scissor:=viewport & _renderViewport
			
			_device.Viewport=viewport
			_device.Scissor=scissor
			_device.ColorMask=ColorMask.All
			_device.DepthMask=True
			
			_device.DepthFunc=DepthFunc.LessEqual
			_device.BlendMode=BlendMode.Opaque
			_device.CullMode=CullMode.Back
			_device.RenderPass=0
			
			RenderModels( -_camera.WorldMatrix,_camera.ProjectionMatrix )
			
		Next
			
	End

End
