
Namespace std.graphics.pixmaploader

Using stb.image
Using std.stream

Internal

Struct stbi_user
	Field stream:Stream
End

Function stbi_read:Int( user:Void Ptr,data:stbi_char Ptr,count:Int )
	Local stream:=Cast<stbi_user Ptr>( user )[0].stream
	Return stream.Read( data,count )
End

Function stbi_skip:Void( user:Void Ptr,count:Int )
	Local stream:=Cast<stbi_user Ptr>( user )[0].stream
	stream.Seek( stream.Position+count )
End

Function stbi_eof:Int( user:Void Ptr )
	Local stream:=Cast<stbi_user Ptr>( user )[0].stream
	Return stream.Eof
End

Class StbPixmap Extends Pixmap
	
	Method New( width:Int,height:Int,format:PixelFormat,data:UByte Ptr,pitch:Int )
		Super.New( width,height,format,data,pitch )
		
		_data=data
	End
	
	Private
	
	Field _data:UByte Ptr
	
	Method OnDiscard() Override
		
		If Not _data Return
		
		stbi_image_free( _data )
		
		Super.OnDiscard()
		
		_data=Null
	End
	
	Method OnFinalize() Override
		
	 	stbi_image_free( _data )
	End
End

Function LoadPixmap:Pixmap( path:String, format:PixelFormat )
	
	Local stream:=Stream.Open( path,"r" )
	If Not stream Return Null

	Local user:stbi_user
	user.stream=stream
	
	Local clbks:stbi_io_callbacks
	clbks.read=stbi_read
	clbks.skip=stbi_skip
	clbks.eof=stbi_eof

	Local req_comp:Int,isfloat:Bool
	
	Select format
	Case PixelFormat.I8,PixelFormat.IA8,PixelFormat.RGB8,PixelFormat.RGBA8
		isfloat=False
		req_comp=PixelFormatDepth( format )
	Case PixelFormat.RGB32F
		isfloat=True
		req_comp=3
	Case PixelFormat.RGBA32F
		isfloat=True
		req_comp=4
	Case PixelFormat.Unknown
		Local pos:=stream.Position
		isfloat=stbi_is_hdr_from_callbacks( Varptr clbks,Varptr user )
		stream.Seek( pos )
		req_comp=0
	Default
		stream.Close()
		Return Null
	End
	
	Local x:Int,y:Int,comp:Int,data:UByte Ptr
	
	If isfloat
		
		stbi_ldr_to_hdr_gamma( 1.0 )
		stbi_hdr_to_ldr_gamma( 1.0 )
		
		data=Cast<UByte Ptr>( stbi_loadf_from_callbacks( Varptr clbks,Varptr user,Varptr x,Varptr y,Varptr comp,req_comp ) )
		
		If format=PixelFormat.Unknown
			Select comp
			Case 1 format=PixelFormat.I32F
			Case 2 format=PixelFormat.IA32F
			Case 3 format=PixelFormat.RGB32F
			Case 4 format=PixelFormat.RGBA32F
			End
		Endif
	Else
		
		data=stbi_load_from_callbacks( Varptr clbks,Varptr user,Varptr x,Varptr y,Varptr comp,req_comp )
		
		If format=PixelFormat.Unknown
			Select comp
			Case 1 format=PixelFormat.I8
			Case 2 format=PixelFormat.IA8
			Case 3 format=PixelFormat.RGB8
			Case 4 format=PixelFormat.RGBA8
			End
		Endif
	Endif
	
	stream.Close()
	
	If format=PixelFormat.Unknown
		Print "Unknown format for image at '"+path+"'"
		Return Null
	endif
	
	Local pixmap:=New StbPixmap( x,y,format,data,x*PixelFormatDepth( format ) )
	
	'jl added
	pixmap.FilePath = path
	
	Return pixmap
End

#rem

#rem monkeydoc @hidden
#end
Function LoadPixmap:Pixmap( path:String,format:PixelFormat )
	
	If ExtractExt( path )=".hdr"
		
		Local file:=filesystem.OpenCFile( path,"rb" )
		If Not file Return Null
		
		Local width:=0,height:=0
		
		If RGBE_ReadHeader( file,Varptr width,Varptr height,Null )<>0
			libc.fclose( file )
			Return Null
		Endif
		
		Local pixmap:=New Pixmap( width,height,PixelFormat.RGB32F )
	
		RGBE_ReadPixels_RLE( file,Cast<Float Ptr>( pixmap.Data ),width,height )
		
		If format<>PixelFormat.Unknown And format<>PixelFormat.RGB32F
			pixmap=pixmap.Convert( format )
		Endif
		
		libc.fclose( file )
		Return pixmap
	Endif

	Local x:Int,y:Int,comp:Int,req_comp:Int
	
	If format<>PixelFormat.Unknown req_comp=PixelFormatDepth( format )
	
	Local stream:=Stream.Open( path,"r" )
	If Not stream Return Null

	Local user:stbi_user
	user.stream=stream
	
	Local clbks:stbi_io_callbacks
	clbks.read=stbi_read
	clbks.skip=stbi_skip
	clbks.eof=stbi_eof
	
	Local data:=stbi_load_from_callbacks( Varptr clbks,Varptr user,Varptr x,Varptr y,Varptr comp,req_comp )
	
	stream.Close()
	
	If Not data Return Null
	
	If format=PixelFormat.Unknown
		Select comp
		Case 1 format=PixelFormat.I8
		Case 2 format=PixelFormat.IA16
		Case 3 format=PixelFormat.RGB24
		Case 4 format=PixelFormat.RGBA32
		Default Assert( False )
		End
	End
	
	Local pixmap:=New StbPixmap( x,y,format,data,x*PixelFormatDepth( format ) )
	
	Return pixmap
End

#End