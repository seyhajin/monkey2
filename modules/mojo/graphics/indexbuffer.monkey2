
Namespace mojo.graphics

Enum IndexFormat
	UINT8=1
	UINT16=2
	UINT32=4
End

Class IndexBuffer Extends Resource
#-
'jl added
	Method New( indices:IndexBuffer )
		_format = indices._format
		_pitch = indices._pitch
		_length = indices._length
		_managed = indices._managed.Slice( 0 )
		_dirtyMin=_length
		_dirtyMax=0
	End

	
'	Method New( indices:UInt[] )
'		Self.New( IndexFormat.UINT32, indices.Length )
'		
''		If _capacity libc.memcpy( AddIndices( _capacity ),indices.Data,_capacity*_pitch )
'		SetIndices( indices.Data, 0, indices.Length )
'	End

	
	Method New( indices:UShort[] )
		Self.New( IndexFormat.UINT16,indices.Length )
		
'		If _capacity libc.memcpy( AddIndices( _capacity ),indices.Data,_capacity*_pitch )
		SetIndices( indices.Data, 0, indices.Length )
	End

	Property Data:UByte Ptr()
		Return _managed.Data
	End

	Method Clear()
		_length = 0
		Invalidate( 0, _length )
	End
#-
	
	Method New( format:IndexFormat,length:Int=0 )
		
		_format=format
		_length=length
		_pitch=Int( _format )
		_managed=New UByte[_length*_pitch]
		_dirtyMin=_length
		_dirtyMax=0
	End

	Method New( indices:UInt[] )
		Self.New( IndexFormat.UINT32,indices.Length )
		
		SetIndices( indices.Data,0,indices.Length )
	End
	
	Property Format:IndexFormat()
		
		Return _format
	End
	
	Property Length:Int()
		
		Return _length
	End
	
	Property Pitch:Int()
		
		Return _pitch
	End

#-
'jl added
	Method AddIndices:UByte Ptr( length:Int )
		local size:int = length * _pitch
		Local managed := New UByte[size]

		Return managed.Data
'		Reserve( _length+count )
'		
'		Local p:=_data.Data+_length*_pitch
'		
'		_length+=count
'		
'		Return p
	End
#-	
	
	#rem monkeydoc Resizes the index buffer.
	#end
	Method Resize( length:Int )

		If length=_length Return
		
		Local managed:=New UByte[length*_pitch]
		
		Local n:=Min( length,_length )
		
		If n libc.memcpy( managed.Data,_managed.Data,n*_pitch )
			
		_managed=managed
		
		_length=length
		
		If _glSeq=glGraphicsSeq glDeleteBuffers( 1,Varptr _glBuffer )
			
		_glSeq=0
	End
	
	#rem monkeydoc Sets a range of indices.
	#end
	Method SetIndices( indices:Void Ptr,first:Int,count:Int )

		DebugAssert( Not _locked,"IndexBuffer is locked" )

		DebugAssert( first>=0 And count>=0 And first<=_length And first+count<=_length,"Invalid index range" )
		
		libc.memcpy( _managed.Data+first*_pitch,indices,count*_pitch )
		
		Invalidate( first,count )
	End
	
	#rem monkeydoc Locks indices.
	
	Make sure to invalidate any indices you modify by using [[Invalidate]].
	
	#end
	Method Lock:UByte ptr()
		
		DebugAssert( Not _locked,"IndexBuffer is already locked" )
		
		_locked=_managed.Data
		
		Return _locked
	End
	
	#rem onkeydoc Invalidates indices.
	
	You should use this method to invalidate any indices you have modified by writing to a locked index buffer.
	
	#End
	Method Invalidate( first:Int,count:Int )
		
'		DebugAssert( _locked,"Index buffer is not locked" )
		
		DebugAssert( first>=0 And count>=0 And first<=_length And first+count<=_length,"Invalid index range" )
		
		_dirtyMin=Min( _dirtyMin,first )
		
		_dirtyMax=Max( _dirtyMax,first+count )
	End
	
	Method Invalidate()
		
		Invalidate( 0,_length )
	End
	
	#rem monkeydoc Unlocks indices.
	#end
	Method Unlock:Void()
		
		DebugAssert( _locked,"Index buffer is not locked" )
		
		_locked=Null
	End
	
	Protected
	
	Method OnDiscard() Override
		
		If _glSeq=glGraphicsSeq glDeleteBuffers( 1,Varptr _glBuffer )
			
		_glSeq=-1
	End
	
	Method OnFinalize() Override

		If _glSeq=glGraphicsSeq glDeleteBuffers( 1,Varptr _glBuffer )
	End
	
	Internal
	
	Method Bind()
		
		DebugAssert( Not _locked,"IndexBuffer.Bind() failed, IndexBuffer is locked" )
		
		If _glSeq<>glGraphicsSeq
			
			glGenBuffers( 1,Varptr _glBuffer )
			glBindBuffer( GL_ELEMENT_ARRAY_BUFFER,_glBuffer )
			
			glBufferData( GL_ELEMENT_ARRAY_BUFFER,_length*_pitch,_managed.Data,GL_DYNAMIC_DRAW )
			_dirtyMin=_length
			_dirtyMax=0

			_glSeq=glGraphicsSeq
			
		Else

			glBindBuffer( GL_ELEMENT_ARRAY_BUFFER,_glBuffer )
		Endif
	
	End
	
	Method Validate()
		
		If _dirtyMax>_dirtyMin
			
			glBufferSubData( GL_ELEMENT_ARRAY_BUFFER,_dirtyMin*_pitch,(_dirtyMax-_dirtyMin)*_pitch,_managed.Data )
			
			_dirtyMin=_length
			_dirtyMax=0
		Endif
	End
	
	Private
	
	Field _format:IndexFormat
	Field _length:Int
	Field _pitch:Int
	
	Field _managed:UByte[]
	Field _dirtyMin:Int
	Field _dirtyMax:Int
	
	Field _locked:UByte Ptr
	
	Field _glSeq:Int
	Field _glBuffer:GLuint
	
End
