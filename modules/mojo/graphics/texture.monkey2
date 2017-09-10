
Namespace mojo.graphics

Using std.resource

Private

Function IsPow2:Bool( w:Int,h:Int )
	Local tw:=Log2( w ),th:=Log2( h )
	Return tw=Round( tw ) And th=Round( th )
End

Function IsDepth:Bool( format:PixelFormat )
	Return format=PixelFormat.Depth32
End

Function glInternalFormat:GLenum( format:PixelFormat )
	Select format
	Case PixelFormat.A8 Return GL_ALPHA
	Case PixelFormat.I8 Return GL_LUMINANCE
	Case PixelFormat.IA8 Return GL_LUMINANCE_ALPHA
	Case PixelFormat.RGB8 Return GL_RGB
	Case PixelFormat.RGBA8 Return GL_RGBA
	Case PixelFormat.RGBA16F Return GL_RGBA
	Case PixelFormat.RGBA32F Return GL_RGBA
	Case PixelFormat.Depth32 Return GL_DEPTH_COMPONENT
	End
	RuntimeError( "Invalid PixelFormat" )
	Return GL_RGBA
End

Function glFormat:GLenum( format:PixelFormat )
	Select format
	Case PixelFormat.A8 Return GL_ALPHA
	Case PixelFormat.I8 Return GL_LUMINANCE
	Case PixelFormat.IA8 Return GL_LUMINANCE_ALPHA
	Case PixelFormat.RGB8 Return GL_RGB
	Case PixelFormat.RGBA8 Return GL_RGBA
	Case PixelFormat.RGBA16F Return GL_RGBA
	Case PixelFormat.RGBA32F Return GL_RGBA
	Case PixelFormat.Depth32 Return GL_DEPTH_COMPONENT
	End
	RuntimeError( "Invalid PixelFormat" )
	Return GL_RGBA
End

Function glType:GLenum( format:PixelFormat )
	Select format
	Case PixelFormat.A8 Return GL_UNSIGNED_BYTE
	Case PixelFormat.I8 Return GL_UNSIGNED_BYTE
	Case PixelFormat.IA8 Return GL_UNSIGNED_BYTE
	Case PixelFormat.RGB8 Return GL_UNSIGNED_BYTE
	Case PixelFormat.RGBA8 Return GL_UNSIGNED_BYTE
	Case PixelFormat.RGBA16F Return GL_HALF_FLOAT
	Case PixelFormat.RGBA32F Return GL_FLOAT
	Case PixelFormat.Depth32 Return GL_UNSIGNED_INT
	End
	RuntimeError( "Invalid PixelFormat" )
	Return GL_UNSIGNED_BYTE
End

Public

#rem monkeydoc Texture flags.

| TextureFlags	| Description
|:--------------|:-----------
| Dynamic		| Texture is frequently updated. This flag should be set if the texture contents are regularly updated and don't need to be preserved.

#end
Enum TextureFlags
	None=			$0000
	WrapS=			$0001
	WrapT=			$0002
	Filter=			$0004
	Mipmap=			$0008
	
	Dynamic=		$00100
	Cubemap=		$00200
	
	WrapST=			WrapS|WrapT
	FilterMipmap=	Filter|Mipmap
End

Enum CubeFace
	PositiveX
	NegativeX
	PositiveY
	NegativeY
	PositiveZ
	NegativeZ
End

#rem monkeydoc @hidden
#end
Class Texture Extends Resource
	
	Private
	
	Method New( face:GLenum,cubeMap:Texture )
		
		_size=cubeMap._size
		_format=cubeMap._format
		_flags=cubeMap._flags
		
		_glTarget=face
		_glInternalFormat=cubeMap._glInternalFormat
		_glFormat=cubeMap._glFormat
		_glType=cubeMap._glType

		_cubeMap=cubeMap
	End
	
	Public
	
	Method New( pixmap:Pixmap,flags:TextureFlags )

		_managed=pixmap
		_size=New Vec2i( pixmap.Width,pixmap.Height )
		_format=pixmap.Format
		_flags=flags
		
		_glTarget=_flags & TextureFlags.Cubemap ? GL_TEXTURE_CUBE_MAP Else GL_TEXTURE_2D
		_glInternalFormat=glInternalFormat( _format )
		_glFormat=glFormat( _format )
		_glType=glType( _format )
		
		If _flags & TextureFlags.Cubemap
			
			If _size.x/4*3=_size.y
				_size.x/=4
				_size.y/=3
			Else If _size.x<>_size.y
				RuntimeError( "Invalid Cubemap size" )
			Endif
			
		Endif
		
#If Not __DESKTOP_TARGET__
		If Not IsPow2( _size.x,_size.y ) _flags&=~TextureFlags.Mipmap
#Endif

		If _flags & TextureFlags.Dynamic
			PastePixmap( _managed,0,0 )
		Endif
	End
	
	Method New( width:Int,height:Int,format:PixelFormat,flags:TextureFlags )
		
		If flags & TextureFlags.Cubemap
			Assert( width=height,"Invalid cubemap size" )
			Assert( flags & TextureFlags.Dynamic,"Cubemaps must be dynamic" )
		Endif

		_managed=Null
		_size=New Vec2i( width,height )
		_format=format
		_flags=flags

		_glTarget=_flags & TextureFlags.Cubemap ? GL_TEXTURE_CUBE_MAP Else GL_TEXTURE_2D
		_glInternalFormat=glInternalFormat( _format )
		_glFormat=glFormat( _format )
		_glType=glType( _format )
		
		#rem
		If _flags & TextureFlags.Cubemap
			
			If _size.x/4*3=_size.y
				_size.x/=4
				_size.y/=3
			Else If _size.x<>_size.y
				RuntimeError( "Invalid Cubemap size" )
			Endif
			
		Endif
		#end

#If Not __DESKTOP_TARGET__
		If Not IsPow2( _size.x,_size.y ) _flags&=~TextureFlags.Mipmap
#Endif
		If _flags & TextureFlags.Cubemap

			_cubeFaces=New Texture[6]
			For Local i:=0 Until 6
				_cubeFaces[i]=New Texture( GL_TEXTURE_CUBE_MAP_POSITIVE_X+i,Self )
			Next
			
		Endif
		
		#rem		
		If Not (_flags & TextureFlags.Dynamic)
			_managed=New Pixmap( width,height,format )
			_managed.Clear( Color.Magenta )
		Endif
		#end
	End
	
	Property Size:Vec2i()
		
		Return _size
	End
	
	Property Width:Int()
	
		Return _size.x
	End
	
	Property Height:Int()
	
		Return _size.y
	End
	
	Property Format:PixelFormat()
	
		Return _format
	End
	
	Property Flags:TextureFlags()
		
		Assert( Not _cubeMap )
		
		Return _flags
	
	Setter( flags:TextureFlags )
		
		Assert( Not _cubeMap )
		
		Local mask:=TextureFlags.WrapS|TextureFlags.WrapT|TextureFlags.Filter|TextureFlags.Mipmap
		
		_flags=(_flags & ~mask) | (flags & mask)
		
		_dirty|=Dirty.TexParams
	End
	
	Method PastePixmap( pixmap:Pixmap,x:Int,y:Int )
		
		Assert( NOT _cubeMap )
		
		If _managed

			_managed.Paste( pixmap,x,y )
			
			_dirty|=Dirty.TexImage|Dirty.Mipmaps
			
		Else
			glPushTexture( _glTarget,ValidateGLTexture() )
			
			glPixelStorei( GL_UNPACK_ALIGNMENT,1 )
			
			If pixmap.Pitch=pixmap.Width*pixmap.Depth
				glTexSubImage2D( GL_TEXTURE_2D,0,x,y,pixmap.Width,pixmap.Height,glFormat( _format ),GL_UNSIGNED_BYTE,pixmap.Data )
			Else
				For Local iy:=0 Until pixmap.Height
					glTexSubImage2D( GL_TEXTURE_2D,0,x,y+iy,pixmap.Width,1,glFormat( _format ),GL_UNSIGNED_BYTE,pixmap.PixelPtr( 0,iy ) )
				Next
			Endif
			
			glPopTexture()
			
			_dirty|=Dirty.Mipmaps
			
		Endif
	
	End
	
	Method GetCubeFace:Texture( face:CubeFace )
		
		If _cubeFaces Return _cubeFaces[ Cast<Int>( face ) ]
		
		Return Null
	End

	Function Load:Texture( path:String,flags:TextureFlags )

		Local pixmap:=Pixmap.Load( path,,True )
		If Not pixmap Return Null
		
		Local texture:=New Texture( pixmap,flags )
		
		Return texture
	End
	
	Function LoadNormal:Texture( path:String,textureFlags:TextureFlags,specular:String,specularScale:Float=1,flipNormalY:Bool=True )

		path=RealPath( path )
		specular=specular ? RealPath( specular ) Else ""

		Local pnorm:=Pixmap.Load( path,,False )
		If Not pnorm Return Null
		
		Local pspec:=Pixmap.Load( specular )
		
		Local yxor:=flipNormalY ? $ff00 Else 0
			
		If pspec And pspec.Width=pnorm.Width And pspec.Height=pnorm.Height
			For Local y:=0 Until pnorm.Height
				For Local x:=0 Until pnorm.Width
					Local n:=pnorm.GetPixelARGB( x,y ) ~ yxor
					Local s:=(pspec.GetPixelARGB( x,y ) Shr 16) & $ff
					n=n & $ffffff00 | Clamp( Int( specularScale * s ),0,255 )
					pnorm.SetPixelARGB( x,y,n )
				Next
			Next
		Else
			Local g:=Clamp( Int( specularScale * 255.0 ),1,255 )
			For Local y:=0 Until pnorm.Height
				For Local x:=0 Until pnorm.Width
					Local n:=pnorm.GetPixelARGB( x,y ) ~ yxor
					n=n & $ffffff00 | g
					pnorm.SetPixelARGB( x,y,n )
				Next
			Next
		Endif
			
		Local texture:=New Texture( pnorm,Null )
		
		Return texture
	End
	
	Function ColorTexture:Texture( color:Color )

		Global _cache:=New Map<Color,Texture>
		
		Local texture:=_cache[color]
		If Not texture
			Local pixmap:=New Pixmap( 1,1 )
			pixmap.Clear( color )
			texture=New Texture( pixmap,Null )
			_cache[color]=texture
		Endif
		Return texture
	End
	
	Function FlatNormal:Texture()
		
		Return ColorTexture( New Color( .5,.5,1 ) )
	End
	
	'***** INTERNAL *****

	#rem monkeydoc @hidden
	#end
	Property GLTarget:GLenum()
		
		Return _glTarget
	End
	
	#rem monkeydoc @hidden
	#end
	Method Modified( r:Recti )
		
		If _cubeMap Return
'		Assert( Not _cubeMap )
		
		If _managed
			glPixelStorei( GL_PACK_ALIGNMENT,1 )
			glReadPixels( r.X,r.Y,r.Width,r.Height,GL_RGBA,GL_UNSIGNED_BYTE,_managed.PixelPtr( r.X,r.Y ) )
		Endif
		
		_dirty|=Dirty.Mipmaps
	End
	
	#rem monkeydoc @hidden
	#end
	Method Bind( unit:GLenum )
		
		Assert( Not _cubeMap )
		
		glActiveTexture( GL_TEXTURE0+unit )

		glBindTexture( _glTarget,ValidateGLTexture() )
	End
	
	#rem monkeydoc @hidden
	#end
	Method ValidateGLTexture:GLuint()
		
		If _cubeMap Return _cubeMap.ValidateGLTexture()
		
		If _discarded Return 0
		
		If _retroMode<>glRetroMode
			_dirty|=Dirty.TexParams
			_retroMode=glRetroMode
		Endif
		
		If _glSeq=glGraphicsSeq And Not _dirty Return _glTexture
		
		glCheck()
		
		If _glSeq<>glGraphicsSeq 
			glGenTextures( 1,Varptr _glTexture )
			_glSeq=glGraphicsSeq
			_dirty=Dirty.All
		Endif
			
		glPushTexture( _glTarget,_glTexture )

		If _dirty & Dirty.TexParams
			
			If _flags & TextureFlags.WrapS
				glTexParameteri( _glTarget,GL_TEXTURE_WRAP_S,GL_REPEAT )
			Else
				glTexParameteri( _glTarget,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE )
			Endif
			
			If _flags & TextureFlags.WrapT
				glTexParameteri( _glTarget,GL_TEXTURE_WRAP_T,GL_REPEAT )
			Else
				glTexParameteri( _glTarget,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE )
			Endif
			
			If _retroMode
				glTexParameteri( _glTarget,GL_TEXTURE_MAG_FILTER,GL_NEAREST )
				glTexParameteri( _glTarget,GL_TEXTURE_MIN_FILTER,GL_NEAREST )
			Else If _flags & TextureFlags.Mipmap
				If _flags & TextureFlags.Filter
					glTexParameteri( _glTarget,GL_TEXTURE_MAG_FILTER,GL_LINEAR )
					glTexParameteri( _glTarget,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR )
				Else
					glTexParameteri( _glTarget,GL_TEXTURE_MAG_FILTER,GL_NEAREST )
					glTexParameteri( _glTarget,GL_TEXTURE_MIN_FILTER,GL_NEAREST_MIPMAP_NEAREST )
				Endif
			Else If _flags & TextureFlags.Filter
				glTexParameteri( _glTarget,GL_TEXTURE_MAG_FILTER,GL_LINEAR )
				glTexParameteri( _glTarget,GL_TEXTURE_MIN_FILTER,GL_LINEAR )
			Else
				glTexParameteri( _glTarget,GL_TEXTURE_MAG_FILTER,GL_NEAREST )
				glTexParameteri( _glTarget,GL_TEXTURE_MIN_FILTER,GL_NEAREST )
			Endif
			
			glCheck()
		Endif
		
		If _dirty & Dirty.TexImage
			
			If _glTarget=GL_TEXTURE_CUBE_MAP

				Const cubeFaces:=New GLenum[]( 
					GL_TEXTURE_CUBE_MAP_NEGATIVE_X,GL_TEXTURE_CUBE_MAP_POSITIVE_Z,GL_TEXTURE_CUBE_MAP_POSITIVE_X,
					GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,GL_TEXTURE_CUBE_MAP_POSITIVE_Y,GL_TEXTURE_CUBE_MAP_NEGATIVE_Y )
					
				Const offsets:=New Int[]( 0,1, 1,1, 2,1, 3,1, 1,0, 1,2 )
				
				For Local i:=0 Until 6
					If _managed
						Local image:=_managed.Window( offsets[i*2]*Width,offsets[i*2+1]*Height,Width,Height )
						If _flags & TextureFlags.Mipmap
							UploadTexImageCubeMap( cubeFaces[i],image )
							_dirty&=~Dirty.Mipmaps
						Else
							UploadTexImage2D( cubeFaces[i],image )
						Endif
					Else
						ClearTexImage2D( cubeFaces[i] )
					Endif
				Next
			Else
				If _managed
					UploadTexImage2D( _glTarget,_managed )
				Else
					ClearTexImage2D( _glTarget )
				Endif
			Endif
			
			glCheck()
		
		Endif
		
		If _dirty & Dirty.Mipmaps
			
			If _flags & TextureFlags.Mipmap glGenerateMipmap( _glTarget )
				
			glCheck()
		End
		
		_dirty=Null
		
		glPopTexture()
		
		glCheck()

		Return _glTexture
	End
	
	Protected

	#rem monkeydoc @hidden
	#end	
	Method OnDiscard() Override
		
		If _cubeMap return
		
		If _glSeq=glGraphicsSeq glDeleteTextures( 1,Varptr _glTexture )
			
		_discarded=True
		_managed=Null
		_glTexture=0
		_glSeq=0
	End
	
	#rem monkeydoc @hidden
	#end	
	Method OnFinalize() Override
		
		If _cubeMap return
		
		If _glSeq=glGraphicsSeq glDeleteTextures( 1,Varptr _glTexture )
	End
	
	Private
	
	Enum Dirty
		TexParams=	1
		TexImage=	2
		Mipmaps=	4
		All=		7
	End
	
	'Global _boundSeq:Int
	'Global _bound:=New GLuint[8]

	Field _size:Vec2i
	Field _format:PixelFormat
	Field _flags:TextureFlags
	Field _managed:Pixmap
	Field _cubeMap:Texture
	Field _cubeFaces:Texture[]
	
	Field _glTarget:GLenum
	Field _glInternalFormat:GLenum
	Field _glFormat:GLenum
	Field _glType:GLenum
	
	Field _discarded:Bool
	Field _retroMode:Bool
	
	Field _dirty:Dirty
	
	Field _glSeq:Int	
	Field _glTexture:GLuint
	
	Method UploadTexImageCubeMap( glTarget:GLenum,image:Pixmap )
		
		Assert( Not _cubeMap )
	
		Local format:=PixelFormat.RGBA32
		Local gliformat:=glInternalFormat( format )
		Local glformat:=glFormat( format )
		Local gltype:=glType( format )
	
		Local data:=image.Convert( format )
		
		Local width:=Width,height:=Height,mip:=0
		
		While width>=1 And height>=1
		
'			Print "Uploading cube texture, width="+width+", height="+height+", mip="+mip
		
			glTexImage2D( glTarget,mip,gliformat,width,height,0,glformat,gltype,Null )
			
			For Local y:=0 Until height
				
				Local p:=data.PixelPtr( 0,y )
				
				'write miplevel to alpha!
				For Local x:=0 Until width
					p[x*4+3]=mip
				Next
		
				glTexSubImage2D( glTarget,mip,0,y,width,1,glformat,gltype,p )
			Next
			
			glFlush() 'macos nvidia bug!
		
			If width=1 And height=1 Exit
			
			Local hdata:=data.MipHalve()
			data=hdata
			width/=2
			height/=2
			mip+=1
		
		Wend

	End
	
	Method UploadTexImage2D( glTarget:GLenum,image:Pixmap )
		
		Assert( Not _cubeMap )
		
		glCheck()
		
		Local width:=image.Width,height:=image.Height

		glPixelStorei( GL_UNPACK_ALIGNMENT,1 )
	
		If image.Pitch=width*image.Depth
			glTexImage2D( glTarget,0,_glInternalFormat,width,height,0,_glFormat,_glType,image.Data )
		Else
			glTexImage2D( glTarget,0,_glInternalFormat,width,height,0,_glFormat,_glType,Null )
			For Local y:=0 Until height
				glTexSubImage2D( glTarget,0,0,y,width,1,_glFormat,_glType,image.PixelPtr( 0,y ) )
			Next
		Endif
		
		glFlush() 'macos nvidia bug!
		
		glCheck()
	End
	
	Method ClearTexImage2D( glTarget:GLenum )
		glCheck()
		
		Local width:=_size.x,height:=_size.y
		
		glTexImage2D( glTarget,0,_glInternalFormat,width,height,0,_glFormat,_glType,Null )
		
		If Not IsDepth( _format )
			
			Local image:=New Pixmap( width,1,Format )
			image.Clear( Color.Magenta )
			
			For Local iy:=0 Until height
				glTexSubImage2D( glTarget,0,0,iy,width,1,_glFormat,_glType,image.Data )
			Next
			
			glFlush() 'macos nvidia bug!
		
		Endif
		
		glCheck()
	End
	
End

Class ResourceManager Extension

	Method OpenTexture:Texture( path:String,flags:TextureFlags=Null )

		Local slug:="Texture:name="+StripDir( StripExt( path ) )+"&flags="+Int( flags )
		
		Local texture:=Cast<Texture>( OpenResource( slug ) )
		If texture Return texture
		
		Local pixmap:=OpenPixmap( path,Null,True )
		If Not pixmap Return Null
		
		texture=New Texture( pixmap,flags )
		
		AddResource( slug,texture )
		
		Return texture
	End

End
