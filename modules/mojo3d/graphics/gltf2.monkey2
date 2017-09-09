
Namespace mojo3d.graphics

#rem monkeydoc @hidden
#end
Class Gltf2Buffer
	Field uri:String
	Field byteLength:Int
End

#rem monkeydoc @hidden
#end
Class Gltf2BufferView
	Field buffer:Gltf2Buffer
	Field byteOffset:Int
	Field byteLength:Int
	Field byteStride:Int
	Field target:Int
End

#rem monkeydoc @hidden
#end
Class Gltf2Accessor
	Field bufferView:Gltf2BufferView
	Field byteOffset:Int
	Field componentType:Int
	Field count:Int
	Field type:String
	Field sizeInBytes:Int
	Field numberOfComponents:Int
End

#rem monkeydoc @hidden
#end
Class Gltf2Image
	Field uri:String
End

#rem monkeydoc @hidden
#end
Class Gltf2Sampler
	Field magFilter:Int
	Field minFilter:Int
	Field wrapS:Int
	Field wrapT:Int
End

#rem monkeydoc @hidden
#end
Class Gltf2Texture
	Field sampler:Gltf2Sampler
	Field source:Gltf2Image
End

#rem monkeydoc @hidden
#end
Class Gltf2Material
	Field name:String
	Field baseColorTexture:Gltf2Texture
	Field baseColorFactor:Vec4f=New Vec4f(1)
	Field metallicRoughnessTexture:Gltf2Texture
	Field metallicFactor:Float=1
	Field roughnessFactor:Float=1
	Field occlusionTexture:Gltf2Texture
	Field occlusionFactor:Vec3f=New Vec3f(1)
	Field emissiveTexture:Gltf2Texture
	Field emissiveFactor:Vec3f=New Vec3f(0)
	Field normalTexture:Gltf2Texture
End

#rem monkeydoc @hidden
#end
Class Gltf2Primitive
	Field POSITION:Gltf2Accessor
	Field NORMAL:Gltf2Accessor
	Field TANGENT:Gltf2Accessor
	Field TEXCOORD_0:Gltf2Accessor
	Field indices:Gltf2Accessor
	Field material:Gltf2Material
	Field mode:Int
End

#rem monkeydoc @hidden
#end
Class Gltf2Mesh
	Field name:String
	Field primitives:Gltf2Primitive[]
End

#rem monkeydoc @hidden
#end
Class Gltf2Node
	Field name:String
	Field parent:Gltf2Node
	Field children:Gltf2Node[]
	Field translation:Vec3f=New Vec3f(0)
	Field rotation:Quatf=New Quatf
	Field scale:Vec3f=New Vec3f(1)
	Field matrix:Mat4f=New Mat4f
	Field mesh:Gltf2Mesh
	Field hasMatrix:Bool
End

#rem monkeydoc @hidden
#end
Class Gltf2Scene
	Field name:String
	Field nodes:Gltf2Node[]
End

#rem monkeydoc @hidden
#end
Class Gltf2Asset
	
	Field buffers:Gltf2Buffer[]
	Field bufferViews:Gltf2BufferView[]
	Field accessors:Gltf2Accessor[]
	Field images:Gltf2Image[]
	Field samplers:Gltf2Sampler[]
	Field textures:Gltf2Texture[]
	Field materials:Gltf2Material[]
	Field meshes:Gltf2Mesh[]
	Field nodes:Gltf2Node[]
	Field scenes:Gltf2Scene[]
	
	Function Load:Gltf2Asset( path:String )
		
		Local root:=JsonObject.Load( path )
		If Not root Return Null

		Local asset:=New Gltf2Asset( root )
		If Not asset.LoadAsset() Return Null
		
		Return asset
	End
	
	Private
	
	Field root:JsonObject
	
	Method New( root:JsonObject )
		Self.root=root
	End
	
	Method GetQuatf:Quatf( jval:JsonArray )
		Return New Quatf( jval.GetNumber(0),jval.GetNumber(1),jval.GetNumber(2),jval.GetNumber(3) )
	End
	
	Method GetVec4f:Vec4f( jval:JsonArray )
		Return New Vec4f( jval.GetNumber(0),jval.GetNumber(1),jval.GetNumber(2),jval.GetNumber(3) )
	End
	
	Method GetVec3f:Vec3f( jval:JsonArray )
		Return New Vec3f( jval.GetNumber(0),jval.GetNumber(1),jval.GetNumber(2) )
	End
	
	Method GetMat4f:Mat4f( jval:JsonArray )
		Return New Mat4f(
			New Vec4f( jval.GetNumber(0),jval.GetNumber(1),jval.GetNumber(2),jval.GetNumber(3) ),
			New Vec4f( jval.GetNumber(4),jval.GetNumber(5),jval.GetNumber(6),jval.GetNumber(7) ),
			New Vec4f( jval.GetNumber(8),jval.GetNumber(9),jval.GetNumber(10),jval.GetNumber(11) ),
			New Vec4f( jval.GetNumber(12),jval.GetNumber(13),jval.GetNumber(14),jval.GetNumber(15) ) )
	End
	
	Method LoadBuffers:Bool()
		
		Local jbuffers:=root.GetArray( "buffers" )
		If Not jbuffers Return True
		
		buffers=New Gltf2Buffer[jbuffers.Length]
		
		For Local i:=0 Until buffers.Length
			
			Local jbuffer:=jbuffers.GetObject( i )
			
			Local buffer:=New Gltf2Buffer
			buffers[i]=buffer
			
			buffer.byteLength=jbuffer.GetNumber( "byteLength" )
			buffer.uri=jbuffer.GetString( "uri" )
		Next
		
		Return True
	End
	
	Method LoadBufferViews:Bool()

		Local jbufferViews:=root.GetArray( "bufferViews" )
		If Not jbufferViews Return True
		
		bufferViews=New Gltf2BufferView[jbufferViews.Length]
		
		For Local i:=0 Until bufferViews.Length
			
			Local jbufferView:=jbufferViews.GetObject( i )
			
			Local bufferView:=New Gltf2BufferView
			bufferViews[i]=bufferView
			
			bufferView.buffer=buffers[jbufferView.GetNumber( "buffer" )]
			bufferView.byteLength=jbufferView.GetNumber( "byteLength" )
			bufferView.byteOffset=jbufferView.GetNumber( "byteOffset" )
			bufferView.byteStride=jbufferView.GetNumber( "byteStride" )
			bufferView.target=jbufferView.GetNumber( "target" )
		Next
		
		Return True
	End
	
	Method LoadAccessors:Bool()
		
		Local jaccessors:=root.GetArray( "accessors" )
		If Not jaccessors Return True
		
		accessors=New Gltf2Accessor[ jaccessors.Length ]
		
		For Local i:=0 Until accessors.Length
			
			Local jaccessor:=jaccessors.GetObject( i )
			
			Local accessor:=New Gltf2Accessor
			accessors[i]=accessor
			
			accessor.bufferView=bufferViews[jaccessor.GetNumber( "bufferView" )]
			accessor.byteOffset=jaccessor.GetNumber( "byteOffset" )
			accessor.componentType=jaccessor.GetNumber( "componentType" )
			accessor.count=jaccessor.GetNumber( "count" )
			accessor.type=jaccessor.GetString( "type" )
		Next
		
		Return True
	End
	
	Method LoadImages:Bool()
		
		Local jimages:=root.GetArray( "images" )
		If Not jimages Return True
		
		images=New Gltf2Image[jimages.Length]
		
		For Local i:=0 Until images.Length
			
			Local jimage:=jimages.GetObject( i )
			
			Local image:=New Gltf2Image
			images[i]=image
			
			image.uri=jimage.GetString( "uri" )
		Next
		
		Return True
	End
	
	Method LoadSamplers:Bool()
		
		Local jsamplers:=root.GetArray( "samplers" )
		If Not jsamplers Return True
		
		samplers=New Gltf2Sampler[jsamplers.Length]
		
		For Local i:=0 Until samplers.Length
			
			Local jsampler:=jsamplers.GetObject( i )
			
			Local sampler:=New Gltf2Sampler
			samplers[i]=sampler
			
			sampler.magFilter=jsampler.GetNumber( "magFilter" )
			sampler.minFilter=jsampler.GetNumber( "minFilter" )
			sampler.wrapS=jsampler.GetNumber( "wrapS" )
			sampler.wrapT=jsampler.GetNumber( "wrapT" )
		Next
		
		Return True
	End
	
	Method LoadTextures:Bool()
		
		Local jtextures:=root.GetArray( "textures" )
		If Not jtextures Return True
		
		textures=New Gltf2Texture[jtextures.Length]
		
		For Local i:=0 Until textures.Length
			
			Local jtexture:=jtextures.GetObject( i )
			
			Local texture:=New Gltf2Texture
			textures[i]=texture
			
			If Not jtexture.Contains( "source" ) Return False
			texture.source=images[jtexture.GetNumber( "source" )]
			
			If jtexture.Contains( "sampler" )
				texture.sampler=samplers[jtexture.GetNumber( "sampler" ) ]
			Endif
		Next
		
		Return True
	End
	
	Method LoadMaterials:Bool()
		
		Local jmaterials:=root.GetArray( "materials" )
		If Not jmaterials Return True
		
		materials=New Gltf2Material[jmaterials.Length]
		
		For Local i:=0 Until materials.Length
			
			Local jmaterial:=jmaterials.GetObject( i )
			
			Local material:=New Gltf2Material
			materials[i]=material
			
			material.name=jmaterial.GetString( "name" )

			Local jpbr:=jmaterial.GetObject( "pbrMetallicRoughness" )
			If jpbr
				Local jobj:=jpbr.GetObject( "baseColorTexture" )
				If jobj
					material.baseColorTexture=textures[jobj.GetNumber( "index" )]
				Endif
				Local jarr:=jpbr.GetArray( "baseColorFactor" )
				If jarr
					material.baseColorFactor=GetVec4f( jarr )
				Endif
				jobj=jpbr.GetObject( "metallicRoughnessTexture" )
				If jobj
					material.metallicRoughnessTexture=textures[jobj.GetNumber( "index" )]
				Endif
				If jpbr.Contains( "metallicFactor" )
					material.metallicFactor=jpbr.GetNumber( "metallicFactor" )
				Endif
				If jpbr.Contains( "roughnessFactor" )
					material.metallicFactor=jpbr.GetNumber( "roughnessFactor" )
				Endif
			End
			
			Local jobj:=jmaterial.GetObject( "emissiveTexture" )
			If jobj
				material.emissiveTexture=textures[jobj.GetNumber( "index" )]
			Endif
			Local jarr:=jmaterial.GetArray( "emissiveFactor" )
			If jarr
				material.emissiveFactor=GetVec3f( jarr )
			Endif
			jobj=jmaterial.GetObject( "normalTexture" )
			If jobj
				material.normalTexture=textures[jobj.GetNumber( "index" )]
			Endif

		Next
		
		Return True
	End
	
	Method LoadMeshes:Bool()
		
		Local jmeshes:=root.GetArray( "meshes" )
		If Not jmeshes Return True
		
		meshes=New Gltf2Mesh[jmeshes.Length]
		
		For Local i:=0 Until meshes.Length
			
			Local mesh:=New Gltf2Mesh
			meshes[i]=mesh
			
			Local jmesh:=jmeshes.GetObject( i )
			mesh.name=jmesh.GetString( "name" )
			
			Local jprims:=jmesh.GetArray( "primitives" )
			
			mesh.primitives=New Gltf2Primitive[jprims.Length]
			
			For Local j:=0 Until jprims.Length
				
				Local prim:=New Gltf2Primitive
				mesh.primitives[j]=prim
				
				Local jprim:=jprims.GetObject( j )
				
				Local jattribs:=jprim.GetObject( "attributes" )
				
				If jattribs.Contains( "POSITION" )
					prim.POSITION=accessors[jattribs.GetNumber( "POSITION" )]
				Endif
				If jattribs.Contains( "NORMAL" )
					prim.NORMAL=accessors[jattribs.GetNumber( "NORMAL" )]
				Endif
				If jattribs.Contains( "TANGENT" )
					prim.TANGENT=accessors[jattribs.GetNumber( "TANGENT" )]
				Endif
				If jattribs.Contains( "TEXCOORD_0" )
					prim.TEXCOORD_0=accessors[jattribs.GetNumber( "TEXCOORD_0" )]
				Endif
				If jprim.Contains( "indices" )
					prim.indices=accessors[jprim.GetNumber( "indices" )]
				Endif
				If jprim.Contains( "material" )
					prim.material=materials[jprim.GetNumber( "material" )]
				Endif
				If jprim.Contains( "mode" )
					prim.mode=jprim.GetNumber( "mode" )
				Else
					prim.mode=4
				Endif
			
			Next
		
		Next
		
		Return True
	End

	Method LoadNodes:Bool()

		Local jnodes:=root.GetArray( "nodes" )
		If Not jnodes Return True
		
		nodes=New Gltf2Node[ jnodes.Length ]
		
		For Local i:=0 Until nodes.Length
			nodes[i]=New Gltf2Node
		Next
		
		For Local i:=0 Until jnodes.Length

			Local jnode:=jnodes.GetObject( i )
			
			Local node:=nodes[i]
			node.name=jnode.GetString( "name" )
			
			Local jchildren:=jnode.GetArray( "children" )
			If jchildren

				node.children=New Gltf2Node[jchildren.Length]
				
				For Local j:=0 Until jchildren.Length
					
					Local child:=nodes[jchildren.GetNumber( j )]
					node.children[j]=child
					
					child.parent=node
				Next
			Endif
			
			If jnode.Contains( "translation" )
				node.translation=GetVec3f( jnode.GetArray( "translation" ) )
				node.translation.z=-node.translation.z
			Endif

			If jnode.Contains( "rotation" )
				node.rotation=GetQuatf( jnode.GetArray( "rotation" ) )
			Endif
			
			If jnode.Contains( "scale" )
				node.scale=GetVec3f( jnode.GetArray( "scale" ) )
			Endif
				
			If jnode.Contains( "matrix" )
				node.matrix=GetMat4f( jnode.GetArray( "matrix" ) )
				node.matrix.t.z=-node.matrix.t.z
			Else
				node.matrix=Mat4f.Translation( node.translation ) * Mat4f.Rotation( node.rotation ) * Mat4f.Scaling( node.scale )
			Endif
			
			If jnode.Contains( "mesh" )
				node.mesh=meshes[jnode.GetNumber( "mesh" )]
			Endif
			
		Next
		
		Return True
	End
	
	Method LoadScenes:Bool()
		
		Local jscenes:=root.GetArray( "scenes" )
		If Not jscenes Return True
		
		scenes=New Gltf2Scene[jscenes.Length]
		
		For Local i:=0 Until jscenes.Length
			
			Local jscene:=jscenes.GetObject( i )
			
			Local scene:=New Gltf2Scene
			scenes[i]=scene

			scene.name=jscene.GetString( "name" )

			Local jnodes:=jscene.GetArray( "nodes" )
			scene.nodes=New Gltf2Node[jnodes.Length]
			
			For Local j:=0 Until jnodes.Length
				scene.nodes[j]=nodes[jnodes.GetNumber( j )]
			Next
		
		Next
		
		Return True
	End
	
	Method LoadAsset:Bool()
		
		Local asset:=root.GetObject( "asset" )
		If Not asset Return False
		
		Local version:=asset.GetString( "version" )
'		Print "Gltf2 version="+version
		
		If Not LoadBuffers() Return False
		If Not LoadBufferViews() Return False
		If Not LoadAccessors() Return False
		If Not LoadImages() Return False
		If Not LoadSamplers() Return False
		If Not LoadTextures() Return False
		If Not LoadMaterials() Return False
		If Not LoadMeshes() Return False
		If Not LoadNodes() Return False
		If Not LoadScenes() Return False
		
		Return True
	End
	
End
