
Namespace test

'#Import "<std>"

'#Reflect std.graphics
'#Reflect test

Class C
	
End

Enum E
	A=1,B=2,C=3
End

Function InvokeMethod:Variant( name:String,instance:Object,args:Variant[]=Null )
	
	If Not instance Return Null
	
	Local type:=instance.DynamicType
	
	While type
	
		For Local decl:=Eachin type.GetDecls()
			
			If decl.Kind<>"Method" Continue
			
			Local ptypes:=decl.Type.ParamTypes
			If ptypes.Length<>args.Length Continue
			
			Local fail:=False
			For Local j:=0 Until args.Length
				If args[j].Type.ExtendsType( ptypes[j] ) Continue
				fail=True
				Exit
			Next
			If fail Continue
			
			Return decl.Invoke( instance,args)
		Next
		
		type=type.SuperType
		
	Wend
	
	Return Null
End

Function EnumTypes()
	
	For Local type:=Eachin TypeInfo.GetTypes()
		
		Print type
		
		For Local decl:=Eachin type.GetDecls()
			
			Print " "+decl
		Next
		
	Next
	
End

Function Main()

	EnumTypes()
	
End
