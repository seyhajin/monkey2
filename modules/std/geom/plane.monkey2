
Namespace std.geom

#rem monkeydoc @hidden
#end
Alias Planef:Plane<Float>

#rem monkeydoc @hidden
#end
Struct Plane<T>

	Field n:Vec3<T>
	Field d:T
	
	Method New()
	End
	
	Method New( n:Vec3<T>,d:T )
		Self.n=n
		Self.d=d
	End
	
	Method New( p:Vec3<T>,n:Vec3<T> )
		Self.n=n
		Self.d=-n.Dot( p )
	End
	
	Method New( v0:Vec3<T>,v1:Vec3<T>,v2:Vec3<T> )
		n=(v1-v0).Cross(v2-v0).Normalize()
		d=-n.Dot( v0 )
	End
	
	Operator-:Plane()
		Return New Plane( -n,-d )
	End
	
	Method Distance:Double( p:Vec3<T> )
		return n.Dot( p )+d
	End

	Method Nearest:Vec3<T>( p:Vec3<T> )
		Return p-n*Distance( p )
	End
	
End
