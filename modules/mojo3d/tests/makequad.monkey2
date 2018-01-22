
#rem

Very simple demo showing how to make a custom mesh.

#end
#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _model:Model
	
	Method New()
		
		'create scene
		'
		_scene=New Scene

		'create camera
		'
		_camera=New Camera( Self )
		_camera.Move( 0,0,-2.5 )
		
		'create light
		'
		_light=New Light
		_light.Rotate( 60,30,0 )
		
		'create quad mesh
		'
		Local vertices:=New Vertex3f[](
			New Vertex3f( -1, 1,0 ),
			New Vertex3f(  1, 1,0 ),
			New Vertex3f(  1,-1,0 ),
			New Vertex3f( -1,-1,0 ) )

		Local indices:=New UInt[]( 0,1,2,0,2,3 )
		
		Local mesh:=New Mesh( vertices,indices )
		
		'Update mesh normals since we haven't provided them ourselves
		'
		mesh.UpdateNormals()
		
		'create model for the mesh
		'
		_model=New Model
		_model.Mesh=mesh
		_model.Material=New PbrMaterial( Color.Red )
		_model.Material.CullMode=CullMode.None

	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		_model.RotateY( 1 )
		
		_scene.Render( canvas )

		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()
	
	New AppInstance
	New MyWindow
	App.Run()
End

	