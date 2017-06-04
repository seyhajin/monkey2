
#Import "<std>"
Using std..

Enum myEnum
	a=1 'OOOOI
	b=2 'OOOIO
	c=4 'OOIOO
	d=8 'OIOOO
	e=16'IOOOO
End

Function Main()

	Local E:myEnum
	Local F:myEnum


	E=E.a | E.d | E.e '11001
	E=E ~ ( E.a | E.b ) '11001 ~ (00001 | 00010 )
	                    '11001 ~      00011

	                    '11001
	             ' XOR  '00011
							 '      -------
	                    '11010
											
	F=E & E.d
	F=F ~ ( E.e | E.d )
End
