
Namespace mojo3d.graphics

#rem monkeydoc The Mesh class.
#end
Class Mesh Extends Resource
	
	#rem monkeydoc Creates a new mesh.
	
	Creates a new empty mesh.
	
	Meshes don't actual contain instances of materials. Instead, mesh triangles are added to 'logical' materials which are effectively just integer indices.
	
	Actual materials are stored in models, and can be accessed via the [[Model.Materials]] property.
	
	#end
	Method New()
		
		_dirty=Null
		_bounds=Boxf.EmptyBounds
		_vbuffer=New VertexBuffer( Vertex3fFormat.Instance,0 )
		_ibuffers=New Stack<IndexBuffer>
	End
	
	Method New( mesh:Mesh )
		_dirty=mesh._dirty
		_bounds=mesh._bounds
		_vbuffer=New VertexBuffer( mesh._vbuffer )
		For Local ibuffer:=Eachin mesh._ibuffers
			_ibuffers.Push( New IndexBuffer( ibuffer ) )
		Next
	End
	
	Method New( vertices:Vertex3f[],triangles:UInt[] )
		Self.New()
		
		AddVertices( vertices )
		AddTriangles( triangles )
	End

	#rem monkeydoc Mesh bounding box.
	#end
	Property Bounds:Boxf()
		
		If _dirty & Dirty.Bounds
			
			Local vertices:=Cast<Vertex3f Ptr>( _vbuffer.Data )
			
			_bounds=Boxf.EmptyBounds
			
			For Local i:=0 Until _vbuffer.Length
				_bounds|=vertices[i].position
			Next
			
			_dirty&=~Dirty.Bounds
		Endif
		
		Return _bounds
	End
	
	#rem monkeydoc Number of vertices.
	#end
	Property NumVertices:Int()
		
		Return _vbuffer.Length
	End
	
	#rem monkeydoc Number of materials.
	
	This will always be at least one.
	
	#end
	Property NumMaterials:Int()
		
		Return _ibuffers.Length
	End
	
	#rem monkeydoc Clears the mesh.
	
	Removes all vertices and primitives from the mesh, and resets the number of logical materials to '1'.
	
	#end
	Method Clear()
		
		_vbuffer.Clear()
		
		For Local ibuffer:=Eachin _ibuffers
			ibuffer.Clear()
		Next
		
		_ibuffers.Resize( 1 )
	End

	#rem monkeydoc @hidden
	#end	
	Method AddMesh( mesh:Mesh )
	
		Local v0:=_vbuffer.Length,i0:=_ibuffers.Length
	
		AddVertices( Cast<Vertex3f Ptr>( mesh._vbuffer.Data ),mesh._vbuffer.Length )
		
		AddMaterials( mesh._ibuffers.Length )
		
		For Local i:=i0 Until _ibuffers.Length
		
			Local ibuffer:=mesh._ibuffers[i-i0]
		
			AddTriangles( Cast<UInt Ptr>( ibuffer.Data ),ibuffer.Length )
		Next
	End
	
	#rem monkeydoc Adds vertices to the mesh.
	#end
	Method AddVertices( vertices:Vertex3f Ptr,count:Int )

		Local p:=_vbuffer.AddVertices( count )
		
		libc.memcpy( p,vertices,count * _vbuffer.Pitch )
		
		_dirty|=Dirty.Bounds
	End
	
	Method AddVertices( vertices:Vertex3f[] )
	
		AddVertices( vertices.Data,vertices.Length )
	End
	
	#rem monkeydoc Adds a single vertex to the mesh
	#end
	Method AddVertex( vertex:Vertex3f )
		
		AddVertices( Varptr vertex,1 )
	End
	
	#rem monkeydoc Adds triangles to the mesh.
	
	The `materialid` parameter must be greater than or equal to 0 and less or equal to [[NumMaterials]].
	
	If `materialid` is equal to NumMaterials, a new material is automatically added first.
	
	#end
	Method AddTriangles( indices:UInt Ptr,count:Int,materialid:Int=0 )
		
		If materialid=_ibuffers.Length AddMaterials( 1 )
		
		Local p:=_ibuffers[materialid].AddIndices( count )
		
		libc.memcpy( p,indices,count*4 )
	End
	
	Method AddTriangles( indices:UInt[],materialid:Int=0 )
	
		AddTriangles( indices.Data,indices.Length,materialid )
	End

	#rem  monkeydoc Adds a single triangle the mesh.
	#end	
	Method AddTriangle( i0:UInt,i1:UInt,i2:UInt,materialid:Int=0 )
		
		AddTriangles( New UInt[]( i0,i1,i2 ),materialid )
	End
	
	#rem monkeydoc Adds materials to the mesh.
	
	Adds `count` logical materials to the mesh.
	
	WIP! Eventually want to be able to add lines, points etc to meshes, probably via this method...
	
	#end
	Method AddMaterials( count:Int )
		
		For Local i:=0 Until count
			
			_ibuffers.Push( New IndexBuffer( IndexFormat.UINT32,0 ) )
		End
	End
	
	#rem monkeydoc Transforms all vertices in the mesh.
	#end
	Method TransformVertices( matrix:AffineMat4f )
		
		Local vertices:=Cast<Vertex3f Ptr>( _vbuffer.Data )
		
		Local cofactor:=matrix.m.Cofactor()
		
		For Local i:=0 Until _vbuffer.Length
		
			vertices[i].position=matrix * vertices[i].position
			
			vertices[i].normal=(cofactor * vertices[i].normal).Normalize()
			
			vertices[i].tangent.XYZ=(cofactor * vertices[i].tangent.XYZ).Normalize()
		Next
		
		_vbuffer.Invalidate()
		
		_dirty|=Dirty.Bounds
	End
	
	#rem monkeydoc Fits all vertices in the mesh to a box.
	#end
	Method FitVertices( box:Boxf,uniform:Bool=True )

		Local bounds:=Bounds
		
		Local scale:=box.Size/bounds.Size
		
		If uniform scale=New Vec3f( Min( scale.x,Min( scale.y,scale.z ) ) )
			
		Local m:=Mat3f.Scaling( scale )
		
		Local t:=box.Center - m * bounds.Center
		
		TransformVertices( New AffineMat4f( m,t ) )			
	End
	
	#rem monkeydoc Updates mesh normals.
	
	Recalculates all vertex normals based on triangle and vertex positions.
	
	#end
	Method UpdateNormals()

		Local vcount:=_vbuffer.Length
		
		Local vertices:=Cast<Vertex3f Ptr>( _vbuffer.Data )
		
		For Local i:=0 Until vcount
			
			vertices[i].normal=New Vec3f(0)
		Next
		
		For Local ibuffer:=Eachin _ibuffers
			
			Local icount:=ibuffer.Length
			Local indices:=Cast<UInt Ptr>( ibuffer.Data )
		
			For Local i:=0 Until icount Step 3
				
				Local i1:=indices[i+0]
				Local i2:=indices[i+1]
				Local i3:=indices[i+2]
				
				Local v1:=vertices[i1].position
				Local v2:=vertices[i2].position
				Local v3:=vertices[i3].position
				
				Local n:=(v2-v1).Cross(v3-v1).Normalize()
				
				vertices[i1].normal+=n
				vertices[i2].normal+=n
				vertices[i3].normal+=n
			
			Next
		
		Next
		
		For Local i:=0 Until vcount
			
			vertices[i].normal=vertices[i].normal.Normalize()
		Next
	
	End

	#rem monkeydoc Updates mesh tangents.
	
	Recalculates all vertex tangents based on triangles, vertex normals and vertex texcoord0.
	
	#end
	Method UpdateTangents()
		
		Local vcount:=_vbuffer.Length
		
		Local vertices:=Cast<Vertex3f Ptr>( _vbuffer.Data )
		
		Local tan1:=New Vec3f[vcount]
		Local tan2:=New Vec3f[vcount]
		
		For Local ibuffer:=Eachin _ibuffers
			
			Local icount:=ibuffer.Length
			Local indices:=Cast<UInt Ptr>( ibuffer.Data )
		
			For Local i:=0 Until icount Step 3
				
				Local i1:=indices[i+0]
				Local i2:=indices[i+1]
				Local i3:=indices[i+2]
				
				Local v1:=vertices+i1
				Local v2:=vertices+i2
				Local v3:=vertices+i3
				
				Local x1:=v2->Tx-v1->Tx
				Local x2:=v3->Tx-v1->Tx
				Local y1:=v2->Ty-v1->Ty
				Local y2:=v3->Ty-v1->Ty
				Local z1:=v2->Tz-v1->Tz
				Local z2:=v3->Tz-v1->Tz
				
				Local s1:=v2->Sx-v1->Sx
				Local s2:=v3->Sx-v1->Sx
				Local t1:=v2->Sy-v1->Sy
				Local t2:=v3->Sy-v1->Sy
				
				Local r:=1.0/(s1*t2-s2*t1)
				
				Local sdir:=New Vec3f( (t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r, (t2 * z1 - t1 * z2) * r )
				Local tdir:=New Vec3f( (s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r, (s1 * z2 - s2 * z1) * r )
				
				tan1[i1]+=sdir
				tan1[i2]+=sdir
				tan1[i3]+=sdir
		
				tan2[i1]+=tdir
				tan2[i2]+=tdir
				tan2[i3]+=tdir
			Next
		Next
	
		For Local i:=0 Until vcount
			
			Local v:=vertices+i
	
			Local n:=v->normal,t:=tan1[i]
			
			v->tangent.XYZ=( t - n * n.Dot( t ) ).Normalize()
			
			v->tangent.w=n.Cross( t ).Dot( tan2[i] ) < 0 ? -1 Else 1
		Next
		
		_vbuffer.Invalidate()
	End
	
	#rem monkeydoc Flips all triangles.
	#end
	Method FlipTriangles()
		
		For Local ibuffer:=Eachin _ibuffers
			
			Local indices:=Cast<UInt Ptr>( ibuffer.Data )
			
			For Local i:=0 Until ibuffer.Length Step 3
				Local t:=indices[i]
				indices[i]=indices[i+1]
				indices[i+1]=t
			Next
			
			ibuffer.Invalidate()
		Next
		
	End
	
	#rem monkeydoc Scales texture coordinates.
	#end
	Method ScaleTexCoords( scale:Vec2f )
		
		Local vertices:=Cast<Vertex3f Ptr>( _vbuffer.Data )
		
		For Local i:=0 Until _vbuffer.Length
		
			vertices[i].texCoord0*=scale
		Next
		
		_vbuffer.Invalidate()
	End

	#rem monkeydoc Gets all vertices in the mesh.
	#end	
	Method GetVertices:Vertex3f[]()
		
		Local vertices:=New Vertex3f[ _vbuffer.Length ]
		
		libc.memcpy( vertices.Data,_vbuffer.Data,_vbuffer.Length*_vbuffer.Pitch )
		
		Return vertices
	End
	
	#rem monkeydoc Get indices for a material id.
	#end
	Method GetIndices:UInt[]( materialid:Int )
	
		Local ibuffer:=_ibuffers[materialid]
		
		Local indices:=New UInt[ ibuffer.Length ]
		
		libc.memcpy( indices.Data,ibuffer.Data,ibuffer.Length*4 )
		
		Return indices
	End

	#rem monkeydoc Gets all indices in the mesh.
	#end	
	Method GetAllIndices:UInt[]()
	
		Local n:=0
		For Local ibuffer:=Eachin _ibuffers
			n+=ibuffer.Length
		Next
		
		Local indices:=New UInt[ n ],p:=indices.Data
		
		For Local ibuffer:=Eachin _ibuffers
			
			libc.memcpy( p,ibuffer.Data,ibuffer.Length*4 )
		
			p+=ibuffer.Length
		Next
		
		Return indices
	End
	
	#rem monkeydoc Loads a mesh from a file.
	
	On its own, mojo3d can only load gltf2 format mesh and model files.
	
	To add more formats, #import the mojo3d-assimp module into your app, eg:
	
	```
	#Import "<mojo3d>"
	#Import "<mojo3d-assimp>"
	```
	
	This will allow you to load any format supported by the assimp module.
	
	However, importing the assimp module into your app will also increase its size.
	
	#end
	Function Load:Mesh( path:String )
	
		For Local loader:=Eachin Mojo3dLoader.Instances
		
			Local mesh:=loader.LoadMesh( path )
			If mesh Return mesh
		
		Next
		
		Return Null
	End
	
	'***** INTERNAL *****
	
	#rem monkeydoc @hidden
	#end
	Method GetVertexBuffer:VertexBuffer()
		
		Return _vbuffer
	End
	
	#rem monkeydoc @hidden
	#end
	Method GetIndexBuffers:Stack<IndexBuffer>()
		
		Return _ibuffers
	End
	
	Private
	
	Enum Dirty
		Bounds=1
	End
	
	Field _dirty:Dirty
	Field _bounds:Boxf
	Field _vbuffer:VertexBuffer
	Field _ibuffers:Stack<IndexBuffer>
	
End
