Namespace jsonifier

Class Invocation
	
	Method New( scope:TypeInfo,decl:DeclInfo,inst:Variant,args:Variant[] )
		_scope=scope
		_decl=decl
		_inst=inst
		_args=args
	End
	
	Property Scope:TypeInfo()
		Return _scope
	End
	
	Property Decl:DeclInfo()
		Return _decl
	End
	
	Property Inst:Variant()
		Return _inst
	End
	
	Property Args:Variant[]()
		Return _args
	End
	
	Method Execute:Variant()
		Return _decl.Invoke( _inst,_args )
	End
	
	Function Ctor:Invocation( obj:Object,args:Variant[] )
		
		Return Ctor( obj,"New",args )
		
		#rem
		
		Local type:=obj.DynamicType
		
		For Local decl:=Eachin type.GetDecls( "New" )
			
			Local ftype:=decl.Type
			If ftype.ParamTypes.Length<>args.Length Continue
			
			Local match:=True
			For Local i:=0 Until args.Length
				If args[i]
					If args[i].Type.ExtendsType( ftype.ParamTypes[i] ) Continue
				Else
					If ftype.ParamTypes[i].Kind="Class" Continue
				Endif
				match=False
				Exit
			Next
			
			If match Return New Invocation( type,decl,Null,args )
		Next
		
		RuntimeError( "Can't find matching ctor for args" )
		
		Return Null
		#end
	End
	
	Function Ctor:Invocation( obj:Object,dname:String,args:Variant[] )
		
		Local type:=obj.DynamicType

		For Local decl:=Eachin type.GetDecls( dname )
			
			Local ftype:=decl.Type
			If ftype.ParamTypes.Length<>args.Length Continue
			
			Local match:=True
			For Local i:=0 Until args.Length
				If args[i]
					If args[i].Type.ExtendsType( ftype.ParamTypes[i] ) Continue
				Else
					If ftype.ParamTypes[i].Kind="Class" Continue
				Endif
				match=False
				Exit
			Next
			
			If match Return New Invocation( type,decl,Null,args )
		Next
		
		RuntimeError( "Can't find matching ctor for args" )
		
		Return Null
	End
	
'	Function DefaultCtor:Invocation( obj:Object )
'	End
	
	Private
	
	Field _scope:TypeInfo
	Field _decl:DeclInfo
	Field _inst:Variant
	Field _args:Variant[]
End

