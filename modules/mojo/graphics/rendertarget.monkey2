
Namespace mojo.graphics

Class RenderTarget Extends Resource
	
	Method New( colorTextures:Texture[],depthTexture:Texture )
		
		_colorTextures=colorTextures.Slice( 0 )
		
		_depthTexture=depthTexture
		
		For Local texture:=Eachin _colorTextures
			SafeRetain( texture )
		Next
		
		SafeRetain( _depthTexture )
		
		_drawBufs=New GLenum[_colorTextures.Length]
		
		For Local i:=0 Until _colorTextures.Length
			_drawBufs[i]=_colorTextures[i] ? GL_COLOR_ATTACHMENT0+i Else GL_NONE
		Next
	End
	
	Property NumColorTextures:Int()
		
		Return _colorTextures.Length
	End
	
	Property HasDepthTexture:Bool()
		
		Return _depthTexture
	End
	
	Property Size:Vec2i()
		
		Return _colorTextures ? _colorTextures[0].Size Else _depthTexture.Size
	End
	
	Method GetColorTexture:Texture( index:Int )
		
		Return index>=0 And index<_colorTextures.Length ? _colorTextures[index] Else Null
	End
	
	Method GetDepthTexture:Texture()
		
		Return _depthTexture
	End
	
	'***** INTERNAL *****
	
	Method CheckStatus()
		
		Local status:=gles20.glCheckFramebufferStatus( GL_FRAMEBUFFER )
		
		If status=GL_FRAMEBUFFER_COMPLETE Return
		
		Local err:=""
		
		Select status
		Case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
			err="GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT"
		Case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT
			err="GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT"
'		Case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS
'			err="GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS"
		Case GL_FRAMEBUFFER_UNSUPPORTED
			err="GL_FRAMEBUFFER_UNSUPPORTED"
		Default
			err="GL_FRAMEBUFFER_?????"
		End
		
		RuntimeError( "Framebuffer incomplete: status="+err )
	End
	
	Method Bind()
	
		glBindFramebuffer( GL_FRAMEBUFFER,ValidateGLFramebuffer() )

		If glexts.GL_draw_buffers 
			glDrawBuffers( _drawBufs.Length,_drawBufs.Data )
		Endif

		If glexts.GL_read_buffer
			glReadBuffer( GL_NONE )
		Endif

		CheckStatus()
	End
	
	Protected
	
	#rem monkeydoc Discards the rendertarget
	#end
	Method OnDiscard() Override
		
		If _glSeq=glGraphicsSeq glDeleteFramebuffers( 1,Varptr _glFramebuffer )
			
		For Local texture:=Eachin _colorTextures
			SafeRelease( texture )
		Next
		
		SafeRelease( _depthTexture )
		
		_colorTextures=Null
		_depthTexture=Null
		_glSeq=0
	End
	
	#rem monkeydoc @hidden
	#end
	Method Finalize() Override

		If _glSeq=glGraphicsSeq glDeleteFramebuffers( 1,Varptr _glFramebuffer )
			
	End
	
	Private
	
	Field _colorTextures:Texture[]
	Field _depthTexture:Texture
	
	Field _drawBufs:GLenum[]
	
	Field _glFramebuffer:GLuint
	Field _glSeq:Int
	
	Method ValidateGLFramebuffer:GLuint()
		
		If _glSeq=glGraphicsSeq Return _glFramebuffer
		
		glCheck()
		
		glGenFramebuffers( 1,Varptr _glFramebuffer )
		
		glPushFramebuffer( GL_FRAMEBUFFER,_glFramebuffer )
		
		For Local i:=0 Until _colorTextures.Length
			
			Local texture:=_colorTextures[i]
			
			If texture glFramebufferTexture2D( GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0+i,GL_TEXTURE_2D,texture.ValidateGLTexture(),0 )

		Next
		
		If _depthTexture
			
			glFramebufferTexture2D( GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,GL_TEXTURE_2D,_depthTexture.ValidateGLTexture(),0 )
			
		Endif
		
		_glSeq=glGraphicsSeq

		glPopFramebuffer()
		
		glCheck()
		
		Return _glFramebuffer
	End
	
End
