
Namespace std.geom

#rem monkeydoc Convenience type alias for Vec3\<Float\>.
#end
Alias Vec3f:Vec3<Float>

#rem monkeydoc The generic Vec3 type provides support for 3 component vectors.

Unless otherwise noted, methods and operators always return a new vec3 containing the result, without modifying any parameters or 'self'.

This allows you to chain operators together easily just like 'real' expressions.

#end
Struct Vec3<T>

	#rem monkeydoc The vector x coordinate.
	#end
	Field x:T

	#rem monkeydoc The vector y coordinate.
	#end
	Field y:T

	#rem monkeydoc The vector z coordinate.
	#end
	Field z:T
	
	#rem Creates a new vec3.
	#end
	Method New()
	End
	
	Method New( t:T )
		x=t;y=t;z=t
	End
	
	Method New( x:T,y:T,z:T )
		Self.x=x;Self.y=y;Self.z=z
	End
	
	Method New( v:Vec2<T>,z:T )
		Self.x=v.x;Self.y=v.y;Self.z=z
	End
	
	Method New( x:T,v:Vec2<T> )
		Self.x=z;Self.y=v.x;Self.z=v.y
	End

	#Rem monkeydoc Converts the vec3 to a vec3 of a different type or a printable string.
	#end
	Method To<C>:Vec3<C>()
		Return New Vec3<C>( x,y,z )
	End
	
	Method To:String()
		Return "Vec3("+x+","+y+","+z+")"
	End
	
	#rem monkeydoc The X coordinate of the vec3.
	#end
	Property X:T()
		Return x
	Setter( x:T )
		Self.x=x
	End
	
	#rem monkeydoc The Y coordinate of the vec3.
	#end
	Property Y:T()
		Return y
	Setter( y:T )
		Self.y=y
	End
	
	#rem monkeydoc The X coordinate of the vec3.
	#end
	Property Z:T()
		Return z
	Setter( z:T )
		Self.z=z
	End
	
	#rem monkeydoc The XY components of the vec3 as a vec2.
	#end
	Property XY:Vec2<T>()
		Return New Vec2<T>( x,y )
	Setter( xy:Vec2<T> )
		x=xy.x;y=xy.y
	End
	
	#rem monkeydoc The YZ components of the vec3 as a vec2.
	#end
	Property YZ:Vec2<T>()
		Return New Vec2<T>( y,z )
	Setter( yz:Vec2<T> )
		y=yz.x;z=yz.y
	End

	#rem monkeydoc The XZ components of the vec3 as a vec2.
	#end
	Property XZ:Vec2<T>()
		Return New Vec2<T>( x,z )
	Setter( xz:Vec2<T> )
		x=xz.x;z=xz.y
	End
	
	#rem monkeydoc Negates the vec3.
	#end
	Operator-:Vec3()
		Return New Vec3( -x,-y,-z )
	End
	
	#rem monkeydoc Multiplies the vec3 by another vec3.
	#end
	Operator*:Vec3( v:Vec3 )
		Return New Vec3( x*v.x,y*v.y,z*v.z )
	End
	
	#rem monkeydoc Divides the vec3 by another vec3.
	#end
	Operator/:Vec3( v:Vec3 )
		Return New Vec3( x/v.x,y/v.y,z/v.z )
	End
	
	#rem monkeydoc Adds the vec3 to another vec3.
	#end
	Operator+:Vec3( v:Vec3 )
		Return New Vec3( x+v.x,y+v.y,z+v.z )
	End
	
	#rem monkeydoc Subtracts another vec3 from the vec3.
	#end
	Operator-:Vec3( v:Vec3 )
		Return New Vec3( x-v.x,y-v.y,z-v.z )
	End
	
	#rem monkeydoc Multiplies the vec3 by a scalar.
	#end
	Operator*:Vec3( s:Double )
		Return New Vec3( x*s,y*s,z*s )
	End
	
	#rem monkeydoc Divides the vec3 by a scalar.
	#end
	Operator/:Vec3( s:Double )
		Return New Vec3( x/s,y/s,z/s )
	End
	
	#rem monkeydoc Adds a scalar to each component of the vec3.
	#end
	Operator+:Vec3( s:T )
		Return New Vec3( x+s,y+s,z+s )
	End
	
	#rem monkeydoc Subtracts a scalar from each component of the vec3.
	#end
	Operator-:Vec3( s:T )
		Return New Vec3( x-s,y-s,z-s )
	End
	
	#rem monkeydoc Returns the pitch of the vec3.
	
	Pitch is the angle of rotation, in radians, of the vec3 around the x axis.
	
	#end
	Property Pitch:Double()
		return -ATan2( y,Sqrt( x*x+z*z ) )
	End

	#rem monkeydoc Returns the yaw of the vec3.
	
	Yaw is the angle of rotation, in radians, of the vec3 around the y axis.
	
	#end
	Property Yaw:Double()
		return -ATan2( x,z )
	End

	#rem monkeydoc Returns the length of the vec3.
	#end
	Property Length:Double()
		Return Sqrt( x*x+y*y+z*z )
	End

	#rem monkeydoc Returns the distance of the vec to another vec3.
	#end
	Method Distance:Double( v:Vec3 )
		Return (v-Self).Length
	End
	
	#rem monkeydoc Normalizes the vec3.
	#end
	Method Normalize:Vec3()
		Return Self/Length
	End
	
	#rem monkeydoc Returns the dot product of the vec3 with another vec3.
	#end
	Method Dot:T( v:Vec3 )
		Return x*v.x+y*v.y+z*v.z
	End

	#rem monkeydoc Returns the cross product of the vec3 with another vec3.
	#end
	Method Cross:Vec3( v:Vec3 )
		Return New Vec3( y*v.z-z*v.y,z*v.x-x*v.z,x*v.y-y*v.x )
	End
	
	#rem monkeydoc Blends the vec3 with another vec3.
	
	Components are linearly blended using `alpha` as a weighting factor.

	If alpha is 0, self is returned.
	
	If alpha is 1, `v` is returned.
	
	#end
	Method Blend:Vec3( v:Vec3,alpha:Double )
		Return New Vec3( (v.x-x)*alpha+x,(v.y-y)*alpha+y,(v.z-z)*alpha+z )
	End

End
