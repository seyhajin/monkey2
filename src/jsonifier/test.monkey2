
Namespace test

#Reflect test

#Import "<std>"

#Import "jsonifier"
#Import "invocation"
#Import "jsonifierexts"

Using std..
Using jsonifier..

Global jsonifier:=New Jsonifier

Class C
	
	Field _parent:C
	
	Field _position:Vec3f
	
	Method New( parent:C )
		
		_parent=parent
		
		Local ctor:=Invocation.Ctor( Self,New Variant[]( parent ) )
		
		jsonifier.AddInstance( Self,ctor )
	End
	
	Property Position:Vec3f()
		
		Return _position
		
	Setter( pos:Vec3f )
		
		_position=pos
	End

End

Function Main()
	
	Local p:C=Null
	
	Print Typeof(p)
	
	For Local i:=0 Until 3
		Local c:=New C( p )
		c.Position=New Vec3f( i,i*2,i*3 )
		p=c
	Next
	
	Local jobj:=jsonifier.JsonifyInstances()
	
	Print jobj.ToJson()
End
