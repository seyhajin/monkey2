
Namespace mx2

Class Expr Extends PNode

	Method New( srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
	End
	
	Method OnSemant:Value( scope:Scope ) Virtual
		Throw New SemantEx( "OnSemant TODO!" )
		Return Null
	End
	
	Method OnSemantType:Type( scope:Scope ) Virtual
		Throw New SemantEx( "Invalid type expression" )
		Return Null
	End
	
	Method OnSemantWhere:Bool( scope:Scope ) Virtual
		Throw New SemantEx( "Invalid 'Where' expression" )
		Return False
	End
	
	Method Semant:Value( scope:Scope )
	
		Try
			semanting.Push( Self )
			
			Local value:=OnSemant( scope )
			
			value.CheckAccess( scope )
			
			semanting.Pop()
			Return value
			
		Catch ex:SemantEx
		
			semanting.Pop()
			Throw ex
		End
		
		Return Null
	End
	
	Method SemantRValue:Value( scope:Scope,type:Type=Null )

		Try
			semanting.Push( Self )
			
			Local value:=OnSemant( scope )
			
			Local rvalue:Value
			If type rvalue=value.UpCast( type ) Else rvalue=value.ToRValue()
			
			rvalue.CheckAccess( scope )
			
			semanting.Pop()
			Return rvalue
			
		Catch ex:SemantEx
		
			semanting.Pop()
			Throw ex
		End
		
		Return Null
	End
	
	Method TrySemantRValue:Value( scope:Scope,type:Type=Null )
	
		Try
		
			Return SemantRValue( scope,type )

		Catch ex:SemantEx
		End
		
		Return Null
	End
	
	Method SemantType:Type( scope:Scope,canBeGeneric:Bool=False )

		Try
			semanting.Push( Self )

			Local type:=OnSemantType( scope )
			
			Local ctype:=TCast<ClassType>( type )
			If Not canBeGeneric And ctype And ctype.types And Not ctype.instanceOf
				Throw New SemantEx( "Illegal use of generic class '"+ctype.ToString()+"'" )
			Endif
			
			semanting.Pop()
			Return type
		
		Catch ex:SemantEx
		
			semanting.Pop()
			Throw ex
		End
		
		Return Null
	End
	
	Method SemantWhere:Bool( scope:Scope )

		Try
			semanting.Push( Self )
			
			Local twhere:=OnSemantWhere( scope )
			
			semanting.Pop()
			Return twhere
		
		Catch ex:SemantEx
		
			semanting.Pop()
			Throw ex
		End
		
		Return False
	End

End

Class ValueExpr Extends Expr

	Field value:Value
	
	Method New( value:Value,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
	
		Self.value=value
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Return value
	End
End

Class IdentExpr Extends Expr

	Field ident:String
	
	Method New( ident:String,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.ident=ident
	End
	
	Method OnSemant:Value( scope:Scope ) Override
		
		Local value:=scope.FindValue( ident )
		If value Return value
		
		Local type:=scope.FindType( ident )
		If type Return New TypeValue( type )
		
		Throw New SemantEx( "Identifier '"+ident+"' Not found" )
	End
	
	Method OnSemantType:Type( scope:Scope ) Override
	
		Local type:=scope.FindType( ident )
		If Not type Throw New SemantEx( "Type '"+ident+"' not found" )
		
		Return type
	End

	Method ToString:String() Override
	
		Return ident
	End
	
End

Class MemberExpr Extends Expr

	Field expr:Expr
	Field ident:String
	
	Method New( expr:Expr,ident:String,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.expr=expr
		Self.ident=ident
	End
	
	Method OnSemant:Value( scope:Scope ) Override
		
		Local evalue:=expr.Semant( scope )
		
		Local tvalue:=Cast<TypeValue>( evalue )
		
		If Not tvalue And TCast<EnumType>( evalue.type )
			
			tvalue=New TypeValue( expr.SemantType( scope ) )
		Endif
		
		If tvalue
			
			Local ctype:=TCast<ClassType>( tvalue.ttype )
			
			If ctype And ctype.types And Not ctype.instanceOf
				Throw New SemantEx( "Class '"+ctype.Name+"' is generic" )
				'throw New SemantEx( "Illegal use of generic class '"+ctype.ToString()+"'" )
			Endif
			
			Local value:=tvalue.FindValue( ident )
			
			If Not value Throw New SemantEx( "Type '"+tvalue.ttype.Name+"' has no member named '"+ident+"'" )
				
			Return value
		Endif
		
		Local value:=evalue.FindValue( ident )
		
		If Not value Throw New SemantEx( "Value of type '"+evalue.type.Name+"' has no member named '"+ident+"'" )
			
		Return value
	End
	
	Method OnSemantType:Type( scope:Scope ) Override
	
		Local etype:=expr.SemantType( scope )
		
		Local type:=etype.FindType( ident )
		If Not type Throw New SemantEx( "Type '"+etype.Name+"' has no member type named '"+ident+"'" )
		
		Return type
	End

	Method ToString:String() Override

		Return expr.ToString()+"."+ident
	End
	
End

Class SafeMemberExpr Extends Expr

	Field expr:Expr
	Field ident:String
	
	Method New( expr:Expr,ident:String,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.expr=expr
		Self.ident=ident
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local block:=Cast<Block>( scope )
		If Not block SemantError( "SafeMemberExpr.OnSemant" )
		
		Local value:=Self.expr.SemantRValue( scope ).RemoveSideEffects( block )

		Local thenValue:=value.FindValue( ident )
		
		If Not thenValue Throw New SemantEx( "Value of type '"+value.type.Name+"' has no member named '"+ident+"'" )

		thenValue=thenValue.ToRValue()
		
		Local ifValue:=value.UpCast( Type.BoolType )
		
		Local elseValue:=New LiteralValue( thenValue.type,"" )
		
		Return New IfThenElseValue( thenValue.type,ifValue,thenValue,elseValue )
	End
End

Class InvokeExpr Extends Expr

	Field expr:Expr
	Field args:Expr[]

	Method New( expr:Expr,args:Expr[],srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.expr=expr
		Self.args=args
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local args:=SemantArgs( Self.args,scope )
		
		Local value:=expr.Semant( scope )
		
		Local ivalue:=value.Invoke( args )
		
		Return ivalue
	End

	Method ToString:String() Override
	
		Return expr.ToString()+"("+Join( args )+")"
	End
End

Class SafeInvokeExpr Extends Expr
	
	Field expr:Expr
	Field ident:String
	Field args:Expr[]

	Method New( expr:Expr,ident:String,args:Expr[],srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.expr=expr
		Self.ident=ident
		Self.args=args
	End
	
	Method OnSemant:Value( scope:Scope ) Override

		Local block:=Cast<Block>( scope )
		If Not block SemantError( "SafeInvokeExpr.OnSemant" )
		
		Local value:=Self.expr.Semant( scope ).RemoveSideEffects( block )
		
		Local vexpr:=New ValueExpr( value,srcpos,endpos )
		
		Local mexpr:=New MemberExpr( vexpr,ident,srcpos,endpos )

		Local iexpr:=New InvokeExpr( mexpr,args,srcpos,endpos )
		
		Local ifValue:=value.UpCast( Type.BoolType )
		
		Local thenValue:=iexpr.Semant( scope )
		
		Local elseValue:=New LiteralValue( thenValue.type,"" )
		
		Return New IfThenElseValue( thenValue.type,ifValue,thenValue,elseValue )
	End
	
End

Class GenericExpr Extends Expr

	Field expr:Expr
	Field args:Expr[]
	
	Method New( expr:Expr,args:Expr[],srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.expr=expr
		Self.args=args
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local value:=expr.Semant( scope )
		
		Local args:=New Type[Self.args.Length]

		For Local i:=0 Until args.Length
			args[i]=Self.args[i].SemantType( scope )
		Next
		
		'FIXME: need proper 'WhereExpr's!
		'
		Local tvalue:=Cast<TypeValue>( value )
		If tvalue Return New TypeValue( tvalue.ttype.GenInstance( args ) )
		
		Return value.GenInstance( args )
	End

	Method OnSemantType:Type( scope:Scope ) Override
	
		Local type:=Self.expr.SemantType( scope,True )
		
		Local args:=New Type[Self.args.Length]

		For Local i:=0 Until args.Length
			args[i]=Self.args[i].SemantType( scope )
		Next
		
		Return type.GenInstance( args )
	End

	Method ToString:String() Override

		Return expr.ToString()+"<"+Join( args )+">"
	End
End

Class NewObjectExpr Extends Expr

	Field type:Expr
	Field args:Expr[]
	
	Method New( type:Expr,args:Expr[],srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		
		Self.type=type
		Self.args=args
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local type:=Self.type.SemantType( scope )
		
		Local ctype:=TCast<ClassType>( type )
		If Not ctype Throw New SemantEx( "Type '"+type.Name+"' is not a class type" )
			
		If Builder.opts.makedocs Return New LiteralValue( type,"" )
		
		If ctype.IsGeneric 
			Throw New SemantEx( "Type '"+type.ToString()+"' is generic" )
		Endif
		
		'hmmm...
'		ctype.SemantMembers()
		
		If ctype.IsAbstract
			Local t:=""
			For Local func:=Eachin ctype.abstractMethods
				If t t+=","
				t+=func.ToString()
			Next
			If t Throw New SemantEx( "Class '"+ctype.Name+"' is abstract due to unimplemented method(s) "+t )
			Throw New SemantEx( "Class '"+ctype.Name+"' is abstract" )
		Endif
		
		Local args:=SemantArgs( Self.args,scope )
		Local ctorFunc:FuncValue
		
		Local ctor:=ctype.FindNode( "new" )
		If ctor

			Local ctorValue:=ctor.ToValue( Null )
			
			Local invoke:=Cast<InvokeValue>( ctorValue.Invoke( args ) )
			If Not invoke Throw New SemantEx( "Can't invoke class '"+ctype.Name+"' constuctor with arguments '"+Join( args )+"'" )
			
			ctorFunc=Cast<FuncValue>( invoke.value )
			If Not ctorFunc SemantError( "NewObjectExpr.OnSemant()" )
			
			ctorFunc.CheckAccess( scope )
			
			args=invoke.args

		Else If args
		
			Throw New SemantEx( "Class '"+type.Name+"' has no constructors" )
			
		Endif
		
		Return New NewObjectValue( ctype,ctorFunc,args )
	End

	Method ToString:String() Override
		Local str:="New "+type.ToString()
		If args str+="("+Join( args )+")"
		Return str
	End
	
End

Class NewArrayExpr Extends Expr

	Field type:ArrayTypeExpr
	Field sizes:Expr[]
	Field inits:Expr[]
	
	Method New( type:ArrayTypeExpr,sizes:Expr[],inits:Expr[],srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		
		Self.type=type
		Self.sizes=sizes
		Self.inits=inits
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local atype:=TCast<ArrayType>( type.SemantType( scope ) )
		If Not atype SemantError( "NewArrayExpr.OnSemant()" )
		
		If atype.IsGeneric Return New LiteralValue( atype,"" )

		Local sizes:=SemantArgs( Self.sizes,scope )
		sizes=UpCast( sizes,Type.IntType )

		Local inits:=SemantArgs( Self.inits,scope )
		inits=UpCast( inits,atype.elemType )
		
		Return New NewArrayValue( atype,sizes,inits )
		
		#rem
'		If atype.elemType.IsGeneric Throw New SemantEx( "Array element type '"+atype.elemType.Name+"' is generic" )
		
		Local sizes:Value[],inits:Value[]
		If Self.inits
		
			'TODO...
			If atype.rank<>1 Throw New SemantEx( "Array must be 1 dimensional" )
			
			inits=SemantArgs( Self.inits,scope )
			inits=UpCast( inits,atype.elemType )
		Else
			sizes=SemantArgs( Self.sizes,scope )
			sizes=UpCast( sizes,Type.IntType )
		Endif
		
		Return New NewArrayValue( atype,sizes,inits )
		#end
	End
		
	Method ToString:String() Override
	
		If sizes Return "New "+type.type.ToString()+"["+Join( sizes )+"]"
		
		Return "New "+type.ToString()+"("+Join( inits )+")"
	End
	
End

Class IndexExpr Extends Expr

	Field expr:Expr
	Field args:Expr[]
	
	Method New( expr:Expr,args:Expr[],srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.expr=expr
		Self.args=args
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local value:=expr.Semant( scope )
		
		Local args:=SemantRValues( Self.args,scope )
		
		Return value.Index( args )
	End

	Method ToString:String() Override
	
		Return expr.ToString()+"["+Join( args )+"]"
	End
End

Class ExtendsExpr Extends Expr

	Field op:String
	Field expr:Expr
	Field type:Expr
	
	Method New( op:String,expr:Expr,type:Expr,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.op=op
		Self.expr=expr
		Self.type=type
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local ctype:=TCast<ClassType>( Self.type.SemantType( scope ) )
		If Not ctype Or (ctype.cdecl.kind<>"class" And ctype.cdecl.kind<>"interface" And ctype.cdecl.kind<>"protocol" ) 
			Throw New SemantEx( "Type '"+type.ToString()+"' is not a class or interface type" )
		Endif
		
		Local value:=Self.expr.Semant( scope )

		Local tvalue:=Cast<TypeValue>( value )
		If tvalue
			If tvalue.ttype.DistanceToType( ctype )>=0 Return LiteralValue.BoolValue( True )
			Local ptype:=TCast<PrimType>( tvalue.ttype )
			If ptype And ptype.ctype.DistanceToType( ctype )>=0 Return LiteralValue.BoolValue( True )
			Return LiteralValue.BoolValue( False )
		Else
			value=value.ToRValue()
		Endif
		
		If value.type.DistanceToType( ctype )>=0 Return LiteralValue.BoolValue( True )
		
		If Not value.type.CanCastToType( ctype ) Return LiteralValue.BoolValue( False )
		
		Local cvalue:=New ExplicitCastValue( ctype,value )
		
		Return cvalue.UpCast( Type.BoolType )
	End
	
	Method OnSemantWhere:Bool( scope:Scope ) Override
	
		Local ctype:=TCast<ClassType>( Self.type.SemantType( scope ) )
		
		If Not ctype Or (ctype.cdecl.kind<>"class" And ctype.cdecl.kind<>"interface" And ctype.cdecl.kind<>"protocol" ) 
			Throw New SemantEx( "Type '"+type.ToString()+"' is not a class or interface type" )
		Endif
		
		Local type:=Self.expr.SemantType( scope )

		Return type.ExtendsType( ctype )
	End
	
	Method ToString:String() Override
	
		Return expr.ToString()+" "+op.Capitalize()+" "+type.ToString()
	End
End

Class CastExpr Extends Expr

	Field type:Expr
	Field expr:Expr
	
	Method New( type:Expr,expr:Expr,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.type=type
		Self.expr=expr
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local type:=Self.type.SemantType( scope )
		
		Local value:=Self.expr.Semant( scope )
		
		'Cast operator?		
		Local castOp:=value.FindValue( "cast" )
		If castOp value=castOp.Invoke( Null )

		'simple upcast - probably shouldn't?		
		If value.type.DistanceToType( type )>=0
			
			'special case variant->bool
			If value.type.Equals( Type.VariantType ) And type.Equals( Type.BoolType )
				
				Return New ExplicitCastValue( type,value.ToRValue() )
			
			Endif
			
			Return value.UpCast( type )
			
		Endif

		value=value.ToRValue()
		
		If Not value.type.CanCastToType( type ) 
			Throw New SemantEx( "Value of type '"+value.type.Name+"' cannot be cast to type '"+type.Name+"'" )
		Endif
		
		Return New ExplicitCastValue( type,value )
	End
		
	Method ToString:String() Override
	
		Return "Cast<"+type.ToString()+">("+expr.ToString()+")"
	End
	
End

Class SelfExpr Extends Expr

	Method New( srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
	End
	
	Method OnSemant:Value( scope:Scope ) Override
		
		Local block:=Cast<Block>( scope )
		If block And block.func.selfValue Return block.func.selfValue
		
		Throw New SemantEx( "'Self' can only be used in properties and methods" )
		Return Null
	End
	
	Method ToString:String() Override
	
		Return "Self"
	End
	
End

Class SuperExpr Extends Expr

	Method New( srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local block:=Cast<Block>( scope )
		If block And block.func.selfValue
		
			Local ctype:=TCast<ClassType>( block.func.selfValue.type )
			If ctype

				Local superType:=ctype.superType
				If superType Return New SuperValue( superType,block.func )

				Throw New SemantEx( "Class '"+ctype.Name+"' has no super class" )

			Endif
		Endif
		
		Throw New SemantEx( "'Super' can only be used in properties and methods" )
		Return Null
	End
	
	Method ToString:String() Override
		Return "Super"
	End
	
End

Class NullExpr Extends Expr

	Method New( srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
	End
	
	Method OnSemant:Value( scope:Scope ) Override
		Return New NullValue
	End
	
	Method ToString:String() Override
		Return "Null"
	End
	
End

Class UnaryopExpr Extends Expr

	Field op:String
	Field expr:Expr
	
	Method New( op:String,expr:Expr,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.op=op
		Self.expr=expr
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local value:=expr.SemantRValue( scope )
		
		Local type:=value.type
		
		Local node:=value.FindValue( op )
		If node Return node.Invoke( Null )
		
		Local ptype:=TCast<PrimType>( type )
		
		Select op
		Case "+","-"
			If Not ptype Or Not ptype.IsNumeric 
				Throw New SemantEx( "Type must be numeric" )
			Endif
			If ptype.IsUnsignedIntegral
				Throw New SemantEx( "Type cannot be unsigned" )
			Endif
		Case "~~"
			Local etype:=TCast<EnumType>( type )
			If etype
				type=etype
			Else If Not ptype Or Not ptype.IsIntegral
				Throw New SemantEx( "Type must be integral" )
			Endif 
		Case "not"
			type=Type.BoolType
		Default
			Throw New SemantEx( "Illegal type for unary operator '"+op+"'" )
		End
		
		Return EvalUnaryop( type,op,value.UpCast( type ) )
	End
	
	Method OnSemantWhere:Bool( scope:Scope ) Override
	
		Select op
		Case "not"
			Local expr:=Self.expr.SemantWhere( scope )
			Return Not expr
		Default
			Throw New SemantEx( "Unary operator '"+op+"' cannot be used in where expressions" )
		End
		
		Return False
	End
	
	
	Method ToString:String() Override
		Return op.Capitalize()+expr.ToString()
	End
	
End

Class BinaryopExpr Extends Expr

	Field op:String
	Field lhs:Expr
	Field rhs:Expr
	
	Method New( op:String,lhs:Expr,rhs:Expr,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.op=op
		Self.lhs=lhs
		Self.rhs=rhs
	End

	Method OnSemant:Value( scope:Scope ) Override
	
		Local lhs:=Self.lhs.Semant( scope )
		Local rhs:=Self.rhs.Semant( scope )
		
		
		If lhs.type=Type.NullType
			rhs=rhs.ToRValue()
			lhs=lhs.UpCast( rhs.type )
		Else If rhs.type=Type.NullType
			lhs=lhs.ToRValue()
			rhs=rhs.UpCast( lhs.type )
		Else
			lhs=lhs.ToRValue()
			rhs=rhs.ToRValue()
		Endif
		
		'check for overloadeded operator
		'
		Local node:=lhs.FindValue( op )
		If node 
			Return node.Invoke( New Value[]( rhs ) )
		Endif
		
		'check for overloaded <=> for comparisons
		'
		Select op
		Case "=","<>","<",">","<=",">="
			Local node:=lhs.FindValue( "<=>" )
			If node
				lhs=node.Invoke( New Value[]( rhs ) )
				rhs=New LiteralValue( lhs.type,"" )	'compare with '0'.
			Endif
		End
		
		Local argTypes:=New Type[2]
		Local type:=BalanceBinaryopTypes( op,lhs.type,rhs.type,argTypes )
		
		If Not type Throw New SemantEx( "Parameter types for binary operator '"+op+"' cannot be determined" )
		
		Return EvalBinaryop( type,op,lhs.UpCast( argTypes[0] ),rhs.UpCast( argTypes[1] ) )
	End
	
	Method OnSemantWhere:Bool( scope:Scope ) Override
	
		Select op
		Case "=","<>"
			Local lhs:=Self.lhs.SemantType( scope )
			Local rhs:=Self.rhs.SemantType( scope )
			If op="=" Return lhs.Equals( rhs )
			Return Not lhs.Equals( rhs )
		Case "and","or"
			Local lhs:=Self.lhs.SemantWhere( scope )
			Local rhs:=Self.rhs.SemantWhere( scope )
			If op="and" Return lhs And rhs
			Return lhs Or rhs
		Default
			Throw New SemantEx( "Binary operator '"+op+"' cannot be used in where expressions" )
		End
		
		Return False
	End
	
	Method ToString:String() Override

		Return "("+lhs.ToString()+op+rhs.ToString()+")"
	End
End

Class ElvisExpr Extends Expr
	
	Field expr:Expr
	Field elseExpr:Expr

	Method New( expr:Expr,elseExpr:Expr,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.expr=expr
		Self.elseExpr=elseExpr
	End
	
	Method OnSemant:Value( scope:Scope ) Override
		
		Local block:=Cast<Block>( scope )
		If Not block SemantError( "ElvisExpr.OnSemant" )
		
		Local value:=Self.expr.SemantRValue( scope ).RemoveSideEffects( block )
		
		Local ifValue:=value.UpCast( Type.BoolType )
		
		Local elseValue:=Self.elseExpr.SemantRValue( scope,value.type )
		
		Return New IfThenElseValue( value.type,ifValue,value,elseValue )
	End
	
End
	

Class IfThenElseExpr Extends Expr

	Field expr:Expr
	Field thenExpr:Expr
	Field elseExpr:Expr
	
	Method New( expr:Expr,thenExpr:Expr,elseExpr:Expr,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.expr=expr
		Self.thenExpr=thenExpr
		Self.elseExpr=elseExpr
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local value:=expr.SemantRValue( scope,Type.BoolType )
		
		Local thenValue:=thenExpr.Semant( scope )
		Local elseValue:=elseExpr.Semant( scope )

		If thenValue.type=Type.NullType
			elseValue=elseValue.ToRValue()
			thenValue=thenValue.UpCast( elseValue.type )
		Else If elseValue.type=Type.NullType
			thenValue=thenValue.ToRValue()
			elseValue=elseValue.UpCast( thenValue.type )
		Endif
		
		Local type:=BalanceTypes( thenValue.type,elseValue.type )
		thenValue=thenValue.UpCast( type )
		elseValue=elseValue.UpCast( type )
		
		Return New IfThenElseValue( type,value,thenValue,elseValue )
	End
	
	Method ToString:String() Override
		Return "("+expr.ToString()+" ? "+thenExpr.ToString()+" Else "+elseExpr.ToString()+")"
	End
End

Class VarptrExpr Extends Expr

	Field expr:Expr
	
	Method New( expr:Expr,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.expr=expr
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local value:=expr.Semant( scope )
		
		If Not value.IsLValue Throw New SemantEx( "Value '"+value.ToString()+"' is not a valid variable reference" )
		
		Return New PointerValue( value )
	End

	Method ToString:String() Override
		Return "Varptr "+expr.ToString()
	End
	
End

Class LiteralExpr Extends Expr

	Field toke:String
	Field tokeType:Int
	Field typeExpr:Expr
	
	Method New( toke:String,tokeType:Int,typeExpr:Expr,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.toke=toke
		Self.tokeType=tokeType
		Self.typeExpr=typeExpr
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local type:Type
		
		If typeExpr
		 
			type=typeExpr.SemantType( scope )

			Local ptype:=TCast<PrimType>( type )
			If Not ptype Throw New SemantEx( "Literal type must be a primitive type" )
			
			Select tokeType
			Case TOKE_INTLIT
				If Not ptype.IsIntegral Throw New SemantEx( "Literal type must be an integral type" )
			Case TOKE_FLOATLIT
				If Not ptype.IsReal Throw New SemantEx( "Literal type must be 'Float' or 'Double'" )
			Case TOKE_STRINGLIT
				If ptype<>Type.StringType Throw New SemantEx( "Literal type must be 'String'" )
			Case TOKE_KEYWORD
				If ptype<>Type.BoolType Throw New SemantEx( "Literal type must be 'Bool'" )
			End
			
		Else
		
			Select tokeType
			Case TOKE_INTLIT 
				type=Type.IntType
			Case TOKE_FLOATLIT 
				type=Type.FloatType
			Case TOKE_STRINGLIT 
				type=Type.StringType
			Case TOKE_KEYWORD
				type=Type.BoolType
			End
			
		Endif
		
		If Not type SemantError( "LiteralExpr.OnSemant()" )
		
		Local t:=toke
		
		Local ptype:=TCast<PrimType>( type )
		
		If ptype And ptype.IsIntegral And t And t[0]=CHAR_DOLLAR
		
			Local n:ULong
			For Local i:=1 Until toke.Length
				Local c:=toke[i]
				If c>=97
					c-=87
				Else If c>=65
					c-=55
				Else
					c-=48
				Endif
				n=n Shl 4 | c
			Next
			t=String( n )
			
		Else If ptype=Type.StringType
		
			t=DequoteMx2String( t )
		Endif
		
		Return New LiteralValue( type,t )
	End
	
	Method ToString:String() Override
		Return toke
	End
	
End

Class LambdaExpr Extends Expr

	Field decl:FuncDecl

	Method New( decl:FuncDecl,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.decl=decl
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		Local func:=New FuncValue( decl,scope,Null,Null )
		
		func.Semant()
		
		Return func
	End

	Method ToString:String() Override
		Return decl.ToString()
	End
End

Class ArrayTypeExpr Extends Expr

	Field type:Expr
	Field rank:Int
	
	Method New( type:Expr,rank:Int,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.type=type
		Self.rank=rank
	End
	
	Method OnSemantType:Type( scope:Scope ) Override
	
		Local type:=Self.type.SemantType( scope )
		
		Return New ArrayType( type,rank )
	End

	Method ToString:String() Override
		Return type.ToString()+"[,,,,,,,,,,,".Slice( 0,rank )+"]"
	End
	
End

Class FuncTypeExpr Extends Expr

	Field retType:Expr
	Field params:VarDecl[]

	Method New( retType:Expr,params:VarDecl[],srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		Self.retType=retType
		Self.params=params
	End

	Method OnSemantType:Type( scope:Scope ) Override

		Local retType:=Self.retType.SemantType( scope )
		
		Local argTypes:=New Type[params.Length]
		For Local i:=0 Until argTypes.Length
			argTypes[i]=params[i].type.SemantType( scope )
		Next
		
		Return New FuncType( retType,argTypes )
	End
	
	Method ToString:String() Override
		Return retType.ToString()+"("+Join( params )+")"
	End

End

Class PointerTypeExpr Extends Expr

	Field type:Expr
	
	Method New( type:Expr,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		
		Self.type=type
	End
	
	Method OnSemantType:Type( scope:Scope ) Override
	
		Local type:=Self.type.SemantType( scope )
		
		Return New PointerType( type )
	End

	Method ToString:String() Override
		Return type.ToString()+" Ptr"
	End
End

Class TypeofExpr Extends Expr

	Field expr:Expr
	Field istype:Bool
	
	Method New( expr:Expr,istype:Bool,srcpos:Int,endpos:Int )
		Super.New( srcpos,endpos )
		
		Self.expr=expr
		Self.istype=istype
	End
	
	Method OnSemant:Value( scope:Scope ) Override
	
		If istype Return New TypeofTypeValue( expr.SemantType( scope ) )
		
		Local rvalue:=expr.SemantRValue( scope )
		If rvalue.type=Type.VoidType Throw New SemantEx( "Invalid Typeof expression" )
		
		Return New TypeofValue( rvalue )
	End
	
End
