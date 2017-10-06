
Namespace mojo3d.graphics

#rem monkeydoc @hidden
#end
Class RenderOp
	Field material:Material
	Field uniforms:UniformBlock
	Field instance:Entity
	Field bones:Mat4f[]
	Field vbuffer:VertexBuffer
	Field ibuffer:IndexBuffer
	Field order:Int
	Field count:Int
	Field first:Int
End

#rem monkeydoc @hidden
#end
Class RenderQueue

	Property Time:Float()
	
		Return _time
		
	Setter( time:Float )
	
		_time=time
	End
	
	Property OpaqueOps:Stack<RenderOp>()
		
		Return _opaqueOps
	End
	
	Property TransparentOps:Stack<RenderOp>()
	
		Return _transparentOps
	End
	
	Property SpriteOps:Stack<RenderOp>()
	
		Return _spriteOps
	End
	
	Property ShadowOps:Stack<RenderOp>()
		
		Return _shadowOps
	End

	'bit of a hack for now, but renderqueue should be able to handle sprites...	
	Property Sprites:Stack<Sprite>()
	
		Return _sprites
	End
	
	Property AddShadowOps:Bool()
		
		Return _addShadowOps
		
	Setter( addShadowOps:Bool )
		
		_addShadowOps=addShadowOps
	End
	
	Method Clear()
	
		_sprites.Clear()	
		_opaqueOps.Clear()
		_shadowOps.Clear()
		_transparentOps.Clear()
	End
	
	Method AddRenderOp( op:RenderOp )
		
		op.material.ValidateShader()
		
		If op.material.BlendMode<>BlendMode.Opaque
			_transparentOps.Push( op )
		Else
			_opaqueOps.Push( op )
		Endif
		
		If _addShadowOps 
			If (op.material.Shader.RenderPassMask & $10000) _shadowOps.Push( op )
		Endif
		
	End

	Method AddRenderOp( material:Material,uniforms:UniformBlock,instance:Entity,vbuffer:VertexBuffer,ibuffer:IndexBuffer,order:Int,count:Int,first:Int )
		Local op:=New RenderOp
		op.material=material
		op.uniforms=uniforms
		op.instance=instance
		op.vbuffer=vbuffer
		op.ibuffer=ibuffer
		op.order=order
		op.count=count
		op.first=first
		AddRenderOp( op )
	End
	
	Method AddRenderOp( material:Material,instance:Entity,vbuffer:VertexBuffer,ibuffer:IndexBuffer,order:Int,count:Int,first:Int )
		Local op:=New RenderOp
		op.material=material
		op.instance=instance
		op.vbuffer=vbuffer
		op.ibuffer=ibuffer
		op.order=order
		op.count=count
		op.first=first
		AddRenderOp( op )
	End
	
	Method AddRenderOp( material:Material,bones:Mat4f[],vbuffer:VertexBuffer,ibuffer:IndexBuffer,order:Int,count:Int,first:Int )
		Local op:=New RenderOp
		op.material=material
		op.bones=bones
		op.vbuffer=vbuffer
		op.ibuffer=ibuffer
		op.order=order
		op.count=count
		op.first=first
		AddRenderOp( op )
	End
	
	Method AddRenderOp( material:Material,vbuffer:VertexBuffer,ibuffer:IndexBuffer,order:Int,count:Int,first:Int )
		Local op:=New RenderOp
		op.material=material
		op.vbuffer=vbuffer
		op.ibuffer=ibuffer
		op.order=order
		op.count=count
		op.first=first
		AddRenderOp( op )
	End
	
	Method AddSpriteOp( material:Material,uniforms:UniformBlock,instance:Entity,vbuffer:VertexBuffer,ibuffer:IndexBuffer,order:Int,count:Int,first:Int )
		Local op:=New RenderOp
		op.material=material
		op.uniforms=uniforms
		op.instance=instance
		op.vbuffer=vbuffer
		op.ibuffer=ibuffer
		op.order=order
		op.count=count
		op.first=first
		_spriteOps.Add( op )
	End
	
	Method AddSprite( sprite:Sprite )
	
		_sprites.Add( sprite )
	End
	
	Private

	Field _time:float	
	Field _opaqueOps:=New Stack<RenderOp>
	Field _transparentOps:=New Stack<RenderOp>
	Field _spriteOps:=New Stack<RenderOp>
	Field _shadowOps:=New Stack<RenderOp>
	
	Field _sprites:=New Stack<Sprite>
	
	Field _addShadowOps:Bool
End
