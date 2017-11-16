
Class C

	Field c:C
	Field f:Int
	
	Property F:Int()
		
		Return f
	
	Setter( f:Int )
		
		Self.f=f
	
	End
End

Function Main()
	
	Local c:C=New C
	
	c.c=c
	
	c?.c?.f=10
	
	c?.c?.F=100
	
	Print c.f
End
