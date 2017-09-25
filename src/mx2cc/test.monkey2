
#Import "<std>"

Using std..

Class C
	
	Field x:Int
	
	Field c:C
	
	Method New()
		
		Local p:=Varptr( c )
	End
		
End

Function Main()
	
	Local c:=New C
	
	c.x=10
	
	GCSuspend()
	
	Local p:=Cast<Void Ptr>( c )

	Print Hex( ulong( p ) )
	
	c=Cast<C>( p )
	
	GCResume()
	
	Print c.x
	
End
