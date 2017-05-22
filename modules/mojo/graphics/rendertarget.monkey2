
Namespace mojo.graphics

Class RenderTarget Extends Resource
	
	Method New( colorTextures:Texture[],depthTexture:Texture )
		
		_colorTextures=colorTextures.Slice( 0 )
		
		_depthTexture=depthTexture
		
		_drawBufs=New GLenum[ _colorTextures.Length]
		
		For Local i:=0 Until _colorTextures.Length
			_drawBufs[i]=_colorTextures[i] ? GL_COLOR_ATTACHMENT0+i Else GL_NONE
		Next
	End
	
	Property Size:Vec2i()
		
		Return _colorTextures ? _colorTextures[0].Size Else _depthTexture.Size
	End
	
	'***** INTERNAL *****
	
	Method Bind()
		
		glBindFramebuffer( GL_FRAMEBUFFER,ValidateGLFramebuffer() )
		
		If glexts.GL_draw_buffers 
			glDrawBuffers( _drawBufs.Length,_drawBufs.Data )
		Endif
	End
	
	Private
	
	Field _colorTextures:Texture[]
	Field _depthTexture:Texture
	
	Field _drawBufs:GLenum[]
	
	Field _glFramebuffer:GLuint
	Field _glSeq:Int
	
	Method ValidateGLFramebuffer:GLuint()
		
		If _glSeq=glGraphicsSeq Return _glFramebuffer
		
		glGenFramebuffers( 1,Varptr _glFramebuffer )
		
		glPushFramebuffer( GL_FRAMEBUFFER,_glFramebuffer )
		
		For Local i:=0 Until _colorTextures.Length
			
			Local texture:=_colorTextures[i]
			
			If texture glFramebufferTexture2D( GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0+i,GL_TEXTURE_2D,texture.ValidateGLTexture(),0 )
			
		Next
		
		If _depthTexture
			
			glFramebufferTexture2D( GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,GL_TEXTURE_2D,_depthTexture.ValidateGLTexture(),0 )
			
		Endif

		Assert( glCheckFramebufferStatus( GL_FRAMEBUFFER )=GL_FRAMEBUFFER_COMPLETE,"Incomplete framebuffer" )
			
		_glSeq=glGraphicsSeq

		glPopFramebuffer()
		
		Return _glFramebuffer
	End
	
End
