
Namespace mojo3d

Internal

Struct SpriteOp
	Field sprite:Sprite

	Field distance:Float
End

Class RenderOp
	Field material:Material
	Field uniforms:UniformBlock	'could be in instance?
	Field instance:Entity
	Field bones:Mat4f[]			'should be in instance
	Field vbuffer:VertexBuffer
	Field ibuffer:IndexBuffer
	Field order:Int
	Field count:Int
	Field first:Int
	
	Field blendMode:BlendMode
	Field distance:Float
End

Public

Class RenderQueue

	Property Time:Float()
	
		Return _time
		
	Setter( time:Float )
	
		_time=time
	End
	
	Property EyePos:Vec3f()
		
		Return _eyePos
		
	Setter( eyePos:Vec3f )
		
		_eyePos=eyePos
		_eyeLen=_eyePos.Length
	End
	
	Property CastsShadow:Bool()
		
		Return _castsShadow
		
	Setter( castsShadow:Bool )
		
		_castsShadow=castsShadow
	End

	Property OpaqueOps:Stack<RenderOp>()
		
		Return _opaqueOps
	End
	
	Property TransparentOps:Stack<RenderOp>()
	
		Return _transparentOps
	End
	
	Property ShadowOps:Stack<RenderOp>()
		
		Return _shadowOps
	End

	Property SpriteOps:Stack<SpriteOp>()
	
		Return _spriteOps
	End

	Method Clear()
		_opaqueOps.Clear()
		_transparentOps.Clear()
		_shadowOps.Clear()
		_spriteOps.Clear()	
	End
	
	Method AddRenderOp( op:RenderOp )
		
		op.blendMode=op.material.BlendMode
		If op.instance And op.instance.Alpha<1 And op.blendMode=BlendMode.Opaque op.blendMode=BlendMode.Alpha
			
		If op.blendMode=BlendMode.Opaque
			DebugAssert( op.material.GetOpaqueShader(),"Material has no opaque shader" )
			_opaqueOps.Push( op )
		Else
			DebugAssert( op.material.GetTransparentShader(),"Material has no transparent shader" )
			op.distance=op.instance ? op.instance.Position.Distance( _eyePos ) Else _eyeLen
			_transparentOps.Push( op )
		Endif
			
		If _castsShadow And op.material.GetShadowShader() _shadowOps.Push( op )
	End
	
	Method AddSpriteOp( op:SpriteOp )
		op.distance=op.sprite ? op.sprite.Position.Distance( _eyePos ) Else _eyeLen
		_spriteOps.Add( op )
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
	
	Method AddSpriteOp( sprite:Sprite )
		DebugAssert( sprite.Material.GetTransparentShader(),"Sprites must be transparent!" )
		Local op:=New SpriteOp
		op.sprite=sprite
		AddSpriteOp( op )
	End
	
	Private

	Field _time:float	
	
	Field _eyePos:Vec3f
	Field _eyeLen:Float
	Field _castsShadow:Bool
	
	Field _opaqueOps:=New Stack<RenderOp>
	Field _transparentOps:=New Stack<RenderOp>
	Field _shadowOps:=New Stack<RenderOp>
	
	Field _spriteOps:=New Stack<SpriteOp>

End
