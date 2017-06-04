
Global g:C

Class C
	
	Field c:C
	
	Method Finalize() Override
		Print "Finalizing 'C'!"
		g=Self
	End

End

Function Main()
	
	Print "Hello World!"
	
	For Local i:=0 Until 1000000
		Local c:=New C
	Next

End
