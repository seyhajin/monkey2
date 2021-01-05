
Namespace mojo.graphics

Using std.resource

Private

'fake it for now!
const GL_RGBA32F:=	$8814
const GL_RGB32F:=	$8815
const GL_RGBA16F:=	$881A
const GL_RGB16F:=	$881B

const GL_DEPTH_COMPONENT32F:=$8CAC

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
'	Case PixelFormat.RGBA16F Return GL_RGBA
	Case PixelFormat.RGB32F Return BBGL_ES ? GL_RGB Else GL_RGB32F
	Case PixelFormat.RGBA32F Return BBGL_ES ? GL_RGBA Else GL_RGBA32F
	Case PixelFormat.Depth32 Return GL_DEPTH_COMPONENT
		'jladded
		Case PixelFormat.Depth32F Return GL_DEPTH_COMPONENT
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
'	Case PixelFormat.RGBA16F Return GL_RGBA
	Case PixelFormat.RGB32F Return GL_RGB
	Case PixelFormat.RGBA32F Return GL_RGBA
	Case PixelFormat.Depth32 Return GL_DEPTH_COMPONENT
		'jl added
		Case PixelFormat.Depth32F Return GL_DEPTH_COMPONENT
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
'	Case PixelFormat.RGBA16F Return GL_HALF_FLOAT
	Case PixelFormat.RGB32F Return GL_FLOAT
	Case PixelFormat.RGBA32F Return GL_FLOAT
	Case PixelFormat.Depth32 Return GL_UNSIGNED_INT
	'jl added
	Case PixelFormat.Depth32F Return GL_UNSIGNED_INT
	End
	RuntimeError( "Invalid PixelFormat" )
	Return GL_UNSIGNED_BYTE
End

Function UploadTexImage2D( glTarget:GLenum,image:Pixmap,mipmap:Bool,envmap:Bool )
	
	glCheck()
	
	Local format:=image.Format
	
	Local gliformat:=glInternalFormat( format )
	Local glformat:=glFormat( format )
	Local gltype:=glType( format )
	
	Local mip:=0
	
	Repeat
		
		Local width:=image.Width,height:=image.Height
		
		If envmap
			'write mip level into alpha channel
			Select format
			Case PixelFormat.RGBA8
				For Local y:=0 until height
					Local p:=image.PixelPtr( 0,y )
					'write miplevel to alpha!
					For Local x:=0 Until width
						p[x*4+3]=mip
					Next
				Next
			Case PixelFormat.RGBA32F
				For Local y:=0 until height
					Local p:=Cast<Float Ptr>( image.PixelPtr( 0,y ) )
					'write miplevel to alpha!
					For Local x:=0 Until width
						p[x*4+3]=mip/255.0
					Next
				Next
			Default
				Assert( False )
			End
		Endif
		
		If image.Pitch=width * image.Depth
			glTexImage2D( glTarget,mip,gliformat,width,height,0,glformat,gltype,image.Data )
			glCheck()
		Else
			glTexImage2D( glTarget,mip,gliformat,width,height,0,glformat,gltype,Null )
			glCheck()
			For Local y:=0 Until height
				glTexSubImage2D( glTarget,mip,0,y,width,1,glformat,gltype,image.PixelPtr( 0,y ) )
				glCheck()
			Next
		Endif
		
		glFlush() 'macos nvidia bug!
		
		If Not envmap Exit
		
		If image.Width=1 And image.Height=1 Exit
		image=image.MipHalve()
		mip+=1
	Forever
	
	glCheck()
End

Function ClearTexImage2D( glTarget:GLenum,width:Int,height:Int,format:PixelFormat,color:Color )
	
	glCheck()
	
	Local gliformat:=glInternalFormat( format )
	Local glformat:=glFormat( format )
	Local gltype:=glType( format )
	
	glTexImage2D( glTarget,0,gliformat,width,height,0,glformat,gltype,Null )
	
	If Not IsDepth( format )
		
		Local image:=New Pixmap( width,1,format )
		image.Clear( color )
		
		For Local iy:=0 Until height
			glTexSubImage2D( glTarget,0,0,iy,width,1,glformat,gltype,image.Data )
		Next
		
		glFlush() 'macos nvidia bug!
	
	Endif
	
	glCheck()
End

Public

#rem monkeydoc Texture flags.

| TextureFlags	| Description
|:--------------|:-----------
| WrapS			| Wrap S texture coordinates
| WrapT			| Wrap T texture coordinates
| WrapST		| Wrap both S and T coordinates
| Filter		| Enable magnification filtering
| Mipmap		| Enable minification mipmapping, and minification filtering if Filter enabled.
| FilterMipmap	| Enable both filterin and mipmapping.
| Dynamic		| The texture contents are regularly updated and don't need to be preserved.
| Cubemap		| The texture is a cubmap.
#end
Enum TextureFlags
	None=			$0000
	WrapS=			$0001
	WrapT=			$0002
	Filter=			$0004
	Mipmap=			$0008
	
	Dynamic=		$0100
	Cubemap=		$0200
	Envmap=			$0400
	
	WrapST=			WrapS|WrapT
	FilterMipmap=	Filter|Mipmap
End

#rem monketdoc @hidden
#end
Enum CubeFace
	PositiveX
	NegativeX
	PositiveY
	NegativeY
	PositiveZ
	NegativeZ
End

#rem monkeydoc The Texture class.

The "MOJO_TEXTURE_MAX_ANISOTROPY" config setting control the max anisotropy of mipmapped textures.

#end
Class Texture Extends Resource
	
	#rem monkeydoc Creates a new texture.
	
	The "MOJO_TEXTURE_MAX_ANISOTROPY" config setting control the max anisotropy of mipmapped textures.

	#end
	Method New( width:Int,height:Int,format:PixelFormat,flags:TextureFlags )
		
		Init( width,height,format,flags,Null )
	End
	
	Method New( pixmap:Pixmap,flags:TextureFlags )
		
		If flags & TextureFlags.Cubemap

			Local size:=pixmap.Size
			
			If size.x=size.y			'1x1?
				
				Init( size.x,size.y,pixmap.Format,flags,Null )
				
				For Local i:=0 Until 6
					_cubeFaces[i].PastePixmap( pixmap,0,0 )
				Next
				
			Else If size.x/4*3=size.y	'4x3?
				
				size=New Vec2i( size.x/4,size.y/3 )
				
				Init( size.x,size.y,pixmap.Format,flags,Null )
				
				Const offsets:=New Int[]( 2,1, 0,1, 1,0, 1,2, 1,1, 3,1 )
				
				For Local i:=0 Until 6
					Local face:=pixmap.Window( offsets[i*2]*size.x,offsets[i*2+1]*size.y,size.x,size.y )
					_cubeFaces[i].PastePixmap( face,0,0 )
				Next
				
			Else
				RuntimeError( "Invalid Cubemap image size" )
			Endif
			
			Return
		Endif
			
		If Not (flags & TextureFlags.Dynamic)
			Init( pixmap.Width,pixmap.Height,pixmap.Format,flags,pixmap )
		Else
			Init( pixmap.Width,pixmap.Height,pixmap.Format,flags,Null )
			PastePixmap( pixmap,0,0 )
		Endif
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

#If Not __DESKTOP_TARGET__
		If Not IsPow2( _size.x,_size.y ) flags&=~TextureFlags.Mipmap
#Endif

		Local mask:=TextureFlags.WrapS|TextureFlags.WrapT|TextureFlags.Filter|TextureFlags.Mipmap
		
		_flags=(_flags & ~mask) | (flags & mask)
		
		If _flags & TextureFlags.Mipmap _dirty|=Dirty.Mipmaps Else _dirty&=~Dirty.Mipmaps
		
		_dirty|=Dirty.TexParams
	End
	
	Property ManagedPixmap:Pixmap()
		
		Return _managed
	End
	
	Method PastePixmap( pixmap:Pixmap,x:Int,y:Int )
		
		If _managed
			_managed.Paste( pixmap,x,y )
			_dirty|=Dirty.TexImage
			Return
		Endif

		_dirty&=~Dirty.Mipmaps	'don't bother generating mipmaps when validating texture...
			
		glActiveTexture( GL_TEXTURE7 )
		
		glBindTexture( _cubeMap ? _cubeMap._glTarget Else _glTarget,ValidateGLTexture() )
		
		If pixmap.Pitch=pixmap.Width*pixmap.Depth
			glTexSubImage2D( _glTarget,0,x,y,pixmap.Width,pixmap.Height,glFormat( _format ),GL_UNSIGNED_BYTE,pixmap.Data )
		Else
			For Local iy:=0 Until pixmap.Height
				glTexSubImage2D( _glTarget,0,x,y+iy,pixmap.Width,1,glFormat( _format ),GL_UNSIGNED_BYTE,pixmap.PixelPtr( 0,iy ) )
			Next
		Endif
		
		If _flags & TextureFlags.Mipmap _dirty|=Dirty.Mipmaps
	End
	
	Method GetCubeFace:Texture( face:CubeFace )
		
		If _cubeFaces Return _cubeFaces[ Cast<Int>( face ) ]
		
		Return Null
	End

	Function Load:Texture( path:String,flags:TextureFlags=TextureFlags.FilterMipmap,flipNormalY:Bool=False )
		
		Local format:=PixelFormat.Unknown
		If flags & TextureFlags.Envmap
			If ExtractExt( path )=".hdr"
				format=PixelFormat.RGBA32F
			Else
				format=PixelFormat.RGBA8
			Endif
		Endif
		
		Local pixmap:=Pixmap.Load( path,format,True )
		If Not pixmap Return Null
		
		If flipNormalY
			For Local y:=0 Until pixmap.Height
				For Local x:=0 Until pixmap.Width
					pixmap.SetPixelARGB( x,y,pixmap.GetPixelARGB( x,y ) ~ $ff00 )
				Next
			Next
		Endif
		
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
		
		If _managed 
'			Print "Texture Modified - Update managed"
			glReadPixels( r.X,r.Y,r.Width,r.Height,GL_RGBA,GL_UNSIGNED_BYTE,_managed.PixelPtr( r.X,r.Y ) )
		Endif

		If _flags & TextureFlags.Mipmap _dirty|=Dirty.Mipmaps
	End
	
	#rem monkeydoc @hidden
	#end
	Method Bind( unit:Int )
		
'		Assert( unit<7 And Not _cubeMap )
		
		Local gltex:=ValidateGLTexture()
		
		glActiveTexture( GL_TEXTURE0+unit )
		glBindTexture( _glTarget,gltex )
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
		
		glActiveTexture( GL_TEXTURE7 )
		glBindTexture( _glTarget,_glTexture )

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
			Else
				 If _flags & TextureFlags.Mipmap
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
				
				If _flags & TextureFlags.Mipmap And Not (_flags & (TextureFlags.Cubemap|TextureFlags.Envmap))
'					If glexts.GL_texture_filter_anisotropic
						Local max:Int=0
						glGetIntegerv( GL_MAX_TEXTURE_MAX_ANISOTROPY,Varptr max )
						Local n:=Min( Int(GetConfig( "MOJO_TEXTURE_MAX_ANISOTROPY",max )),max )
						glTexParameteri( _glTarget,GL_TEXTURE_MAX_ANISOTROPY,n )
'					Endif
				Endif
								
			Endif
			
			glCheck()
		Endif
		
		If _dirty & Dirty.TexImage
			
			Local mipmap:=(_flags & TextureFlags.Mipmap)<>Null
			Local envmap:=(_flags & TextureFlags.Envmap)<>Null
			
			Select _glTarget
			Case GL_TEXTURE_2D
				
				If _managed
					UploadTexImage2D( _glTarget,_managed,mipmap,envmap )
					If envmap mipmap=False
				else
					ClearTexImage2D( _glTarget,_size.x,_size.y,_format,Color.Black )
				Endif
					
			Case GL_TEXTURE_CUBE_MAP
				
				If _cubeFaces[0]._managed
					For Local i:=0 Until 6
						Local face:=_cubeFaces[i]
						UploadTexImage2D( face._glTarget,face._managed,mipmap,envmap )
					Next
					If envmap mipmap=False
				Else
					For Local i:=0 Until 6
						Local face:=_cubeFaces[i]
						ClearTexImage2D( face._glTarget,face._size.x,face._size.y,face._format,Color.Black )
					Next
				Endif
				
			End
			
			If mipmap glGenerateMipmap( _glTarget )
			_dirty&=~Dirty.Mipmaps
			
		Endif
		
		If _dirty & Dirty.Mipmaps
			If _flags & TextureFlags.Mipmap 
				glGenerateMipmap( _glTarget )
				glCheck()
			Endif
		End
		
		_dirty=Null
		
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
	
	Field _discarded:Bool
	Field _retroMode:Bool
	
	Field _dirty:Dirty
	
	Field _glSeq:Int	
	Field _glTexture:GLuint
	
	Method Init( width:Int,height:Int,format:PixelFormat,flags:TextureFlags,managed:Pixmap )
		
		If flags & TextureFlags.Cubemap Assert( width=height,"Cubemaps must be square" )

		_size=New Vec2i( width,height )
		_format=format
		_flags=flags
		
		_glTarget=_flags & TextureFlags.Cubemap ? GL_TEXTURE_CUBE_MAP Else GL_TEXTURE_2D

#If Not __DESKTOP_TARGET__
		If Not IsPow2( _size.x,_size.y ) _flags&=~TextureFlags.Mipmap
#Endif
		If _flags & TextureFlags.Cubemap
			
			_cubeFaces=New Texture[6]
			
			For Local i:=0 Until 6
				Local face:=New Texture( _size.x,_size.y,_format,_flags & ~TextureFlags.Cubemap )
				face._glTarget=GL_TEXTURE_CUBE_MAP_POSITIVE_X+i
				face._cubeMap=Self
				_cubeFaces[i]=face
			Next
			
			Return
		Endif
		
		If Not (_flags & TextureFlags.Dynamic)
			If Not managed managed=New Pixmap( width,height,format )
			_managed=managed
		Endif
		
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
