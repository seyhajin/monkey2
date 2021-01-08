
Namespace mojo.graphics

#Import "shaders/@/shaders"

Internal

Const A_POSITION:=0
Const A_TEXCOORD0:=1
Const A_TEXCOORD1:=2
Const A_COLOR:=3
Const A_NORMAL:=4
Const A_TANGENT:=5
Const A_WEIGHTS:=6
Const A_BONES:=7

'jl added
'------------------------------------------------------------
Const A_COLOR2:=8
Const A_XYZPOSITION:=9
Const A_COLOR3:=10
'------------------------------------------------------------

Private

Class GLUniform

	Field name:String
	Field location:Int
	Field texunit:Int
	Field size:Int
	Field type:Int
	Field block:Int
	Field uniformId:Int

	Method New( name:String,location:Int,texunit:Int,size:Int,type:Int )
		Self.name=name
		Self.location=location
		Self.texunit=texunit
		Self.size=size
		Self.type=type
		
		If name.StartsWith( "g_" )
			name=name.Slice( 2 )
			block=0
		Else If name.StartsWith( "r_" )
			name=name.Slice( 2 )
			block=1
		Else If name.StartsWith( "i_" )
			name=name.Slice( 2 )
			block=2
		Else If name.StartsWith( "m_" )
			name=name.Slice( 2 )
			block=3
		Else If name.StartsWith( "x_" )
			name=name.Slice( 2 )
			block=4
		Endif
		
		uniformId=UniformBlock.GetUniformId( name,block )
	End
	
End

Class GLProgram

	Field _glprogram:GLuint
	Field _uniforms:=New GLUniform[8][]
	Field _textures:=New GLUniform[8][]
	Field _ublockSeqs:=New Int[8]
	Field _glRetroSeq:Int

	Method New( glprogram:GLuint )

		_glprogram=glprogram
		
		Local uniforms:=New Stack<GLUniform>[8]
		Local textures:=New Stack<GLUniform>[8]
		For Local i:=0 Until 8
			uniforms[i]=New Stack<GLUniform>
			textures[i]=New Stack<GLUniform>
		Next
			
		Local n:Int
		glGetProgramiv( _glprogram,GL_ACTIVE_UNIFORMS,Varptr n )
			
		Local size:Int,type:UInt,length:Int,nameBuf:=New Byte[256],texunit:=0
			
		For Local i:=0 Until n
			
			glGetActiveUniform( _glprogram,i,nameBuf.Length,Varptr length,Varptr size,Varptr type,Cast<GLchar Ptr>( nameBuf.Data ) )
	
			Local name:=String.FromCString( nameBuf.Data )
			
			Local i:=name.Find( "[" )
			If i<>-1
				name=name.Slice( 0,i )
			Endif
				
			Local location:=glGetUniformLocation( _glprogram,name )
			If location=-1 Continue  'IE fix...
			
			Local uniform:=New GLUniform( name,location,texunit,size,type )
			
			uniforms[uniform.block].Push( uniform )
			
			Select type
			Case GL_SAMPLER_2D,GL_SAMPLER_CUBE
				textures[uniform.block].Push( uniform )
				texunit+=1
			End
			
		Next
		
		For Local i:=0 until 8
			_uniforms[i]=uniforms[i].ToArray()
			_textures[i]=textures[i].ToArray()
			_ublockSeqs[i]=-1
		Next
	End
	
	Property GLProgram:GLuint()
	
		Return _glprogram
	End

	Method ValidateUniforms( ublocks:UniformBlock[] )
		
		For Local i:=0 Until 8

			Local ublock:=ublocks[ i ]
			
			If Not ublock Or ublock.Seq=_ublockSeqs[i] Continue
			
			_ublockSeqs[i]=ublock.Seq
			
			For Local u:=Eachin _uniforms[i]
			
				Select u.type
				Case GL_BOOL

					glUniform1i( u.location,ublock.GetInt( u.uniformId ) )

				Case GL_INT

					glUniform1i( u.location,ublock.GetInt( u.uniformId ) )

				Case GL_FLOAT

					glUniform1f( u.location,ublock.GetFloat( u.uniformId ) )

				Case GL_FLOAT_VEC2

					glUniform2fv( u.location,1,ublock.GetVec2fv( u.uniformId ) )

				Case GL_FLOAT_VEC3

					glUniform3fv( u.location,1,ublock.GetVec3fv( u.uniformId ) )
					
				Case GL_FLOAT_VEC4
				
					glUniform4fv( u.location,1,ublock.GetVec4fv( u.uniformId ) )
					
				Case GL_FLOAT_MAT3
				
					glUniformMatrix3fv( u.location,1,False,ublock.GetMat3fv( u.uniformId ) )
					
				Case GL_FLOAT_MAT4
				
					Local size:=u.size
					
					If size>1 size=ublock.GetMat4fArray( u.uniformId ).Length
					
					glUniformMatrix4fv( u.location,size,False,ublock.GetMat4fv( u.uniformId ) )
					
				Case GL_SAMPLER_2D,GL_SAMPLER_CUBE
				
					glUniform1i( u.location,u.texunit )
				End
			
			Next
		
		Next
		
		For Local i:=0 Until 8
			
			If Not _textures[i] Continue
			
			For Local u:=Eachin _textures[i]
				
				Local tex:=ublocks[i].GetTexture( u.uniformId )
				If Not tex
					Print( "Can't bind shader texture uniform '"+u.name+"' - no texture!" )
					Continue
				Endif
				
				tex.Bind( u.texunit )
			Next
		
		Next
		
		glActiveTexture( GL_TEXTURE0 )
	
	End
	
End

Public

#rem monkeydoc The Shader class.
#end
Class Shader

	#rem monkeydoc Creates a new shader.
	#end
	Method New( name:String,source:String,defs:String )
	
		_name=name
		_source=source
		
		For Local def:=Eachin defs.Replace( ";","~n" ).Split( "~n" )
		
			def=def.Trim()
			If Not def Continue

			if Not def.Contains( " " ) def+=" 1"
			
			_defs+="#define "+def+"~n"
		Next
		
		EnumPasses()
	End
	
	#rem monkeydoc The shader name.
	#end
	Property Name:String()
	
		Return _name
	End
	
	#rem monkeydoc The shader source code.
	#end
	Property Source:String()
	
		Return _source
	End
	
	#rem monkeydoc The renderpasses the shader is valid for.
	#end
	Property RenderPasses:Int[]()
	
		Return _rpasses
	End
	
	#rem monkeydoc Renderpass bitmask.
	#end
	Property RenderPassMask:Int()
	
		Return _rpassMask
	End
	
	#rem monkeydoc Shader global uniforms.
	#end
	Property Uniforms:UniformBlock()
		
		If Not _uniforms _uniforms=New UniformBlock( 0 )
		
		Return _uniforms
	End
	
	'***** INTERNAL *****
	
	#rem monkeydoc @hidden
	#end
	Method Bind( renderPass:Int )
	
		If _glSeq<>glGraphicsSeq
			_glSeq=glGraphicsSeq
			Rebuild()
		Endif
		
		glUseProgram( _programs[renderPass].GLProgram )
	End
	
	#rem monkeydoc @hidden
	#end
	Method ValidateUniforms( renderPass:Int,ublocks:UniformBlock[] )
	
		_programs[renderPass].ValidateUniforms( ublocks )
	End

	#rem monkeydoc Gets a shader with a given name.
	#end	
	Function GetShader:Shader( name:String,defs:String="" )
		
		Local tag:=name+";"+defs
		
		If _cache.Contains( tag ) Return _cache[tag]
		
		local source:=LoadString( "asset::shaders/"+name+".glsl" )
		
		Local shader:=source ? New Shader( name,source,defs ) Else Null
		
		_cache[tag]=shader
		
		Return shader
	End
	
	#rem monkeydoc Gets a shader with a given name.
	#end	
	Function Open:Shader( name:String,defs:String="" )
		
		Return GetShader( name,defs )
	End

'------------------------------------------------------------
'jl added
	#rem monkeydoc Loads a shader with a given name.
	#end	
	Function Load:Shader( name:String, defs:String="" )
'		Return GetShader( name, defs )
		local nm:string = StripExt( StripDir(name) )
'		Print "nm:"+nm 
		Local tag := nm+";"+defs
		
		If _cache.Contains( tag ) Return _cache[tag]
		
		local source:String = LoadString( name )
		If not source Then
			Print "Shader: Can't load "+name
			return Null
		End if
			
'		Print name
'		Print source
		
'		Local shader:=source ? New Shader( name,source,defs ) Else Null
		local shader:Shader = New Shader( nm, source, defs )
		If not shader Then
			Print "Shader: Can't create"
			return Null
		End if
		
		_cache[tag]=shader
		
		Return shader
	End
'------------------------------------------------------------
	
	Private
	
	Global _cache:=New StringMap<Shader>

	Field _name:String	
	Field _source:String
	Field _defs:String
	
	Field _rpasses:Int[]
	Field _rpassMask:Int
	Field _uniforms:UniformBlock
	
	Field _programs:=New GLProgram[32]
	Field _glSeq:Int
	
	Method EnumPasses()

		Local tag:="//@renderpasses"
		Local tagi:=_source.Find( tag )
		If tagi=-1
			Print "Shader source:~n"+_source
			RuntimeError( "Can't find '"+tag+"' tag" )
		Endif
		tagi+=tag.Length
		Local tage:=_source.Find( "~n",tagi )
		If tage=-1 tage=_source.Length
		Local tagv:=_source.Slice( tagi,tage )
		Local rpasses:=tagv.Split( "," )
		If Not rpasses
			Print "Shader source:~n"+_source
			RuntimeError( "Invalid renderpasses value: '"+tagv+"'" )
		Endif
		_rpasses=New Int[rpasses.Length]
		For Local i:=0 Until rpasses.Length
			_rpasses[i]=Int( rpasses[i] )
			_rpassMask|=(1 Shl _rpasses[i])
		Next
		
	End
	
	'Find common/vertex/fragment chunks
	'
	Method SplitSource:String[]( source:String )
		
		Local i0:=source.Find( "~n//@vertex" )
		If i0=-1 
			Print "Shader source:~n"+source
			RuntimeError( "Can't find //@vertex chunk" )
		Endif
		
		Local i1:=source.Find( "~n//@fragment",i0+1 )
		If i1=-1
			Print "Shader source:~n"+source
			RuntimeError( "Can't find //@fragment chunk" )
		Endif
			
		Local cs:=source.Slice( 0,i0 )+"~n"
		Local vs:=source.Slice( i0,i1 )+"~n"
		Local fs:=source.Slice( i1 )+"~n"
		
		Local chunks:=New String[3]
		
		'Find //@imports in common section
		
		i0=0
		
		Repeat
			i0=cs.Find( "~n//@import",i0 )
			If i0=-1 Exit
			
			Local i1:=cs.Find( "~n",i0+1 )
			If i1=-1 RuntimeError( "Malformed @import directive in shader" )
				
			Local f:=cs.Slice( i0+11,i1 ).Trim()
			i0=i1
			
			If Not f.StartsWith( "~q" ) Or Not f.EndsWith( "~q" )
				RuntimeError( "Malformed @import directive in shader" )
				Exit
			Endif
			
			f=f.Slice(1,-1)
			Local path:="asset::shaders/imports/"+f+".glsl"
			Local src:=LoadString( path )
			Assert( src,"Can't import shader from "+path )
			
			Local tchunks:=SplitSource( src )
			
			chunks[0]+=tchunks[0]
			chunks[1]+=tchunks[1]
			chunks[2]+=tchunks[2]
			
'			Print "Imported "+f
		
		Forever
		
		chunks[0]+=cs
		chunks[1]+=vs
		chunks[2]+=fs
		
		Return chunks
	End
	
	Method Rebuild()
		
		glCheck()
		
		Local chunks:=SplitSource( _source )
		
		Local cs:=_defs+chunks[0]
		Local vs:=cs+chunks[1]
		Local fs:=cs+chunks[2]
		
		For Local rpass:=Eachin _rpasses
		
			Local defs:="#define MX2_RENDERPASS "+rpass+"~n"
			
'			Print "~n~n*************** Vertex Shader ***************~n"+defs+vs
'			Print "~n~n*************** Fragment Shader ****************~n"+defs+fs
			
			Local vshader:=glCompile( GL_VERTEX_SHADER,defs+vs )
			Local fshader:=glCompile( GL_FRAGMENT_SHADER,defs+fs )
				
			Local glprogram:=glCreateProgram()
			
			glAttachShader( glprogram,vshader )
			glAttachShader( glprogram,fshader )
			glDeleteShader( vshader )
			glDeleteShader( fshader )
				
			glBindAttribLocation( glprogram,A_POSITION,"a_Position" )
			glBindAttribLocation( glprogram,A_TEXCOORD0,"a_TexCoord0" )
			glBindAttribLocation( glprogram,A_TEXCOORD1,"a_TexCoord1" )
			glBindAttribLocation( glprogram,A_COLOR,"a_Color" )
			glBindAttribLocation( glprogram,A_NORMAL,"a_Normal" )
			glBindAttribLocation( glprogram,A_TANGENT,"a_Tangent" )
			glBindAttribLocation( glprogram,A_WEIGHTS,"a_Weights" )
			glBindAttribLocation( glprogram,A_BONES,"a_Bones" )
			
			'jl added
'------------------------------------------------------------			
			glBindAttribLocation( glprogram,A_COLOR2,"a_Color2" )
			glBindAttribLocation( glprogram,A_COLOR3,"a_Color3" )
			glBindAttribLocation( glprogram,A_XYZPOSITION,"a_XYZPosition" )
'------------------------------------------------------------

			glLink( glprogram )
			
			Local program:=New GLProgram( glprogram )
			
			_programs[rpass]=program
		Next
		
		glCheck()
	End

End
