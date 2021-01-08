
Namespace mojo.graphics

#rem monkeydoc @hidden
#end	
Class VertexFormat
	
	Method New()
	End
	
	Property Pitch:Int() Virtual
		Return 0
	End

	Method UpdateGLAttribs() Virtual
	End
End

#rem

Vertex buffers can 'grow' stack-like.

Use Resize or AddVertices to grow a vertex buffer.

#end
Class VertexBuffer Extends Resource
	
	Method New( format:VertexFormat,length:Int=0 )
		
		_format=format
		_length=length
		_pitch=_format.Pitch
		_managed=New UByte[_length*_pitch]
		_dirtyMin=_length
		_dirtyMax=0
	End
	
	Method New( vertices:Vertex3f[] )
		Self.New( Vertex3f.Format,vertices.Length )
		
		SetVertices( vertices.Data,0,vertices.Length )
	End

'------------------------------------------------------------
	'jl added
	Method New( vertices:VertexBuffer )
		_format = vertices._format
		_length = vertices._length
		_pitch = vertices._pitch
		_managed = vertices._managed.Slice( 0 )
	End

	Property Data:UByte Ptr()
		Return _managed.Data
	End

	Method Clear()
		_length = 0
		Invalidate( 0, _length )
	End
'------------------------------------------------------------
	
	Property Format:VertexFormat()
		
		Return _format
	End
	
	Property Length:Int()
		
		Return _length
	End
	
	Property Pitch:Int()
		
		Return _pitch
	End

'------------------------------------------------------------
'jl added
'	Method AddVertices( vertices:Vertex3f Ptr,count:Int )
'		Local p:=_vbuffer.AddVertices( count )
'		
'		libc.memcpy( p, vertices, count * _vbuffer.Pitch )
'		
'		_dirty|=Dirty.Bounds
'	End
	Method AddVertices:UByte Ptr( length:Int )
		local size:int = length * _pitch
		Local managed := New UByte[size]

		Return managed.Data
		
'		Reserve( _length+count )
'
'		Local p := _data.Data+_length*_pitch
'		
'		_length += count
'		
'		Return p
	End
'------------------------------------------------------------
	
	#rem monkeydoc Resizes the vertex buffer.
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
	
	#rem monkeydoc Sets a range of vertices.
	#end
	Method SetVertices( vertices:Void Ptr,first:Int,count:Int )
		
		DebugAssert( Not _locked,"VertexBuffer is locked" )
		
		DebugAssert( first>=0 And count>=0 And first<=_length And first+count<=_length,"Invalid vertex range" )
		
		libc.memcpy( _managed.Data+first*_pitch,vertices,count*_pitch )
		
		Invalidate( first,count )
	End
	
	#rem monkeydoc Locks vertices.
	
	Make sure to invalidate any vertices you modify by using [[Invalidate]].
	
	#end
	Method Lock:UByte ptr()
		
		DebugAssert( Not _locked,"VertexBuffer is already locked" )
		
		_locked=_managed.Data
		
		Return _locked
	End
	
	#rem onkeydoc Invalidates vertices.
	
	You should use this method to invalidate any vertices you have modified by writing to a locked vertex buffer.
	
	#End
	Method Invalidate( first:Int,count:Int )
		
'		DebugAssert( _locked,"Vertex buffer is not locked" )
		
		DebugAssert( first>=0 And count>=0 And first<=_length And first+count<=_length,"Invalid vertex range" )
		
		_dirtyMin=Min( _dirtyMin,first )
		
		_dirtyMax=Max( _dirtyMax,first+count )
	End
	
	Method Invalidate()
		
		Invalidate( 0,_length )
	End
	
	#rem monkeydoc Unlocks vertices.
	#end
	Method Unlock:Void()
		
		DebugAssert( _locked,"Vertex buffer is not locked" )
		
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
		
		DebugAssert( Not _locked,"VertexBuffer.Bind() failed, VertexBuffer is locked" )
		
		If _glSeq<>glGraphicsSeq
			
			glGenBuffers( 1,Varptr _glBuffer )
			glBindBuffer( GL_ARRAY_BUFFER,_glBuffer )
			
			glBufferData( GL_ARRAY_BUFFER,_length*_pitch,_managed.Data,GL_DYNAMIC_DRAW )
			_dirtyMin=_length
			_dirtyMax=0

			_glSeq=glGraphicsSeq
			
		Else

			glBindBuffer( GL_ARRAY_BUFFER,_glBuffer )
		Endif
		
		If _format _format.UpdateGLAttribs()
	End
	
	Method Validate()
		
		If _dirtyMax>_dirtyMin
			
			glBufferSubData( GL_ARRAY_BUFFER,_dirtyMin*_pitch,(_dirtyMax-_dirtyMin)*_pitch,_managed.Data )
			
			_dirtyMin=_length
			_dirtyMax=0
		
		Endif
	End
	
	Private
	
	Field _format:VertexFormat
	Field _length:Int
	Field _pitch:Int
	
	Field _managed:UByte[]
	Field _dirtyMin:Int
	Field _dirtyMax:Int
	
	Field _locked:UByte Ptr
	
	Field _glSeq:Int
	Field _glBuffer:GLuint
	
End
