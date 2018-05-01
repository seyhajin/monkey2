
Class C

	Method Update()
		Print "Update!"
	End
		
End

Class D

	Method NewC:C()
		
		Return New C
	End
End

Function Main()
	
	
	(New D).NewC().Update()
	
End

