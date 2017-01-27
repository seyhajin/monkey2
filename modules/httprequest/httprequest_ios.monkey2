
Namespace httprequest

#Import "native/httprequest.mm"

#Import "native/httprequest.h"

Extern

Enum ReadyState="bbReadyState"
	Unsent
	Done
	Error
End

Class HttpRequest="bbHttpRequest"
	
	Field ReadyStateChanged:Void()="readyStateChanged"
	
	Property ReadyState:ReadyState()="readyState"
		
	Property ResponseText:String()="responseText"
		
	Property Status:Int()="status"

	Method New()
		
	Method New( req:String,url:String,readyStateChanged:Void()=Null )
		
	Method Open( req:String,url:String )="open"
		
	Method SetHeader( name:String,value:String )="setHeader"
		
	Method Send()="send"
		
	Method Send( text:String )="send"
		
End
