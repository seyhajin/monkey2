
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/"

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
		
		Visible=true
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
		
		'create scene
		'		
		_scene=New Scene
		
		_scene.ClearColor=Color.Sky
		
		'create camera
		'
		_camera=New Camera
		
		_camera.Move( 0,0,-5 )
		
		New FlyBehaviour( _camera )
		
		'create light
		'
		_light=New Light
		
		_light.Rotate( 75,15,0 )
		
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
		
		_morpher.Visible=True
		
	End
	
	Method OnRender( canvas:Canvas ) Override

		RequestRender()
		
		_camera.Viewport=Rect

		_scene.Render( canvas )

		canvas.Scale( Width/640.0,Height/480.0 )
		
		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()
	
	New AppInstance
	
	New MyWindow
	
	App.Run()
End
		
		
		
