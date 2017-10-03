
Class C
	Field x:Int,y:Int
End

Enum E
	A,B,C
End

Function F2:Int( n:Int )
	Local i:=n*2
	Return i
End

Function F1:Int( n:Int )
	Local i:=F2(n*2)
	Return i
End

Function Main()

	Local e:E
	Local c:=New C
	Local c2:C
	Local t:=New C[20]
	t[5]=c
	
	DebugStop()

	Print "HERE!"
	
	Local i:=0
	While i<10
		Print "i="+i
		i+=1
	Wend

	For Local i:=0 Until 10
		If i<5
			Print "i<5"
		Else If i<7
			Print "i<7"
		Else
			Print "i"
		endif
		Print F1(i)
	Next
	
	Print "HERE!"
End
