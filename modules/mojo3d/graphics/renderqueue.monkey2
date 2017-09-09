
Namespace mojo3d.graphics

#rem monkeydoc @hidden
#end
Class RenderOp
	Field material:Material
	Field uniforms:UniformBlock
	Field vbuffer:VertexBuffer
	Field ibuffer:IndexBuffer
	Field instance:Entity
	Field bones:Mat4f[]
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
	
	Property ShadowOps:Stack<RenderOp>()
		
		Return _shadowOps
	End
	
	Property AddShadowOps:Bool()
		
		Return _addShadowOps
		
	Setter( addShadowOps:Bool )
		
		_addShadowOps=addShadowOps
	End
	
	Method Clear()
		
		_opaqueOps.Clear()
		_shadowOps.Clear()
		_transparentOps.Clear()
	End
	
	Method AddRenderOp( op:RenderOp )
		
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
	
	Method AddRenderOp( material:Material,vbuffer:VertexBuffer,ibuffer:IndexBuffer,instance:Entity,order:Int,count:Int,first:Int )
		Local op:=New RenderOp
		op.material=material
		op.vbuffer=vbuffer
		op.ibuffer=ibuffer
		op.instance=instance
		op.order=order
		op.count=count
		op.first=first
		AddRenderOp( op )
	End
	
	Method AddRenderOp( material:Material,vbuffer:VertexBuffer,ibuffer:IndexBuffer,instance:Entity,bones:Mat4f[],order:Int,count:Int,first:Int )
		Local op:=New RenderOp
		op.material=material
		op.vbuffer=vbuffer
		op.ibuffer=ibuffer
		op.instance=instance
		op.bones=bones
		op.order=order
		op.count=count
		op.first=first
		AddRenderOp( op )
	End
	
	Private

	Field _time:float	
	Field _opaqueOps:=New Stack<RenderOp>
	Field _transparentOps:=New Stack<RenderOp>
	Field _shadowOps:=New Stack<RenderOp>
	
	Field _addShadowOps:Bool
End
