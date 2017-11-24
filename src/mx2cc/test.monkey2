Namespace myapp

#Import "<std>"
#Import "<mojo>"

Using std..

Class C
	
	Field x:Int
	
	Property X:Int()
		
		Return x
		
	Setter( x:Int )
		
		Self.x=x
	End
End

Function Main()
	
	Local c:=New C
	
	c.X=10
	
	Print c.X
End
