
Namespace std.geom

#rem monkeydoc @hidden
#end
Alias Mat3f:Mat3<Float>

#rem monkeydoc @hidden
#end
Struct Mat3<T>

	Field i:Vec3<T>
	Field j:Vec3<T>
	Field k:Vec3<T>
	
	Method New()
		i.x=1;j.y=1;k.z=1
	End
	
	Method New( ix:Float,jy:Float,kz:Float )
		i.x=ix; j.y=jy; k.z=kz
	End
	
	Method New( i:Vec3<T>,j:Vec3<T>,k:Vec3<T> )
		Self.i=i; Self.j=j; Self.k=k
	End
	
	Method New( ix:T,iy:T,iz:T,jx:T,jy:T,jz:T,kx:T,ky:T,kz:T )
		i.x=ix; i.y=iy; i.z=iz
		j.x=jx; j.y=jy; j.z=jz
		k.x=kx; k.y=ky; k.z=kz
	End

	Method New( quat:Quat<T> )
		Local xx:=quat.v.x*quat.v.x , yy:=quat.v.y*quat.v.y , zz:=quat.v.z*quat.v.z
		Local xy:=quat.v.x*quat.v.y , xz:=quat.v.x*quat.v.z , yz:=quat.v.y*quat.v.z
		Local wx:=quat.w*quat.v.x   , wy:=quat.w*quat.v.y   , wz:=quat.w*quat.v.z
		i.x=1-2*(yy+zz) ; i.y=  2*(xy-wz) ; i.z=  2*(xz+wy)
		j.x=  2*(xy+wz) ; j.y=1-2*(xx+zz) ; j.z=  2*(yz-wx)
		k.x=  2*(xz-wy) ; k.y=  2*(yz+wx) ; k.z=1-2*(xx+yy)
	End
	
	Operator To<C>:Mat3<C>()
		Return New Mat3<C>( i,j,k )
	End
	
	Operator To:String()
		Return "Mat3("+i+","+j+","+k+")"
	End
	
	Property Determinant:T()
		Return i.x*(j.y*k.z-j.z*k.y )-i.y*(j.x*k.z-j.z*k.x )+i.z*(j.x*k.y-j.y*k.x )
	End
	
	Operator~:Mat3()
		Return New Mat3( i.x,j.x,k.x, i.y,j.y,k.y, i.z,j.z,k.z )
	End
	
	Operator-:Mat3()
		Local t:=1.0/Determinant
		Return New Mat3(
			 t*(j.y*k.z-j.z*k.y),-t*(i.y*k.z-i.z*k.y), t*(i.y*j.z-i.z*j.y),
			-t*(j.x*k.z-j.z*k.x), t*(i.x*k.z-i.z*k.x),-t*(i.x*j.z-i.z*j.x),
			 t*(j.x*k.y-j.y*k.x),-t*(i.x*k.y-i.y*k.x), t*(i.x*j.y-i.y*j.x) )
	End
	
	Operator*:Mat3( m:Mat3 )
		Return New Mat3(
			i.x*m.i.x+j.x*m.i.y+k.x*m.i.z, i.y*m.i.x+j.y*m.i.y+k.y*m.i.z, i.z*m.i.x+j.z*m.i.y+k.z*m.i.z,
			i.x*m.j.x+j.x*m.j.y+k.x*m.j.z, i.y*m.j.x+j.y*m.j.y+k.y*m.j.z, i.z*m.j.x+j.z*m.j.y+k.z*m.j.z,
			i.x*m.k.x+j.x*m.k.y+k.x*m.k.z, i.y*m.k.x+j.y*m.k.y+k.y*m.k.z, i.z*m.k.x+j.z*m.k.y+k.z*m.k.z )
	End
	
'	Operator*:Mat3( q:Quat<T> )
'		Return Self * New Mat3( q )
'	End
	
	Operator*:Vec3<T>( v:Vec3<T> )
		Return New Vec3<T>( i.x*v.x+j.x*v.y+k.x*v.z,i.y*v.x+j.y*v.y+k.y*v.z,i.z*v.x+j.z*v.y+k.z*v.z )
	End
	
	Method Cofactor:Mat3()
		Return New Mat3(
			 (j.y*k.z-j.z*k.y),-(j.x*k.z-j.z*k.x), (j.x*k.y-j.y*k.x),
			-(i.y*k.z-i.z*k.y), (i.x*k.z-i.z*k.x),-(i.x*k.y-i.y*k.x),
			 (i.y*j.z-i.z*j.y),-(i.x*j.z-i.z*j.x), (i.x*j.y-i.y*j.x) )
	End
	
	Method GetPitch:Double()
		Return k.Pitch
	End
	
	Method GetYaw:Double()
		Return k.Yaw
	End
	
	Method GetRoll:Double()
		Return ATan2( i.y,j.y )
	End
	
	Method GetRotation:Vec3<T>()
		Return New Vec3<T>( GetPitch(),GetYaw(),GetRoll() )
	End
	
	Method GetQuat:Quat<T>()
		Local r:Quat<T>
		Local m:=Orthogonalize()
		Local t:=m.i.x+m.j.y+m.k.z
		If t>EPSILON
			t=Sqrt( t+1 )*2
			r.v.x=(m.k.y-m.j.z)/t
			r.v.y=(m.i.z-m.k.x)/t
			r.v.z=(m.j.x-m.i.y)/t
			r.w=t/4
		Else If m.i.x>m.j.y And m.i.x>m.k.z
			t=Sqrt( m.i.x-m.j.y-m.k.z+1 )*2
			r.v.x=t/4
			r.v.y=(m.j.x+m.i.y)/t
			r.v.z=(m.i.z+m.k.x)/t
			r.w=(m.k.y-m.j.z)/t
		Else If m.j.y>m.k.z
			t=Sqrt( m.j.y-m.k.z-m.i.x+1 )*2
			r.v.x=(m.j.x+m.i.y)/t
			r.v.y=t/4
			r.v.z=(m.k.y+m.j.z)/t
			r.w=(m.i.z-m.k.x)/t
		Else
			t=Sqrt( m.k.z-m.j.y-m.i.x+1 )*2
			r.v.x=(m.i.z+m.k.x)/t
			r.v.y=(m.k.y+m.j.z)/t
			r.v.z=t/4
			r.w=(m.j.x-m.i.y)/t
		Endif
		Return r
	End
	
	Method GetScaling:Vec3<T>()
		Return New Vec3<T>( i.Length,j.Length,k.Length )
	End
	
	Method Rotate:Mat3( rv:Vec3<T> )
		Return Self * Rotation( rv )
	End
	
	Method Rotate:Mat3( rx:Double,ry:Double,rz:Double )
		Return Self * Rotation( rx,ry,rz )
	End
	
	Method Rotate:Mat3( quat:Quat<T> )
		Return Self * Rotation( quat )
	End
	
	Method Scale:Mat3( rv:Vec3<T> )
		Return Self * Scaling( rv )
	End

	Method Scale:Mat3( sx:T,sy:T,sz:T )
		Return Self * Scaling( sx,sy,sz )
	End
	
	Method Scale:Mat3( t:T )
		Return Self * Scaling( t )
	End

	Method Orthogonalize:Mat3()
		Local k:=Self.k.Normalize()
		Return New Mat3( j.Cross( k ).Normalize(),k.Cross( i ).Normalize(),k )
	End
	
	#rem monkeydoc Creates a rotation matrix from euler angles.
	#end
	Function Yaw:Mat3( an:Double )
		Local sin:=Sin(an),cos:=Cos(an)
		Return New Mat3( cos,0,sin, 0,1,0, -sin,0,cos )
	End
	
	#rem monkeydoc Creates a rotation matrix from euler angles.
	#end
	Function Pitch:Mat3( an:Double )
		Local sin:=Sin(an),cos:=Cos(an)
		return New Mat3( 1,0,0, 0,cos,sin, 0,-sin,cos )
	End
	
	#rem monkeydoc Creates a rotation matrix from euler angles.
	#end
	Function Roll:Mat3( an:Double )
		Local sin:=Sin(an),cos:=Cos(an)
		Return New Mat3( cos,sin,0, -sin,cos,0, 0,0,1 )
	End
	
	#rem monkeydoc Creates a rotation matrix from euler angles or a quaternion.
	#end
	Function Rotation:Mat3( rv:Vec3<Double> )
		Return Yaw( rv.y ) * Pitch( rv.x ) * Roll( rv.z )
	End
	
	Function Rotation:Mat3( rx:Double,ry:Double,rz:Double )
		Return Yaw( ry ) * Pitch( rx ) * Roll( rz )
	End

	Function Rotation:Mat3( quat:Quat<T> )
		Local r:Mat3
		Local xx:=quat.v.x*quat.v.x , yy:=quat.v.y*quat.v.y , zz:=quat.v.z*quat.v.z
		Local xy:=quat.v.x*quat.v.y , xz:=quat.v.x*quat.v.z , yz:=quat.v.y*quat.v.z
		Local wx:=quat.w*quat.v.x   , wy:=quat.w*quat.v.y   , wz:=quat.w*quat.v.z
		r.i.x=1-2*(yy+zz) ; r.i.y=  2*(xy-wz) ; r.i.z=  2*(xz+wy)
		r.j.x=  2*(xy+wz) ; r.j.y=1-2*(xx+zz) ; r.j.z=  2*(yz-wx)
		r.k.x=  2*(xz-wy) ; r.k.y=  2*(yz+wx) ; r.k.z=1-2*(xx+yy)
		Return r
	End
	
	#rem monkeydoc Creates a rotation matrix from euler angles.
	
	Order of rotation is Yaw * Pitch * Roll.
	
	#end
	#rem monkeydoc Creates a scaling matrix.
	#end
	Function Scaling:Mat3( sv:Vec3<T> )
		Return New Mat3( sv.x,sv.y,sv.z )
	End

	Function Scaling:Mat3( sx:T,sy:T,sz:T )
		Return New Mat3( sx,sy,sz )
	End
	
	Function Scaling:Mat3( t:T )
		Return New Mat3( t,t,t )
	End

End
