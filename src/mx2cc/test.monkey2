
#Import "test2"

Class B

	Method New( t:Int=0 )
		Print "B.New"
	End
	
End

Class C Extends B

	Method New()
		Print "C.New"
	End
End

Function Main()

	Local c:=New C
End
