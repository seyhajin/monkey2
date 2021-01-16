
Namespace std.stream

Using libc

#rem monkeydoc FileStream class.
#end
Class FileStream Extends Stream

	#rem monkeydoc True if no more data can be read from the stream.
	
	You can still write to a filestream even if `Eof` is true - disk space permitting!
	
	#end
	Property Eof:Bool() Override
		Return _pos>=_end
	End

	#rem monkeydoc Current filestream position.
	
	The current file read/write position.
	
	#end
	Property Position:Int() Override
		Return _pos
	End

	#rem monkeydoc Current filestream length.
	
	The length of the filestream. This is the same as the length of the file.
	
	The file length can increase if you write past the end of the file.
	
	#end	
	Property Length:Int() Override
		Return _end
	End


'------------------------------------------------------------	
'jl added
	#rem monkeydoc stream filepath.
	#end
	Property FilePath:string()
		Return _filePath
	End
'------------------------------------------------------------
	
	#rem monkeydoc Seeks to a position in the filestream.
	
	@param offset The position to seek to.
	
	#end
	Method Seek( position:Int ) Override
		DebugAssert( position>=0 And position<=_end )
	
		fseek( _file,position,SEEK_SET )
		_pos=position
		DebugAssert( ftell( _file )=_pos )	'Sanity check...
	End
	
	#rem monkeydoc Reads data from the filestream.
	
	@param buf A pointer to the memory to read the data into.
	
	@param count The number of bytes to read.
	
	@return The number of bytes actually read.
	
	#end
	Method Read:Int( buf:Void Ptr,count:Int ) Override
		count=Clamp( count,0,_end-_pos )
		count=fread( buf,1,count,_file )
		_pos+=count
		DebugAssert( ftell( _file )=_pos )	'Sanity check...
		Return count
	End
	
	#rem monkeydoc Writes data to the filestream.
	
	Writing past the end of the file will increase the length of a filestream.
	
	@param buf A pointer to the memory to write the data from.
	
	@param count The number of bytes to write.
	
	@return The number of bytes actually written.
	
	#end
	Method Write:Int( buf:Void Ptr,count:Int ) Override
		If count<=0 Return 0
		count=fwrite( buf,1,count,_file )
		_pos+=count
		_end=Max( _pos,_end )
		DebugAssert( ftell( _file )=_pos )	'Sanity check...
		Return count
	End
	
	#rem monkeydoc Opens a file and returns a new filestream.

	When opening a file using "r" or "rw", the file must already exist or the function will fail and null will be returned.
	
	When opening a file using "w", any existing file at the same path will be overwritten.
	
	@param path The path of the file to open.
	
	@param mode The mode to open the file in: "r", "w" or "rw".
	
	@return A new filestream, or null if the file could not be opened.
	
	#end
	Function Open:FileStream( path:String, mode:String )
		Select mode
		Case "r" mode="rb"
		Case "w" mode="wb"
		Case "rw" mode="r+b"
		Default
			Return Null
		End

		Local file:=OpenCFile( path, mode )
		If Not file Return Null

'jl modified
		Return New FileStream( file, path )
	End
	
Protected
	
	Method OnDiscard() Override
		fclose( _file )
		_file=Null
		_pos=0
		_end=0
	end

	
	Method OnFinalize() Override
		fclose( _file )
	End
	
Private
	
'------------------------------------------------------------	
'jl added
	field _filePath:string
'------------------------------------------------------------

	Field _file:FILE Ptr
	Field _pos:Int
	Field _end:Int
	
	Method New( cfile:FILE Ptr )
		_file=cfile
		_pos=ftell( _file )
		fseek( _file,0,SEEK_END )
		_end=ftell( _file )
		fseek( _file,_pos,SEEK_SET )
		
		DebugAssert( ftell( _file )=_pos )	'Sanity check...
		_filePath = ""
	End

'jl added
'------------------------------------------------------------
	Method New( cfile:FILE Ptr, path:string )
		_file=cfile
		_pos=ftell( _file )
		fseek( _file,0,SEEK_END )
		_end=ftell( _file )
		fseek( _file,_pos,SEEK_SET )
		
		DebugAssert( ftell( _file )=_pos )	'Sanity check...
		_filePath = path
	End
'------------------------------------------------------------
	
End
