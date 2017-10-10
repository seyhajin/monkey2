Class Type
	Method M()
		Print "HEY!"
	End
End

Class Comp
	
	Const type:=New Type
End

Class Entity
	
	Property P<T>:Int()
		
		Local t:=T.type
		
		t.M()
		
		Return 0
		
	Setter( t:Int )
		
		T.type.M()
		
	End
	
End
	
Function Main()
	
	Local e:=New Entity
	
	e.P<Comp> =10
	
	Print e.P<Comp>
	
End
