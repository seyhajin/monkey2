
Namespace httprequest

#Import "<std>"

Using std..

#If __TARGET__="windows" Or __TARGET__="linux"

#Import "httprequest_desktop"

#Import "bin/wget.exe"

#Else If __TARGET__="macos" Or  __TARGET__="ios"

#Import "httprequest_ios"

#Elseif __TARGET__="emscripten"

#Import "httprequest_emscripten"

#Elseif __TARGET__="android"

#Import "httprequest_android"

#Endif

Enum ReadyState
	Unsent=0
	Opened=1
	HeadersReceived=2
	Loading=3
	Done=4
	Error=5
End

Class HttpRequestBase
	
	Field ReadyStateChanged:Void()
	
	Method New()
		
		_readyState=ReadyState.Unsent
		_timeout=10
		_status=-1
	End
	
	Method New( req:String,url:String,readyStateChanged:Void()=Null )
		
		Self.New()
		
		Open( req,url )
		
		ReadyStateChanged=readyStateChanged
	End
	
	Property Timeout:Float()
		
		Return _timeout
		
	Setter( timeout:Float )
		
		_timeout=timeout
	End
	
	Property ReadyState:ReadyState()
		
		Return _readyState
	End
	
	Property ResponseText:String()
		
		Return _response
	End
	
	Property Status:Int()
		
		Return _status
	End
	
	Method Open( req:String,url:String )
		
		If _readyState<>ReadyState.Unsent Return
		
		_method=req
		
		_url=url
		
		OnOpen()
		
		_readyState=ReadyState.Opened
		
		ReadyStateChanged()
	End
	
	Method SetHeader( header:String,value:String )
		
		If _readyState<>ReadyState.Opened Return
		
		OnSetHeader( header,value )
	End
	
	Method Send()
		
		Send( "" )
	End
	
	Method Send( text:String )

		If _readyState<>ReadyState.Opened Return
		
		OnSend( text )
	End
	
	Protected
	
	Field _timeout:Float=10.0
	Field _response:String
	Field _status:Int=-1
	Field _method:String
	Field _url:String
	
	Method OnOpen() Virtual
	End

	Method OnSetHeader( header:String,value:String ) Abstract
	
	Method OnSend( text:String ) Abstract
	
	Method SetReadyState( readyState:ReadyState )
		
		If readyState=_readyState Return
		
		_readyState=readyState
		
		ReadyStateChanged()
	End
	
	Private
	
	Field _readyState:ReadyState
	
End

