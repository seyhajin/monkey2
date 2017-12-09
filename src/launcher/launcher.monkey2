
#Import "<libc>"
#Import "<std>"

Using std..

#If __HOSTOS__="windows"

'to build resource.o when icon changes...
'
'windres resource.rc resource.o

#If __ARCH__="x86"
#Import "resource.o"
#Elseif __ARCH__="x64"
#Import "resource_x64.o"
#endif

#Endif

Function Main()

	Local qargs:=AppArgs().Slice( 1 )
	For Local i:=0 Until qargs.Length
		qargs[i]="~q"+qargs[i]+"~q"
	Next
	Local args:=" ".Join( qargs )

#If __HOSTOS__="windows"

	libc.system( "bin\ted2_windows\ted2.exe "+args )
	
#Else If __HOSTOS__="macos"

	libc.system( "open ~q"+std.filesystem.AppDir()+"../../../bin/ted2_macos.app~q --args "+args )

#Else If __HOSTOS__="linux"

	libc.system( "bin/ted2_linux/ted2 "+args+" >/dev/null 2>/dev/null &" )

#Else If __HOSTOS__="raspbian"

	libc.system( "bin/ted2_raspbian/ted2 "+args+" >/dev/null 2>/dev/null &" )

#Endif

End
