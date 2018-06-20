
Namespace myapp

#reflect myapp

Class C
End

Class C Extension
	Method Update()
	End
End

Function Main()
	
	For Local type:=Eachin TypeInfo.GetTypes()
		
		Print type
		
		For Local decl:=eachin type.GetDecls()
			
			Print "  "+decl
			
		Next
		
	Next
	
End
