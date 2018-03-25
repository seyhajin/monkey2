Namespace jsonifier

Class Jsonifier
	
	Method AddInstance( obj:Object,ctor:Invocation )
		
		Assert( Not _instsByObj.Contains( obj ) )
		
		Local inst:=New Instance
		inst.obj=obj
		inst.id=_insts.Length
		inst.ctor=ctor
		inst.initialState=JsonifyState( obj )
		
		_instsByObj[inst.obj]=inst
		_instsById[inst.id]=inst

		_insts.Add( inst )
	End
	
	Method JsonifyInstances:JsonObject()
		
		Local jobj:=New JsonObject
		
		Local jinsts:=New JsonArray( _insts.Length )
		
		For Local i:=0 Until jinsts.Length
			
			Local inst:=_insts[i]
			Local jobj:=New JsonObject
			
			jobj["type"]=New JsonString( inst.obj.DynamicType.Name )
			jobj["ctor"]=Jsonify( inst.ctor )
			jobj["initialState"]=JsonifyState( inst.obj )
			
			jinsts[i]=jobj
		Next

		jobj["instances"]=jinsts
		
		Return jobj
	End
	
	Method Dejsonify( jobj:JsonObject )
		
		Local jinsts:=jobj.GetArray( "instances" )
		
		For Local i:=0 Until jinsts.Length
			
			Local jobj:=jinsts.GetObject( i )
			Local ctor:=Cast<Invocation>( Dejsonify( jobj["ctor"],Typeof<Invocation> ) )
			
			Local obj:=Cast<Object>( ctor.Execute() )
			
			_dejsonified.Add( obj )
			
			DejsonifyState( obj,jobj.GetObject( "initialState" ),obj.DynamicType )
		Next
	End
	
	Method Jsonify:JsonValue( value:Variant )
		
		Local type:=value.Type
		
		'handle primitive types
		Select type
		Case Typeof<Bool>
			Return New JsonBool( Cast<Bool>( value ) )
		Case Typeof<Int>
			Return New JsonNumber( Cast<Int>( value ) )
		Case Typeof<Float>
			Return New JsonNumber( Cast<Float>( value ) )
		Case Typeof<String>
			Return New JsonString( Cast<String>( value ) )
		End
		
		'handle references
		Select type.Kind
		Case "Class"
			Local obj:=Cast<Object>( value )
			If Not obj Return JsonValue.NullValue
			Local inst:=_instsByObj[obj]
			If inst Return New JsonString( inst.id )
		End
		
		'try custom jsonifiers
		For Local jext:=Eachin JsonifierExt.All
			Local jvalue:=jext.Jsonify( value,Self )
			If jvalue Return jvalue
		Next
		
		RuntimeError( "TODO: No jsonifier found for type '"+type+"'" )
		Return Null
	End
	
	Method Dejsonify:Variant( jvalue:JsonValue,type:TypeInfo )
		
		'handle primitive types
		Select type
		Case Typeof<Bool>
			Return jvalue.ToBool()
		Case Typeof<Int>
			Return Int( jvalue.ToNumber() )
		Case Typeof<Float>
			Return Float( jvalue.ToNumber() )
		Case Typeof<String>
			Return jvalue.ToString()
		End
		
		'handle references
		Select type.Kind
		Case "Class"
			If jvalue.IsNull
				Return type.NullValue
			Elseif jvalue.IsString
				Local id:=Int( jvalue.ToString() )
				Assert( id>=0 And id<_dejsonified.Length,"Dejsonify error" )
				Return _dejsonified[id]
			Endif
		End
		
		'try custom jsonifiers
		For Local jext:=Eachin JsonifierExt.All
			Local value:=jext.Dejsonify( jvalue,type,Self )
			If value Return value
		Next
		
		RuntimeError( "No dejsonifier found for type '"+type+"'" )
		Return Null
	End
	
	Method JsonifyArray<C>:JsonArray( values:C[] )
		
		Local jvalues:=New JsonArray( values.Length )
		
		For Local i:=0 Until jvalues.Length
			jvalues[i]=Jsonify( values[i] )
		Next
		
		Return jvalues
	End
	
	Method DejsonifyArray<C>:C[]( jvalue:JsonValue )
		
		Local jvalues:=jvalue.ToArray()
		Local values:=New C[jvalues.Length]
		
		For Local i:=0 Until values.Length
			values[i]=Cast<C>( Dejsonify( jvalues[i],Typeof<C> ) )
		Next
		
		Return values
	End
	
	Private
	
	Class Instance
		Field obj:Object
		Field id:Int
		Field ctor:Invocation
		Field initialState:JsonObject
	End
	
	Field _insts:=New Stack<Instance>
	
	Field _instsByObj:=New Map<Object,Instance>
	Field _instsById:=New Map<Int,Instance>
	
	Field _dejsonified:=New Stack<Object>
	
	Method JsonifyState:JsonObject( obj:Object )
		
		Local jobj:=New JsonObject
		
		JsonifyState( obj,jobj,obj.DynamicType )
		
		Return jobj
	End
	
	Method JsonifyState( obj:Object,jobj:JsonObject,type:TypeInfo )
		
		If type.SuperType JsonifyState( obj,jobj,type.SuperType )
		
		For Local d:=Eachin type.GetDecls()
			
			If d.Kind<>"Property" Continue
			'Note: Add DeclInfo.Access property so we can do public fields only?
			If Not d.Gettable Or Not d.Settable Continue
			
			jobj.SetValue( d.Name,Jsonify( d.Get( obj ) ) )
		Next
		
	End
	
	Method DejsonifyState( obj:Object,jobj:JsonObject,type:TypeInfo  )
		
		If type.SuperType DejsonifyState( obj,jobj,type.SuperType )

		For Local d:=Eachin type.GetDecls()
			
			If d.Kind<>"Property" Continue
			'Note: Add DeclInfo.Access property so we can do public fields only?
			If Not d.Gettable Or Not d.Settable Continue
			
			d.Set( obj,Dejsonify( jobj.GetValue( d.Name ),d.Type ) )
		Next
	
	End
	
End


Class JsonifierExt
	
	Const All:=New Stack<JsonifierExt>
	
	Method New()
		All.Add( Self )
	End
	
	Method Jsonify:JsonValue( value:Variant,jsonifier:Jsonifier ) Abstract
	
	Method Dejsonify:Variant( jvalue:JsonValue,type:TypeInfo,jsonifier:Jsonifier ) Abstract
End

