
Enum WindowFlags
	HighDPI=1
	Resizable=2
End

Function Main()
	
	Local flags:=WindowFlags.HighDPI
	
	flags|=WindowFlags.Resizable
End