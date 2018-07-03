
#rem Threading note

* Const/Global vars use TLS

* Const/Global vars in namespace/type scopes are only initialized on main thread.

* Const/Global vars in block scopes are initialized for every thread.

#end

#Import "<thread>"

Class C
End

Function Test()
	
	Const N:=10
	
	Local threads:=New Thread[N]
	
	For Local i:=0 Until N
		
		Print "Starting thread "+i
		
		Local sema:=New Semaphore
	
		threads[i]=New Thread( Lambda()
		
			Print "Starting thread "+Thread.Current().Id
			
			sema.Signal()
		
			For Local i:=0 Until 10
				
				Print "thread="+Thread.Current().Id+" i="+i
				
				For Local j:=0 Until 1000
					Local tmp:=New C
					Local tmp2:=tmp
				Next
			Next
			
		End )
		
		sema.Wait()
		
		Print "Thread started "+threads[i].Id
	
	Next
	
	For Local i:=0 Until N
		
		Print "Joining "+i
		
		threads[i].Join()

		Print "Joined "+i
	Next
End

Function Main()
	
	Local N:=10
	
	GCSetTrigger( 65536 )
	
	For Local i:=0 Until N
	
		Print "Test "+i
		
		Test()
	Next
	
	Print "Goodbye!"
End
