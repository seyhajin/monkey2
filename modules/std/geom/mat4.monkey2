
Namespace std.geom

#rem monkeydoc @hidden
#end
Alias Mat4f:Mat4<Float>

#rem monkeydoc @hidden
#end
Struct Mat4<T>

	Field i:Vec4<T>
	Field j:Vec4<T>
	Field k:Vec4<T>
	Field t:Vec4<T>
	
	Method New()
		i.x=1;j.y=1;k.z=1;t.w=1
	End
	
	Method New( ix:T,jy:T,kz:T,tw:T )
		i.x=ix;j.y=jy;k.z=kz;t.w=tw
	End
	
	Method New( i:Vec4<T>,j:Vec4<T>,k:Vec4<T>,t:Vec4<T> )
		Self.i=i;Self.j=j;Self.k=k;Self.t=t
	End
	
	Method New( m:Mat3<T> )
		i.XYZ=m.i ; j.XYZ=m.j ; k.XYZ=m.k ; t.w=1
	End
	
	Method New( m:AffineMat3<T> )
		i.XY=m.i ; j.XY=m.j ; k.z=1 ; t.XY=m.t ; t.w=1
	End
	
	Method New( m:AffineMat4<T> )
		i.XYZ=m.m.i ; j.XYZ=m.m.j ; k.XYZ=m.m.k ; t.XYZ=m.t ; t.w=1
	End
	
	Operator*:Mat4( m:Mat4 )
		Local r:Mat4
		
		r.i.x=i.x*m.i.x + j.x*m.i.y + k.x*m.i.z + t.x*m.i.w 
		r.i.y=i.y*m.i.x + j.y*m.i.y + k.y*m.i.z + t.y*m.i.w
		r.i.z=i.z*m.i.x + j.z*m.i.y + k.z*m.i.z + t.z*m.i.w
		r.i.w=i.w*m.i.x + j.w*m.i.y + k.w*m.i.z + t.w*m.i.w
		
		r.j.x=i.x*m.j.x + j.x*m.j.y + k.x*m.j.z + t.x*m.j.w 
		r.j.y=i.y*m.j.x + j.y*m.j.y + k.y*m.j.z + t.y*m.j.w
		r.j.z=i.z*m.j.x + j.z*m.j.y + k.z*m.j.z + t.z*m.j.w
		r.j.w=i.w*m.j.x + j.w*m.j.y + k.w*m.j.z + t.w*m.j.w
		
		r.k.x=i.x*m.k.x + j.x*m.k.y + k.x*m.k.z + t.x*m.k.w 
		r.k.y=i.y*m.k.x + j.y*m.k.y + k.y*m.k.z + t.y*m.k.w
		r.k.z=i.z*m.k.x + j.z*m.k.y + k.z*m.k.z + t.z*m.k.w
		r.k.w=i.w*m.k.x + j.w*m.k.y + k.w*m.k.z + t.w*m.k.w
		
		r.t.x=i.x*m.t.x + j.x*m.t.y + k.x*m.t.z + t.x*m.t.w 
		r.t.y=i.y*m.t.x + j.y*m.t.y + k.y*m.t.z + t.y*m.t.w
		r.t.z=i.z*m.t.x + j.z*m.t.y + k.z*m.t.z + t.z*m.t.w
		r.t.w=i.w*m.t.x + j.w*m.t.y + k.w*m.t.z + t.w*m.t.w
		
		Return r
	End
	
	Operator*:Mat4( m:AffineMat4<T> )

		Local r:Mat4
		
		r.i.x=i.x*m.m.i.x + j.x*m.m.i.y + k.x*m.m.i.z
		r.i.y=i.y*m.m.i.x + j.y*m.m.i.y + k.y*m.m.i.z
		r.i.z=i.z*m.m.i.x + j.z*m.m.i.y + k.z*m.m.i.z
		r.i.w=i.w*m.m.i.x + j.w*m.m.i.y + k.w*m.m.i.z
		
		r.j.x=i.x*m.m.j.x + j.x*m.m.j.y + k.x*m.m.j.z
		r.j.y=i.y*m.m.j.x + j.y*m.m.j.y + k.y*m.m.j.z
		r.j.z=i.z*m.m.j.x + j.z*m.m.j.y + k.z*m.m.j.z
		r.j.w=i.w*m.m.j.x + j.w*m.m.j.y + k.w*m.m.j.z
		
		r.k.x=i.x*m.m.k.x + j.x*m.m.k.y + k.x*m.m.k.z
		r.k.y=i.y*m.m.k.x + j.y*m.m.k.y + k.y*m.m.k.z
		r.k.z=i.z*m.m.k.x + j.z*m.m.k.y + k.z*m.m.k.z
		r.k.w=i.w*m.m.k.x + j.w*m.m.k.y + k.w*m.m.k.z
		
		r.t.x=i.x*m.t.x   + j.x*m.t.y   + k.x*m.t.z + t.x
		r.t.y=i.y*m.t.x   + j.y*m.t.y   + k.y*m.t.z + t.y
		r.t.z=i.z*m.t.x   + j.z*m.t.y   + k.z*m.t.z + t.z
		r.t.w=i.w*m.t.x   + j.w*m.t.y   + k.w*m.t.z + t.w
		
		Return r
	End
	
	Operator*:Mat4( m:Mat3<T> )

		Local r:Mat4
		
		r.i.x=i.x*m.i.x + j.x*m.i.y + k.x*m.i.z
		r.i.y=i.y*m.i.x + j.y*m.i.y + k.y*m.i.z
		r.i.z=i.z*m.i.x + j.z*m.i.y + k.z*m.i.z
		r.i.w=i.w*m.i.x + j.w*m.i.y + k.w*m.i.z
		
		r.j.x=i.x*m.j.x + j.x*m.j.y + k.x*m.j.z
		r.j.y=i.y*m.j.x + j.y*m.j.y + k.y*m.j.z
		r.j.z=i.z*m.j.x + j.z*m.j.y + k.z*m.j.z
		r.j.w=i.w*m.j.x + j.w*m.j.y + k.w*m.j.z
		
		r.k.x=i.x*m.k.x + j.x*m.k.y + k.x*m.k.z
		r.k.y=i.y*m.k.x + j.y*m.k.y + k.y*m.k.z
		r.k.z=i.z*m.k.x + j.z*m.k.y + k.z*m.k.z
		r.k.w=i.w*m.k.x + j.w*m.k.y + k.w*m.k.z
		
		r.t.x=t.x
		r.t.y=t.y
		r.t.z=t.z
		r.t.w=t.w
		
		Return r
	End
	
	#rem monkeydoc Creates a translation matrix.
	#end
	Function Translation:Mat4( tv:Vec3<T> )
		Return Translation( tv.x,tv.y,tv.z )
	End
	
	Function Translation:Mat4( tx:T,ty:T,tz:T )
		Local r:=New Mat4
		r.t.x=tx;r.t.y=ty;r.t.z=tz;r.t.w=1
		Return r
	End

	#rem monkeydoc Creates a rotation matrix.
	#end
	Function Rotation:Mat4( rv:Vec3<Double> )
		Return Rotation( rv.x,rv.y,rv.z )
	End
	
	Function Rotation:Mat4( rx:Double,ry:Double,rz:Double )
		Return New Mat4( Mat3<T>.Rotation( rx,ry,rz ) )
	End
	
	#rem monkeydoc Creates a scaling matrix.
	#end
	Function Scaling:Mat4( sx:T,sy:T,sz:T )
		Return New Mat4( sx,sy,sz,1 )
	End
	
	Function Scaling:Mat4( sv:Vec3<T> )
		Return Scaling( sv.x,sv.y,sv.z )
	End
	
	Function Scaling:Mat4( t:T )
		Return Scaling( t,t,t )
	End

	#rem monkeydoc Creates an orthographic projection matrix.
	#End	
	Function Ortho:Mat4( left:Double,right:Double,bottom:Double,top:Double,near:Double,far:Double )

		Local w:=right-left,h:=top-bottom,d:=far-near,r:Mat4

		r.i.x=2/w
		r.j.y=2/h
		r.k.z=2/d
		r.t.x=-(right+left)/w
		r.t.y=-(top+bottom)/h
		r.t.z=-(far+near)/d
		r.t.w=1

		Return r
	End
	
	Function Frustum:Mat4( left:Double,right:Double,bottom:Double,top:Double,near:Double,far:Double )
	
		Local w:=right-left,h:=top-bottom,d:=far-near,near2:=near*2,r:Mat4

		r.i.x=near2/w
		r.j.y=near2/h
		r.k.x=(right+left)/w
		r.k.y=(top+bottom)/h
		r.k.z=(far+near)/d
		r.k.w=1
		r.t.z=-(far*near2)/d
		
		Return r
	End
	
End
