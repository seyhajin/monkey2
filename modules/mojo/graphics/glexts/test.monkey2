
Namespace myapp

#Import "<std>"
#Import "<mojo>"

Using std..
Using mojo..

Class MyWindow Extends GLWindow

	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )
		
		BeginGL()
		
		Print glGetString( GL_VENDOR )
		Print glGetString( GL_VERSION )
		Print glGetString( GL_RENDERER )
		Print glGetString( GL_EXTENSIONS ).Replace( " ","~n" )
		
		Print ""

		InitGLexts()
		
		glCheck()
		
		Local gltexs:=New GLuint[4]
		
		glGenTextures( gltexs.Length,gltexs.Data )
		
		glBindTexture( GL_TEXTURE_2D,gltexs[0] )
		glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST )
		glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST )
		glTexImage2D( GL_TEXTURE_2D,0,GL_RGBA,640,480,0,GL_RGBA,GL_HALF_FLOAT,Null )
'		glTexImage2D( GL_TEXTURE_2D,0,GL_RGBA,640,480,0,GL_RGBA,GL_UNSIGNED_BYTE,Null )
		Print "texture[0]="+gltexs[0]
		glCheck()
		
		glBindTexture( GL_TEXTURE_2D,gltexs[1] )
		glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST )
		glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST )
		glTexImage2D( GL_TEXTURE_2D,0,GL_RGBA,640,480,0,GL_RGBA,GL_HALF_FLOAT,Null )
'		glTexImage2D( GL_TEXTURE_2D,0,GL_RGBA,640,480,0,GL_RGBA,GL_UNSIGNED_BYTE,Null )
		Print "texture[1]="+gltexs[1]
		glCheck()
		
		glBindTexture( GL_TEXTURE_2D,gltexs[2] )
		glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST )
		glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST )
		glTexImage2D( GL_TEXTURE_2D,0,GL_RGBA,640,480,0,GL_RGBA,GL_HALF_FLOAT,Null )
'		glTexImage2D( GL_TEXTURE_2D,0,GL_RGBA,640,480,0,GL_RGBA,GL_UNSIGNED_BYTE,Null )
		Print "texture[2]="+gltexs[2]
		glCheck()
		
		glBindTexture( GL_TEXTURE_2D,gltexs[3] )
		glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST )
		glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST )
		glTexImage2D( GL_TEXTURE_2D,0,GL_DEPTH_COMPONENT,640,480,0,GL_DEPTH_COMPONENT,GL_UNSIGNED_INT,Null )
		Print "texture[3]="+gltexs[3]
		glCheck()
		
		glBindTexture( GL_TEXTURE_2D,0 )
		
		Local glfb:GLuint
		
		glGenFramebuffers( 1,Varptr glfb )
		glCheck()
		
		glBindFramebuffer( GL_FRAMEBUFFER,glfb )
		glCheck()
		
		Local i:Int
		glGetIntegerv( GL_MAX_COLOR_ATTACHMENTS,Varptr i )
		Print "MAX_COLOR_ATTACHMENTS="+i
		
		glFramebufferTexture2D( GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,gltexs[0],0 )
		glFramebufferTexture2D( GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT1,GL_TEXTURE_2D,gltexs[1],0 )
		glFramebufferTexture2D( GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT2,GL_TEXTURE_2D,gltexs[2],0 )
		glFramebufferTexture2D( GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,GL_TEXTURE_2D,gltexs[3],0 )
		glCheck()
		
		Assert( glCheckFramebufferStatus( GL_FRAMEBUFFER )=GL_FRAMEBUFFER_COMPLETE,"Incomplete framebuffer" )
		
		glCheck()
		
		glBindFramebuffer( GL_FRAMEBUFFER,0 )
		
		glCheck()
		
		Print "TEST COMPLETE!"
		
		EndGL()
	End

	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
	
		canvas.DrawText( "Hello World!",Width/2,Height/2,.5,.5 )
	End
	
End

Function Main()

'	libc.setenv( "SDL_ANGLE_RENDERER","OPENGL",0 )
	libc.setenv( "SDL_ANGLE_RENDERER","D3D11",0 )

	Local config:=New StringMap<String>
	
	config["GL_context_profile"]="es"
	config["GL_context_major_version"]=2
	config["GL_context_minor_version"]=0

	config["GL_depth_buffer_enabled"]=1

	New AppInstance( config )
	
	New MyWindow
	
	App.Run()
End
