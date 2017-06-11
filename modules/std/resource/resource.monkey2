
Namespace std.resource

Class Resource
	
	Field Discarded:Void()
	
	Property Refs:Int()
		
		Return _refs
	End
	
	Method Retain()
		
		If Not _refs Return
		
		_refs+=1
	End
	
	Method Release()
		
		If Not _refs Return
		
		If _refs=1 Discard() Else _refs-=1
	End
	
	Method Discard()
		
		If Not _refs Return
		
		_refs=0
		
		OnDiscard()
		
		Discarded()
	End
	
	Method AddDependancy( r:Resource )
		
		If Not r Return
		
		r.Retain()

		Discarded+=r.Release
	End
	
	Protected
	
	Method OnDiscard() Virtual
	End
	
	Private
	
	Field _refs:=1
End

Class ResourceManager Extends Resource

	Method New()

		_managers.Push( Self )
	End
	
	Method OpenResource:Resource( slug:String )
	
		For Local manager:=Eachin _managers
		
			Local r:=manager._retained[slug]

			If Not r Continue
			
			If manager<>Self AddResource( slug,r )
			
			Return r
		Next

		Return Null
	End
	
	Method AddResource( slug:String,r:Resource )

		If Not r Or _retained.Contains( slug ) Return
		
		_retained[slug]=r
	End
	
	Protected
	
	Method OnDiscard() Override
	
		_managers.Remove( Self )
		
		For Local it:=Eachin _retained
			
			it.Value.Release()
				
			it.Value=Null
		Next
		
		_retained=Null
	End
	
	Private
	
	Global _managers:=New Stack<ResourceManager>
	
	Global _refs:=New StringMap<Int>
	
	Field _retained:=New StringMap<Resource>

End

Function SafeRetain( r:Resource )
	
	If r r.Retain()
End

Function SafeRelease( r:Resource )
	
	If r r.Release()
End
