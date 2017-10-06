
Namespace std.geom

#rem monkeydoc Convenience type alias for Vec2\<Int\>.
#end
Alias Vec2i:Vec2<Int>

#rem monkeydoc Convenience type alias for Vec2\<Float\>.
#end
Alias Vec2f:Vec2<Float>

#rem monkeydoc The generic Vec2 type provides support for 2 component vectors.

Unless otherwise noted, methods and operators always return a new vec2 containing the result, without modifying any parameters or 'self'.

This allows you to chain operators together easily just like 'real' expressions.

#end
Struct Vec2<T>

	#rem monkeydoc Vector x coordinate.
	#end
	Field x:T
	
	#rem monkeydoc Vector y coodinate.
	#end
	Field y:T
	
	#rem monkeydoc Creates a new vector.
	#end
	Method New()
	End
	
	Method New( t:T )
		x=t;y=t
	End
		
	Method New( x:T,y:T )
		Self.x=x;Self.y=y
	End
	
	#rem monkeydoc Converts the vector to a vector of a different type or a printable string.
	#end
	Operator To<C>:Vec2<C>()
		Return New Vec2<C>( x,y )
	End

	Operator To:String()
		Return "Vec2("+x+","+y+")"
	End

	#rem monkeydoc The X coordinate of the vector.
	#end
	Property X:T()
		Return x
	Setter( x:T )
		Self.x=x
	End
	
	#rem monkeydoc The Y coordinate of the vector.
	#end
	Property Y:T()
		Return y
	Setter( y:T )
		Self.y=y
	End
	
	#rem monkeydoc Negates the vector.
	#end
	Operator-:Vec2()
		Return New Vec2( -x,-y )
	End
	
	#rem monkeydoc Multiplies the vector by another vector.
	#end
	Operator*:Vec2( v:Vec2 )
		Return New Vec2( x*v.x,y*v.y )
	End

	#rem monkeydoc Divides the vector by another vector.
	#end	
	Operator/:Vec2( v:Vec2 )
		Return New Vec2( x/v.x,y/v.y )
	End

	#rem monkeydoc Adds another vector to the vector.
	#end	
	Operator+:Vec2( v:Vec2 )
		Return New Vec2( x+v.x,y+v.y )
	End
	
	#rem monkeydoc Subtracts another vector from the vector.
	#end
	Operator-:Vec2( v:Vec2 )
		Return New Vec2( x-v.x,y-v.y )
	End
	
	#rem monkeydoc Multiplies the vector by a scalar.
	#end
	Operator*:Vec2( s:Double )
		Return New Vec2( x*s,y*s )
	End
	
	#rem monkeydoc Divides the vector by a scalar.
	#end
	Operator/:Vec2( s:Double )
		Return New Vec2( x/s,y/s )
	End
	
	#rem monkeydoc Adds a scalar to the vector.
	#end
	Operator+:Vec2( s:T )
		Return New Vec2( x+s,y+s )
	End
	
	#rem monkeydoc Subtracts a scalar from the vector.
	#end
	Operator-:Vec2( s:T )
		Return New Vec2( x-s,y-s )
	End
	
	#rem monkeydoc The length of the vector.
	#end
	Property Length:Double()
		Return Sqrt( x*x+y*y )
	End

	#rem monkeydoc The normal to the vector.
	#end	
	Property Normal:Vec2()
		Return New Vec2( -y,x )
	End

	#rem monkeydoc Computes the distance from this vector to another.
	#end
	Method Distance:Double( v:Vec2 )
		Return (v-Self).Length
	End
	
	#rem monkeydoc Normalizes the vector.
	#end
	Method Normalize:Vec2()
		Return Self/Length
	End
	
	#rem monkeydoc Computes the dot product of the vector with another vector.
	#end
	Method Dot:T( v:Vec2 )
		Return x*v.x+y*v.y
	End
	
	#rem monkeydoc Blends the vector with another vector.
	#end
	Method Blend:Vec2( v:Vec2,alpha:Double )
		Return New Vec2( (v.x-x)*alpha+x,(v.y-y)*alpha+y )
	End
	
End

#rem monkeydoc Transforms a Vec2\<Int\> by an AffineMat3.
#end
Function TransformVec2i<T>:Vec2i( vec:Vec2i,matrix:AffineMat3<T> )
	
	Local tmp:=matrix * New Vec2<T>( rect.min.x,rect.min.y )
	
	Return New Vec2i( Round( tmp.x ),Round( tmp.y ) )
End

