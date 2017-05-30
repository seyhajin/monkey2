
#Import "<mojo>"

Using std..
Using mojo..

Function Main()
	
	Print "Wotzup?"
	Print "Hello World!!!!"
	
	Print "CurrentDir="+CurrentDir()
	ChangeDir( "../.." )
	Print "CurrentDir="+CurrentDir()

End
