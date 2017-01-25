
Namespace httprequest

#Import "<jni>"
#Import "<std>"
#Import "<mojo>"
#Import "<sdl2>"

#Import "native/Monkey2HttpRequest.java"
#Import "native/httprequest.cpp"
#Import "native/httprequest.h"

Using jni..
Using std..
Using mojo..
Using sdl2..

Extern Private

Global onReadyStateChanged:Void(jobject,Int)="bbHttpRequest::onReadyStateChanged"

Global onResponseReceived:Void(jobject,String,Int,Int)="bbHttpRequest::onResponseReceived"

private

Function OnMainFiber( func:Void() )
	
	If Fiber.Current()=Fiber.Main() func() Else App.Idle+=func
	
End

Public

Enum ReadyState
	
	Unsent=0
	Opened=1
	HeadersReceived=2
	Loading=3
	Done=4
	Error=5

End

Class HttpRequest
	
	Field ReadyStateChanged:Void()
	
	Method New()

		Local env:=Android_JNI_GetEnv()
		
		Init( env )
		
		Local obj:=env.AllocObject( _class )
		
		_obj=env.NewGlobalRef( obj )
		
		Insert()
	End
	
	Method New( req:String,url:String,readyStateChanged:Void()=Null )
		Self.New()
		
		ReadyStateChanged=readyStateChanged
		
		Open( req,url )
	End
	
	Property ReadyState:ReadyState()
		
		Return Cast<ReadyState>( _readyState )

	End
	
	Property ResponseText:String()
		
		Return _response
	End
	
	Property Status:Int()
		
		Return _status
	End
	
	Method Discard()
		
		Remove()
		
		Local env:=Android_JNI_GetEnv()
		
		env.DeleteGlobalRef( _obj )
		
	End
	
	Method Open( req:String,url:String )
		
		OnMainFiber( Lambda()
		
			Local env:=Android_JNI_GetEnv()
		
			env.CallVoidMethod( _obj,_open,New Variant[]( req,url ) )
		End )
	End
	
	Method SetHeader( header:String,value:String )
		
		OnMainFiber( Lambda()

			Local env:=Android_JNI_GetEnv()
		
			env.CallVoidMethod( _obj,_setHeader,New Variant[]( header,value ) )
		End )
	End
	
	Method Send()
		
		Send( "" )
	End
	
	Method Send( text:String )
		
		OnMainFiber( Lambda()

			Local env:=Android_JNI_GetEnv()
		
			env.CallVoidMethod( _obj,_send,New Variant[]( text ) )
		
		End )
		
	End
	
	Private
	
	Global _list:HttpRequest
	
	Field _succ:HttpRequest
	Field _obj:jobject
	Field _readyState:Int
	Field _response:String
	Field _status:int
	
	Method New( peer:jobject )
		_obj=peer
	End
	
	Method Insert()
		_succ=_list
		_list=Self
	End
	
	Method Remove()
		local inst:=_list,pred:HttpRequest=Null
		While inst
			If inst=Self
				If pred
					pred._succ=_succ
				Else
					_list=_succ
				Endif
				Return
			Endif
			pred=inst
			inst=inst._succ
		Wend
	End
	
	Global _class:jclass
	Global _open:jmethodID
	Global _setHeader:jmethodID
	Global _send:jmethodID
	
	Function OnReadyStateChanged( obj:jobject,state:Int )
		
		Local env:=Android_JNI_GetEnv()
		
		Local inst:=_list
		
		While inst
			
			If env.IsSameObject( obj,inst._obj )
				
				inst._readyState=state
				
				inst.ReadyStateChanged()
				
				Return
			Endif
			
			inst=inst._succ
		Wend
		
	End
	
	Function OnResponseReceived( obj:jobject,response:String,status:Int,state:Int )

		Local env:=Android_JNI_GetEnv()
		
		Local inst:=_list
		
		While inst
			
			If env.IsSameObject( obj,inst._obj )
				
				inst._response=response
				
				inst._status=status
				
				inst._readyState=state
				
				inst.ReadyStateChanged()
			
			Endif

			inst=inst._succ
		wend
	End
	
	Function Init( env:JNIEnv )
		If _class Return
	
		_class=env.FindClass( "com/monkey2/lib/Monkey2HttpRequest" )
		If Not _class RuntimeError( "Can't find com.monkey2.lib.Monkey2HttpRequest class" )
		
		_open=env.GetMethodID( _class,"open","(Ljava/lang/String;Ljava/lang/String;)V" )
		
		_setHeader=env.GetMethodID( _class,"setHeader","(Ljava/lang/String;Ljava/lang/String;)V" )
	
		_send=env.GetMethodID( _class,"send","(Ljava/lang/String;)V" )
		
		onReadyStateChanged=OnReadyStateChanged
		
		onResponseReceived=OnResponseReceived
	End
	
End

		
