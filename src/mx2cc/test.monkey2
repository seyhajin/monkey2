
Namespace test

#Import "<reflection>"

#Import "<mojo3d>"
#Import "<std>"

Using reflection..

Using std..

#Reflect mojo3d
#Reflect std

#Reflect test

Class C
End

Class D Extends C
	
	Property Position:Vec3f()
	
		Return New Vec3f(1,2,3)
	End
End

Class E
	
	Field _c:C=New D
	
	Field _pos:=New Vec3f( 1,2,3 )
	
	Method GetC:C()
		
		Return _c
	End
	
End

Class E Extension
	
	Property D:D()
		
		Return Cast<D>( GetC() )
	End
	
	Property Position:Vec3f()
		
		Return _pos
	
	Setter( pos:Vec3f )
		
		_pos=pos
	End
	
End

Function Main()

	DebugTypes()
	
	Local e:=New E
	
	SetProperty( "Position",e,New Vec3f( 4,5,6 ) )
	
	Print GetProperty<Vec3f>( "Position",e )
	
End
