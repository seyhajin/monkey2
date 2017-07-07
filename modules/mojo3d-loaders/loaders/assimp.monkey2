
Namespace mojo3d.loaders

Struct aiVector3D extension
	
	Operator To:Vec3f()
		Return New Vec3f( x,y,z )
	End

End

Struct aiQuaternion Extension
	
	Operator To:Quatf()
		Return New Quatf( x,y,z,-w )
	End

End

Struct aiMatrix4x4 Extension
	
	Operator To:Mat4f()
		Return New Mat4f(
			New Vec4f( a1,b1,c1,d1 ),
			New Vec4f( a2,b2,c2,d2 ),
			New Vec4f( a3,b3,c3,d3 ),
			New Vec4f( a4,b4,c4,d4 ) )
	End
	
	Operator To:AffineMat4f()
		If d1<>0 Or d2<>0 Or d3<>0 Or d4<>1 Print "WARNING! Assimp node matrix is not affine!"
		Return New AffineMat4f(
			New Vec3f( a1,b1,c1 ),
			New Vec3f( a2,b2,c2 ),
			New Vec3f( a3,b3,c3 ),
			New Vec3f( a4,b4,c4 ) )
	End
	
End

Class AssimpLoader
	
	Method New( scene:aiScene,dir:String )
		_scene=scene
		_dir=dir
	End
	
	Method LoadMesh:Mesh()
		
		Local model:=New Model
		
		For Local i:=0 Until _scene.mNumMeshes
			
			AddMesh( _scene.mMeshes[i],model )
		Next
		
		model.Mesh.UpdateTangents()
		
		Return model.Mesh
	End
	
	Method LoadModel:Model()
		
		Local model:=LoadNode( _scene.mRootNode,Null )
		
		model.Animator=LoadAnimator()
		
		Return model
	End
	
	Private
	
	Field _scene:aiScene
	Field _dir:String
	
	Field _materials:=New Stack<Material>
	Field _nodes:=New StringMap<Entity>
	Field _entityIds:=New StringMap<Int>
	Field _entities:=New Stack<Entity>
	
	Method LoadMaterial:Material( aimaterial:aiMaterial,boned:Bool=False )
		
		Local material:=New PbrMaterial( boned )
		
		Local aipath:aiString,path:String
		Local aicolor:aiColor4D,color:Color
			
		aiGetMaterialTexture( aimaterial,aiTextureType_DIFFUSE,0,Varptr aipath )
		path=aipath.data
		If path
			path=_dir+StripDir( path )
			Local texture:=Texture.Load( path,TextureFlags.FilterMipmap )
			If texture material.ColorTexture=texture
		Endif
			
		aiGetMaterialColor( aimaterial,AI_MATKEY_COLOR_DIFFUSE,0,0,Varptr aicolor )
		material.ColorFactor=New Color( aicolor.r,aicolor.g,aicolor.b,aicolor.a )
		
		Return material
	End
	
	Method AddMesh( aimesh:aiMesh,model:Model )

		Local vertices:=New Vertex3f[ aimesh.mNumVertices ]
		
		Local vp:=aimesh.mVertices
		Local np:=aimesh.mNormals
		Local tp:=aimesh.mTextureCoords[0]
		
		For Local i:=0 Until vertices.Length
			vertices[i].position=New Vec3f( vp[i].x,vp[i].y,vp[i].z )
			vertices[i].normal=New Vec3f( np[i].x,np[i].y,np[i].z )
			If tp vertices[i].texCoord0=New Vec2f( tp[i].x,tp[i].y )
		Next
		
		If aimesh.mNumBones

			Local n:=aimesh.mNumBones
			
			Local bones:=model.Bones,i0:=bones.Length
		
			bones=bones.Resize( i0+n )
			
			Print "numBones="+n
			
			For Local i:=0 Until n
		
				Local aibone:=aimesh.mBones[i]
				
				bones[i0+i].entity=_entities[ _entityIds[ aibone.mName.data ] ]
				
				bones[i0+i].offset=Cast<AffineMat4f>( aibone.mOffsetMatrix )
				
				For Local j:=0 Until aibone.mNumWeights
					
					Local aiweight:=aibone.mWeights[j]
					
					Local wp:=Cast<Float Ptr>( Varptr vertices[aiweight.mVertexId].weights )
					Local bp:=Cast<UByte Ptr>( Varptr vertices[aiweight.mVertexId].bones )
					
					Local k:=0
					For k=0 Until 4
						If wp[k] Continue
						wp[k]=aiweight.mWeight
						bp[k]=i0+i
						Exit
					Next
					If k=4 print "Too many vertex weights"
						
				Next
			Next
		
			model.Bones=bones
		
		Endif

		Local indices:=New UInt[ aimesh.mNumFaces*3 ]
		
		Local fp:=aimesh.mFaces,v0:=model.Mesh.NumVertices
		
		For Local i:=0 Until aimesh.mNumFaces
			indices[i*3+0]=fp[i].mIndices[0]+v0
			indices[i*3+1]=fp[i].mIndices[1]+v0
			indices[i*3+2]=fp[i].mIndices[2]+v0
		Next
		
		model.Mesh.AddVertices( vertices )
		
		model.Mesh.AddTriangles( indices )

	End
	
	Method LoadNode:Model( node:aiNode,parent:Model )
		
		Local model:=New Model( parent )
		
		model.Name=node.mName.data
		
		Local matrix:=Cast<AffineMat4f>( node.mTransformation )

		Local scl:=matrix.m.GetScaling()
		Local rot:=matrix.m.Scale( 1/scl.x,1/scl.y,1/scl.z )
		Local pos:=matrix.t

		model.Position=pos
		model.Basis=rot
		model.Scale=scl
		
		_nodes[ node.mName.data ]=model
		_entityIds[ node.mName.data ]=_entities.Length
		_entities.Push( model )
		
		For Local i:=0 Until node.mNumChildren
			
			LoadNode( node.mChildren[i],model )
		Next

		If node.mNumMeshes
		
			model.Mesh=New Mesh
			
			Local materials:=New Stack<Material>
		
			For Local i:=0 Until node.mNumMeshes
				
				Local aimesh:=_scene.mMeshes[ node.mMeshes[i] ]
					
				AddMesh( aimesh,model )
				
				materials.Push( LoadMaterial( _scene.mMaterials[aimesh.mMaterialIndex],aimesh.mNumBones>0 ) )
			Next
						
			model.Mesh.UpdateTangents()
			
			model.Materials=materials.ToArray()
			
		Endif
		
		Return model
	End
	
	Method LoadAnimationChannel:AnimationChannel( aichan:aiNodeAnim )
		
		Local posKeys:=New PositionKey[ aichan.mNumPositionKeys ]
		
		For Local i:=0 Until posKeys.Length
			
			Local aikey:=aichan.mPositionKeys[i]
			
			posKeys[i]=New PositionKey( aikey.mTime,aikey.mValue )
		Next
		
		Local rotKeys:=New RotationKey[ aichan.mNumRotationKeys ]
		
		For Local i:=0 Until rotKeys.Length
			
			Local aikey:=aichan.mRotationKeys[i]
			
			rotKeys[i]=New RotationKey( aikey.mTime,aikey.mValue )
		Next
		
		Local sclKeys:=New ScaleKey[ aichan.mNumScalingKeys ]
		
		For Local i:=0 Until sclKeys.Length
			
			Local aikey:=aichan.mScalingKeys[i]
			
			sclKeys[i]=New ScaleKey( aikey.mTime,aikey.mValue )
		Next
		
		Return New AnimationChannel( posKeys,rotKeys,sclKeys )
		
	End
	
	Method LoadAnimation:Animation( aianim:aiAnimation )
		
		Local channels:=New AnimationChannel[ _entities.Length ]
		
		For Local i:=0 Until aianim.mNumChannels
			
			Local aichan:=aianim.mChannels[i]
			
			Local id:=_entityIds[ aichan.mNodeName.data ]
			
			Print "i="+i+", id="+id
			
			channels[id]=LoadAnimationChannel( aichan )
		
		Next
		
		Return New Animation( channels,aianim.mDuration,aianim.mTicksPerSecond )
		
	End
	
	Method LoadAnimator:Animator()
		
		If Not _scene.mNumAnimations Return Null
		
		Local animations:=New Animation[_scene.mNumAnimations]
		
		For Local i:=0 Until _scene.mNumAnimations
			
			animations[i]=LoadAnimation( _scene.mAnimations[i] )

		Next
		
		Return New Animator( animations,_entities.ToArray() )

	End

End

Public

#rem monkeydoc @hidden
#End
Class AssimpMojo3dLoader Extends Mojo3dLoader

	Const Instance:=New AssimpMojo3dLoader
	
	Method LoadMesh:Mesh( path:String ) Override

		Local flags:UInt=0
		
		flags|=aiProcess_MakeLeftHanded | aiProcess_FlipWindingOrder | aiProcess_FlipUVs
		flags|=aiProcess_JoinIdenticalVertices | aiProcess_SortByPType
		flags|=aiProcess_Triangulate | aiProcess_GenSmoothNormals 
		flags|=aiProcess_PreTransformVertices
		
		Local scene:=LoadScene( path,flags )
		If Not scene Return Null
		
		Local loader:=New AssimpLoader( scene,ExtractDir( path ) )
		Local mesh:=loader.LoadMesh()
		
		Return mesh
	End
	
	Method LoadModel:Model( path:String ) Override
	
		Local flags:UInt=0
		
		flags|=aiProcess_MakeLeftHanded | aiProcess_FlipWindingOrder | aiProcess_FlipUVs
		flags|=aiProcess_JoinIdenticalVertices | aiProcess_SortByPType
		flags|=aiProcess_Triangulate | aiProcess_GenSmoothNormals 
		
		Local scene:=LoadScene( path,flags )
		If Not scene Return Null
		
		Local loader:=New AssimpLoader( scene,ExtractDir( path ) )
		Local model:=loader.LoadModel()
		
		Return model
	End
	
	Private

	Function LoadScene:aiScene( path:String,flags:UInt )
		
		Local data:=DataBuffer.Load( path )

		Local scene:=aiImportFileFromMemory( Cast<libc.char_t Ptr>( data.Data ),data.Length,flags,ExtractExt( path ).Slice( 1 ) )
		
		data.Discard()
		
		Return scene
	End
	
End
