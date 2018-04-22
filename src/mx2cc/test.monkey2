
Function Main()
	
	Local t:=New Int[3,3]( 
	1,2,3,
	4,5,6,
	7,8,9 )
	
	For Local y:=0 Until 3
		For Local x:=0 Until 3
			Print t[x,y]
		Next
	Next
	
End
