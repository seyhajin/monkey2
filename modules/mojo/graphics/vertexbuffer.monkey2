
Namespace mojo.graphics

#rem monkeydoc @hidden
#end	
Class VertexFormat
	
	Property Pitch:Int() Abstract

	Method UpdateGLAttribs() Abstract
End

#rem monkeydoc @hidden
#end	
Class VertexBuffer

	Method New( format:VertexFormat,capacity:Int )
		_format=format
		_capacity=capacity
		_pitch=_format.Pitch
		_length=0
		_clean=0
		_data=New UByte[_capacity*_pitch]
	End
	
	Method New( vertices:VertexBuffer )
		_format=vertices._format
		_capacity=vertices._capacity
		_pitch=vertices._pitch
		_length=vertices._length
		_clean=0
		_data=vertices._data.Slice( 0 )
	End
	
	Method New( vertices:Vertex3f[] )
		Self.New( Vertex3fFormat.Instance,vertices.Length )
		
		libc.memcpy( AddVertices( vertices.Length ),vertices.Data,_capacity*_pitch )
	End
	
	Property Data:UByte Ptr()
		
		Return _data.Data
	End
	
	Property Format:VertexFormat()
		
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
	
	Method AddVertices:UByte Ptr( count:Int )
		Reserve( _length+count )

		Local p:=_data.Data+_length*_pitch
		
		_length+=count
		
		Return p
	End

	'***** INTERNAL *****
	
	Method Bind()
		
		If _glSeq<>glGraphicsSeq
			
			glGenBuffers( 1,Varptr _glBuffer )
			glBindBuffer( GL_ARRAY_BUFFER,_glBuffer )
			
			glBufferData( GL_ARRAY_BUFFER,_capacity*_pitch,Null,GL_DYNAMIC_DRAW )
'			Print "bound vb "+_glBuffer
			
			_glSeq=glGraphicsSeq
			_clean=0
		Else
			glBindBuffer( GL_ARRAY_BUFFER,_glBuffer )
'			Print "bound vb "+_glBuffer
		Endif
		
		_format.UpdateGLAttribs()
			
	End
	
	Method Validate()
	
		If _length=_clean Return
		
		glBufferData( GL_ARRAY_BUFFER,_length*_pitch,_data.Data,GL_DYNAMIC_DRAW )
'		Print "updated vb "+_glBuffer

		_clean=_length
	End
		
	Private
	
	Field _format:VertexFormat
	Field _capacity:Int
	Field _pitch:int
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
