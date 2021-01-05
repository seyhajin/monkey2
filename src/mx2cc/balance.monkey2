
Namespace mx2

Function BalanceIntegralTypes:Type( lhs:PrimType,rhs:PrimType )

	If Not lhs Or Not rhs Or Not lhs.IsIntegral Or Not rhs.IsIntegral
		Throw New SemantEx( "Types must be integral" )
	Endif

	If lhs=Type.ULongType Or rhs=Type.ULongType Return Type.ULongType
	
	If lhs=Type.LongType Or rhs=Type.LongType Return Type.LongType
	
	If lhs.IsUnsignedIntegral Or rhs.IsUnsignedIntegral Return Type.UIntType
	
	Return Type.IntType
End

Function BalanceNumericTypes:Type( lhs:PrimType,rhs:PrimType )

	If Not lhs Or Not rhs Or Not lhs.IsNumeric Or Not rhs.IsNumeric
		Throw New SemantEx( "Types must be numeric" )
	Endif

	If lhs=Type.DoubleType Or rhs=Type.DoubleType Return Type.DoubleType

	If lhs=Type.FloatType Or rhs=Type.FloatType Return Type.FloatType
	
	Return BalanceIntegralTypes( lhs,rhs )
End

Function BalancePrimTypes:Type( lhs:PrimType,rhs:PrimType )

	If Not lhs And Not rhs
		Throw New SemantEx( "Types must be primitive" )
	Endif
	
	If Not lhs lhs=rhs Else If Not rhs rhs=lhs

	'variant->bool has priority over bool->variant
	'
	If lhs=Type.BoolType And rhs=Type.VariantType Return Type.BoolType
	
	If rhs=Type.BoolType And lhs=Type.VariantType Return Type.BoolType

	'whatever->variant
	'
	If lhs=Type.VariantType Or rhs=Type.VariantType Return Type.VariantType

	'whatever->string
	'	
	If lhs=Type.StringType Or rhs=Type.StringType Return Type.StringType
	
	'whatever->bool
	'
	If lhs=Type.BoolType Or rhs=Type.BoolType Return Type.BoolType

	Return BalanceNumericTypes( lhs,rhs )
End

Function BalanceTypes:Type( lhs:Type,rhs:Type )

	Local plhs:=TCast<PrimType>( lhs )
	Local prhs:=TCast<PrimType>( rhs )
	
	If plhs And prhs Return BalancePrimTypes( plhs,prhs )
	
	If lhs.DistanceToType( rhs )>=0 Return rhs		'And rhs.DistanceToType( lhs )<=0 Return rhs
	If rhs.DistanceToType( lhs )>=0 Return lhs		'And lhs.DistanceToType( rhs )<=0 Return lhs
	
	Throw New SemantEx( "Types '"+lhs.Name+"' and '"+rhs.Name+"' are incompatible" )
	
	Return Null
End

'returns result type and lhs/rhs cast types in argTtypes
'
Function BalanceBinaryopTypes:Type( op:String,lhs:Type,rhs:Type,argTypes:Type[] )

	Local plhs:=TCast<PrimType>( lhs )
	Local prhs:=TCast<PrimType>( rhs )
	
	Local type:Type,ltype:Type,rtype:Type
	
	Select op
	Case "+"
		If TCast<PointerType>( lhs )
			type=lhs
			rtype=BalanceIntegralTypes( prhs,prhs )
		Else If TCast<PointerType>( rhs )
			type=rhs
			ltype=BalanceIntegralTypes( plhs,plhs )
		Else If (plhs and plhs=Type.StringType) Or (prhs and prhs=Type.StringType)
			type=BalancePrimTypes( plhs,prhs )
		Else
			type=BalanceNumericTypes( plhs,prhs )
		Endif
		
	Case "-"
	
		If TCast<PointerType>( lhs )
			If TCast<PointerType>( rhs )
				If Not lhs.Equals( rhs ) Throw New SemantEx( "Pointers are of different type" )
				type=Type.IntType
				ltype=lhs
				rtype=rhs
			Else
				type=lhs
				ltype=type
				rtype=BalanceIntegralTypes( prhs,prhs )
			Endif
		Else
			type=BalanceNumericTypes( plhs,prhs )
		Endif
		
	Case "*","/","mod","+","-"
	
		type=BalanceNumericTypes( plhs,prhs )
		
	Case "&","|","~~"
	
		If TCast<EnumType>( lhs ) Or TCast<EnumType>( rhs )
			If lhs.Equals( rhs ) type=lhs
		Else
			type=BalanceIntegralTypes( plhs,prhs )
		Endif
		
	Case "shl","shr"
	
		If plhs And plhs.IsIntegral
			type=BalanceIntegralTypes( plhs,plhs )
			rtype=Type.IntType
		Endif
	
	Case "=","<>","<",">","<=",">="
	
		type=Type.BoolType
		ltype=BalanceTypes( lhs,rhs )
		rtype=ltype
		
	Case "<=>"
		
		type=Type.IntType
		ltype=BalanceTypes( lhs,rhs )
		rtype=ltype
		
	Case "and","or"

		type=Type.BoolType
	End
	
	If Not type Throw New SemantEx( "Invalid operand types for binary operator '"+op+"'" )
	
	argTypes[0]=ltype ? ltype Else type
	argTypes[1]=rtype ? rtype Else type
	
	Return type
	
End

'returns type to cast rhs to...
'
Function BalanceAssignTypes:Type( op:String,lhs:Type,rhs:Type )

	If op="=" Return lhs
	
	Local plhs:=TCast<PrimType>( lhs )
	
	Select op
	Case "+="
	
		If plhs
		
			If plhs=Type.StringType Or plhs.IsNumeric Return lhs
			
		Else If TCast<PointerType>( lhs )

			Local prhs:=TCast<PrimType>( rhs )
			If prhs
				If prhs=Type.LongType Or prhs=Type.ULongType Return rhs
				If prhs.IsIntegral Return Type.IntType
			Endif
			
		Else If TCast<FuncType>( lhs )
		
			Return lhs
			
		Endif
		
	Case "-="

		If plhs
		
			If plhs.IsNumeric Return lhs
			
		Else If TCast<PointerType>( lhs )
		
			Local prhs:=TCast<PrimType>( rhs )
			If prhs
				If prhs=Type.LongType Or prhs=Type.ULongType Return rhs
				If prhs And prhs.IsIntegral Return Type.IntType
			Endif
			
		Else If TCast<FuncType>( lhs )
		
			Return lhs
			
		Endif
		
	Case "*=","/=","mod="
	
		If plhs And plhs.IsNumeric Return lhs
	
	Case "&=","|=","~="
	
		If plhs And plhs.IsIntegral Return lhs
		
		If TCast<EnumType>( lhs ) And lhs.Equals( rhs ) Return lhs
		
	Case "shl=","shr="
	
		If plhs And plhs.IsIntegral Return Type.IntType
		
	Case "and=","or="
	
		If plhs And plhs=Type.BoolType Return Type.BoolType
		
	End
	
	Throw New SemantEx( "Invalid type for assignment" )
	
End
