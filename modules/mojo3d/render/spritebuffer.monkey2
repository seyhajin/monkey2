
Namespace mojo3d

#rem monkeydoc @hidden
#end
Class SpriteBuffer
	
	Method New()
		_vbuffer=New VertexBuffer( Vertex3f.Format,0 )
		
		_ibuffer=New IndexBuffer( IndexFormat.UINT32,0 )
	End
	
	Method AddSprites( rq:RenderQueue,camera:Camera )
	
		Local sprites:=rq.Sprites
		
		If sprites.Empty Return
		
		Local n:=sprites.Length
		
		If n*4>_vbuffer.Length
			_vbuffer.Resize( Max( _vbuffer.Length*3/2,n*4 ) )
		Endif
		
		If n*6>_ibuffer.Length
			Local i0:=_ibuffer.Length/6
			_ibuffer.Resize( Max( _ibuffer.Length*3/2,n*6 ) )
			Local ip:=Cast<UInt Ptr>( _ibuffer.Lock() )+i0*6
			For Local i:=i0 Until n
				ip[0]=i*4
				ip[1]=i*4+1
				ip[2]=i*4+2
				ip[3]=i*4
				ip[4]=i*4+2
				ip[5]=i*4+3
				ip+=6
			Next
			_ibuffer.Invalidate( i0*6,(n-i0)*6 )
			_ibuffer.Unlock()
		Endif
		
		Local vp:=Cast<Vertex3f Ptr>( _vbuffer.Lock() )
		
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
				rq.AddSpriteOp( cmaterial,Null,Null,_vbuffer,_ibuffer,3,(i-i0)*2,i0*6 )
				cmaterial=material
				i0=i
			Endif
			
			Local r:=camera.Basis
			
			Select sprite.Mode
			Case SpriteMode.Upright
	
				r.j=New Vec3f( 0,1,0 ) ; r.i=r.j.Cross( r.k ).Normalize()
			End
			
			Local matrix:=New AffineMat4f( r.Scale( sprite.Scale ),sprite.Position )
			
			Local texrect:=sprite.TextureRect,handle:=sprite.Handle
			
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
		
		rq.AddSpriteOp( cmaterial,Null,Null,_vbuffer,_ibuffer,3,(i-i0)*2,i0*6 )
		
		_vbuffer.Invalidate()
		
		_vbuffer.Unlock()
	End

	Private
	
	Field _vbuffer:VertexBuffer
	
	Field _ibuffer:IndexBuffer
	
End
