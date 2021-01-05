
Namespace std.stream

Using libc
Using std.memory
Using std.collections

#rem monkeydoc Stream class.
#end
Class Stream Extends std.resource.Resource

	#rem monkeydoc True if no more data can be read from the stream.
	#end
	Property Eof:Bool() Abstract
	
	#rem monkeydoc Current stream position.
	
	In the case of non-seekable streams, `Position` will always be -1.
	
	#end
	Property Position:Int() Abstract

	#rem monkeydoc Current stream length.
	
	In the case of non-seekable streams, `Length` is the number of bytes that can be read from the stream without 'blocking'.
	
	#end	
	Property Length:Int() Abstract
	
	#rem monkeydoc Closes the stream.
	#end
	Method Close:Void()
		
		If Not _open Return
		
		_open-=1
		
		If _open Return
		
		If _sharedPath _shared.Remove( _sharedPath )
		
		OnClose()
	End

	#rem monkeydoc Seeks to a position in the stream.
	
	In debug builds, a runtime error will occur if the stream is not seekable or `position` is out of range.
	
	@param position The position to seek to.
	
	#end
	Method Seek( position:Int ) Abstract
	
	#rem monkeydoc Reads data from the stream into memory.
	
	Reads `count` bytes of data from the stream into either a raw memory pointer or a databuffer.
	
	Returns the number of bytes actually read.
	
	@param buf A pointer to the memory to read the data into.
	
	@param data The databuffer to read the data into.
	
	@param count The number of bytes to read from the stream.
	
	@return The number of bytes actually read.
	
	#end
	Method Read:Int( buf:Void Ptr,count:Int ) Abstract
	
	Method Read:Int( data:DataBuffer,offset:Int,count:Int )
		DebugAssert( offset>=0 And count>=0 And offset+count<=data.Length )
		
		Return Read( data.Data+offset,count )
	End
	
	#rem monkeydoc Writes data to the stream from memory.
	
	Writes `count` bytes of data to the stream from either a raw memory pointer or a databuffer.
	
	Returns the number of bytes actually written
	
	@param buf A pointer to the memory to write the data from.

	@param data The databuffer to write the data from.
	
	@param count The number of bytes to write to the stream.
	
	@return The number of bytes actually written.
	
	#end
	Method Write:Int( buf:Void Ptr,count:Int ) Abstract

	Method Write:Int( data:DataBuffer,offset:Int,count:Int )
		DebugAssert( offset>=0 And count>=0 And offset+count<=data.Length )

		Return Write( data.Data+offset,count )
	End

	#rem monkeydoc The byte order of the stream.
	
	The default byte order is ByteOrder.LittleEndian.
	
	#end
	Property ByteOrder:ByteOrder()
		
		Return _swap ? ByteOrder.BigEndian Else ByteOrder.LittleEndian
		
	Setter( byteOrder:ByteOrder )
		
		_swap=(byteOrder=ByteOrder.BigEndian)
	End
	
	#rem monkeydoc Reads as many bytes as possible from a stream into memory.
	
	Continously reads data from a stream until either `count` bytes are read or the end of stream is reached.
	
	Returns the number of bytes read or the data read.

	@param buf memory to read bytes into.
	
	@param data data buffer to read bytes into.
	
	@param count number of bytes to read.
	
	#end
	Method ReadAll:Int( buf:Void Ptr,count:Int )
	
		Local pos:=0
		
		While pos<count
			Local n:=Read( Cast<UByte Ptr>( buf )+pos,count-pos )
			If n<=0 Exit
			pos+=n
		Wend
		
		Return pos
	End
	
	Method ReadAll:Int( data:DataBuffer,offset:Int,count:Int )
	
		Return ReadAll( data.Data+offset,count )
	End
	
	Method ReadAll:DataBuffer( count:Int )
	
		Local data:=New DataBuffer( count )
		Local n:=ReadAll( data,0,count )
		If n=count Return data
		Local tmp:=data.Slice( 0,n )
		data.Discard()
		Return tmp
	End
	
	Method ReadAll:DataBuffer()
	
		If Length>=0 Return ReadAll( Length-Position )

		Local bufs:=New Stack<DataBuffer>
		Local buf:=New DataBuffer( 4096 ),pos:=0
		Repeat
			pos=ReadAll( buf,0,4096 )
			If pos<4096 Exit
			bufs.Push( buf )
			buf=New DataBuffer( 4096 )
		Forever
		Local len:=bufs.Length * 4096 + pos
		Local data:=New DataBuffer( len )
		pos=0
		For Local buf:=Eachin bufs
			buf.CopyTo( data,0,pos,4096 )
			buf.Discard()
			pos+=4096
		Next
		buf.CopyTo( data,0,pos,len-pos )
		buf.Discard()
		Return data
	End

	#rem monkeydoc Reads data from the stream and throws it away.

	@param count The number of bytes to skip.
	
	@return The number of bytes actually skipped.
	
	#end
	Method Skip:Int( count:Int )

		If count<=0 Return 0
		
		Local tmp:=libc.malloc( 4096 ),n:=0
		
		While n<count
			Local t:=Read( tmp,Min( count-n,4096 ) )
			If t<=0 Exit
			n+=t
		Wend
		
		libc.free( tmp )
		Return n
	End
	
	Property SharedPath:String()
		
		If Not _sharedPath
			
			Global sharedId:=0
			sharedId+=1
			
			Local path:="@"+sharedId
			_sharedPath="stream::"+path
			_shared[path]=Self
		Endif
		
		Return _sharedPath
	End
	
	#rem monkeydoc Reopens the stream.
	#end
	Method Reopen:Stream()
		
		_open+=1
		
		Return Self
	End

#-	
'jl added

	#rem monkeydoc Write abool as an unsigned byte to the stream.
	@param data The ubyte to write.
	#end
	Method WriteBool( data:Bool )
		Local out:UByte = 0
		If data Then out = 1
		
'		_tmpbuf.PokeUByte( 0,out )
'		Write( _tmpbuf.Data,1 )
		Write( Varptr data,1 )
	End


	#rem monkeydoc Reads an unsigned byte as a bool from the stream.
	@return The ubyte read.
	#end
	Method ReadBool:Bool()
		Local n:UByte
		Read( Varptr n,1 )
		If n > 0 Then Return True

'		If Read( _tmpbuf.Data,1 )=1 Return _tmpbuf.PeekUByte( 0 ) = 1
		
		Return false
	End

'jl end
#-
	
	#rem monkeydoc Reads a byte from the stream.
	
	@return The byte read.
	
	#end
	Method ReadByte:Byte()
		
		Local n:Byte
		Read( Varptr n,1 )
		Return n
	End
	
	#rem monkeydoc Reads an unsigned byte from the stream.
	
	@return The ubyte read.
	
	#end
	Method ReadUByte:UByte()
		
		Local n:UByte
		Read( Varptr n,1 )
		Return n
	End
	
	#rem monkeydoc Reads a 16 bit short from the stream.
	
	@return The short read.
	
	#end
	Method ReadShort:Short()

		Local n:Short
		If Read( Varptr n,2 )<>2 n=0
		If _swap Swap2( Varptr n )
		Return n
	End
	
	#rem monkeydoc Reads a 16 bit unsigned short from the stream.
	
	@return The ushort read.
	
	#end
	Method ReadUShort:UShort()

		Local n:UShort
		If Read( Varptr n,2 )<>2 n=0
		If _swap Swap2( Varptr n )
		Return n
	End
	
	#rem monkeydoc Reads a 32 bit int from the stream.
	
	@return The int read.
	
	#end
	Method ReadInt:Int()
		
		Local n:Int
		If Read( Varptr n,4 )<>4 n=0
		If _swap Swap4( Varptr n )
		Return n
	End
	
	#rem monkeydoc Reads a 32 bit unsigned int from the stream.
	
	@return The uint read.
	
	#end
	Method ReadUInt:UInt()
		
		Local n:UInt
		If Read( Varptr n,4 )<>4 n=0
		If _swap Swap4( Varptr n )
		Return n
	End
	
	#rem monkeydoc Reads a 32 bit long from the stream.
	
	@return The long read.
	
	#end
	Method ReadLong:Long()
		
		Local n:Long
		If Read( Varptr n,8 )<>8 n=0
		If _swap Swap8( Varptr n )
		Return n
	End
	
	#rem monkeydoc Reads a 32 bit unsigned long from the stream.
	
	@return The ulong read.
	
	#end
	Method ReadULong:ULong()
		
		Local n:ULong
		If Read( Varptr n,8 )<>8 n=0
		If _swap Swap8( Varptr n )
		Return n
	End
	
	#rem monkeydoc Reads a 32 bit float from the stream.
	
	@return The float read.
	
	#end
	Method ReadFloat:Float()

		Local n:Float
		If Read( Varptr n,4 )<>4 n=0
		If _swap Swap4( Varptr n )
		Return n
	End
	
	#rem monkeydoc Reads a 64 bit double from the stream.
	
	@return The double read.
	
	#end
	Method ReadDouble:Double()
		
		Local n:Double
		If Read( Varptr n,8 )<>8 n=0
		If _swap Swap8( Varptr n )
		Return n
	End
	
	#rem monkeydoc Reads the entire stream into a string.
	#end
	Method ReadString:String()
		Local data:=ReadAll()
		Local str:=data.PeekString( 0 )
		data.Discard()
		Return str
	End
	
	#rem monkeydoc Reads a size prefixed string from the stream.
	
	Reads an int from the stream, then a string from that many bytes.

	@return the string read.
	
	#end
	Method ReadSizedString:String()
		Local n:=ReadInt() 
		Local data:=ReadAll( n )
		Local str:=data.PeekString( 0 )
		data.Discard()
		Return str
	End
	
	#rem monkeydoc Reads a null terminated cstring from the stream.
	
	@return the string read.
	
	#end
	Method ReadCString:String()
		Local buf:=New Stack<Byte>
		While Not Eof
			Local chr:=ReadByte()
			If Not chr Exit
			buf.Push( chr )
		Wend
		Return String.FromCString( buf.Data.Data,buf.Length )
	End
	
	#rem monkeydoc Reads a line of text from the stream.
	
	Bytes are read from the stream until a newline character (ascii code 10) or null character (ascii code 0) is read, or end of file is detected.
		
	The bytes read are returned in the form of a string, excluding any terminating newline or null character.
		
	Carriage return characters (ascii code 13) are silently ignored.
	
	#end
	Method ReadLine:String()
		Local buf:=New Stack<Byte>
		While Not Eof
			Local chr:=ReadByte()
			If Not chr Or chr=10 exit
			If chr=13 Continue
			buf.Push( chr )
		Wend
		Return String.FromCString( buf.Data.Data,buf.Length )
	End
	
	#rem monkeydoc Writes a byte to the stream.
	
	@param data The byte to write.
	
	#end
	Method WriteByte( data:Byte )
		
		Write( Varptr data,1 )
	End
	
	#rem monkeydoc Write an unsigned byte to the stream.
	
	@param data The ubyte to write.

	#end
	Method WriteUByte( data:UByte )
		
		Write( Varptr data,1 )
	End
	
	#rem monkeydoc Writes a 16 bit short to the stream.
	
	@param data The short to write.

	#end
	Method WriteShort( data:Short )

		If _swap Swap2( Varptr data )
		Write( Varptr data,2 )
	End
	
	#rem monkeydoc Writes a 16 bit unsigned short to the stream.
	
	@param data The ushort to write.

	#end
	Method WriteUShort( data:UShort )

		If _swap Swap2( Varptr data )
		Write( Varptr data,2 )
	End
	
	#rem monkeydoc Writes a 32 bit int to the stream.
	
	@param data The int to write.

	#end
	Method WriteInt( data:Int )
		
		If _swap Swap4( Varptr data )
		Write( Varptr data,4 )
	End
	
	#rem monkeydoc Writes a 32 bit unsigned int to the stream.
	
	@param data The uint to write.

	#end
	Method WriteUInt( data:UInt )

		If _swap Swap4( Varptr data )
		Write( Varptr data,4 )
	End
	
	#rem monkeydoc Writes a 64 bit long to the stream.
	
	@param data The long to write.

	#end
	Method WriteLong( data:Long )

		If _swap Swap8( Varptr data )
		Write( Varptr data,8 )
	End
	
	#rem monkeydoc Writes a 64 bit unsigned long to the stream.
	
	@param data The ulong to write.

	#end
	Method WriteULong( data:ULong )

		If _swap Swap8( Varptr data )
		Write( Varptr data,8 )
	End
	
	#rem monkeydoc Writes a 32 bit float to the stream,
	
	@param data The float to write.

	#end
	Method WriteFloat:Void( data:Float )

		If _swap Swap4( Varptr data )
		Write( Varptr data,4 )
	End
	
	#rem monkeydoc Writes a 64 bit double to the stream.
	
	@param data The double to write.

	#end
	Method WriteDouble( data:Double )

		If _swap Swap8( Varptr data )
		Write( Varptr data,8 )
	End
	
	#rem monkeydoc Writes a string to the stream (NOT null terminated).

	@param str The string to write.
	
	#end
	Method WriteString( str:String )
		
		Local buf:=New DataBuffer( str.CStringLength )
		buf.PokeString( 0,str )
		Write( buf,0,buf.Length )
		buf.Discard()
	End
	
	#rem monkeydoc Writes a size prefixed string to the stream.
	
	Writes an int containing the size of the string to the stream, followed the string itself.
	
	#end
	Method WriteSizedString( str:String )
		
		WriteInt( str.CStringLength )
		WriteString( str )
	End
	
	#rem monkeydoc Writes a null terminated cstring to the stream.
	
	@param str The string to write.
	
	#end
	Method WriteCString( str:String )
		
		WriteString( str )
		WriteByte( 0 )
	End
	
	#rem monkeydoc Writes a line of text to the stream.
	
	Writes the characters in `str` followed by the line terminating sequence "~r~n".
	
	#end
	Method WriteLine( str:String )
		
		WriteString( str )
		WriteString( "~r~n" )
	End
	
	#rem monkeydoc Opens a stream
	
	`mode` should be "r" for read, "w" for write or "rw" for read/write.
	
	If the stream could not be opened, null will be returned.
	
	When opening a file using "r" or "rw", the file must already exist or the function will fail and null will be returned.
	
	When opening a file using "w", any existing file at the same path will be overwritten.
	
	Stream paths may include the following prefixes:
	
	| Stream path prefix	| Supported targets | Description
	|:----------------------|:------------------|:-----------
	| `asset::`				| All				| Open a stream for reading an app asset.
	| `internal::`			| Mobile			| Open a stream for reading/writing internal app storage.
	| `external::`			| Android			| Open a stream for reading/writing external app storage.
	| `home::`				| Desktop 			| Open a stream for reading/writing a file in the user's home directory.
	| `desktop::`			| Desktop 			| Open a stream for reading/writing a file in the user's desktop directory.
	
	@param mode The mode to open the stream in: "r", "w" or "rw"
	
	#end
	Function Open:Stream( path:String,mode:String )

		Local i:=path.Find( "::" )
		If i=-1 Return FileStream.Open( path,mode )
		
		Local proto:=path.Slice( 0,i )
		Local ipath:=path.Slice( i+2 )
		
		If proto="stream" Return _shared[ipath].Reopen()
		
		Return OpenFuncs[proto]( proto,ipath,mode )
	End
	
	#rem monkeydoc Stream open function type
	#end
	Alias OpenFunc:Stream( proto:String,path:String,mode:String )
	
	#rem monkeydoc Stream open functions map
	#end
	Const OpenFuncs:=New StringMap<OpenFunc>
	
	Protected
	
	Method New()
		
		_swap=false
		
		_open=1
	End
	
	Method OnClose() Virtual
		
		Discard()
	End
	
	Private
	
	Field _swap:Bool
	
	Field _open:Int
	
	Field _sharedPath:String
	
	Global _shared:=New StringMap<Stream>
	
	Function Swap2( v:Void Ptr )
		Local t:=Cast<UShort Ptr>( v )[0]
		Cast<UShort Ptr>( v )[0]=(t Shr 8 & $ff) | (t & $ff) Shl 8
	End
	
	Function Swap4( v:Void Ptr )
		Local t:=Cast<UInt Ptr>( v )[0]
		Cast<UInt Ptr>( v )[0]=(t Shr 24 & $ff) | (t & $ff) Shl 24 | (t Shr 8 & $ff00) | (t & $ff00) Shl 8
	End
	
	Function Swap8( v:Void Ptr )
		Local t:=Cast<ULong Ptr>( v )[0]
		Cast<ULong Ptr>( v )[0]=(t Shr 56 & $ff) | (t & $ff) Shl 56 | (t Shr 40 & $ff00) | (t & $ff00) Shl 40 | (t Shr 24 & $ff0000) | (t & $ff0000) Shl 24 | (t Shr 8 & $ff000000) | (t & $ff000000) Shl 8
	End

End
