
Class C Final
	
	Protected
	
	Field x:Int
	
End

Class C Extension
	
	Method Test:Int()
		
		Return x
	End
	
End
	
Function Main()
	
	Local c:=New C
	
	Print c.Test()

End
	