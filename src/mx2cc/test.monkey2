
Global weakRef:WeakRef

Class C
End

Function Test()
	
	weakRef=New WeakRef( New C )
End

Function Main()
	
	Test()
	
'	Local tmp:=weakRef.Target
	
	Print "weakRef valid="+(weakRef.Target<>Null)
	
	GCCollect()
	GCCollect()

	Print "weakRef valid="+(weakRef.Target<>Null)
	
	Print "Hello World"
	
End
