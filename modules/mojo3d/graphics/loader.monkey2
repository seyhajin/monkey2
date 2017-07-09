
Namespace mojo3d.graphics

#rem monkeydoc @hidden
#end
Class Mojo3dLoader

	Const Instances:=New Stack<Mojo3dLoader>
	
	Method New()
		Instances.Push( Self )
	End
	
	Method LoadMesh:Mesh( path:String ) Virtual
		Return Null
	End
	
	Method LoadModel:Model( path:String ) Virtual
		Return Null
	End

End
