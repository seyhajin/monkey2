
Namespace mojo3d

#rem monkeydoc The Camera class.
#end
Class Camera Extends Entity

	#rem monkeydoc Creates a new camera.
	#end	
	Method New( parent:Entity=Null )
		Super.New( parent )
		
		Viewport=New Recti( 0,0,640,480 )
		Near=1
		Far=1000
		FOV=90
		
		Visible=True
	End
	
	#rem monkeydoc Copies the camera.
	#end
	Method Copy:Camera( parent:Entity=Null ) Override
		
		Local copy:=New Camera( Self,parent )
		
		CopyTo( copy )
		
		Return copy
	End

	#rem monkeydoc @hidden
	#end	
	Property Viewport:Recti()
		
		Return _viewport
		
	Setter( viewport:Recti )
		
		_viewport=viewport

		_aspect=Float( _viewport.Width )/Float( _viewport.Height )
		
		'_dirty|=Dirty.ProjMatrix
	End
	
	#rem monkeydoc Aspect ratio.
	
	Defaults to 1.0.
	
	#end
	Property Aspect:Float()
		
		Return _aspect
	End
	
	#rem monkeydoc Vertical field of view in degrees.
	
	Defaults to 90.0.
	
	#end
	Property FOV:Float()
	
		Return _fovy
		
	Setter( fovy:Float )
	
		_fovy=fovy
		
		'_dirty|=Dirty.ProjMatrix
	End
	
	#rem monkeydoc Near clip plane distance.
	
	Defaults to 1.0.
	
	#end
	Property Near:Float()
	
		Return _near
	
	Setter( nearz:Float )
	
		_near=nearz
		
		'_dirty|=Dirty.ProjMatrix
	End
	
	#rem monkeydoc Far clip plane distance.
	
	Defaults to 1000.0.
	
	#end
	Property Far:Float()
	
		Return _farz
	
	Setter( farz:Float )
	
		_farz=farz
		
		'_dirty|=Dirty.ProjMatrix
	End
	
	#rem monkeydoc @hidden
	#end	
	Property ProjectionMatrix:Mat4f()
	
		If _dirty & Dirty.ProjMatrix
			
			_projMatrix=Mat4f.Perspective( _fovy,_aspect,_near,_farz )
		
			_dirty&=~Dirty.ProjMatrix
		Endif
		
		Return _projMatrix
		
	Setter( matrix:Mat4f )
		
		_projMatrix=matrix
		
		_dirty&=~Dirty.ProjMatrix
	End
	
	#rem monkeydoc Converts a point from world coordinates to viewport coordinates.
	#end
	Method ProjectToViewport:Vec2f( worldVertex:Vec3f )

		Local clip_coords:=ProjectionMatrix * InverseMatrix * New Vec4f( worldVertex,1.0 )
		
		Local ndc_coords:=clip_coords.XY/clip_coords.w
		
		Local vp_coords:=Cast<Vec2f>( Viewport.Size ) * (ndc_coords * 0.5 + 0.5)
	
		Return vp_coords
	End
	
	#rem monkeydoc Converts a point from viewport coordinates to world coordinates.
	#end
	Method UnprojectFromViewport:Vec3f( viewportCoords:Vec2f )
	
		Local vp_coords:=viewportCoords / Cast<Vec2f>( Viewport.Size ) * 2.0 - 1.0
	
		Local clip_coords:=New Mat4f( Matrix ) * -ProjectionMatrix * New Vec4f( vp_coords,-1.0,1.0 )
		
		Local world_coords:=clip_coords.XYZ/clip_coords.w
		
		Return world_coords
	End
	
	Method Pick:RayCastResult( viewportCoords:Vec2f,collisionMask:Int=-1 )
		
		If viewportCoords.x<0 Or viewportCoords.y<0 Or viewportCoords.x>=_viewport.Width Or viewportCoords.y>=_viewport.Height Return Null
		
		Local vpcoords:=viewportCoords
		
		vpcoords.x=vpcoords.x/_viewport.Width*2-1
		vpcoords.y=vpcoords.y/_viewport.Height*2-1
		
		Local iproj:=-ProjectionMatrix
		
		Local rayFrom:=Matrix * (iproj * New Vec3f( vpcoords,-1 ))
		Local rayTo:=Matrix * (iproj * New Vec3f( vpcoords,1 ))
		
		Return Scene.RayCast( rayFrom,rayTo,collisionMask )
	End
	
	Method MousePick:RayCastResult( collisionMask:Int=-1 )
	
		Local mouse:=Cast<Vec2f>( Mouse.Location )

		If App.ActiveWindow mouse.y=App.ActiveWindow.Height-mouse.y
			
		mouse.x-=Viewport.min.x
		mouse.y-=Viewport.min.y
		
		Return Pick( mouse,collisionMask )
	End
	
	Protected

	Method New( camera:Camera,parent:Entity )
		Super.New( camera,parent )
		
		Viewport=camera.Viewport
		Near=camera.Near
		Far=camera.Far
		FOV=camera.FOV
	End
	
	Method OnShow() Override
		
		Scene.Cameras.Add( Self )
	End
	
	Method OnHide() Override
		
		Scene.Cameras.Remove( Self )
	End
	
	Private
	
	Enum Dirty
		ProjMatrix=1
	End
	
	Field _viewport:=New Recti( 0,0,640,480 )
	
	Field _aspect:Float
	
	Field _fovy:Float
	
	Field _near:Float
	
	Field _farz:Float
	
	Field _dirty:Dirty=Dirty.ProjMatrix
	
	Field _projMatrix:Mat4f
	
End
