
Namespace test

#Import "<std>"

Using std..

Struct Test<T>

	Const A:=New Test( 10 )
	Const B:=New Test[ 100 ]
	
	Field t:T
	
	Method New( t:T )
		Self.t=t
	End
End


Function Main()

	Print Test<Int>.A.t
	Print Test<Int>.B.Length
	

End
