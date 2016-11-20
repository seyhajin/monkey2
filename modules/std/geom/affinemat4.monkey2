
Namespace std.geom

#rem monkeydoc @hidden Convenience type alias for AffineMat4\<Float\>
#end
Alias AffineMat4f:AffineMat4<Float>

#rem monkeydoc @hidden Affine 4x4 matrix class.

An affine 4x4 matrix is a 4x4 matrix whose right hand column is always 0,0,0,1.

Affine 4x4 matrices are often used for 3d transformations such as scaling, rotation and translation.

#end
Struct AffineMat4<T>

	Field m:Mat3<T>
	Field v:Vec3<T>
	
	Method New()
		m.i.x=1; m.j.y=1; m.k.z=1
	End
	
	Method New( m:Mat3<T>,v:Vec3<T> )
		Self.m=m; Self.v=v
	End
	
	Method New( m:Mat3<T> )
		Self.m=m
	End
	
	Method New( v:Vec3<T> )
		m.i.x=1; m.j.y=1; m.k.z=1 ; Self.v=v
	End
	
	Method New( i:Vec3<T>,j:Vec3<T>,k:Vec3<T>,v:Vec3<T> )
		m.i=i; m.j=j; m.k=k; Self.v=v
	End

	Method New( ix:T,iy:T,iz:T,jx:T,jy:T,jz:T,kx:T,ky:T,kz:T,vx:T,vy:T,vz:T )
		m.i.x=ix; m.i.y=iy; m.i.z=iz
		m.j.x=jx; m.j.y=jy; m.j.z=jz
		m.k.x=kx; m.k.y=ky; m.k.z=kz
		v.x=vx; v.y=vy; v.z=vz
	End
	
	#rem monkeydoc Converts the matrix to a matrix of a different type.
	#end
	Operator To<C>:AffineMat4<C>()
		Return New AffineMat4<C>( m,t )
	End 
	
	#rem monkeydoc Converts the matrix to a printable string.
	#end
	Operator To:String()
		Return "AffineMat4("+m+","+v+")"
	End
	
	#rem monkeydoc Returns the transpose of the matrix.
	#End
	Operator~:AffineMat4()
		Local i:=~m
		Return New AffineMat4( i,i*-v )
	End
	
	#rem monkeydoc Returns the inverse of the matrix.
	#end
	Operator-:AffineMat4()
		Local i:=-m
		Return New AffineMat4( i,i*-v )
	End
	
	#rem monkeydoc Multiplies the matrix by another matrix and returns the result.
	#end
	Operator*:AffineMat4( q:AffineMat4 )
		Return New AffineMat4( m*q.m,m*q.v+v )
	End
	
	#rem monkeydoc Multiplies a vector by the matrix and returns the result.
	#end
	Operator*:Vec3<T>( v:Vec3<T> )
		Return New Vec3<T>( 
			m.i.x*v.x+m.j.x*v.y+m.k.x*v.z+v.x,
			m.i.y*v.x+m.j.y*v.y+m.k.y*v.z+v.y,
			m.i.z*v.x+m.j.z*v.y+m.k.z*v.z+v.z )
	End

	#rem monkeydoc Applies a translation transformation to the matrix and returns the result.
	#end
	Method Translate:AffineMat4( tv:Vec3<T> )
		Return Self * TranslationMatrix( tv )
	End
	
	#rem monkeydoc Applies a rotation transformation to the matrix and returns the result.
	#end
	Method Rotate:AffineMat4( rv:Vec3<T> )
		Return Self * RotationMatrix( rv )
	End
	
	#rem monkeydoc Applies a scaling transformation to the matrix and returns the result.
	#end
	Method Scale:AffineMat4( rv:Vec3<T> )
		Return Self * ScalingMatrix( rv )
	End
	
	#rem monkeydoc Creates a translation matrix.
	#end
	Function TranslationMatrix:AffineMat4( tv:Vec3<T> )
		Return New AffineMat4( tv )
	End
	
	#rem monkeydoc Creates a rotation matrix.
	#end
	Function RotationMatrix:AffineMat4( rv:Vec3<T> )
		Return New AffineMat4( Mat3<T>.RotationMatrix( rv ) )
	End
	
	#rem monkeydoc Creates a scaling matrix.
	#end
	Function ScalingMatrix:AffineMat4( sv:Vec3<T> )
		Return New AffineMat4( Mat3<T>.ScalingMatrix( sv ) )
	End
	
End
