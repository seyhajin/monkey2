Namespace mojo3d.jsonifier

Class Jsonifier
	
	Method AddInstance( obj:Object,ctor:Invocation )
		
		Assert( Not _instsByObj.Contains( obj ) )
		
		Local inst:=New Instance
		inst.obj=obj
		inst.id="@"+String(_insts.Length)
		inst.ctor=ctor
		inst.initialState=JsonifyState( obj )
		
		_instsByObj[inst.obj]=inst
		_instsById[inst.id]=inst

		_insts.Add( inst )
	End

	'ctor via ctor
	Method AddInstance( obj:Object,args:Variant[] )
		
		AddInstance( obj,New Invocation( obj.DynamicType,"New",Null,args ) )
	end

	'ctor via method call
	Method AddInstance( obj:Object,decl:String,inst:Variant,args:Variant[] )
		
		AddInstance( obj,New Invocation( decl,inst,args ) )
	End

	'ctor via function call
	Method AddInstance( obj:Object,decl:String,args:Variant[] )
		
		AddInstance( obj,New Invocation( decl,Null,args ) )
	End

	#rem
	'function/method call	
	Method AddInstance( obj:Object,name:String,args:Variant[] )
		
		AddInstance( obj,New Invocation( name,args ) )
	End
	
	#end
	
	Method JsonifyInstances:JsonObject()
		
		Local jobj:=New JsonObject
		
		Local jinsts:=New JsonArray( _insts.Length )
		
		For Local i:=0 Until jinsts.Length
			
			Local inst:=_insts[i]
			Local jobj:=New JsonObject
			
			jobj["id"]=New JsonString( inst.id )
			jobj["type"]=New JsonString( inst.obj.DynamicType.Name )
			jobj["ctor"]=Jsonify( inst.ctor )
			
			Local state:=JsonifyState( inst.obj ),dstate:=New JsonObject
			
			For Local it:=Eachin state.All()
				
				Local x:=it.Value
				Local y:=inst.initialState.GetValue( it.Key )
				
				If CompareJson( x,y )<>0 dstate[it.Key]=x
			Next
			
			jobj["state"]=dstate
			
			jinsts[i]=jobj
		Next

		jobj["instances"]=jinsts
		
		Return jobj
	End
	
	Method DejsonifyInstances( jobj:JsonObject )
		
		Local jinsts:=jobj.GetArray( "instances" )
		
		For Local i:=0 Until jinsts.Length
			
			Local obj:Object
						
			If i<_insts.Length
				
				obj=_insts[i].obj
				
			Else
				Local jobj:=jinsts.GetObject( i )
				
				Local ctor:=Cast<Invocation>( Dejsonify( jobj["ctor"],Typeof<Invocation> ) )
			
				obj=Cast<Object>( ctor.Execute() )
			Endif
			
			_dejsonified.Add( obj )
		Next
		
		For Local i:=0 Until _dejsonified.Length
			
			Local jobj:=jinsts.GetObject( i )
			
			Local obj:=_dejsonified[i]
			
			DejsonifyState( obj,jobj.GetObject( "state" ),obj.DynamicType )
		Next
	End
	
	Method Jsonify:JsonValue( value:Variant )
		
		If Not value Return JsonValue.NullValue
		
		Local type:=value.Type
		Assert( type )
		
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
		Case Typeof<Bool[]>
			Return JsonifyArray( Cast<Bool[]>( value ) )
		Case Typeof<Int[]>
			Return JsonifyArray( Cast<Int[]>( value ) )
		Case Typeof<Float[]>
			Return JsonifyArray( Cast<Float[]>( value ) )
		Case Typeof<String[]>
			Return JsonifyArray( Cast<String[]>( value ) )
		End
		
		'handle enums+references
		Select type.Kind
		Case "Class"
			Local obj:=Cast<Object>( value )
			If Not obj Return JsonValue.NullValue
			Local inst:=_instsByObj[obj]
			If inst Return New JsonString( inst.id )
		Case "Enum"
			Return New JsonNumber( value.EnumValue )
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
		Case Typeof<Bool[]>
			Return DejsonifyArray<Bool>( jvalue )
		Case Typeof<Int[]>
			Return DejsonifyArray<Int>( jvalue )
		Case Typeof<Float[]>
			Return DejsonifyArray<Float>( jvalue )
		Case Typeof<String[]>
			Return DejsonifyArray<String>( jvalue )
		End
		
		'handle references
		Select type.Kind
		Case "Class"
			If jvalue.IsNull
				Return type.NullValue
			Elseif jvalue.IsString
				Local id:=Int( jvalue.ToString().Slice( 1 ) )
				Assert( id>=0 And id<_dejsonified.Length,"Dejsonify error" )
				Local obj:=_dejsonified[id]
				Return obj
			Endif
		Case "Enum"
			Return type.MakeEnum( jvalue.ToNumber() )
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
		Field id:String
		Field ctor:Invocation
		Field initialState:JsonObject
	End
	
	Field _insts:=New Stack<Instance>
	
	Field _instsByObj:=New Map<Object,Instance>
	Field _instsById:=New StringMap<Instance>
	
	Field _dejsonified:=New Stack<Object>
	
	Method JsonifyState:JsonObject( obj:Object )
		
		Local jobj:=New JsonObject
		
		JsonifyState( obj,jobj,obj.DynamicType )
		
		Return jobj
	End
	
	Method JsonifyState( obj:Object,jobj:JsonObject,type:TypeInfo )
		
		If type.Kind<>"Class" Return
		
		If type.SuperType JsonifyState( obj,jobj,type.SuperType )
		
		For Local d:=Eachin type.GetDecls()
			
			If d.Kind<>"Property" Continue
			'Note: Add DeclInfo.Access property so we can do public fields only?
			If Not d.Gettable Or Not d.Settable Continue
			
			If Not Int( d.GetMetaValue( "jsonify" ) ) Continue
			
			jobj.SetValue( d.Name,Jsonify( d.Get( obj ) ) )
		Next
		
	End
	
	Method DejsonifyState( obj:Object,jobj:JsonObject,type:TypeInfo  )
		
		If type.Kind<>"Class" Return
		
		If type.SuperType DejsonifyState( obj,jobj,type.SuperType )

		For Local d:=Eachin type.GetDecls()
			
			If d.Kind<>"Property" Continue
			'Note: Add DeclInfo.Access property so we can do public fields only?
			If Not d.Gettable Or Not d.Settable Or Not jobj.Contains( d.Name ) Continue
			
			If Not Int( d.GetMetaValue( "jsonify" ) ) Continue
			
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

