
Namespace mojo3d.graphics

#rem monkeydoc The Camera class.
#end
Class Camera Extends Entity

	#rem monkeydoc Creates a new camera.
	#end	
	Method New( parent:Entity=Null )
		Super.New( parent )
		
		Viewport=New Recti( 0,0,640,480 )
		Fov=90
		Near=1
		Far=1000
		
		Show()
	End
	
	#rem monkeydoc Copies the camera.
	#end
	Method Copy:Camera( parent:Entity=Null ) Override
		
		Local copy:=New Camera( Self,parent )
		
		CopyComplete( copy )
		
		Return copy
	End

	#rem monkeydoc @hidden
	#end	
	Property Viewport:Recti()
		
		Return _viewport
		
	Setter( viewport:Recti )
		
		_viewport=viewport

		_aspect=Float( _viewport.Width )/Float( _viewport.Height )
		
		_dirty|=Dirty.ProjMatrix
	End
	
	#rem monkeydoc Aspect ratio.
	
	Defaults to 1.0.
	
	#end
	Property Aspect:Float()
		
		Return _aspect
	End
	
	#rem monkeydoc Vertical field of view in degrees.
	
	Defaults to 90.0
	
	#end
	Property Fov:Float()
	
		Return _fovy
		
	Setter( fovy:Float )
	
		_fovy=fovy
		
		_dirty|=Dirty.ProjMatrix
	End
	
	#rem monkeydoc Near clip plane distance.
	
	Defaults to 1.0.
	
	#end
	Property Near:Float()
	
		Return _near
	
	Setter( nearz:Float )
	
		_near=nearz
		
		_dirty|=Dirty.ProjMatrix
	End
	
	#rem monkeydoc Far clip plane distance.
	
	Defaults to 1000.0.
	
	#end
	Property Far:Float()
	
		Return _farz
	
	Setter( farz:Float )
	
		_farz=farz
		
		_dirty|=Dirty.ProjMatrix
	End
	
	#rem monkeydoc @hidden
	#end	
	Property ProjectionMatrix:Mat4f()
	
		If _dirty & Dirty.ProjMatrix
			
			_projMatrix=Mat4f.Perspective( _fovy,_aspect,_near,_farz )
		
			_dirty&=~Dirty.ProjMatrix
		Endif
		
		Return _projMatrix
	End
	
	Protected

	#rem monkeydoc @hidden
	#end	
	Method New( camera:Camera,parent:Entity )
		Super.New( camera,parent )
		
		Viewport=camera.Viewport
		Fov=camera.Fov
		Near=camera.Near
		Far=camera.Far
		
		Show()
	End
	
	#rem monkeydoc @hidden
	#end	
	Method OnShow() Override
		
		Scene.Cameras.Add( Self )
	End
	
	#rem monkeydoc @hidden
	#end	
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
