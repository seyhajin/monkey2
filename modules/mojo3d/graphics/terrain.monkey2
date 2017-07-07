
Namespace mojo3d.graphics

#rem monkeydoc The Terrain class.
#end
Class Terrain Extends Entity

	#rem monkeydoc Creates a new terrain.
	#end	
	Method New( heightMap:Pixmap,bounds:Boxf,material:Material,parent:Entity=null )
		Super.New( parent )
		
		Local cellSize:=128
		
		Assert( heightMap.Width=heightMap.Height,"Terrain heightmap must be square" )
		
		Assert( Log2( heightMap.Width )=Floor( Log2( heightMap.Width ) ),"Terrain heightmap size must be power of 2" )

		Assert( Log2( cellSize )=Floor( Log2( cellSize ) ),"Terrain cell size must be power of 2" )
		
		Assert( heightMap.Width>=cellSize,"Terrain heightmap size must be greater than cell size" )
		
		_heightMap=heightMap
		_size=heightMap.Width
		_bounds=bounds
		_material=material
		_cellSize=cellSize
		
		Init()
		
		Show()
	End
	
	Method OnRender( rq:RenderQueue )
		
		Local count:=_ibuffer.Length/3
		
		For Local vbuffer:=Eachin _vbuffers

			rq.AddRenderOp( _material,vbuffer,_ibuffer,Self,3,count,0 )
			
		Next
	End
	
	Protected
	
	Method OnShow() Override
		
		Scene.Terrains.Add( Self )
	End
	
	Method OnHide() Override
		
		Scene.Terrains.Remove( Self )
	End
	
	Private
	
	Field _heightMap:Pixmap
	Field _bounds:Boxf
	Field _material:Material
	
	Field _cellSize:Int
	Field _size:Int
	
	Field _ibuffer:IndexBuffer
	Field _vbuffers:VertexBuffer[]
	
	Method GetPosition:Vec3f( i:Int,j:Int )
		
		i=Clamp( i,0,_size-1 )
		j=Clamp( j,0,_size-1 )
		
		Local x:=Float(i)/Float(_size-1)
		Local z:=Float(j)/Float(_size-1)
		
		Local y:=_heightMap.PixelPtr( i,j )[0]/255.0
		
		Return New Vec3f( x,y,z ) * _bounds.Size+_bounds.min
	End

	Method GetTexCoord0:Vec2f( i:Int,j:Int )
	
		Local x:=Float(i)/Float(_size-1)
		Local z:=Float(j)/Float(_size-1)

		Return New Vec2f( x,z )
	End
	
	Method GetNormal:Vec3f( i:Int,j:Int )

		Local v0:=GetPosition( i,j )
		Local v1:=GetPosition( i,Min( j+1,_size-1 ) )
		Local v2:=GetPosition( Min( i+1,_size-1 ),j )
		Local v3:=GetPosition( i,Max( j-1,0 ) )
		Local v4:=GetPosition( Max( i-1,0 ),j )
				
		Local n0:=(v1-v0).Cross(v2-v0).Normalize()
		Local n1:=(v2-v0).Cross(v3-v0).Normalize()
		Local n2:=(v3-v0).Cross(v4-v0).Normalize()
		Local n3:=(v4-v0).Cross(v1-v0).Normalize()
			
		Local n:=(n0+n1+n2+n3).Normalize()
			
'		If (i&15)=0 And (j&15)=0 print "n="+v
			
'		DebugAssert( n.y>0 )
		
		Return n
	End
	
	Function GetIndexBuffer:IndexBuffer( cellSize:Int )
		
		Global _ibuffers:=New IntMap<IndexBuffer>
				
		If _ibuffers.Contains( cellSize ) Return _ibuffers[cellSize]
	
		Local indices:=New Uint[ cellSize*cellSize*6 ],ip:=indices.Data
				
		For Local j:=0 Until cellSize
		
			Local k:=j*(cellSize+1)
		
			For Local i:=k Until k+cellSize
			
				Local v0:=i,v1:=i+cellSize+1,v2:=i+cellSize+2,v3:=i+1
			
				If (j~(i-k)) & 1
	 				ip[0]=v1 ; ip[1]=v2 ; ip[2]=v3
	 				ip[3]=v1 ; ip[4]=v3 ; ip[5]=v0
				Else
					ip[0]=v2 ; ip[1]=v3 ; ip[2]=v0
					ip[3]=v2 ; ip[4]=v0 ; ip[5]=v1
				Endif
				
				ip+=6
			Next
		Next
		
		Local ibuffer:=New IndexBuffer( indices )
		
		_ibuffers[cellSize]=ibuffer
		
		Return ibuffer
	End
	
	Method Init()
		
		_ibuffer=GetIndexBuffer( _cellSize )
		
		Local vbuffers:=New Stack<VertexBuffer>
		
		Local vertices:=New Stack<Vertex3f>
		
		For Local j0:=0 Until _size Step _cellSize
		
			Local j1:=j0+_cellSize

			For Local i0:=0 Until _size Step _cellSize
			
				Local i1:=i0+_cellSize
				
				Local v0:=vertices.Length
				
				For Local j:=j0 To j1
				
					For Local i:=i0 To i1
					
						Local p:=GetPosition( i,j )
						
						Local t0:=GetTexCoord0( i,j )
						
						Local n:=GetNormal( i,j )
						
						Local v:=New Vertex3f( p,t0,n )
						
						vertices.Push( v )
					
					Next
					
				Next
				
				UpdateTangents( vertices.Data.Data,vertices.Length,Cast<UInt Ptr>( _ibuffer.Data ),_ibuffer.Length )
				
				Local vbuffer:=New VertexBuffer( vertices.ToArray() )

				vbuffers.Push( vbuffer )
				
				vertices.Clear()
			Next
			
		Next
		
		_vbuffers=vbuffers.ToArray()

	End
	
End
