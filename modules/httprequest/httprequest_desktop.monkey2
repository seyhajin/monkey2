
Namespace httprequest

Function Hello()
End

Class HttpRequest Extends HttpRequestBase
	
	Method New()
	End
	
	Protected
	
	Method OnSend( text:String ) Override
		
		Global id:=0
		
		id+=1
		
		_tmp=GetEnv( "TMP" )+"\wget-"+id+".txt"
		
	#if __TARGET__="windows"
		Local post_data:=_req="POST" ? " -post-data=~q"+text+"~q" Else ""
		Local cmd:="wget -q -T "+_timeout+" -O ~q"+_tmp+"~q --method="+_req+post_data+" ~q"+_url+"~q"
	#else
		Local cmd:="curl -s -m "+timeout+" -o ~q"+_tmp+"~q ~q"+url+"~q"
	#endif
		
		_process=New Process
		
		_process.Finished=Lambda()
		
			If Not _process Return
		
			If _process.ExitCode=0
				
				_response=LoadString( _tmp )
				
				DeleteFile( _tmp )
				
				_status=200
				
				_process=Null
				
				SetReadyState( ReadyState.Done )
				
			Else
				
				DeleteFile( _tmp )
				
				_status=404
				
				_process=Null
				
				SetReadyState( ReadyState.Error )
				
			Endif
		End
		
		SetReadyState( ReadyState.Loading )
		
		_process.Start( cmd )
	End
	
	Method OnCancel() Override
		
		If Not _process Return

		DeleteFile( _tmp )
		
		_process.Terminate()
		
		_process=Null
		
		_status=-1

		SetReadyState( ReadyState.Error )
	End
	
	Private
	
	Field _process:Process
	
	Field _tmp:String
End
