
#Import "<std>"

Using std..

Struct btVec3
	
End

Struct Vec3<T> Extension
	
	Operator To:btVec3()
		Return New btVec3
	End

End

Function Test( v:btVec3 )
End

Function Main()
	
	Print "Hello World!"

	Local t:=New Vec3f
	Test( t )
	
End
