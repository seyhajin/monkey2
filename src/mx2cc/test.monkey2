
Interface I
End

Interface J
End

Class A
End

Class B
End

Class C Implements I
End

Class D Implements J
End

Class E<X,Y> Where X Implements I Or Y Implements J
End

Function Main()
	
	Local test:=New E<A,D>
	
End
	