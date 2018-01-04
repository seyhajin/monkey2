
Namespace test

#Import "<reflection>"
#Import "<std>"
#Import "<mojo>"
#Import "<mojox>"
#Import "<mojo3d>"

#Reflect test
#Reflect std
#Reflect mojo
#Reflect mojo3d
#Reflect mojox

Using reflection..
Using std..

Class E
	
	Field _name:="Brian"
	
	Field _pos:=New Vec3f( 1,2,3 )
	
	Property Name:String()
		
		Return _name
	
	Setter( name:String )
		
		_name=name
	End
	
End

Class E Extension
	
	Property Position:Vec3f()
		
		Return _pos
	
	Setter( pos:Vec3f )
		
		_pos=pos
	End
	
End

Function Main()

	Local e:=New E
	
	SetProperty( "Name",e,"Douglas" )
	
	Print GetProperty<String>( "Name",e )
	
	SetProperty( "Position",e,New Vec3f( 4,5,6 ) )
	
	Print GetProperty<Vec3f>( "Position",e )
	
End
