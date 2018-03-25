
Namespace test

Class C
End

Struct S<T>
End

Alias Si:S<Int>

Function Get<T>:TypeInfo()
	Return Typeof( Cast<T>( Null ) )
End

Function Main()
	
	Print Typeof<C>
	
	Print Typeof<Si>
	
End
