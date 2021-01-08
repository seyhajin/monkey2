
Namespace mojo.graphics

#rem monkeydoc Blend modes.

Blend modes are used with the [[Canvas.BlendMode]] property.

| BlendMode	| Description
|:----------|:-----------
| Opaque	| Blending disabled.
| Alpha		| Alpha blending.
| Multiply	| Multiply blending.
| Additive	| Additive blending.

#end
Enum BlendMode
	None=0
	Opaque=1
	Alpha=2
	Additive=3
	Multiply=4
'jl added
'------------------------------------------------------------	
	Alpha3d = 5
'------------------------------------------------------------	
End

#rem monkeydoc @hidden Color mask values.

Color masks are used with the [[Canvas.ColorMask]] property.

| ColorMask	| Descripten
|:----------|:----------
| Red		| Red color mask.
| Green		| Green color mask.
| Blue		| Blue color mask.
| Alpha		| Alpha color mask.
#end
Enum ColorMask
	None=0
	Red=1
	Green=2
	Blue=4
	Alpha=8
	All=15
End

Enum DepthFunc
	Never=0
	Less=1
	Equal=2
	LessEqual=3
	Greater=4
	NotEqual=5
	GreaterEqual=6
	Always=7
End

Enum CullMode
	None=0
	Back=1
	Front=2
End

#rem monkeydoc @hidden
#end
Class GraphicsDevice

	Method New()
		Init()
	End

	Method New( width:Int,height:Int )
		Init()
		
		_deviceSize=New Vec2i( width,height )
		
		_rtargetSize=_deviceSize
	End
	
	Method Resize( size:Vec2i )
	
		_deviceSize=size
	
		If Not _rtarget _rtargetSize=size
		
		_dirty|=Dirty.Viewport|Dirty.Scissor
	End
	
	Property RenderTargetSize:Vec2i()
	
		Return _rtargetSize
	End
	
	'***** PUBLIC *****
	
	Property RenderTarget:RenderTarget()

		Return _rtarget
	
	Setter( renderTarget:RenderTarget )

		FlushTarget()
	
		_rtarget=renderTarget
		
		_rtargetSize=_rtarget ? _rtarget.Size Else _deviceSize
		
		_dirty|=Dirty.RenderTarget|Dirty.Viewport|Dirty.Scissor
	End
	
	Property Viewport:Recti()
	
		Return _viewport
	
	Setter( viewport:Recti )
		If viewport=_viewport Return
	
		FlushTarget()
	
		_viewport=viewport
		
		_dirty|=Dirty.Viewport|Dirty.Scissor
	End
	
	Property Scissor:Recti()
	
		Return _scissor
	
	Setter( scissor:Recti )
		If scissor=_scissor Return
	
		FlushTarget()
	
		_scissor=scissor
		
		_dirty|=Dirty.Scissor
	End
	
	Property ColorMask:ColorMask()
	
		Return _colorMask
		
	Setter( colorMask:ColorMask )
		If colorMask=_colorMask Return
	
		_colorMask=colorMask
		
		_dirty|=Dirty.ColorMask
	End
	
	Property DepthMask:Bool()
		
		Return _depthMask
	
	Setter( depthMask:Bool )
		If depthMask=_depthMask Return
		
		_depthMask=depthMask
		
		_dirty|=Dirty.DepthMask
	End
	
	Property DepthFunc:DepthFunc()
		
		Return _depthFunc
	
	Setter( depthFunc:DepthFunc )
		If depthFunc=_depthFunc Return
		
		_depthFunc=depthFunc
		
		_dirty2|=Dirty.DepthFunc
	End
	
	Property BlendMode:BlendMode()
	
		Return _blendMode
	
	Setter( blendMode:BlendMode )
		If blendMode=_blendMode Return
	
		_blendMode=blendMode
		
		_dirty2|=Dirty.BlendMode
	End
	
	Property CullMode:CullMode()
		
		Return _cullMode
	
	Setter( cullMode:CullMode )
		If cullMode=_cullMode Return
		
		_cullMode=cullMode
		
		_dirty2|=Dirty.CullMode
	End

	Property RetroMode:Bool()
		
		Return _retroMode
	
	Setter( retroMode:Bool )
		If retroMode=_retroMode Return
		
		_retroMode=retroMode
		
		_dirty2|=Dirty.RetroMode
	End
	
	Property VertexBuffer:VertexBuffer()
	
		Return _vertexBuffer
		
	Setter( vbuffer:VertexBuffer )
		If vbuffer=_vertexBuffer Return
	
		_vertexBuffer=vbuffer
		
		_dirty2|=Dirty.VertexBuffer
	End
	
	Property IndexBuffer:IndexBuffer()
	
		Return _indexBuffer
		
	Setter( ibuffer:IndexBuffer )
		If ibuffer=_indexBuffer Return
	
		_indexBuffer=ibuffer
		
		_dirty2|=Dirty.IndexBuffer
	End
	
	Property RenderPass:Int()
	
		Return _rpass
		
	Setter( rpass:Int )
		If rpass=_rpass Return
	
		_rpass=rpass
		
		_dirty2|=Dirty.Shader
	End
	
	Property Shader:Shader()
	
		Return _shader

	Setter( shader:Shader )
		If shader=_shader Return
	
		_shader=shader
		
		_dirty2|=Dirty.Shader
	End
	
	Method BindUniformBlock( ublock:UniformBlock )
	
		_ublocks[ublock.BlockId]=ublock
	End
	
	Method GetUniformBlock:UniformBlock( block:Int )
	
		Return _ublocks[block]
	End
	
	Method CopyPixels( rect:Recti,pixmap:Pixmap,dstx:Int,dsty:Int )
		
		Validate()
		
		glReadPixels( rect.X,rect.Y,rect.Width,rect.Height,GL_RGBA,GL_UNSIGNED_BYTE,pixmap.PixelPtr( dstx,dsty ) )
		
		If Not _rtarget And rect.Height>1
			If rect.min.x<>0 Or rect.min.y<>0 Or rect.Size<>_rtargetSize
				pixmap.Window( rect.X,rect.Y,rect.Width,rect.Height ).FlipY()
			Else
				pixmap.FlipY()
			End
		Endif
	End
	
	Method Clear( color:Color,depth:Float=1 )
		
		Validate()
		
		If Not _scissorTest glEnable( GL_SCISSOR_TEST )
		
		Local mask:GLbitfield
		
		If _colorMask
			glClearColor( color.r,color.g,color.b,color.a )
			mask|=GL_COLOR_BUFFER_BIT
		Endif
		
		If _depthMask
			glClearDepth( depth )
			mask|=GL_DEPTH_BUFFER_BIT
		Endif
		
		glClear( mask )
		
		If Not _scissorTest glDisable( GL_SCISSOR_TEST )
		
		_modified=True

		glCheck()
	End
	
	Method Render( order:Int,count:Int,offset:Int=0 )
		
		Validate2()
		
		If Not _shaderValid Return
	
		Local n:=order*count
	
		Select order
		Case 1 glDrawArrays( GL_POINTS,offset,n )
		Case 2 glDrawArrays( GL_LINES,offset,n )
		Case 3 glDrawArrays( GL_TRIANGLES,offset,n )
		Default
			For Local i:=0 Until count
				glDrawArrays( GL_TRIANGLE_FAN,offset+i*order,order )
			Next
		End
		
		_modified=True

		glCheck()
	End

	Method RenderIndexed( order:Int,count:Int,offset:Int=0 )
		
		Validate2()

		If Not _shaderValid Return
		
		Local n:=order*count
		
		Local gltype:GLenum,pitch:Int
		
		Select _indexBuffer.Format
		Case IndexFormat.UINT16
			gltype=GL_UNSIGNED_SHORT
			pitch=2
		Case IndexFormat.UINT32
			gltype=GL_UNSIGNED_INT
			pitch=4
		Default 
			RuntimeError( "Invalid index format" )
		End

		Local p:=Cast<UByte Ptr>( offset * pitch )
		
		Select order
		Case 1 glDrawElements( GL_POINTS,n,gltype,p )
		Case 2 glDrawElements( GL_LINES,n,gltype,p )
		Case 3 glDrawElements( GL_TRIANGLES,n,gltype,p )
		Default
			For Local i:=0 Until count
				glDrawElements( GL_TRIANGLE_FAN,order,gltype,p+i*order*pitch )
			Next
		End

		_modified=True
		
		glCheck()
	End

	Method FlushTarget()
		
		'Print "GraphicsDevice.FlushTarget _modified="+_modified
		
		If Not _modified Return
		
		_modified=False
		
		If Not _rtarget Or Not _rtarget.NumColorTextures Return
			
'		Validate()
			
		For Local i:=0 Until _rtarget.NumColorTextures
			
			Local texture:=_rtarget.GetColorTexture( i )
			
			texture.Modified( _viewport & _scissor )
		Next
		
	End
	
	Private
	
	Enum Dirty
		'
		'stuff that affects Clear()
		RenderTarget=		$0001
		Viewport=			$0002
		Scissor=			$0004
		ColorMask=			$0008
		DepthMask=			$0010
		'
		'stuff that affects Render()
		DepthFunc=			$0100
		BlendMode=			$0200
		CullMode=			$0400
		RetroMode=			$0800
		VertexBuffer=		$1000
		IndexBuffer=		$2000
		Shader=				$4000
		'
		All=				$7fff
		'
	End
	
	Field _dirty:Dirty
	Field _dirty2:Dirty
	Field _modified:Bool
	
	Field _rtarget:RenderTarget
	Field _rtargetSize:Vec2i
	Field _deviceSize:Vec2i
	Field _viewport:Recti
	Field _scissor:Recti
	Field _scissorTest:Bool
	Field _colorMask:ColorMask
	Field _depthMask:Bool
	Field _depthFunc:DepthFunc
	Field _blendMode:BlendMode
	Field _cullMode:CullMode
	Field _retroMode:Bool
	Field _vertexBuffer:VertexBuffer
	Field _indexBuffer:IndexBuffer
	Field _ublocks:=New UniformBlock[8]
	Field _shader:Shader
	Field _shaderValid:Bool
	Field _rpass:Int
	
	Global _glSeq:Int
	Global _current:GraphicsDevice
	Global _defaultFbo:GLint
	Global _defaultDrawBuf:GLint
	Global _defaultReadBuf:GLint
	
	Method Init()
		_depthFunc=DepthFunc.Less
		_blendMode=BlendMode.Alpha
		_cullMode=CullMode.Back
		_colorMask=ColorMask.All
		_depthMask=True
	End
	
	Function InitGL()

		glCheck()
		
		glPixelStorei( GL_PACK_ALIGNMENT,1 )
		glPixelStorei( GL_UNPACK_ALIGNMENT,1 )
		
		glGetIntegerv( GL_FRAMEBUFFER_BINDING,Varptr _defaultFbo )
		
		If BBGL_seamless_cube_map glEnable( GL_TEXTURE_CUBE_MAP_SEAMLESS )
		
		If Not BBGL_ES
			glGetIntegerv( GL_DRAW_BUFFER,Varptr _defaultDrawBuf )
			glGetIntegerv( GL_READ_BUFFER,Varptr _defaultReadBuf )
			glEnable( GL_POINT_SPRITE )
			glEnable( GL_VERTEX_PROGRAM_POINT_SIZE )
			glEnable( GL_TEXTURE_CUBE_MAP_SEAMLESS )
		Endif
			
		glCheck()
	End
	
	Method Validate()
		
		glCheck()

		If _glSeq<>glGraphicsSeq
			_glSeq=glGraphicsSeq
			_current=Null
			InitGL()
		Endif

		If _current<>Self
			If _current _current.FlushTarget()
			_current=Self
			_dirty=Dirty.All
			_dirty2=Dirty.All
		Else
			If Not _dirty Return
		Endif
		
		If _dirty & Dirty.RenderTarget
			
			If _rtarget
				_rtarget.Bind()
			Else
				glBindFramebuffer( GL_FRAMEBUFFER,_defaultFbo )
				
				If Not BBGL_ES
					glDrawBuffer( _defaultDrawBuf )
					glReadBuffer( _defaultReadBuf )
				Endif
				
			Endif

		Endif
	
		If _dirty & Dirty.Viewport
			
			If _rtarget
				glViewport( _viewport.X,_viewport.Y,Max( _viewport.Width,0 ),Max( _viewport.Height,0 ) )
			Else
				glViewport( _viewport.X,_deviceSize.y-_viewport.Bottom,Max( _viewport.Width,0 ),Max( _viewport.Height,0 ) )
			End
			
		Endif
		
		If _dirty & Dirty.Scissor
		
			Local scissor:=_scissor & _viewport
			
			_scissorTest=scissor<>_viewport
			
			If _scissorTest glEnable( GL_SCISSOR_TEST ) Else glDisable( GL_SCISSOR_TEST )
			
			If _rtarget
				glScissor( scissor.X,scissor.Y,Max( scissor.Width,0 ),Max( scissor.Height,0 ) )
			Else
				glScissor( scissor.X,_rtargetSize.y-scissor.Bottom,Max( scissor.Width,0 ),Max( scissor.Height,0 ) )
			Endif
			
		Endif
		
		If _dirty & Dirty.ColorMask
			
			Local r:=Bool( _colorMask & ColorMask.Red )
			Local g:=Bool( _colorMask & ColorMask.Green )
			Local b:=Bool( _colorMask & ColorMask.Blue )
			Local a:=Bool( _colorMask & ColorMask.Alpha )
			
			glColorMask( r,g,b,a )
		
		Endif
		
		If _dirty & Dirty.DepthMask
			
			glDepthMask( _depthMask )
			
		Endif
		
		glCheck()
		
		_dirty=Null
	End
	
	Method Validate2()
		
		Validate()
		
		glCheck()
		
		If _dirty2 & Dirty.DepthFunc
			
			If _depthFunc=DepthFunc.Always
				glDisable( GL_DEPTH_TEST )
			Else
				glEnable( GL_DEPTH_TEST )
				Select _depthFunc
				Case DepthFunc.Never
					glDepthFunc( GL_NEVER )
				Case DepthFunc.Less
					glDepthFunc( GL_LESS )
				Case DepthFunc.Equal
					glDepthFunc( GL_EQUAL )
				Case DepthFunc.LessEqual
					glDepthFunc( GL_LEQUAL )
				Case DepthFunc.Greater
					glDepthFunc( GL_GREATER )
				Case DepthFunc.NotEqual
					glDepthFunc( GL_NOTEQUAL )
				Case DepthFunc.GreaterEqual
					glDepthFunc( GL_GEQUAL )
				Default
					RuntimeError( "Invalid DepthFunc" )
				End
			Endif
		
		Endif
		
		If _dirty2 & Dirty.BlendMode
			
			If _blendMode=BlendMode.Opaque
				glDisable( GL_BLEND )
			Else
				glEnable( GL_BLEND )
				Select _blendMode
				Case BlendMode.Alpha
					glBlendFunc( GL_ONE,GL_ONE_MINUS_SRC_ALPHA )
'jl added						
'------------------------------------------------------------
					Case BlendMode.Alpha3d
						glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA ) 'alphablend
'------------------------------------------------------------
				Case BlendMode.Additive
					glBlendFunc( GL_ONE,GL_ONE )
				Case BlendMode.Multiply
					glBlendFunc( GL_DST_COLOR,GL_ONE_MINUS_SRC_ALPHA )
				Default
					RuntimeError( "Invalid BlendMode" )
				End
			Endif

		Endif
		
		If _dirty2 & Dirty.CullMode
			
			If _cullMode=CullMode.None
				glDisable( GL_CULL_FACE )
			Else
				glEnable( GL_CULL_FACE )
				Select _cullMode
				Case CullMode.Back
					glCullFace( GL_FRONT )
				Case CullMode.Front
					glCullFace( GL_BACK )
				Default
					RuntimeError( "Invalid CullMode" )
				End
			Endif
		
		Endif
		
		If _dirty2 & Dirty.RetroMode
			
			If _retroMode<>glRetroMode
				glRetroMode=_retroMode
				glRetroSeq+=1
			Endif
		
		Endif
		
		If _dirty2 & Dirty.VertexBuffer
		
			 _vertexBuffer.Bind()
		Endif

		If _dirty2 & Dirty.IndexBuffer
		
			If _indexBuffer _indexBuffer.Bind()
		Endif
		
		If _dirty2 & Dirty.Shader
			
			_ublocks[0]=_shader.Uniforms
			
			_shaderValid=_shader.RenderPassMask & 1 Shl _rpass <> 0
		
			If _shaderValid _shader.Bind( _rpass )
		Endif
		
		_vertexBuffer.Validate()
		
		If _indexBuffer _indexBuffer.Validate()

		If _shaderValid _shader.ValidateUniforms( _rpass,_ublocks )
		
		glCheck()
		
		_dirty2=Null
	End
	
End
