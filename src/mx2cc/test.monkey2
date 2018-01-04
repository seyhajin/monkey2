
Namespace test

#Reflect test

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
	
	'search extensions...
	
	Return Null
End

Function PrintAllTypes()
	
	For Local type:=Eachin TypeInfo.GetTypes()
		
		Print type
		
		For Local decl:=Eachin type.GetDecls()
			
			Print " "+decl
		Next
		
	Next
	
End

Class C
End

Class C Extension
	
	Method Update()
		
		Print "It worked!"
	End
	
End

Function Main()
	
	Print "All types:"
	
	PrintAllTypes()
	
	Local c:=New C
	
	For Local type:=Eachin TypeInfo.GetTypes()
		
		'look for extension
		If type.Kind="Class Extension" And type.SuperType=Typeof(c)
			
			Print "Found extension!"
			
			Local decl:=type.GetDecl( "Update" )
			
			decl.Invoke( c,Null )
		Endif
	
	Next
	
	Print "Bye!"
End
		
