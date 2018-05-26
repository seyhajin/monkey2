
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojox>"
#Import "<httprequest>"

Using std..
Using mojo..
Using mojox..
Using httprequest..

Class MyWindow Extends Window
	
	Method New( title:String="HttpRequest demo",width:Int=640,height:Int=480,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )

		Layout="letterbox"		
		
		Local label:=New Label
		
		Local req:=New HttpRequest
		
		req.Timeout=10

		req.ReadyStateChanged=Lambda()
		
			label.Text="Ready state changed to "+Int( req.ReadyState )+" status="+req.Status
			
			Select req.ReadyState
			Case ReadyState.Done
				Print "Request done ReponseText=~q"+req.ResponseText+"~q Status="+req.Status
				Print "Length="+req.ResponseText.Length
			Case ReadyState.Error
				Print "Request error Status="+req.Status
			End
		
		End
		
	#If __TARGET__="emscripten"
		Const url:="test.txt"
	#else
		Const url:="https://www.github.com"
	#endif
		
		req.Open( "GET",url )
		
		Local button:=New Button( "CANCEL!" )
		
		button.Clicked+=Lambda()
		
			req.Cancel()
		End
		
		Local dockingView:=New DockingView
		
		dockingView.AddView( label,"top" )
		
		dockingView.ContentView=button
		
		ContentView=dockingView
		
		req.Send()
	End

#rem
	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
	
		canvas.DrawText( "Hello World!",Width/2,Height/2,.5,.5 )
	End
#end
	
	Method OnMeasure:Vec2i() Override
		
		Return New Vec2i( 320,240 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
