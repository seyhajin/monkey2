
Namespace mojo3d.graphics

#rem monkeydoc The Model class.
#end
Class Model Extends Entity
	
	#rem monkeydoc @hidden
	#end
	Struct Bone
		Field entity:Entity
		Field offset:AffineMat4f
	End
	
	#rem monkeydoc Creates a new model.
	#end
	Method New( parent:Entity=Null )
		Super.New( parent )
		
		Show()
	End
	
	Method New( mesh:Mesh,material:Material,parent:Entity=Null )
		Self.New( parent )
		
		_mesh=mesh
		
		_material=material
	End
	
	#rem monkeydoc Copies the model.
	#end	
	Method Copy:Model( parent:Entity=Null ) Override
		
		Local copy:=New Model( Self,parent )
		
		CopyComplete( copy )
		
		Return copy
	End

	#rem monkeydoc The mesh rendered by the model.
	#end	
	Property Mesh:Mesh()
		
		Return _mesh
	
	Setter( mesh:Mesh )
		
		_mesh=mesh
	End
	
	#rem monkeydoc The default material to use for rendering.
	#end
	Property Material:Material()
		
		Return _material
	
	Setter( material:Material )
		
		_material=material
	End

	#rem monkeydoc The materials to use for rendering.
	#end	
	Property Materials:Material[]()
		
		Return _materials
		
	Setter( materials:Material[] )
		
		_materials=materials
	End
	
	#rem monkeydoc @hidden
	#end
	Property Bones:Bone[]()
		
		Return _bones
	
	Setter( bones:Bone[] )
		
		_bones=bones
	End
	
	Property CastsShadow:Bool()
		
		Return _castsShadow
		
	Setter( castsShadow:Bool )
	
		_castsShadow=castsShadow
	End
	
	#rem monkeydoc Loads a model from a file path.
	
	On its own, mojo3d can only load gltf2 format mesh and model files.
	
	To add more formats, #import the mojo3d-assimp module into your app, eg:
	
	```
	#Import "<mojo3d>"
	#Import "<mojo3d-assimp>"
	```
	
	This will allow you to load any format supported by the assimp module.
	
	However, importing the assimp module into your app will also increase its size.
	
	#end
	Function Load:Model( path:String )
	
		For Local loader:=Eachin Mojo3dLoader.Instances
		
			Local model:=loader.LoadModel( path )
			
			If model Return model
		Next
		
		Return Null
	
	End

	#rem monkeydoc Loads a boned model from a file path.
	
	On its own, mojo3d can only load gltf2 format mesh and model files.
	
	To add more formats, #import the mojo3d-assimp module into your app, eg:
	
	```
	#Import "<mojo3d>"
	#Import "<mojo3d-assimp>"
	```
	
	This will allow you to load any format supported by the assimp module.
	
	However, importing the assimp module into your app will also increase its size.
	
	#end
	Function LoadBoned:Model( path:String )
	
		For Local loader:=Eachin Mojo3dLoader.Instances
		
			Local model:=loader.LoadBonedModel( path )
			
			If model Return model
		Next
		
		Return Null
	End

	#rem monkeydoc @hidden
	#end	
	Method OnRender( rq:RenderQueue )
		
		If Not _mesh Return
		
		Local instance:=Self
		
		If _bones

			instance=Null
		
			If _boneMatrices.Length<>_bones.Length _boneMatrices=New Mat4f[ _bones.Length ]
			
			For Local i:=0 Until _bones.Length
				Local bone:=_bones[i]
				_boneMatrices[i]=New Mat4f( bone.entity.Matrix * bone.offset )
			Next
		End
		
		Local vbuffer:=_mesh.GetVertexBuffer()
		
		Local ibuffers:=_mesh.GetIndexBuffers()
		
		For Local i:=0 Until ibuffers.Length
			
			Local material:=i<_materials.Length And _materials[i] ? _materials[i] Else _material
			
			Local ibuffer:=ibuffers[i]
			
			rq.AddRenderOp( material,vbuffer,ibuffer,instance,_boneMatrices,3,ibuffer.Length/3,0 )
			
		Next
	End
	
	Protected

	#rem monkeydoc @hidden
	#end
	Method New( model:Model,parent:Entity )
		Super.New( model,parent )
		
		_mesh=model._mesh
		
		_material=model._material
		
		_materials=model._materials.Slice( 0 )
		
		_castsShadow=model._castsShadow
		
		Show()
	End

	#rem monkeydoc @hidden
	#end	
	Method OnShow() Override
		
		Scene.Models.Add( Self )
	End
	
	#rem monkeydoc @hidden
	#end	
	Method OnHide() Override
		
		Scene.Models.Remove( Self )
	End
	
	Private
	
	Field _mesh:Mesh
	Field _material:Material
	Field _materials:Material[]

	Field _bones:Bone[]
	Field _boneMatrices:Mat4f[]
	
	Field _castsShadow:Bool=true
	
End
