
Namespace test

#Reflect test

#Import "<std>"

#Import "jsonifier"
#Import "invocation"
#Import "jsonifierexts"
#Import "comparejson"

Using std..
Using jsonifier..

Global editing:=True
Global jsonifier:=New Jsonifier

Class Component
	
	Method New( entity:Entity )
		
		_entity=entity
		
		_entity.AddComponent( Self )
	End
	
	Property Entity:Entity()
		
		Return _entity
	End
	
	Protected
	
	Method SaveInitialState()
		
		If editing jsonifier.AddInstance( Self,New Variant[]( _entity ) )
	End
	
	Private
	
	Field _entity:Entity
	
End

Class Behaviour Extends Component
	
	Method New( entity:Entity )
		
		Super.New( entity )
			
		SaveInitialState()
	End
	
	Property Color:Color()
		
		Return _color
		
	Setter( color:Color )
		
		_color=color
	End
	
	Private
	
	Field _color:Color=graphics.Color.White
	
End

Class Entity
	
	Method New( parent:Entity )
		
		_parent=parent
	End
	
	Property Visible:Bool()
		
		Return _visible
	
	Setter( visible:Bool )
		
		_visible=visible
	End
	
	Method AddComponent<T>:T()
		
		Local component:=New T( Self )
		
		Return component
	End
	
	Protected
	
	Method SaveInitialState()
		
		If editing jsonifier.AddInstance( Self,New Variant[]( _parent ) )
	End
	
	Private
	
	Field _parent:Entity
	
	Field _visible:Bool
	
	Field _components:=New Stack<Component>
	
	Method AddComponent( component:Component )
		
		_components.Add( component )
	End
	
End

Class Camera Extends Entity
	
	Method New( parent:Entity )

		Super.New( parent )
		
		SaveInitialState()
		
		Visible=True
	End
	
End

Class Light Extends Entity
	
	Method New( parent:Entity )
		
		Super.New( parent )
		
		SaveInitialState()
		
		Visible=True
	End

End

Class Model Extends Entity
	
	Method New( parent:Entity )
		
		Super.New( parent )
		
		SaveInitialState()
		
		Visible=True
	End
	
	Function Load:Model( path:String,parent:Entity )
		
		Local model:=New Model( parent,True )
		
		If editing jsonifier.AddInstance( model,"Load",New Variant[]( path,parent ) )
		
		Return model
	End
	
	Private
	
	Method New( parent:Entity,loading:Bool )
		
		Super.New( parent )
	End

End

Function CreateScene()
	
	Print "CreateScene"

	jsonifier=New Jsonifier
	
	Local camera:=New Camera( Null )
	
	Local light:=New Light( Null )
	
	Local root:=Model.Load( "blah.txt",Null )
	
	For Local i:=0 Until 3
		
		Local model:=New Model( root )
		
		Local component:=New Behaviour( model )
	Next
	
End

Function SaveScene:JsonObject()
	
	Print "SaveScene"

	Local jobj:=jsonifier.JsonifyInstances()
	
	Return jobj
End

Function LoadScene( jobj:JsonObject )
	
	Print "LoadScene"
	
	jsonifier=New Jsonifier
	
	jsonifier.DejsonifyInstances( jobj )
End

Function Main()
	
	CreateScene()
	
	Local saved1:=SaveScene()
	
	LoadScene( saved1 )
	
	Local saved2:=SaveScene()
	
	If CompareJson( saved1,saved2 )=0
		Print saved1.ToJson()+"~nOkay!"
	Else
		Print "saved1:~n"+saved1.ToJson()+"~nsaved2:~n"+saved2.ToJson()+"~nError!"
	Endif
	
End
