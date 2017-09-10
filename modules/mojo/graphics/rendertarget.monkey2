
Namespace mojo.graphics

Class RenderTarget Extends Resource
	
	Method New( colorTextures:Texture[],depthTexture:Texture )
		
		_colorTextures=colorTextures.Slice( 0 )
		
		_depthTexture=depthTexture
		
		_glDrawBufs=New GLenum[_colorTextures.Length]
		
		For Local i:=0 Until _colorTextures.Length
			_glDrawBufs[i]=_colorTextures[i] ? GL_COLOR_ATTACHMENT0+i Else GL_NONE
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
		
		Print "ColorTexture0 format="+(_colorTextures ? Cast<Int>( _colorTextures[0].Format ) Else 0)
		Print "DepthTexture format="+(_depthTexture ? Cast<Int>( _depthTexture.Format ) Else 0)
		
		RuntimeError( "Framebuffer incomplete: status="+err )
	End
	
	Method Bind()
	
		glBindFramebuffer( GL_FRAMEBUFFER,ValidateGLFramebuffer() )

		If glexts.GL_draw_buffers 
			glDrawBuffers( _glDrawBufs.Length,_glDrawBufs.Data )
		Endif

		If glexts.GL_read_buffer
			glReadBuffer( _glDrawBufs ? _glDrawBufs[0] Else GL_NONE )
		Endif

		CheckStatus()
	End
	
	Protected
	
	#rem monkeydoc Discards the rendertarget
	#end
	Method OnDiscard() Override
		
		If _glSeq=glGraphicsSeq glDeleteFramebuffers( 1,Varptr _glFramebuffer )
			
		_colorTextures=Null
		_depthTexture=Null
		
		_glSeq=-1
	End
	
	#rem monkeydoc @hidden
	#end
	Method OnFinalize() Override

		If _glSeq=glGraphicsSeq glDeleteFramebuffers( 1,Varptr _glFramebuffer )
	End
	
	Private
	
	Field _colorTextures:Texture[]
	Field _depthTexture:Texture
	Field _glDrawBufs:GLenum[]
	
	Field _glFramebuffer:GLuint
	Field _glSeq:Int
	
	Method ValidateGLFramebuffer:GLuint()
		
		If _glSeq=glGraphicsSeq Return _glFramebuffer
		
		glCheck()
		
		glGenFramebuffers( 1,Varptr _glFramebuffer )
		
		glPushFramebuffer( GL_FRAMEBUFFER,_glFramebuffer )
		
		For Local i:=0 Until _colorTextures.Length
			
			Local texture:=_colorTextures[i]
			
			If texture glFramebufferTexture2D( GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0+i,texture.GLTarget,texture.ValidateGLTexture(),0 )

		Next
		
		If _depthTexture
			
			glFramebufferTexture2D( GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,_depthTexture.GLTarget,_depthTexture.ValidateGLTexture(),0 )
		
		Endif
		
		_glSeq=glGraphicsSeq

		glPopFramebuffer()
		
		glCheck()
		
		Return _glFramebuffer
	End
	
End
