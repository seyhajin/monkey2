
#reflect test

Namespace test

Class C

End

Function Main()
	
'	Local c:C'=New C

	Local v:=Typeof<C>.NullValue
	
	Local c:=Cast<C>( v )
	
	If c Print "no null" Else Print "null"
		
	Print Typeof(c)=Typeof<C>
End
