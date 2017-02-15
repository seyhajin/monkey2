
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
	Field t:Vec3<T>
	
	Method New()
		m.i.x=1; m.j.y=1; m.k.z=1
	End
	
	Method New( m:Mat3<T>,t:Vec3<T> )
		Self.m=m; Self.t=t
	End
	
	Method New( m:Mat3<T> )
		Self.m=m
	End
	
	Method New( t:Vec3<T> )
		m.i.x=1; m.j.y=1; m.k.z=1 ; Self.t=t
	End
	
	Method New( i:Vec3<T>,j:Vec3<T>,k:Vec3<T>,t:Vec3<T> )
		m.i=i; m.j=j; m.k=k; Self.t=t
	End

	Method New( ix:T,iy:T,iz:T,jx:T,jy:T,jz:T,kx:T,ky:T,kz:T,vx:T,vy:T,vz:T )
		m.i.x=ix; m.i.y=iy; m.i.z=iz
		m.j.x=jx; m.j.y=jy; m.j.z=jz
		m.k.x=kx; m.k.y=ky; m.k.z=kz
		t.x=vx; t.y=vy; t.z=vz
	End
	
	#rem monkeydoc Converts the matrix to a matrix of a different type.
	#end
	Operator To<C>:AffineMat4<C>()
		Return New AffineMat4<C>( m,t )
	End 
	
	#rem monkeydoc Converts the matrix to a printable string.
	#end
	Operator To:String()
		Return "AffineMat4("+m+","+t+")"
	End
	
	#rem monkeydoc Returns the transpose of the matrix.
	#End
	Operator~:AffineMat4()
		Local i:=~m
		Return New AffineMat4( i,i*-t )
	End
	
	#rem monkeydoc Returns the inverse of the matrix.
	#end
	Operator-:AffineMat4()
		Local i:=-m
		Return New AffineMat4( i,i*-t )
	End
	
	#rem monkeydoc Multiplies the matrix by another matrix and returns the result.
	#end
	Operator*:AffineMat4( q:AffineMat4 )
		Return New AffineMat4( m*q.m,m*q.t+t )
	End
	
	#rem monkeydoc Multiplies a vector by the matrix and returns the result.
	#end
	Operator*:Vec3<T>( v:Vec3<T> )
		Return New Vec3<T>( 
			m.i.x*v.x+m.j.x*v.y+m.k.x*v.z+t.x,
			m.i.y*v.x+m.j.y*v.y+m.k.y*v.z+t.y,
			m.i.z*v.x+m.j.z*v.y+m.k.z*v.z+t.z )
	End

	#rem monkeydoc Applies a translation transformation to the matrix and returns the result.
	#end
	Method Translate:AffineMat4( tx:T,ty:T,tz:T )
		Return Self * Translation( tx,ty,tz )
	End
	
	Method Translate:AffineMat4( tv:Vec3<T> )
		Return Self * Translation( tv )
	End

	#rem monkeydoc Applies a rotation transformation to the matrix and returns the result.
	#end
	Method Rotate:AffineMat4( rx:Double,ry:Double,rz:Double )
		Return Self * Rotation( rx,ry,rz )
	End

	Method Rotate:AffineMat4( rv:Vec3<Double> )
		Return Self * Rotation( rv )
	End
	
	#rem monkeydoc Applies a scaling transformation to the matrix and returns the result.
	#end
	Method Scale:AffineMat4( sx:T,sy:T,sz:T )
		Return Self * Scaling( sx,sy,sz )
	End
	
	Method Scale:AffineMat4( sv:Vec3<T> )
		Return Self * Scaling( sv )
	End
	
	Method Scale:AffineMat4f( scaling:T )
		Return Self * Scaling( scaling )
	End
	
	#rem monkeydoc Creates a translation matrix.
	#end
	Function Translation:AffineMat4( tv:Vec3<T> )
		Return New AffineMat4( tv )
	End
	
	Function Translation:AffineMat4( tx:T,ty:T,tz:T )
		Return New AffineMat4( New Vec3<T>( tx,ty,tz ) )
	End

	#rem monkeydoc Creates a rotation matrix from a quaternion.
	#end
	Function Rotation:AffineMat4( quat:Quat<T> )
		Return New AffineMat4( Mat3<T>.Rotation( quat ) )
	End
	
	#rem monkeydoc Creates a rotation matrix from euler angles.
	
	Order of rotation is Yaw * Pitch * Roll.
	
	#end
	Function Rotation:AffineMat4( rv:Vec3<Double> )
		Return New AffineMat4( Mat3<T>.Rotation( rv ) )
	End
	
	Function Rotation:AffineMat4( rx:Double,ry:Double,rz:Double )
		Return New AffineMat4( Mat3<T>.Rotation( rx,ry,rz ) )
	End
	
	#rem monkeydoc Creates a scaling matrix.
	#end
	Function Scaling:AffineMat4( sv:Vec3<T> )
		Return New AffineMat4( Mat3<T>.Scaling( sv ) )
	End
	
	Function Scaling:AffineMat4( sx:T,sy:T,sz:T )
		Return New AffineMat4( Mat3<T>.Scaling( sx,sy,sz ) )
	End
	
	Function Scaling:AffineMat4( t:T )
		Return Scaling( t,t,t )
	End
	
End
