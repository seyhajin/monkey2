
Namespace std.graphics.pixmaploader

Private

Using stb.image
Using std.stream

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

#rem monkeydoc @hidden
#end
Class StbPixmap Extends Pixmap
	
	Method New( width:Int,height:Int,format:PixelFormat,data:UByte Ptr,pitch:Int )
		Super.New( width,height,format,data,pitch )
		
		_data=data
	End
	
	Private
	
	Field _data:UByte Ptr
	
	Method OnDiscard() Override
		
		Super.OnDiscard()
		
		stbi_image_free( _data )
		
		_data=Null
	End
	
	Method OnFinalize() Override
		
	 	stbi_image_free( _data )
	End
End

Public

#rem monkeydoc @hidden
#end
Function LoadPixmap:Pixmap( path:String,format:PixelFormat )

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
