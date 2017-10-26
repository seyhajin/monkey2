Interface I
	
	Method A:Int()
	
End

Interface I2
	
	Method B:Int()
	
End

Interface J Extends I,I2
	
End

Class C Implements J
	
	Method A:Int()
		Return 1
	End
	
	Method B:Int()
		Return 1
	End
	
End

Class D
End

Class Test<T> Where T Implements INumeric

End

Function Main()
	
	Local test:Test<Int>
	
	Local j:J=New C
	
	print j.A()
End
