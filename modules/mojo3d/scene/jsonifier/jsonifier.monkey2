Namespace mojo3d.jsonifier

Class Jsonifier

	Method AddInstance( obj:Variant,ctor:Invocation )
		
		Local tobj:=Cast<Object>( obj )
		
		Assert( Not _instsByObj.Contains( tobj ) )
		
		Local inst:=New Instance
		inst.obj=obj
		inst.id="@"+String(_insts.Length)
		inst.ctor=ctor
		inst.initialState=JsonifyState( tobj )
		
		_instsByObj[tobj]=inst
		_instsById[inst.id]=inst

		_insts.Add( inst )
	End

	'ctor via ctor
	Method AddInstance( obj:Variant,args:Variant[] )
		
		AddInstance( obj,New Invocation( obj.DynamicType,"New",Null,args ) )
	end

	'ctor via method call
	Method AddInstance( obj:Variant,decl:String,inst:Variant,args:Variant[] )
		
		AddInstance( obj,New Invocation( decl,inst,args ) )
	End

	'ctor via function call
	Method AddInstance( obj:Variant,decl:String,args:Variant[] )
		
		AddInstance( obj,New Invocation( decl,Null,args ) )
	End

	Method JsonifyInstances:JsonObject()
		
		Local jobj:=New JsonObject
		
		jobj["assetsDir"]=New JsonString( AssetsDir() )
		
		Local jinsts:=New JsonArray( _insts.Length )
		
		For Local i:=0 Until _insts.Length
			
			Local jobj:=New JsonObject
			
			Local inst:=_insts[i]
			Local tobj:=Cast<Object>( inst.obj )
			
			jobj["id"]=New JsonString( inst.id )
			
			jobj["type"]=New JsonString( tobj.DynamicType.Name )
			
			jobj["ctor"]=Jsonify( inst.ctor )
			
			Local state:=JsonifyState( tobj ),dstate:=New JsonObject
			
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
		
		Local assetsDir:=AssetsDir()
		
		If jobj.Contains( "assetsDir" ) SetAssetsDir( jobj.GetString( "assetsDir" ) )
		
		Local jinsts:=jobj.GetArray( "instances" )
		
		For Local i:=0 Until jinsts.Length
			
			Local jobj:=jinsts.GetObject( i )
			
			Local obj:Variant
						
			If i<_insts.Length
				
				obj=_insts[i].obj
			Else
				Local ctor:=Cast<Invocation>( Dejsonify( jobj["ctor"],Typeof<Invocation> ) )
			
				obj=ctor.Execute()
			Endif

			_dejsonified.Add( obj )
			
			Local tobj:=Cast<Object>( obj )
			
			'set value type state only on this pass.
			If jobj.Contains( "state" ) DejsonifyState( tobj,jobj.GetObject( "state" ),tobj.DynamicType,False )
		Next

		'set reference type state - do this on a second pass 'coz of forward refs. Probably wont always work?
		For Local i:=0 Until _dejsonified.Length
			
			Local jobj:=jinsts.GetObject( i )
			
			Local obj:=_dejsonified[i]
			
			Local tobj:=Cast<Object>( obj )
			
			If jobj.Contains( "state" ) DejsonifyState( tobj,jobj.GetObject( "state" ),tobj.DynamicType,True )
		Next
		
		SetAssetsDir( assetsDir )
	End
	
	Method Jsonify:JsonValue( value:Variant )
		
		If Not value Return JsonValue.NullValue
		
		Local type:=value.Type
		Assert( type )
		
		'handle primitive types
		Select type
		Case Typeof<Bool>
			Return New JsonBool( Cast<Bool>( value ) )
		Case Typeof<Short>
			Return New JsonNumber( Cast<Short>( value ) )
		Case Typeof<Int>
			Return New JsonNumber( Cast<Int>( value ) )
		Case Typeof<Float>
			Return New JsonNumber( Cast<Float>( value ) )
		Case Typeof<String>
			Return New JsonString( Cast<String>( value ) )
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

		Select type.Kind
		Case "Class"
			Return JsonValue.NullValue
		Case "Array"
			Local n:=value.GetArrayLength()
			Local jarray:=New JsonArray( n )
			For Local i:=0 Until n
				jarray[i]=Jsonify( value.GetArrayElement( i ) )
			Next
			Return jarray
		End
		
		RuntimeError( "TODO: No jsonifier found for type '"+type+"'" )
		Return Null
	End
	
	Method Dejsonify<T>:T( jvalue:JsonValue )
		
		Return Cast<T>( Dejsonify( jvalue,Typeof<T> ) )
	End
	
	Method Dejsonify:Variant( jvalue:JsonValue,type:TypeInfo )
		
		'handle primitive types
		Select type
		Case Typeof<Bool>
			Return jvalue.ToBool()
		Case Typeof<Short>
			Return Short( jvalue.ToNumber() )
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
				Local id:=Int( jvalue.ToString().Slice( 1 ) )
				Assert( id>=0 And id<_dejsonified.Length,"Dejsonify error" )
				Local inst:=_dejsonified[id]
				Return inst
			Endif
		Case "Enum"
			Return type.MakeEnum( jvalue.ToNumber() )
		End
		
		'try custom jsonifiers
		For Local jext:=Eachin JsonifierExt.All
			Local value:=jext.Dejsonify( jvalue,type,Self )
			If value Return value
		Next

		Select type.Kind
		Case "Class"
			Return type.NullValue
		Case "Array"
			Local elemType:=type.ElementType
			Local jarray:=Cast<JsonArray>( jvalue )
			Local n:=jarray.Length,v:=elemType.NewArray( n )
			For Local i:=0 Until n
				Local elem:=Dejsonify( jarray[i],elemType )
				v.SetArrayElement( i,elem )
			Next
			Return v
		End
		
		RuntimeError( "No dejsonifier found for type '"+type+"'" )
		
		Return Null
	End
	
	Private
	
	Class Instance
		Field obj:Variant
		Field id:String
		Field ctor:Invocation
		Field initialState:JsonObject
	End
	
	Field _insts:=New Stack<Instance>
	
	Field _instsByObj:=New Map<Object,Instance>
	Field _instsById:=New StringMap<Instance>
	
	Field _dejsonified:=New Stack<Variant>
	
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

	Method DejsonifyState( obj:Object,jobj:JsonObject,type:TypeInfo,insts:Bool )
		
		If type.Kind<>"Class" Return
		
		If type.SuperType DejsonifyState( obj,jobj,type.SuperType,insts )

		For Local d:=Eachin type.GetDecls()
			
			If d.Kind<>"Property" Continue
			'Note: Add DeclInfo.Access property so we can do public fields only?
			If Not d.Gettable Or Not d.Settable Or Not jobj.Contains( d.Name ) Continue
			
			If Not Int( d.GetMetaValue( "jsonify" ) ) Continue
			
			Local type:=d.Type
			
			Local isinst:=type.Kind="Class"
			
			If Not isinst And type.Kind="Array" And type.ElementType.Kind="Class" isinst=True
				
			If isinst<>insts Continue
			
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

