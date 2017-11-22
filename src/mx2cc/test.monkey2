Namespace myapp

#Import "<std>"

Using std..

Function Main()

	Local stack:=New Stack<String>
	
	Local compare:=Lambda:Bool( i1:Int,i2:String )
		Return Int(i2)=i1
	End
	
	' 1. compile error
	stack.Sort( compare )
	' 2. compile error
'	stack.Sort<Int>( compare,10 )
	' 3. works (the name is different)
'	stack.Sort2( compare )
	
End

Class Stack<T> Extension
	
	' I want to compare different types, why not
	' like a compare wrapper with its internal walue
	
	Method Sort<V>( compareFunc:Bool( v:V,t:T ) )
		
		Print "Here!"
	
		' custom sorting is here
		For Local v:=Eachin Self
	
		Next
	End
	
	Method Sort3<V>( compareFunc:Bool( v:V,t:T ) )
		
		Print "Here!"
	
		' custom sorting is here
		For Local v:=Eachin Self
	
		Next
	End
	
	' try to change method signature by additional parameter
	' error is still here
	
	Method Sort<V>( compareFunc:Bool( v:V,t:T ),someVar:V )
		
		Print "Here2!"
	
		' custom sorting is here
		For Local v:=Eachin Self
	
		Next
	End
	
	Method Sort2<V>( compareFunc:Bool( v:V,t:T ) )
	
		' custom sorting is here
		For Local v:=Eachin Self
	
		Next
	End
	
End
