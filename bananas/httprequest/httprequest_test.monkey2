
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<httprequest>"

Using std..
Using mojo..
Using httprequest..

Class MyWindow Extends Window
	
	Field req:HttpRequest

	Method New( title:String="HttpRequest demo",width:Int=640,height:Int=480,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )
		
		req=New HttpRequest( "GET","http://www.blitzbasic.com",Lambda()
		
			Print "Ready state changed to "+Int( req.ReadyState )
			
			If req.ReadyState=4 
				Print "ReponseText="+req.ResponseText
				Print "Status="+req.Status
			Endif
		
		End )
		
		New Fiber( Lambda()
		
			req.Send()
			
		End )
	End

	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
	
		canvas.DrawText( "Hello World!",Width/2,Height/2,.5,.5 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
