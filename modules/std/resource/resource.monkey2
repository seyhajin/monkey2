
Namespace std.resource

#Rem monkeydoc The Resource class.

Currently WIP!

#end
Class Resource
	
	#rem monkeydoc Invoked when a resource is dscarded.
	#end
	Field Discarded:Void()
	
	#rem monkeyoc @hidden
	#end
	Property Refs:Int()
		
		Return _refs
	End
	
	#rem monkeyoc @hidden
	#end
	Method Retain()
		
		If Not _refs Return
		
		_refs+=1
	End
	
	#rem monkeyoc @hidden
	#end
	Method Release()
		
		If Not _refs Return
		
		If _refs=1 Discard() Else _refs-=1
	End
	
	#rem monkeyoc @hidden
	#end
	Method AddDependancy( r:Resource )
		
		If Not r Return
		
		r.Retain()

		Discarded+=r.Release
	End
	
	#rem monkeyoc Discards the resource.
	
	Calling this will cause the resource's internal [[OnDiscard]] method to be invoked, followed by the [[Discarded]] signal.
	
	A resource can only be discarded once. Once discarded a resource should be consider invalid.
	
	#end
	Method Discard()
		
		If Not _refs Return
		
		_refs=0
		
		OnDiscard()
		
		Discarded()
	End
	
	Protected
	
	#rem monkeyoc @hidden
	
	This method is invoked when the resource is discarded.
	
	This is where subclasses should place their actual discard code.
	
	#end
	Method OnDiscard() Virtual
	End
	
	Private
	
	Field _refs:=1
End

#rem monkeydoc @hidden
#end
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

#rem monkeydoc @hidden
#end
Function SafeRetain( r:Resource )
	
	If r r.Retain()
End

#rem monkeydoc @hidden
#end
Function SafeRelease( r:Resource )
	
	If r r.Release()
End
