
Namespace ted2

#Import "<mojo3d>"
#Import "<mojo3d-assimp>"

Using mojo3d..

Class SceneDocumentView Extends View

	Method New( doc:SceneDocument )
		_doc=doc
		
		Layout="fill"
	End
	
	Protected
	
	Method OnRender( canvas:Canvas ) Override
	
		For Local x:=0 Until Width Step 64
			For Local y:=0 Until Height Step 64
				canvas.Color=(x~y) & 64 ? New Color( .1,.1,.1 ) Else New Color( .05,.05,.05 )
				canvas.DrawRect( x,y,64,64 )
			Next
		Next
		
		Local model:=_doc.Model
		If Not model
			canvas.Clear( Color.Sky )
			Return
		Endif
		
		RequestRender()
		
		If Keyboard.KeyDown( Key.Up )
			model.RotateX( .1 )
		Else If Keyboard.KeyDown( Key.Down )
			model.RotateX( -.1 )
		Endif
		
		If Keyboard.KeyDown( Key.Left )
			model.RotateY( .1,True )
		Else If Keyboard.KeyDown( Key.Right )
			model.RotateY( -.1,True )
		Endif

		If Keyboard.KeyDown( Key.A )
			_doc.Camera.MoveZ( .1 )
		Else If Keyboard.KeyDown( Key.Z )
			_doc.Camera.MoveZ( -.1 )
		Endif
		
		_doc.Scene.Render( canvas,_doc.Camera )
	End
	
	Method OnMouseEvent( event:MouseEvent ) Override
	End
	
	Private

	Field _doc:SceneDocument
End

Class SceneDocument Extends Ted2Document
	
	Method New( path:String )
		Super.New( path )
		
		_view=New SceneDocumentView( Self )
		
		_scene=New Scene
		
		Scene.SetCurrent( _scene )
		
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.MoveZ( -2.5 )
			
		_light=New Light
		_light.RotateX( Pi/2 )
		
		Scene.SetCurrent( Null )
	End
	
	Property Model:Model()
	
		Return _model
	End
	
	Property Scene:Scene()
		
		Return _scene
	End
	
	Property Camera:Camera()
		
		Return _camera
	End
	
	Protected
	
	Method OnLoad:Bool() Override

		Scene.SetCurrent( _scene )
		
		Print "Loading model:"+Path

		_model=Model.Load( Path )

		If _model
			_model.Mesh.FitVertices( New Boxf( -1,1 ) )
		Endif
		
		Scene.SetCurrent( Null )
	
		Return True
	End
	
	Method OnSave:Bool() Override

		Return False
	End
	
	Method OnClose() Override
		
	End
	
	Method OnCreateView:SceneDocumentView() Override
	
		Return _view
	End
	
	Private
	
	Field _view:SceneDocumentView
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _model:Model
End

Class SceneDocumentType Extends Ted2DocumentType

	Protected
	
	Method New()
		AddPlugin( Self )
		
		Extensions=New String[]( ".b3d",".3ds",".dae" )
	End
	
	Method OnCreateDocument:Ted2Document( path:String ) Override
		
		Return New SceneDocument( path )
	End
	
	Private
	
	Global _instance:=New SceneDocumentType
	
End
