
Namespace std.geom

#rem monkeydoc @hidden
#end
Alias Vec4f:Vec4<Float>

#rem monkeydoc @hidden
#end
Struct Vec4<T>

	Field x:T
	Field y:T
	Field z:T
	Field w:T
	
	Method New()
	End
	
	Method New( t:T )
		x=t;y=t;z=t;w=t
	End
	
	Method New( x:T,y:T,z:T,w:T )
		Self.x=x;Self.y=y;Self.z=z;Self.w=w
	End
	
	Method New( v:Vec3<T>,w:T )
		x=v.x;y=v.y;z=v.z;Self.w=w
	End
	
	Method New( v:Vec2<T>,z:T,w:T )
		x=v.x;y=v.y;Self.z=z;Self.w=w
	End
	
	Property X:T()
		Return x
	Setter( x:T )
		Self.x=x
	End
	
	Property Y:T()
		Return y
	Setter( y:T )
		Self.y=y
	End
	
	Property Z:T()
		Return z
	Setter( z:T )
		Self.z=z
	End
	
	Property W:T()
		Return w
	Setter( w:T )
		Self.w=w
	End
	
	Property XY:Vec2<T>()
		Return New Vec2<T>( x,y )
	Setter( xy:Vec2<T> )
		x=xy.x;y=xy.y
	End
	
	Property XYZ:Vec3<T>()
		Return New Vec3<T>( x,y,z )
	Setter( xyz:Vec3<T> )
		x=xyz.x;y=xyz.y;z=xyz.z
	End
	
	Operator To:String()
		Return "Vec4("+x+","+y+","+z+","+w+")"
	End
	
	Operator To<C>:Vec4<C>()
		Return New Vec4<C>( x,y,z,w )
	End
	
	Operator-:Vec4()
		Return New Vec4( -x,-y,-z,-w )
	End
	
	Operator*:Vec4( v:Vec4 )
		Return New Vec4( x*v.x,y*v.y,z*v.z,w*v.w )
	End
	
	Operator/:Vec4( v:Vec4 )
		Return New Vec4( x/v.x,y/v.y,z/v.z,w/v.w )
	End
	
	Operator+:Vec4( v:Vec4 )
		Return New Vec4( x+v.x,y+v.y,z+v.z,w+v.w )
	End
	
	Operator-:Vec4( v:Vec4 )
		Return New Vec4( x-v.x,y-v.y,z-v.z,w-v.w )
	End
	
	Operator*:Vec4( s:Double )
		Return New Vec4( x*s,y*s,z*s,w*s )
	End
	
	Operator/:Vec4( s:Double )
		Return New Vec4( x/s,y/s,z/s,w/s )
	End
	
	Operator+:Vec4( s:T )
		Return New Vec4( x+s,y+s,z+s,w+s )
	End
	
	Operator-:Vec4( s:T )
		Return New Vec4( x-s,y-s,z-s,w-s )
	End
	
	Property Length:Double()
		Return Sqrt( x*x+y*y+z*z )
	End

	Method Dot:Double( v:Vec4 )
		Return x*v.x+y*v.y+z*v.z+w*v.w
	End
	
	Method Normalize:Vec4()
		Return Self/Length
	End
	
	Method Blend:Vec4( v:Vec4,alpha:Double )
		Return New Vec4( (v.x-x)*alpha+x,(v.y-y)*alpha+y,(v.z-z)*alpha+z,(v.w-w)*alpha+w )
	End
	
	Method ToString:String()
		Return "Vec4("+x+","+y+","+z+","+w+")"
	End

End
