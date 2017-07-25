
Namespace mojo3d.graphics

Private

Const DegreesToRadians:=Pi/180.0

Const RadiansToDegrees:=180.0/Pi

Public

#rem monkeydoc Entity extension methods.
#end
Class Entity Extension

	#rem monkeydoc Local rotation in degrees.
	#end
	Property Rotation:Vec3f()
		
		Return Basis.GetRotation() * RadiansToDegrees
	
	Setter( rotation:Vec3f )
		
		Basis=Mat3f.Rotation( rotation * DegreesToRadians )
	End
	
	#rem monkeydoc World rotation in degrees.
	#end
	Property WorldRotation:Vec3f()
		
		Return WorldBasis.GetRotation() * RadiansToDegrees
	
	Setter( rotation:Vec3f )
		
		WorldBasis=Mat3f.Rotation( rotation * DegreesToRadians )
	End
	
	#rem monkeydoc X coordinate of local position.
	#end
	Property X:Float()
		
		Return Position.x
		
	Setter( x:Float )
		
		Local v:=Position
		Position=New Vec3f( x,v.y,v.z )
	End
	
	#rem monkeydoc Y coordinate of local position.
	#end
	Property Y:Float()
	
		Return Position.y
	
	Setter( y:Float )
		
		Local v:=Position
		Position=New Vec3f( v.x,y,v.z )
	End

	#rem monkeydoc Z coordinate of local position.
	#end
	Property Z:Float()
	
		Return Position.z
	
	Setter( z:Float )
		
		Local v:=Position
		Position=New Vec3f( v.x,v.y,z )
	End
	
	#rem monkeydoc X coordinate of world position.
	#end
	Property WorldX:Float()
		
		Return WorldPosition.x
		
	Setter( x:Float )

		Local v:=WorldPosition		
		WorldPosition=New Vec3f( x,v.y,v.z )
	End
	
	#rem monkeydoc Y coordinate of world position.
	#end
	Property WorldY:Float()
	
		Return WorldPosition.y
	
	Setter( y:Float )
		
		Local v:=WorldPosition		
		WorldPosition=New Vec3f( v.x,y,v.z )
	End

	#rem monkeydoc Z coordinate of world position.
	#end
	Property WorldZ:Float()
	
		Return WorldPosition.z
	
	Setter( z:Float )
		
		Local v:=WorldPosition		
		WorldPosition=New Vec3f( v.x,v.y,z )
	End
	
	#Rem monkeydoc Rotation around the X axis in degrees.
	#End
	Property Rx:Float()
		
		Return Rotation.x
		
	Setter( rx:Float )
		
		Local r:=Rotation
		Rotation=New Vec3f( rx,r.y,r.z )
	End

	#Rem monkeydoc Rotation around the Y axis in degrees.
	#End
	Property Ry:Float()
		
		Return Rotation.y
		
	Setter( ry:Float )
		
		Local r:=Rotation
		Rotation=New Vec3f( r.x,ry,r.z )
	End

	#Rem monkeydoc Rotation around the X axis in degrees.
	#End
	Property Rz:Float()
		
		Return Rotation.z
		
	Setter( rz:Float )
		
		Local r:=Rotation
		Rotation=New Vec3f( r.x,r.y,rz )
	End

	#Rem monkeydoc Rotation around the X axis in degrees.
	#End
	Property WorldRx:Float()
		
		Return WorldRotation.x
		
	Setter( rx:Float )
		
		Local r:=WorldRotation
		WorldRotation=New Vec3f( rx,r.y,r.z )
	End

	#Rem monkeydoc Rotation around the Y axis in degrees.
	#End
	Property WorldRy:Float()
		
		Return WorldRotation.y
		
	Setter( ry:Float )
		
		Local r:=WorldRotation
		WorldRotation=New Vec3f( r.x,ry,r.z )
	End

	#Rem monkeydoc Rotation around the X axis in degrees.
	#End
	Property WorldRz:Float()
		
		Return WorldRotation.z
		
	Setter( rz:Float )
		
		Local r:=WorldRotation
		WorldRotation=New Vec3f( r.x,r.y,rz )
	End
	
	#rem monkeydoc Scale on the x axis.
	#end
	Property Sx:Float()
		
		Return Scale.x
	
	Setter( sx:Float )
		
		Local s:=Scale
		Scale=New Vec3f( sx,s.y,s.z )
	End
	
	#rem monkeydoc Scale on the y axis.
	#end
	Property Sy:Float()
		
		Return Scale.y
	
	Setter( sy:Float )
		
		Local s:=Scale
		Scale=New Vec3f( s.x,sy,s.z )
	End
	
	#rem monkeydoc Scale on the z axis.
	#end
	Property Sz:Float()
		
		Return Scale.z
	
	Setter( sz:Float )
		
		Local s:=Scale
		
		Scale=New Vec3f( s.x,s.y,sz )
	End
	
	#rem monkeydoc Scale on the x axis.
	#end
	Property WorldSx:Float()
		
		Return WorldScale.x
	
	Setter( sx:Float )
		
		Local s:=WorldScale
		
		WorldScale=New Vec3f( sx,s.y,s.z )
	End
	
	#rem monkeydoc Scale on the y axis.
	#end
	Property WorldSy:Float()
		
		Return WorldScale.y
	
	Setter( sy:Float )
		
		Local s:=WorldScale
		
		WorldScale=New Vec3f( s.x,sy,s.z )
	End
	
	#rem monkeydoc Scale on the z axis.
	#end
	Property WorldSz:Float()
		
		Return WorldScale.z
	
	Setter( sz:Float )
		
		Local s:=WorldScale
		
		WorldScale=New Vec3f( s.x,s.y,sz )
	End
	
	#rem monkeydoc Sets entity basis matrix in local or world space.
	#end
	Method SetBasis( basis:Mat3f,worldSpace:Bool=False )
		
		If worldSpace WorldBasis=basis Else Basis=basis
	End
	
	#rem monkeydoc Gets entity basis matrix in local or world space.
	#end
	method GetBasis:Mat3f( worldSpace:Bool=False )
		
		Return worldSpace ? WorldBasis Else Basis
	
	End

	#rem monkeydoc Sets entity position in local or world space.
	#end
	Method SetPosition( position:Vec3f,worldSpace:Bool=False )
		
		If worldSpace WorldPosition=position Else Position=position
	End
	
	Method SetPosition( x:Float,y:Float,z:Float,worldSpace:Bool=False )
		
		SetPosition( New Vec3f( x,y,z ),worldSpace )
	End
	
	#rem monkeydoc Gets entity position in local or world space.
	#end
	Method GetPostition:Vec3f( worldSpace:Bool=False )
		
		Return worldSpace ? WorldPosition Else Position
	End
	
	#rem monkeydoc Sets entity rotation in euler angles in local or world space.
	#end
	Method SetRotation( rotation:Vec3f,worldSpace:Bool=False )
		
		Local basis:=Mat3f.Rotation( rotation * DegreesToRadians )
		
		If worldSpace WorldBasis=basis Else Basis=basis
	End
	
	Method SetRotation( rx:Float,ry:Float,rz:Float,worldSpace:Bool=False )
		
		SetRotation( New Vec3f( rx,ry,rz ),worldSpace )
	End
	
	#rem monkeydoc Gets entity rotation in euler angles in local or world space.
	#end
	Method GetRotation:Vec3f( worldSpace:Bool=False )
		
		Local basis:=worldSpace ? WorldBasis Else Basis
		
		Return basis.GetRotation() * RadiansToDegrees
	End
	
	#rem monkeydoc Sets entity scale in local or world space.
	#end
	Method SetScale( scale:Vec3f,worldSpace:Bool=False )
		
		If worldSpace WorldScale=scale Else Scale=scale
	End
	
	Method SetScale( sx:Float,sy:Float,sz:Float,worldSpace:Bool=False )
		
		SetScale( New Vec3f( sx,sy,sz ),worldSpace )
	End

	#rem monkeydoc Gets entity scale in local or world space.
	#end
	Method GetScale:Vec3f( worldSpace:Bool=False )
		
		Return worldSpace ? WorldScale Else Scale
	End
	
	#rem monkeydoc Moves the entity.
	
	Moves the entity relative to its current orientation.
	
	#end	
	Method Move( tv:Vec3f,worldSpace:Bool=False )
		
		If worldSpace WorldPosition+=tv Else Position+=Basis * tv
	End
	
	Method Move( tx:Float,ty:Float,tz:Float )
		
		Move( New Vec3f( tx,ty,tz ) )
	End
	
	#rem monkeydoc Moves the entity on the X axis.
	
	Moves the entity relative to its current orientation.
	
	#end	
	Method MoveX( tx:Float,worldSpace:Bool=False )
		
		If worldSpace WorldX+=tx Else Position+=Basis.i * tx
	End
	
	#rem monkeydoc Moves the entity on the Y axis.
	
	Moves the entity relative to its current orientation.
	
	#end	
	Method MoveY( ty:Float,worldSpace:Bool=False )

		If worldSpace WorldY+=ty Else Position+=Basis.j * ty
	End
	
	#rem monkeydoc Moves the entity on the Z axis.
	
	Moves the entity relative to its current orientation.
	
	#end	
	Method MoveZ( tz:Float,worldSpace:Bool=False )

		If worldSpace WorldZ+=tz Else Position+=Basis.k * tz
	End
	
	#rem monkeydoc Rotates the entity.
	
	Rotates the entity.
	
	If `postRotate` is true, the rotation is applied after the entity's world rotation.
		
	If `postRotate` is false, the rotation is applied before the entity's local rotation.
		
	#end
	Method Rotate( rv:Vec3f,postRotate:Bool=False )
		
		Local basis:=Mat3f.Rotation( rv * DegreesToRadians )
		
		If postRotate WorldBasis=basis*WorldBasis Else Basis*=basis
	End
	
	Method Rotate( rx:Float,ry:Float,rz:Float,postRotate:Bool=False )
		
		Rotate( New Vec3f( rx,ry,rz ),postRotate )
	End
	
	#rem monkeydoc Rotates the entity around the X axis.
	#end
	Method RotateX( rx:Float,postRotate:Bool=False )
		
		Local basis:=Mat3f.Pitch( rx * DegreesToRadians )
		
		If postRotate WorldBasis=basis*WorldBasis Else Basis*=basis
	End

	#rem monkeydoc Rotates the entity around the Y axis.
	#end
	Method RotateY( ry:Float,postRotate:Bool=False )

		Local basis:=Mat3f.Yaw( ry * DegreesToRadians )
		
		If postRotate WorldBasis=basis*WorldBasis Else Basis*=basis
	End

	#rem monkeydoc Rotates the entity around the Z axis.
	#end
	Method RotateZ( rz:Float,postRotate:Bool=False )

		Local basis:=Mat3f.Roll( rz * DegreesToRadians )
		
		If postRotate WorldBasis=basis*WorldBasis Else Basis*=basis
	End

	#rem monkeydoc Points the entity at a target.
	#end
	Method PointAt( target:Vec3f,up:Vec3f=New Vec3f( 0,1,0 ) )
		
		Local k:=(target-WorldPosition).Normalize()
		
		Local i:=up.Cross( k ).Normalize()
		
		Local j:=k.Cross( i )
		
		WorldBasis=New Mat3f( i,j,k )
	End
	
	Method PointAt( target:Entity,up:Vec3f=New Vec3f( 0,1,0 ) )
		
		PointAt( target.WorldPosition )
	End

End
