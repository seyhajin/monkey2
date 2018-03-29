
Namespace mojo3d

#rem monkeydoc The Model class.
#end
Class Model Extends Renderable
	
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
		
		Name="Model"
		
		AddInstance()
		
		Visible=True
	End
	
	Method New( mesh:Mesh,material:Material,parent:Entity=Null )
		
		Super.New( parent )
		
		Name="Model"
		
		AddInstance( New Variant[]( mesh,material,parent ) )
		
		Mesh=mesh
		Materials=New Material[]( material )
		Material=material
		
		Visible=True
	End
	
	#rem monkeydoc Copies the model.
	#end	
	Method Copy:Model( parent:Entity=Null ) Override
		
		Local copy:=OnCopy( parent )
		
		CopyTo( copy )
		
		copy._bones=_bones.Slice( 0 )
		
		For Local i:=0 Until _bones.Length
			
			copy._bones[i].entity=_bones[i].entity.LastCopy
		Next
		
		Return copy
	End

	#rem monkeydoc The mesh rendered by the model.
	#end
	[jsonify=1]
	Property Mesh:Mesh()
		
		Return _mesh
	
	Setter( mesh:Mesh )
		
		_mesh=mesh
	End
	
	#rem monkeydoc The materials to use for rendering.
	#end
	Property Materials:Material[]()
		
		Return _materials
		
	Setter( materials:Material[] )
		
		_materials=materials
	End
	
	#rem monkeydoc The default material to use for rendering.
	#end
	[jsonify=1]
	Property Material:Material()
		
		Return _material
	
	Setter( material:Material )
		
		_material=material
	End

	#rem monkeydoc @hidden
	#end
	Property Bones:Bone[]()
		
		Return _bones
	
	Setter( bones:Bone[] )
		
		_bones=bones
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
			
			If Not model Continue
			
			If model.Scene.Editing model.Scene.Jsonifier.AddInstance( model,"mojo3d.Model.Load",New Variant[]( path )  )
				
			Return model
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
	
	Protected

	Method New( model:Model,parent:Entity )
		
		Super.New( model,parent )
		
		Mesh=model.Mesh
		
		Materials=model.Materials
		
		Material=model.Material
		
		AddInstance( model )
	End
	
	Method OnCopy:Model( parent:Entity ) Override
		
		Return New Model( Self,parent )
	End
	
	Internal

	Method OnRender( rq:RenderQueue ) Override
		
		If Not _mesh Return
		
		If _bones
			
			If _boneMatrices.Length<>_bones.Length _boneMatrices=New Mat4f[ _bones.Length ]
			
			For Local i:=0 Until _bones.Length
				Local bone:=_bones[i]
				_boneMatrices[i]=New Mat4f( bone.entity.Matrix * bone.offset )
			Next
		End
		
		Local vbuffer:=_mesh.GetVertexBuffer()
		
		For Local i:=0 Until _mesh.NumMaterials

			Local ibuffer:=_mesh.GetIndexBuffer( i )

			Local material:=i<_materials.Length And _materials[i] ? _materials[i] Else _material
			
			If _bones
				rq.AddRenderOp( material,_boneMatrices,vbuffer,ibuffer,3,ibuffer.Length/3,0 )
			Else
				rq.AddRenderOp( material,Self,vbuffer,ibuffer,3,ibuffer.Length/3,0 )
			Endif
			
		Next
	End
	
	Private
	
	Field _mesh:Mesh
	Field _material:Material
	Field _materials:Material[]

	Field _bones:Bone[]
	Field _boneMatrices:Mat4f[]
	
End
