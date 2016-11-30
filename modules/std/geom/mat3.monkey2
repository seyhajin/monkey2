
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
	
	Method New( i:Vec3<T>,j:Vec3<T>,k:Vec3<T> )
		Self.i=i; Self.j=j; Self.k=k
	End
	
	Method New( q:Quat<T> )
		Local xx:=q.v.x*q.v.x , yy:=q.v.y*q.v.y , zz:=q.v.z*q.v.z
		Local xy:=q.v.x*q.v.y , xz:=q.v.x*q.v.z , yz:=q.v.y*q.v.z
		Local wx:=q.w*q.v.x   , wy:=q.w*q.v.y   , wz:=q.w*q.v.z
		i.x=1-2*(yy+zz) ; i.y=  2*(xy-wz) ; i.z=  2*(xz+wy)
		j.x=  2*(xy+wz) ; j.y=1-2*(xx+zz) ; j.z=  2*(yz-wx)
		k.x=  2*(xz-wy) ; k.y=  2*(yz+wx) ; k.z=1-2*(xx+yy)
	End
	
	Method New( ix:Float,jy:Float,kz:Float )
		i.x=ix; j.y=jy; k.z=kz
	End
	
	Method New( ix:T,iy:T,iz:T,jx:T,jy:T,jz:T,kx:T,ky:T,kz:T )
		i.x=ix; i.y=iy; i.z=iz
		j.x=jx; j.y=jy; j.z=jz
		k.x=kx; k.y=ky; k.z=kz
	End
	
	Method To<C>:Mat3<C>()
		Return New Mat3<C>( i,j,k )
	End
	
	Method To:String()
		Return "Mat3("+i+","+j+","+k+")"
	End
	
	Method To:Quat<T>()
		Return New Quat<T>( Self )
	End
	
	Property Determinant:Double()
		return i.x*(j.y*k.z-j.z*k.y )-i.y*(j.x*k.z-j.z*k.x )+i.z*(j.x*k.y-j.y*k.x )
	End
	
	Property Cofactor:Mat3()
		Return New Mat3(
			 (j.y*k.z-j.z*k.y),-(j.x*k.z-j.z*k.x), (j.x*k.y-j.y*k.x),
			-(i.y*k.z-i.z*k.y), (i.x*k.z-i.z*k.x),-(i.x*k.y-i.y*k.x),
			 (i.y*j.z-i.z*j.y),-(i.x*j.z-i.z*j.x), (i.x*j.y-i.y*j.x) )
	End
	
	Property Pitch:Double()
		Return k.Pitch
	End
	
	Property Yaw:Double()
		Return k.Yaw
	End
	
	Property Roll:Double()
		Return ATan2( i.y,j.y )
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
	
	Operator*:Mat3( q:Quat<T> )
		Return Self * New Mat3( q )
	End
	
	Operator*:Vec3<T>( v:Vec3<T> )
		Return New Vec3<T>( i.x*v.x+j.x*v.y+k.x*v.z,i.y*v.x+j.y*v.y+k.y*v.z,i.z*v.x+j.z*v.y+k.z*v.z )
	End
	
	Method Rotate:Mat3( rv:Vec3<T> )
		Return Self * RotationMatrix( rv )
	End
	
	Method Scale:Mat3( rv:Vec3<T> )
		Return Self * ScalingMatrix( rv )
	End

	Method Orthogonalize:Mat3()
		Local k:=Self.k.Normalize()
		Return New Mat3( j.Cross( k ).Normalize(),k.Cross( i ).Normalize(),k )
	End
	
	Function YawMatrix:Mat3( an:Double )
		Local sin:=Sin(an),cos:=Cos(an)
		Return New Mat3( cos,0,sin, 0,1,0, -sin,0,cos )
	End
	
	Function PitchMatrix:Mat3( an:Double )
		Local sin:=Sin(an),cos:=Cos(an)
		return New Mat3( 1,0,0, 0,cos,sin, 0,-sin,cos )
	End
	
	Function RollMatrix:Mat3( an:Double )
		Local sin:=Sin(an),cos:=Cos(an)
		Return New Mat3( cos,sin,0, -sin,cos,0, 0,0,1 )
	End
	
	Function RotationMatrix:Mat3( rv:Vec3<T> )
		Return YawMatrix( rv.y ) * PitchMatrix( rv.x ) * RollMatrix( rv.z )
	End
	
	Function ScalingMatrix:Mat3( sv:Vec3<T> )
		Return New Mat3( sv.x,sv.y,sv.z )
	End

End
