
Namespace mojo.graphics

Enum IndexFormat
	UINT16=1
	UINT32=2
End

#rem monkeydoc @hidden
#end	
Class IndexBuffer

	Method New( format:IndexFormat,capacity:Int )

		_format=format
		_capacity=capacity
		_pitch=_format=IndexFormat.UINT16 ? 2 Else 4
		_length=0
		_clean=0
		_data=New UByte[_capacity*_pitch]
	End
	
	Method New( indices:IndexBuffer )

		_format=indices._format
		_capacity=indices._capacity
		_pitch=indices._pitch
		_length=indices._length
		_clean=0
		_data=indices._data.Slice( 0 )
	End
	
	Method New( indices:UInt[] )
		Self.New( IndexFormat.UINT32,indices.Length )
		
		libc.memcpy( AddIndices( indices.Length ),indices.Data,_capacity*_pitch )
	End
	
	Method New( indices:UShort[] )
		Self.New( IndexFormat.UINT16,indices.Length )
		
		libc.memcpy( AddIndices( indices.Length ),indices.Data,_capacity*_pitch )
	End
	
	Property Data:UByte Ptr()
		
		Return _data.Data
	End
	
	Property Format:IndexFormat()
		
		Return _format
	End
	
	Property Capacity:Int()
	
		Return _capacity
	End

	Property Pitch:Int()
		
		Return _pitch
	End
	
	Property Length:Int()
	
		Return _length
	End
	
	Method Clear()
		_length=0
		_clean=0
	End
	
	Method Invalidate()
		_clean=0
	End
	
	Method AddIndices:UByte Ptr( count:Int )
		Reserve( _length+count )
		
		Local p:=_data.Data+_length*_pitch
		
		_length+=count
		
		Return p
	End
	
	'***** INTERNAL *****
	
	Method Bind()
	
		If _glSeq<>glGraphicsSeq
			
			glGenBuffers( 1,Varptr _glBuffer )
			glBindBuffer( GL_ELEMENT_ARRAY_BUFFER,_glBuffer )
			
			glBufferData( GL_ELEMENT_ARRAY_BUFFER,_capacity*_pitch,Null,GL_DYNAMIC_DRAW )
'			Print "bound ib "+_glBuffer
		
			_glSeq=glGraphicsSeq
			_clean=0
		Else
			glBindBuffer( GL_ELEMENT_ARRAY_BUFFER,_glBuffer )
'			Print "bound ib "+_glBuffer
		Endif

	End
	
	Method Validate()
		
		If _length=_clean Return
		
		glBufferData( GL_ELEMENT_ARRAY_BUFFER,_length*_pitch,_data.Data,GL_DYNAMIC_DRAW )
'		Print "updated ib "+_glBuffer
		
		_clean=_length
	End
		
	Private
	
	Field _format:IndexFormat
	Field _capacity:Int
	Field _pitch:Int
	Field _length:Int
	Field _clean:Int
	Field _data:UByte[]

	Field _glSeq:Int
	Field _glBuffer:GLuint

	Method Reserve( capacity:Int )
		
		If _capacity>=capacity Return
		
		_capacity=Max( _length*2+_length,capacity )
		
		Local data:=New UByte[_capacity*_pitch]
		
		libc.memcpy( data.Data,_data.Data,_length*_pitch )
		
		_data=data
		
	End

End
