
#Import "<std>"
#Import "<mojo>"

Using std..
Using mojo..

Global f:void()

Function Test2()
End

Function Test2( x:Int )
End

Class C
	
	Method New()
		f=Test
	End
	
	Method Test()
		print "Here!"
	End
	
	Method Test( x:Int )
	End
End

Function Main()
	
	New C
	
	f()
	
	
End
