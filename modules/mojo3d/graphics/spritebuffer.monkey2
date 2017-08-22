
Namespace mojo3d.graphics

#rem monkeydoc @hidden
#end
Class SpriteBuffer
	
	Method New()
		
		If _spriteVertices Return
		
		_spriteVertices=New VertexBuffer( Vertex3fFormat.Instance,0 )
		
		_spriteIndices=New IndexBuffer( IndexFormat.UINT32,0 )
	End
	
	Method AddSpriteops:Vertex3f ptr( vp:Vertex3f Ptr,rq:RenderQueue,sprites:Stack<Sprite>,camera:Camera )
		
		If Not sprites.Length Return vp
		
		
		Return vp
	end		
	
	Method AddSprites( rq:RenderQueue,sprites:Stack<Sprite>,camera:Camera )
		
		If sprites.Empty Return
		
		Local n:=sprites.Length

		_spriteVertices.Clear()
		Local vp:=Cast<Vertex3f Ptr>( _spriteVertices.AddVertices( n*4 ) )
		
		If n>_spriteIndices.Length/6
			Local i:=_spriteIndices.Length/6
			Local ip:=Cast<UInt Ptr>( _spriteIndices.AddIndices( (n-i)*6 ) )
			For Local j:=i Until n
				ip[0]=j*4
				ip[1]=j*4+1
				ip[2]=j*4+2
				ip[3]=j*4
				ip[4]=j*4+2
				ip[5]=j*4+3
				ip+=6
			Next
		Endif
		
		'Sort sprites by distance from camera. Only really need to do this for transparent sprites, but meh...
		'
		sprites.Sort( Lambda:Int( x:Sprite,y:Sprite )
			Return camera.Position.Distance( y.Position ) <=> camera.Position.Distance( x.Position )
		End )

		Local cmaterial:=sprites[0].Material
		Local i0:=0,i:=0
		
		For Local sprite:=Eachin sprites
			
			Local material:=sprite.Material
			If material<>cmaterial
				rq.AddRenderOp( cmaterial,_spriteVertices,_spriteIndices,Null,3,(i-i0)*2,i0*6 )
				cmaterial=material
				i0=i
			Endif
			
			Local r:=camera.Basis
			
			Select sprite.Mode
			Case SpriteMode.Upright
	
				r.j=New Vec3f( 0,1,0 ) ; r.i=r.j.Cross( r.k ).Normalize()
			End
			
			Local matrix:=New AffineMat4f( r.Scale( sprite.Scale ),sprite.Position )
			
			Local texrect:=sprite.TextureRect
			
			Local handle:=sprite.Handle
			
			vp[0].position=matrix * New Vec3f( -handle.x,1-handle.y,0 )
			vp[0].texCoord0=New Vec2f( texrect.min.x,texrect.min.y )
			
			vp[1].position=matrix * New Vec3f( 1-handle.x,1-handle.y,0 )
			vp[1].texCoord0=New Vec2f( texrect.max.x,texrect.min.y )

			vp[2].position=matrix * New Vec3f( 1-handle.x,-handle.y,0 )
			vp[2].texCoord0=New Vec2f( texrect.max.x,texrect.max.y )
			
			vp[3].position=matrix * New Vec3f( -handle.x,-handle.y,0 )
			vp[3].texCoord0=New Vec2f( texrect.min.x,texrect.max.y )
			
			vp+=4
			i+=1
		Next
		
		rq.AddRenderOp( cmaterial,_spriteVertices,_spriteIndices,Null,3,(i-i0)*2,i0*6 )
		
	End

	Private
	
	Field _spriteVertices:VertexBuffer
	
	Field _spriteIndices:IndexBuffer
	
End
