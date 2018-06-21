
Namespace test

#Import "<windows.h>"

Extern

Alias DWORD:UInt
Alias LPDWORD:DWORD Ptr

Public

Function Test( p:LPDWORD )
	
	Print p[0]
End

Function Main()
	
	Local t:DWORD=10
	
	Test( Varptr t )
End
