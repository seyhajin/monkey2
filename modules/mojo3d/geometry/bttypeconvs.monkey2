
Namespace mojo3d

Public

Struct Vec3<T> Extension

	Operator To:btVector3()

		Return New btVector3( x,y,z )
	End
End

Struct btVector3 Extension

	Operator To:Vec3f()

		Return New Vec3f( x,y,z )
	End
End

Struct Vec4<T> Extension
	Operator To:btVector4()

		Return New btVector4( x,y,z,w )
	End
End

Struct btVector4 Extension

	Operator To:Vec4f()
	
		Return New Vec4f( x,y,z,w )
	End
End

Struct Mat3f Extension

	Operator To:btMatrix3x3()

		Return New btMatrix3x3( i.x,j.x,k.x, i.y,j.y,k.y, i.z,j.z,k.z )
	End
End

Struct btMatrix3x3 Extension

	Operator To:Mat3f()
	
		Return New Mat3f( Cast<Vec3f>( getColumn(0) ),Cast<Vec3f>( getColumn(1) ),Cast<Vec3f>( getColumn(2) ) )
	End
End


Struct AffineMat4f<T> Extension
	
	Operator To:btTransform()
	
		Return New btTransform( Cast<btMatrix3x3>( m ),Cast<btVector3>( t ) )
	End

End

Struct btTransform Extension
	
	Operator To:AffineMat4f()
	
		Return New AffineMat4f( Cast<Mat3f>( getBasis() ),Cast<Vec3f>( getOrigin() ) )
	End

End




