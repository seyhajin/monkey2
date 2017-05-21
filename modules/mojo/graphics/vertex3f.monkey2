
Namespace mojo.graphics

Struct Vertex3f

	Field position:Vec3f	'0
	Field texCoord0:Vec2f	'12
	Field normal:Vec3f		'20
	Field tangent:Vec4f		'32
	Field weights:Vec4f		'48
	Field bones:UInt		'64

	Const Pitch:=68			'68
	
	Method New()
	End
	
	Method New( x:Float,y:Float,z:Float,s0:Float=0,t0:Float=0,nx:Float=0,ny:Float=0,nz:Float=0 )
		position.x=x
		position.y=y
		position.z=z
		texCoord0.x=s0
		texCoord0.y=t0
		normal.x=nx
		normal.y=ny
		normal.z=nz
	End
	
	Method New( position:Vec3f,texCoord0:Vec2f=New Vec2f,normal:Vec3f=New Vec3f )
		Self.position=position
		Self.texCoord0=texCoord0
		Self.normal=normal
	End
	
	Operator To:String()
		Return "Vertex3f("+position+")"
	End
	
	Property Tx:Float()
		Return position.x
	Setter( tx:Float )
		position.x=tx
	End
	
	Property Ty:Float()
		Return position.y
	Setter( ty:Float )
		position.y=ty
	End
	
	Property Tz:Float()
		Return position.z
	Setter( tz:Float )
		position.z=tz
	End

	Property Sx:Float()
		Return texCoord0.x
	Setter( sx:Float )
		texCoord0.x=sx
	End
	
	Property Sy:Float()
		Return texCoord0.y
	Setter( sy:Float )
		texCoord0.y=sy
	End
	
End

Class Vertex3fFormat Extends VertexFormat

	Const Instance:=New Vertex3fFormat
	
	Property Pitch:Int() Override
		
		Return 68
	End

	Method UpdateGLAttribs() Override
		
		glEnableVertexAttribArray( A_POSITION ) ; glVertexAttribPointer( A_POSITION,3,GL_FLOAT,False,Pitch,Cast<Void Ptr>( 0 ) )
		glEnableVertexAttribArray( A_TEXCOORD0 ) ; glVertexAttribPointer( A_TEXCOORD0,2,GL_FLOAT,False,Pitch,Cast<Void Ptr>( 12 ) )
		glEnableVertexAttribArray( A_NORMAL ) ; glVertexAttribPointer( A_NORMAL,3,GL_FLOAT,False,Pitch,Cast<Void Ptr>( 20 ) )
		glEnableVertexAttribArray( A_TANGENT ) ; glVertexAttribPointer( A_TANGENT,4,GL_FLOAT,False,Pitch,Cast<Void Ptr>( 32 ) )
		glEnableVertexAttribArray( A_WEIGHTS ) ; glVertexAttribPointer( A_WEIGHTS,4,GL_FLOAT,False,Pitch,Cast<Void Ptr>( 48 ) )
		glEnableVertexAttribArray( A_BONES ) ; glVertexAttribPointer( A_BONES,4,GL_UNSIGNED_BYTE,False,Pitch,Cast<Void Ptr>( 64 ) )
	End
	
End
