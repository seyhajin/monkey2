
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/"

#Import "util"

Using std..
Using mojo..
Using mojo3d..

Class Morpher Extends Renderable

	Method New( mesh0:Mesh,mesh1:Mesh,material:Material,parent:Entity=null )
		Super.New( parent )

		'get mesh vertices - don't need entire meshes	
		_vertices0=mesh0.GetVertices()
		_vertices1=mesh1.GetVertices()
		_material=material
		
		'create vertexbuffer
		'
		_vbuffer=New VertexBuffer( Vertex3f.Format,_vertices0.Length )
		
		'create and initilize indexbuffer
		'	
		Local indices:=mesh0.GetIndices( 0 )
		_ibuffer=New IndexBuffer( IndexFormat.UINT32,indices.Length )
		_ibuffer.SetIndices( indices.Data,0,indices.Length )
	End
	
	Protected
	
	Method OnRender( rq:RenderQueue ) override
	
		Local alpha:=Sin( Now() )*.5+.5
		
		'lock vertex buffer
		Local vp:=Cast<Vertex3f Ptr>( _vbuffer.Lock() )
		
		For Local i:=0 Until _vbuffer.Length
		
			Local v:=_vertices0[i]

			'interpolate position			
			v.position=_vertices0[i].position.Blend( _vertices1[i].position,alpha )
			
			'interpolate normal
			v.normal=_vertices0[i].normal.Blend( _vertices1[i].normal,alpha ).Normalize()
			
			vp[i]=v
		Next
		
		'invalidate all vertices
		_vbuffer.Invalidate()
		
		'unlock vertices
		_vbuffer.Unlock()
		
		'add renderop
		rq.AddRenderOp( _material,Self,_vbuffer,_ibuffer,3,_ibuffer.Length/3,0 )
	End
	
	Private
	
	Field _vertices0:Vertex3f[]
	Field _vertices1:Vertex3f[]
	Field _material:Material
	
	Field _vbuffer:VertexBuffer
	Field _ibuffer:IndexBuffer
	
	Field _nvertices:Int
End

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _morpher:Morpher
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		Print gles20.glGetString( gles20.GL_EXTENSIONS ).Replace( " ","~n" )
		
		'create scene
		'		
		_scene=Scene.GetCurrent()
		
		_scene.ClearColor=Color.Sky
		
		'create camera
		'
		_camera=New Camera
		_camera.Move( 0,0,-5 )
		
		'create light
		'
		_light=New Light
		_light.RotateX( 90 )
		_light.CastsShadow=True
		
		Local mesh1:=Mesh.CreateBox( New Boxf( -1,1 ),8,8,8 )
		
		Local mesh2:=Mesh.CreateBox( New Boxf( -1,1 ),8,8,8 )
		
		'sphericalize mesh2
		For Local i:=0 Until mesh2.NumVertices
			Local v:=mesh2.GetVertex( i )
			v.position=v.position.Normalize()
			v.normal=v.position.Normalize()
			mesh2.SetVertex( i,v )
		Next
		
		Local material:=New PbrMaterial( Color.Green )
		
		_morpher=New Morpher( mesh1,mesh2,material )
	End
	
	Method OnRender( canvas:Canvas ) Override

		RequestRender()

		util.Fly( _camera,Self )
		
		_scene.Render( canvas,_camera )

		canvas.Scale( Width/640.0,Height/480.0 )
		
		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()
	
	Local config:=New StringMap<String>

'	config["mojo3d_renderer"]="deferred"		'defeault on non-mobile targets.

'	config["mojo3d_renderer"]="forward-direct"	'default on mobile targets. depth buffer must be enabled too.
'	config["GL_depth_buffer_enabled"]=1

'	config["mojo3d_renderer"]="forward"
		
	New AppInstance( config )
	
	New MyWindow
	
	App.Run()
End
		
		
		
