Namespace jsonifier

Class StateMachine
	
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
End

Class StateMachineJsonifier Extends Jsonifier
	
	Method Jsonify:JsonValue( value:Variant,jsonifier:Jsonifier ) Override
		
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
	


End

	
