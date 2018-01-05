
Namespace test

#Reflect test

Enum E
	A,B,C
End

Function Test( e:E )
	
	Print "e="+Int( e )
End

Function Main()
	
	Print Typeof<E>

	Local e:=E.A
	
	Print Typeof( e )
	
	Local type:=Typeof( e )
	
	For Local decl:=Eachin type.GetDecls()
		
		Local e:=Cast<E>( decl.Get( Null ) )
		
		Print decl.Name+"="+Int( e )
	
	Next
	
	Local rtest:=TypeInfo.GetType( "test" ).GetDecl( "Test" )
	
	rtest.Invoke( Null,New Variant[]( E.C ) )

End
