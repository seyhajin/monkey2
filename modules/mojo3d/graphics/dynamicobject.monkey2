
Namespace mojo3d

Class DynamicObject

	Method SetDynamicProperty<T>( name:String,value:T )
	
		If Not _dynprops _dynprops=New StringMap<Object>
		
		_dynprops[name]=value
	End
	
	Method GetDynamicProperty<T>:T( name:String )
	
		Return _dynprops ? Cast<T>( _dynprops[name] ) Else Null
	End
	
	Private
	
	Field _dynprops:StringMap<Object>
End
