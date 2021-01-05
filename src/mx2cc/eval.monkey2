
Namespace mx2

Function EvalUnaryopError()
	
	SemantError( "EvalUnaryop()" )
End

Function EvalUnaryop:LiteralValue( type:Type,op:String,arg:LiteralValue )
	
	Local ptype:=TCast<PrimType>( type )
	
	If ptype

		If ptype=Type.BoolType
			
			Local r:=(arg.value="true")
			
			Select op
			Case "not" r=Not r
			Default EvalUnaryopError()
			End

			Return New LiteralValue( ptype,r ? "true" Else "false" )
			
		Else If ptype.IsSignedIntegral
			
			Local r:Long,r0:=Cast<Long>( arg.value )
			Select op
			Case "+" r=r0
			Case "-" r=-r0
			Case "~~" r=~r0
			Default EvalUnaryopError()
			End

			Return New LiteralValue( ptype,r )
			
		Else If ptype.IsUnsignedIntegral
	
			Local r:ULong,r0:=Cast<ULong>( arg.value )
			Select op
			Case "+" r=r0
			Case "~~" r=~r0
			Default EvalUnaryopError()
			End
	
			Return New LiteralValue( ptype,r )
	
		Else If ptype.IsReal
			
			Local r:Double,r0:=Cast<Double>( arg.value )
			
			Select op
			Case "+" r=r0
			Case "-" r=-r0
			Default EvalUnaryopError()
			End

			Return New LiteralValue( ptype,r )
		
		Endif
	
	Else

		Local etype:=TCast<EnumType>( type )
		If etype
			
			If etype.edecl.IsExtern Return Null
			
			Local r:=Cast<Int>( arg.value )
			
			Select op
			Case "~~" r=~r
			Default EvalUnaryopError()
			End
			
			Return New LiteralValue( type,r )
			
		Endif
	
	Endif
	
	EvalUnaryopError()

	Return Null
End

Function EvalUnaryop:Value( type:Type,op:String,arg:Value )

	Local t:=Cast<LiteralValue>( arg )
	If t
		Local value:=EvalUnaryop( type,op,t )
		If value Return value
	Endif
	
	Return New UnaryopValue( type,op,arg )
End

Function EvalBinaryopError()
	
	SemantError( "EvalBinaryop()" )
End

Function EvalBinaryop:LiteralValue( type:Type,op:String,lhs:LiteralValue,rhs:LiteralValue )
	
	Local ptype:=TCast<PrimType>( type )
	If ptype
	
		If ptype=Type.BoolType
			
			Local ptype:=TCast<PrimType>( lhs.type )
			If Not ptype Return Null
				
			Local r:Bool
			
			If ptype=Type.BoolType
				
				Local x:=(lhs.value="true"),y:=(rhs.value="true" )
				
				Select op
				Case "and" r=x And y
				Case "or" r=x Or y
				Default EvalBinaryopError()
				End
			
			Else If ptype.IsSignedIntegral
	
				Local x:=Cast<Long>( lhs.value ),y:=Cast<Long>( rhs.value )
				
				Select op
				Case ">=" r=(x>=y)
				Case "<=" r=(x<=y)
				Case "<>" r=(x<>y)
				Case ">" r=(x>y)
				Case "<" r=(x<y)
				Case "=" r=(x=y)
				Default EvalBinaryopError()
				End
			
			Else If ptype.IsUnsignedIntegral
				
				Local x:=Cast<ULong>( lhs.value ),y:=Cast<ULong>( rhs.value )
				
				Select op
				Case ">=" r=(x>=y)
				Case "<=" r=(x<=y)
				Case "<>" r=(x<>y)
				Case ">" r=(x>y)
				Case "<" r=(x<y)
				Case "=" r=(x=y)
				Default EvalBinaryopError()
				End
			
			Else If ptype.IsReal
	
				Local x:=Cast<Double>( lhs.value ),y:=Cast<Double>( rhs.value )
				
				Select op
				Case ">=" r=(x>=y)
				Case "<=" r=(x<=y)
				Case "<>" r=(x<>y)
				Case ">" r=(x>y)
				Case "<" r=(x<y)
				Case "=" r=(x=y)
				Default EvalBinaryopError()
				End
				
			Else If ptype=Type.StringType
				
				Local x:=lhs.value,y:=rhs.value
				
				Select op
				Case ">=" r=(x>=y)
				Case "<=" r=(x<=y)
				Case "<>" r=(x<>y)
				Case ">" r=(x>y)
				Case "<" r=(x<y)
				Case "=" r=(x=y)
				Default EvalBinaryopError()
				End
				
			Else

				EvalBinaryopError()
			
			Endif
			
			Return New LiteralValue( Type.BoolType,r ? "true" Else "false" )
		
		Else If ptype.IsSignedIntegral
			
			Local r:Long,x:=Cast<Long>( lhs.value ),y:=Cast<Long>( rhs.value )
			
			Select op
			Case "*" r=x * y
			Case "/" r=x / y
			Case "mod" r=x Mod y
			Case "+" r=x + y
			Case "-" r=x - y
			Case "&" r=x & y
			Case "|" r=x | y
			Case "~~" r=x ~ y
			Case "shl" r=x Shl Cast<Int>( rhs.value )
			Case "shr" r=x Shr Cast<Int>( rhs.value )
			Default EvalBinaryopError()
			End
			
			Return New LiteralValue( ptype,r )
		
		Else If ptype.IsUnsignedIntegral

			Local r:ULong,x:=Cast<ULong>( lhs.value ),y:=Cast<ULong>( rhs.value )
			
			Select op
			Case "*" r=x * y
			Case "/" r=x / y
			Case "mod" r=x Mod y
			Case "+" r=x + y
			Case "-" r=x - y
			Case "&" r=x & y
			Case "|" r=x | y
			Case "~~" r=x ~ y
			Case "shl" r=x Shl Cast<Int>( rhs.value )
			Case "shr" r=x Shr Cast<Int>( rhs.value )
			Default EvalBinaryopError()
			End
			
			Return New LiteralValue( ptype,r )
		
		Else If ptype.IsReal

			Local r:Double,x:=Cast<Double>( lhs.value ),y:=Cast<Double>( rhs.value )
			
			Select op
			Case "*" r=x * y
			Case "/" r=x / y
			Case "mod" r=x Mod y
			Case "+" r=x + y
			Case "-" r=x - y
			Default EvalBinaryopError()
			End
			
			Return New LiteralValue( ptype,r )
			
		Else If ptype=Type.StringType
			
			Local r:String,x:=lhs.value,y:=rhs.value
			
			Select op
			Case "+" r=x+y
			Default EvalBinaryopError()
			End
			
			Return New LiteralValue( ptype,r )
		
		Endif

		EvalBinaryopError()
	
	Else
	
		Local etype:=TCast<EnumType>( type )
		If etype
			
			If etype.edecl.IsExtern Return Null
			
			Local r:Int,x:=Int( lhs.value ),y:=Int( rhs.value )
			
			Select op
			Case "&" r=x & y
			Case "|" r=x | y
			Case "~~" r=x ~ y
			Default EvalBinaryopError()
			End
			
			Return New LiteralValue( type,String( r ) )
		Endif
	
	Endif
	
	EvalBinaryopError()
	
	Return Null
End

Function EvalBinaryop:Value( type:Type,op:String,lhs:Value,rhs:Value )

	Local x:=Cast<LiteralValue>( lhs )
	If x
		Local y:=Cast<LiteralValue>( rhs )
		If y
			Local value:=EvalBinaryop( type,op,x,y )
			If value Return value
		Endif
	Endif
	
	Return New BinaryopValue( type,op,lhs,rhs )
End
