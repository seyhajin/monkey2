
Namespace std.graphics

Using std.resource

Extern Private

Function ldexp:Float( x:Float,exp:Int )
	
Function frexp:Float( arg:Float,exp:Int Ptr )
	
Private

Function GetColorRGBE8:Color( p:UByte Ptr)
	If Not p[3] Return Color.Black
	Local f:=ldexp( 1.0,p[3]-136 )
	Return New Color( p[0]*f,p[1]*f,p[2]*f )
End

Function SetColorRGBE8( p:UByte Ptr,color:Color )
	Local v:=color.r,e:=0
	If color.g>v v=color.g
	If color.b>v v=color.b
	If( v<1e-32) p[0]=0;p[1]=0;p[2]=0;p[3]=0;Return
	v=frexp( v,Varptr e ) * 256.0/v
	p[0]=color.r*v
	p[1]=color.g*v
	p[2]=color.b*v
	p[0]=e+128
End
	
Public

#rem monkeydoc Pixmaps allow you to store and manipulate rectangular blocks of pixel data.

A pixmap contains a block of memory used to store a rectangular array of pixels.

#end
Class Pixmap Extends Resource

	#rem monkeydoc Creates a new pixmap.
	
	When you have finished with the pixmap, you should call its inherited [[resource.Resource.Discard]] method.

	@param width The width of the pixmap in pixels.
	
	@param height The height of the pixmap in pixels.
	
	@param format The pixmap format.
	
	@param data A pointer to the pixmap data.
	
	@param pitch The pitch of the data.
	
	#end
	Method New( width:Int,height:Int,format:PixelFormat=PixelFormat.RGBA8 )
'		Print "New pixmap1, width="+width+", height="+height

		Local depth:=PixelFormatDepth( format )
		Local pitch:=width*depth
		Local data:=Cast<UByte Ptr>( GCMalloc( pitch*height ) )
		
		_width=width
		_height=height
		_format=format
		_depth=depth
		_pitch=pitch
		_owned=True
		_data=data
		
		'jl added
		_filePath = ""
	End

	
	Method New( width:Int,height:Int,format:PixelFormat,data:UByte Ptr,pitch:Int )
'		Print "New pixmap2, width="+width+", height="+height

		Local depth:=PixelFormatDepth( format )
		
		_width=width
		_height=height
		_format=format
		_depth=depth
		_data=data
		_pitch=pitch

		'jl added
		_filePath = ""
	End

	
	#rem monkeydoc The width and height of the pixmap.
	
	#end
	Property Size:Vec2i()
		Return New Vec2i( _width,_height )
	End


	#rem monkeydoc The pixmap width.
	
	#end
	Property Width:Int()
		Return _width
	End

	
	#rem monkeydoc The pixmap height.
	
	#end
	Property Height:Int()
		Return _height
	End
	
	#rem monkeydoc The pixmap format.
	
	#end
	Property Format:PixelFormat()
		
		Return _format
	End
	
	#rem monkeydoc The pixmap depth. 
	
	The number of bytes per pixel.
	
	#end
	Property Depth:Int()
		
		Return _depth
	End
	
	#rem monkeydoc True if pixmap format includes alpha.
	#end
	Property HasAlpha:Bool()
		
		Select _format
		Case PixelFormat.A8,PixelFormat.IA8,PixelFormat.RGBA8
			Return True
		End
		Return False
	End
	
	#rem monkeydoc The raw pixmap data.
	
	#end
	Property Data:UByte Ptr()
		
		Return _data
	End
	
	#rem monkeydoc The pixmap pitch.
	
	This is the number of bytes between one row of pixels in the pixmap and the next.
	
	#end
	Property Pitch:Int()
		
		Return _pitch
	End
	
'------------------------------------------------------------	
'jl added
	#rem monkeydoc Image filepath.
	#end
	Property FilePath:string()
		Return _filePath
	Setter( filePath:string )
		_filePath = filePath
	End
'------------------------------------------------------------

	#rem monkeydoc Gets a pointer to a pixel in the pixmap.
	
	@param x the x coordinate of the pixel.
	
	@param y the y coordinate of the pixel.
	
	@return the address of the pixel at `x`, `y`.
	
	#end
	Method PixelPtr:UByte Ptr( x:Int,y:Int )
		
		Return _data + y*_pitch + x*_depth
	End
	
	#rem monkeydoc Sets a pixel to a color.
	
	Sets the pixel at `x`, `y` to `pixel`.
	
	In debug builds, a runtime error will occur if the pixel coordinates lie outside of the pixmap area.
	
	@param x The x coordinate of the pixel.
	
	@param y The y coordinate of the pixel.
	
	@param color The color to set the pixel to.
	
	#end
	Method SetPixel( x:Int,y:Int,color:Color )
		DebugAssert( x>=0 And y>=0 And x<_width And y<_height,"Pixmap pixel coordinates out of range" )
		
		Local p:=PixelPtr( x,y )
		
		Select _format
		Case PixelFormat.A8
			p[0]=color.a * 255
		Case PixelFormat.I8
			p[0]=color.r * 255
		Case PixelFormat.IA8
			p[0]=color.r * 255
			p[1]=color.a * 255
		Case PixelFormat.RGB8
			p[0]=color.r * 255
			p[1]=color.g * 255
			p[2]=color.b * 255
		Case PixelFormat.RGBA8
			p[0]=color.r * 255
			p[1]=color.g * 255
			p[2]=color.b * 255
			p[3]=color.a * 255
		Case PixelFormat.RGB32F
			Local f:=Cast<Float Ptr>( p )
			f[0]=color.r
			f[1]=color.g
			f[2]=color.b
		Case PixelFormat.RGBA32F
			Local f:=Cast<Float Ptr>( p )
			f[0]=color.r
			f[1]=color.g
			f[2]=color.b
			f[3]=color.a
		Case PixelFormat.RGBE8
			SetColorRGBE8( p,color )
		Default
			Assert( False )
		End
	End

	#rem monkeydoc Gets the color of a pixel.
	
	Gets the pixel at `x`, `y` and returns it in ARGB format.
	
	In debug builds, a runtime error will occur if the pixel coordinates lie outside of the pixmap area.

	@param x The x coordinate of the pixel.
	
	@param y The y coordinate of the pixel.
	
	@return The color of the pixel at `x`, `y`.
	
	#end
	Method GetPixel:Color( x:Int,y:Int )
		DebugAssert( x>=0 And y>=0 And x<_width And y<_height,"Pixmap pixel coordinates out of range" )
	
		Local p:=PixelPtr( x,y )

		Select _format
		Case PixelFormat.A8 
			Return New Color( 0,0,0,p[0]/255.0 )
		Case PixelFormat.I8
			Local i:=p[0]/255.0
			Return New Color( i,i,i,1 )
		Case PixelFormat.IA8
			Local i:=p[0]/255.0
			Return New Color( i,i,i,p[1]/255.0 )
		Case PixelFormat.RGB8
			Return New Color( p[0]/255.0,p[1]/255.0,p[2]/255.0,1 )
		Case PixelFormat.RGBA8
			Return New Color( p[0]/255.0,p[1]/255.0,p[2]/255.0,p[3]/255.0 )
		Case PixelFormat.RGB32F
			Local f:=Cast<Float Ptr>( p )
			Return New Color( f[0],f[1],f[2] )
		Case PixelFormat.RGBA32F
			Local f:=Cast<Float Ptr>( p )
			Return New Color( f[0],f[1],f[2],f[3] )
		Case PixelFormat.RGBE8
			Return GetColorRGBE8( p )
		Default
			Assert( False )
		End
		Return Color.None
	End

'jl added
''------------------------------------------------------------
	#rem monkeydoc Sets a pixel to an RGBA color using bytes.
	Sets the pixel at `x`, `y` to `pixel`.
	In debug builds, a runtime error will occur if the pixel coordinates lie outside of the pixmap area.
	@param x The x coordinate of the pixel.
	@param y The y coordinate of the pixel.
	@param r the red component of the pixel.
	@param g the green component of the pixel.
	@param b the blue component of the pixel.
	@param a the alpha component of the pixel.
	#end
	method SetPixel( x:int, y:int, r:UByte, g:UByte, b:UByte, a:uByte )
		Local p:=PixelPtr( x,y )
		p[0] = r
		p[1] = g
		p[2] = b
		p[3] = a
	End method
	method SetPixel( x:int, y:int, r:float, g:float, b:float, a:float )
		Local p:=PixelPtr( x,y )
		p[0] = r * 255
		p[1] = g * 255
		p[2] = b * 255
		p[3] = a * 255
	End method
''------------------------------------------------------------	
	
	#rem monkeydoc Sets a pixel to an ARGB color.
	
	Sets the pixel at `x`, `y` to `pixel`.
	
	In debug builds, a runtime error will occur if the pixel coordinates lie outside of the pixmap area.
	
	@param x The x coordinate of the pixel.
	
	@param y The y coordinate of the pixel.
	
	@param color The pixel to set in ARGB format.
	
	#end
	Method SetPixelARGB( x:Int,y:Int,color:UInt )
		DebugAssert( x>=0 And y>=0 And x<_width And y<_height,"Pixmap pixel coordinates out of range" )
	
		Local p:=PixelPtr( x,y )
		
		Select _format
		Case PixelFormat.A8
			p[0]=color Shr 24
		Case PixelFormat.I8
			p[0]=color Shr 16
		Case PixelFormat.IA8
			p[0]=color Shr 24
			p[1]=color Shr 16
		Case PixelFormat.RGB8
			p[0]=color Shr 16
			p[1]=color Shr 8
			p[2]=color
		Case PixelFormat.RGBA8
			p[0]=color Shr 16
			p[1]=color Shr 8
			p[2]=color
			p[3]=color Shr 24
		Case PixelFormat.RGB32F
			Local f:=Cast<Float Ptr>( p )
			f[0]=((color Shr 16)&255)/255.0
			f[1]=((color Shr 8)&255)/255.0
			f[2]=(color&255)/255.0
		Case PixelFormat.RGBA32F
			Local f:=Cast<Float Ptr>( p )
			f[0]=((color Shr 16)&255)/255.0
			f[1]=((color Shr 8)&255)/255.0
			f[2]=(color&255)/255.0
			f[3]=((color Shr 24)&255)/255.0
		Case PixelFormat.RGBE8
			SetColorRGBE8( p,New Color( ((color Shr 16)&255)/255.0,((color Shr 8)&255)/255.0,(color&255)/255.0,((color Shr 24)&255)/255.0 ) )
		Default
			SetPixel( x,y,New Color( ((color Shr 16)&255)/255.0,((color Shr 8)&255)/255.0,(color&255)/255.0,((color Shr 24)&255)/255.0 ) )
		End
	End

	#rem monkeydoc Gets the ARGB color of a pixel.
	
	Get the pixel at `x`, `y` and returns it in ARGB format.

	@param x the x coordinate of the pixel.
	
	@param y the y coordinate of the pixel.
	
	@return the pixel at `x`, `y` in ARGB format.
	
	#end
	Method GetPixelARGB:UInt( x:Int,y:Int )
		DebugAssert( x>=0 And y>=0 And x<_width And y<_height,"Pixmap pixel coordinates out of range" )
	
		Local p:=PixelPtr( x,y )
		
		Select _format
		Case PixelFormat.A8 
			Return p[0] Shl 24
		Case PixelFormat.I8 
			Local i:=p[0]
			Return UByte($ff) Shl 24 | i Shl 16 | i Shl 8 | i
		Case PixelFormat.IA8
			Local i:=p[1]
			Return p[0] Shl 24 | i Shl 16 | i Shl 8 | i
		Case PixelFormat.RGB8
			Return UByte($ff) Shl 24 | p[0] Shl 16 | p[1] Shl 8 | p[2]
		Case PixelFormat.RGBA8
			Return p[3] Shl 24 | p[0] Shl 16 | p[1] Shl 8 | p[2]
		Case PixelFormat.RGB32F
			Local f:=Cast<Float Ptr>( p )
			Return UInt($ff) Shl 24 | UInt(f[0]*255.0) Shl 16 | UInt(f[1]*255.0) Shl 8 | UInt(f[2]*255.0)
		Case PixelFormat.RGBA32F
			Local f:=Cast<Float Ptr>( p )
			Return UInt(f[3]*255.0) Shl 24 | UInt(f[0]*255.0) Shl 16 | UInt(f[1]*255.0) Shl 8 | UInt(f[2]*255.0)
		Case PixelFormat.RGBE8
			Local color:=GetColorRGBE8( p )
			Return UInt($ff) Shl 24 | UInt(color.r*255.0) Shl 16 | UInt(color.g*255.0) Shl 8 | UInt(color.b*255.0)
		Default
			Local color:=GetPixel( x,y )
			Return UInt(color.a*255.0) Shl 24 | UInt(color.r*255.0) Shl 16 | UInt(color.g*255.0) Shl 8 | UInt(color.b*255.0)
		End

		Return 0
	End
	
	'Optimize!
	'
	#rem monkeydoc Clears the pixmap to a given color.
	
	@param color The color to clear the pixmap to.
	
	#end
	Method Clear( color:Color )

		For Local y:=0 Until _height
			For Local x:=0 Until _width
				SetPixel( x,y,color )
			Next
		Next
	End
	
	#rem monkeydoc Clears the pixmap to an ARGB color.
	
	@param color ARGB color to clear the pixmap to.
	
	#end
	Method ClearARGB( color:UInt )

		For Local y:=0 Until _height
			For Local x:=0 Until _width
				SetPixelARGB( x,y,color )
			Next
		Next
	End


	#rem monkeydoc Creates a copy of the pixmap.
	@return A new pixmap.
	#end
	Method Copy:Pixmap()
		Local pitch:=Width * Depth
		Local data:=Cast<UByte Ptr>( libc.malloc( pitch * Height ) )
		For Local y:=0 Until Height
			memcpy( data+y*pitch,PixelPtr( 0,y ),pitch )
		Next
		Return New Pixmap( Width, Height, Format, data, pitch )
	End

	
	#rem monkeydoc Paste a pixmap to the pixmap.
	In debug builds, a runtime error will occur if the operation would write to pixels outside of the pixmap.
	Note: No alpha blending is performed - pixels in the pixmap are simply overwritten.
	@param pixmap The pixmap to paste.
	@param x The x coordinate.
	@param y The y coordinate.
	#end
	Method Paste( pixmap:Pixmap, x:Int, y:Int )
		DebugAssert( x>=0 And x+pixmap._width<=_width And y>=0 And y+pixmap._height<=_height )
		
		For Local ty:=0 Until pixmap._height
			For Local tx:=0 Until pixmap._width
				SetPixel( x+tx,y+ty,pixmap.GetPixel( tx,ty ) )
			Next
		Next
	End

	'Optimize!
	'
	#rem monkeydoc Converts the pixmap to a different format.
	
	@param format The pixel format to convert the pixmap to.
	
	@return A new pixmap.
	
	#end
	Method Convert:Pixmap( format:PixelFormat )
		
		Local t:=New Pixmap( _width,_height,format )
		
		If IsFloatPixelFormat( _format ) And Not IsFloatPixelFormat( format )
			For Local y:=0 Until _height
				For Local x:=0 Until _width
					Local c:=GetPixel( x,y )
					c.r=Clamp( c.r,0.0,1.0 )
					c.g=Clamp( c.g,0.0,1.0 )
					c.b=Clamp( c.b,0.0,1.0 )
					c.a=Clamp( c.a,0.0,1.0 )
					t.SetPixel( x,y,c )
				Next
			Next
		Else
			For Local y:=0 Until _height
				For Local x:=0 Until _width
					t.SetPixel( x,y,GetPixel( x,y ) )
				Next
			Next
		Endif
		
		Return t
	End
	
	'Optimize!
	'
	#rem monkeydoc Premultiply pixmap r,g,b components by alpha.
	#end
	Method PremultiplyAlpha()
		
		Select _format
		Case PixelFormat.IA8,PixelFormat.RGBA8,PixelFormat.RGBA16F,PixelFormat.RGBA32F
			
			For Local y:=0 Until _height
				For Local x:=0 Until _width
					Local color:=GetPixel( x,y )
					color.r*=color.a
					color.g*=color.a
					color.b*=color.a
					SetPixel( x,y,color )
				Next
			Next
		End
	End
	
	#rem monkeydoc @hidden Halves the pixmap for mipmapping
	
	Mipmap must be even width and height.
	
	FIXME: Handle funky sizes.
	
	#end
	Method MipHalve:Pixmap()
		
		If Width=1 And Height=1 Return Null
		
		Local dst:=New Pixmap( Max( Width/2,1 ),Max( Height/2,1 ),Format )
		
		If Width=1
			For Local y:=0 Until dst.Height
				Local c0:=GetPixel( 0,y*2 )
				Local c1:=GetPixel( 0,y*2+1 )
				dst.SetPixel( 0,y,(c0+c1)*0.5 )
			Next
			Return dst
		Else If Height=1
			For Local x:=0 Until dst.Width
				Local c0:=GetPixel( x*2,0 )
				Local c1:=GetPixel( x*2+1,0 )
				dst.SetPixel( x,0,(c0+c1)*0.5 )
			Next
			Return dst
		Endif

		Select _format
		Case PixelFormat.RGBA8
			
			For Local y:=0 Until dst.Height
				
				Local dstp:=Cast<UInt Ptr>( dst.PixelPtr( 0,y ) )
				Local srcp0:=Cast<UInt Ptr>( PixelPtr( 0,y*2 ) )
				Local srcp1:=Cast<UInt Ptr>( PixelPtr( 0,y*2+1 ) )
				
				For Local x:=0 Until dst.Width
					
					Local src0:=srcp0[0],src1:=srcp0[1],src2:=srcp1[0],src3:=srcp1[1]
					
					Local dst:=( (src0 Shr 2)+(src1 Shr 2)+(src2 Shr 2)+(src3 Shr 2) ) & $ff000000
					dst|=( (src0 & $ff0000)+(src1 & $ff0000)+(src2 & $ff0000)+(src3 & $ff0000) ) Shr 2 & $ff0000
					dst|=( (src0 & $ff00)+(src1 & $ff00)+(src2 & $ff00)+(src3 & $ff00) ) Shr 2 & $ff00
					dst|=( (src0 & $ff)+(src1 & $ff)+(src2 & $ff)+(src3 & $ff) ) Shr 2
					
					dstp[x]=dst
					
					srcp0+=2
					srcp1+=2
				Next
			Next
		Default
			For Local y:=0 Until dst.Height
				
				For Local x:=0 Until dst.Width
					
					Local c0:=GetPixel( x*2,y*2 )
					Local c1:=GetPixel( x*2+1,y*2 )
					Local c2:=GetPixel( x*2+1,y*2+1 )
					Local c3:=GetPixel( x*2,y*2+1 )
					Local cm:=(c0+c1+c2+c3)*.25
					dst.SetPixel( x,y,cm )
				Next
			Next
		End
		
		Return dst
	End
	
	#rem monkeydoc Flips the pixmap on the Y axis.
	#end
	Method FlipY()
		
		Local sz:=Width*Depth
		
		Local tmp:=New UByte[sz]
		
		For Local y:=0 Until Height/2
			
			Local p1:=PixelPtr( 0,y )
			Local p2:=PixelPtr( 0,Height-1-y )
			
			libc.memcpy( tmp.Data,p1,sz )
			libc.memcpy( p1,p2,sz )
			libc.memcpy( p2,tmp.Data,sz )
		Next
	End
	
	#rem monkeydoc Returns a rectangular window into the pixmap.
	
	In debug builds, a runtime error will occur if the rectangle lies outside of the pixmap area.
	
	@param x The x coordinate of the top left of the rectangle.

	@param y The y coordinate of the top left of the rectangle.
	
	@param width The width of the rectangle.

	@param height The height of the rectangle.
	
	#end
	Method Window:Pixmap( x:Int,y:Int,width:Int,height:Int )
		DebugAssert( x>=0 And y>=0 And width>=0 And height>=0 And x+width<=_width And y+height<=_height )
		
		Local pixmap:=New Pixmap( width,height,_format,PixelPtr( x,y ),_pitch )
		
		Return pixmap
	End
	
	#rem monkeydoc Saves the pixmap to a file.
	
	The only save format currently suppoted is PNG.
	
	#End
	Method Save:Bool( path:String )
		Return SavePixmap( Self,path )
	End
	
	#rem monkeydoc Loads a pixmap from a file.
	
	@param path The file path.
	
	@param format The format to load the pixmap in.
	
	@return Null if the file could not be opened, or contained invalid image data.
	
	#end
	Function Load:Pixmap( path:String, format:PixelFormat=Null, pmAlpha:Bool=False )
		Local pixmap:=pixmaploader.LoadPixmap( path,format )
		
		If Not pixmap And Not ExtractRootDir( path ) pixmap=pixmaploader.LoadPixmap( "image::"+path,format )
		
		If pixmap And pmAlpha pixmap.PremultiplyAlpha()
		
		'jl added
		if pixmap then pixmap.FilePath = path
		
		Return pixmap
	End

	
Protected
	
	#rem monkeydoc @hidden
	#end
	Method OnDiscard() Override
		If _owned GCFree( _data )
			
		_data=Null
	End

	
	#rem monkeydoc @hidden
	#end
	Method OnFinalize() Override
		If _owned GCFree( _data )
	End

Private
	
'------------------------------------------------------------	
'jl added
	field _filePath:string
'------------------------------------------------------------

	Field _width:Int
	Field _height:Int
	Field _format:PixelFormat
	Field _depth:Int
	Field _pitch:Int
	Field _owned:Bool
	Field _data:UByte Ptr
End

Class ResourceManager Extension

	Method OpenPixmap:Pixmap( path:String,format:PixelFormat=Null,pmAlpha:Bool=False )
	
		Local slug:="Pixmap:name="+StripDir( StripExt( path ) )+"&format="+Int( format )+"&pmAlpha="+Int( pmAlpha )

		Local pixmap:=Cast<Pixmap>( OpenResource( slug ) )
		If pixmap Return pixmap
		
		pixmap=Pixmap.Load( path,format,pmAlpha )
		If Not pixmap Return Null
		
		AddResource( slug,pixmap )
		
		Return pixmap
	End
	
End
