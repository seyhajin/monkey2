
Namespace mojo.graphics

#rem monkeydoc The UniformBlock class.
#end
Class UniformBlock Extends Resource

	Method New( name:Int,linearColors:Bool=False )
	
		_name=name
		
		_linearColors=linearColors
	End
	
	Method New( uniforms:UniformBlock )
	
		_name=uniforms._name
		
		_linearColors=uniforms._linearColors
		
		For Local i:=0 Until _uniforms.Length
			_uniforms[i]=uniforms._uniforms[i]
		Next
	End
	
	Property Name:Int()
	
		Return _name
	End
	
	Property LinearColors:Bool()
	
		Return _linearColors
	
	Setter( linearColors:Bool )
	
		_linearColors=linearColors
	End
	
	Function GetUniformId:Int( name:String,block:Int )
		Local ids:=_ids[block]
		If Not ids
			ids=New StringMap<Int>
			_ids[block]=ids
		Endif
		Local id:=ids[name]
		If Not id
			id=ids.Count()+1
			ids[name]=id
		Endif
		Return id
	End
	
	Method GetUniformId:Int( name:String )
		Return GetUniformId( name,_name )
	End
	
	Method GetUniformId:Int( name:String,type:Type )
		Local id:=GetUniformId( name,_name )
		DebugAssert( _uniforms[id].type=type,"Invalid uniform type" )
		Return id
	End

	'***** Int *****
	'	
	Method SetInt( uniform:String,value:Int )
		SetData( uniform,value,Type.Integer )
	End
	
	Method GetInt:Int( uniform:String )
		Return GetData<Int>( uniform,Type.Integer )
	End
	
	Method GetInt:Int( id:Int )
		Return GetDataPtr<Int>( id,Type.Integer )[0]
	End
	
	'***** Float *****
	'	
	Method SetFloat( uniform:String,value:Float )
		SetData( uniform,value,Type.Scalar )
	End
	
	Method GetFloat:Float( uniform:String )
		Return GetData<Float>( uniform,Type.Scalar )
	End
	
	Method GetFloat:Float( id:Int )
		Return GetFloatPtr( id,Type.Scalar )[0]
	End
	
	'***** Vec2f *****
	'
	Method SetVec2f( uniform:String,value:Vec2f )
		SetData( uniform,value,Type.Vec2f )
	End
	
	method GetVec2f:Vec2f( uniform:String )
		Return GetData<Vec2f>( uniform,Type.Vec2f )
	End
	
	Method GetVec2fv:Float Ptr( id:Int )
		Return GetFloatPtr( id,Type.Vec2f )
	End
	
	'***** Vec3f *****
	'
	Method SetVec3f( uniform:String,value:Vec3f )
		SetData( uniform,value,Type.Vec3f )
	End

	Method GetVec3f:Vec3f( uniform:String )
		Return GetData<Vec3f>( uniform,Type.Vec3f )
	End
	
	Method GetVec3fv:Float Ptr( id:Int )
		Return GetFloatPtr( id,Type.Vec3f )
	End
	
	'***** Vec4f *****
	'	
	Method SetVec4f( uniform:String,value:Vec4f )
		SetData( uniform,value,Type.Vec4f )
	End

	Method GetVec4f:Vec4f( uniform:String )
		Return GetData<Vec4f>( uniform,Type.Vec4f )
	End
	
	Method GetVec4fv:Float Ptr( id:Int )
		Return GetFloatPtr( id,Type.Vec4f )
	End
	
	'***** Color (really just Vec4f) *****
	'
	Method SetColor( uniform:String,value:Color )
		If _linearColors
			value.r=Pow(value.r,2.2 )
			value.g=Pow(value.g,2.2 )
			value.b=Pow(value.b,2.2 )
		Endif
		SetData( uniform,value,Type.Vec4f )
	End

	Method GetColor:Color( uniform:String )
		Local value:=GetData<Color>( uniform,Type.Vec4f )
		If _linearColors
			value.r=Pow(value.r,1.0/2.2 )
			value.g=Pow(value.g,1.0/2.2 )
			value.b=Pow(value.b,1.0/2.2 )
		Endif
		Return value
	End
	
	'***** Mat3f *****
	'
	Method SetMat3f( uniform:String,value:Mat3f )
		SetData( uniform,value,Type.Mat3f )
	End

	Method GetMat3f:Mat3f( uniform:String )
		Return GetData<Mat3f>( uniform,Type.Mat3f )
	End
	
	Method GetMat3fv:Float Ptr( id:Int )
		Return GetFloatPtr( id,Type.Mat3f )
	End
	
	'***** AffineMat3f *****
	'
	Method SetAffineMat3f( uniform:String,value:AffineMat3f )
		Local m:=New Mat3f( value.i.x,value.i.y,0, value.j.x,value.j.y,0, value.t.x,value.t.y,1 )
		SetData( uniform,m,Type.Mat3f )
	End
	
	Method GetAffineMat3f:AffineMat3f( uniform:String )
		Local m:=GetData<Mat3f>( uniform,Type.Mat3f )
		Return New AffineMat3f( m.i.x,m.i.y,m.j.x,m.j.y,m.k.x,m.k.y )
	End
	
	'***** Mat4f *****
	'
	Method SetMat4f( uniform:String,value:Mat4f )
		SetData( uniform,value,Type.Mat4f )
	End

	Method SetMat4f( uniform:String,value:AffineMat4f )
		SetData( uniform,New Mat4f( value ),Type.Mat4f )
	End

	Method GetMat4f:Mat4f( uniform:String )
		Return GetData<Mat4f>( uniform,Type.Mat4f )
	End
	
	Method GetMat4fv:Float Ptr( id:Int )
		If _uniforms[id].type=Type.Mat4fArray Return Varptr _uniforms[id].arrayData[0].i.x
		Return GetFloatPtr( id,Type.Mat4f )
	End

	'***** Mat4f array *****
	'
	Method SetMat4fArray( uniform:String,value:Mat4f[] )
		Local id:=GetUniformId( uniform )
		_uniforms[id].arrayData=value
		_uniforms[id].type=Type.Mat4fArray
		_seq=_gseq
		_gseq+=1
	End
	
	Method GetMat4fArray:Mat4f[]( uniform:String )
		Local id:=GetUniformId( uniform )
		DebugAssert( _uniforms[id].type=Type.Mat4fArray,"Invalidate uniform type" )
		Return _uniforms[id].arrayData
	End

	Method GetMat4fArray:Mat4f[]( id:Int )
		DebugAssert( _uniforms[id].type=Type.Mat4fArray,"Invalidate uniform type" )
		Return _uniforms[id].arrayData
	End

	'***** Texture *****
	'
	Method SetTexture( uniform:String,value:Texture )
		Local id:=GetUniformId( uniform )
		_uniforms[id].texture=value
		_uniforms[id].type=Type.Texture
		_seq=_gseq
		_gseq+=1
	End

	Method GetTexture:Texture( uniform:String )
		Local id:=GetUniformId( uniform )
		DebugAssert( _uniforms[id].type=Type.Texture,"Invalid uniform type" )
		Return _uniforms[id].texture
	End
	
	Method GetTexture:Texture( id:Int )
		DebugAssert( _uniforms[id].type=Type.Texture,"Invalid uniform type" )
		Return _uniforms[id].texture
	End
	
	#rem monkeydoc @hidden
	#end	
	Property Seq:Int()
		Return _seq
	End
	
	Protected
	
	#rem monkeydoc @hidden
	#end	
	Method OnDiscard() Override
		
		_uniforms=Null
	End
	
	Private
	
	Global _gseq:Int=1
	Global _ids:=New StringMap<Int>[8]
	
	Enum Type
		None=0
		Scalar=1
		Vec2f=2
		Vec3f=3
		Vec4f=4
		Mat3f=5
		Mat4f=6
		Texture=7
		Mat4fArray=8
		Integer=9
	End
	
	Struct Uniform
		Field type:Type
		Field texture:Texture
		Field arrayData:Mat4f[]
		Field floatData:Mat4f
	End

	Field _name:Int
	Field _seq:Int
	Field _linearColors:bool
	Field _uniforms:=New Uniform[64]
	
	Method SetData<T>( uniform:String,data:T,type:Type )
		Local id:=GetUniformId( uniform )
		Cast<T Ptr>( Varptr _uniforms[id].floatData )[0]=data
		_uniforms[id].type=type
		_seq=_gseq
		_gseq+=1
	End
	
	Method GetData<T>:T( uniform:String,type:Type )
		Local id:=GetUniformId( uniform )
		DebugAssert( _uniforms[id].type=type,"Invalid uniform type" )
		Return Cast<T Ptr>( Varptr _uniforms[id].floatData )[0]
	End

	Method GetDataPtr<T>:T Ptr( uniform:String,type:Type )
		Local id:=GetUniformId( uniform )
		DebugAssert( _uniforms[id].type=type,"Invalid uniform type" )
		Return Cast<T Ptr>( Varptr _uniforms[id].floatData )
	End
	
	Method GetFloatPtr:Float Ptr( id:Int,type:Type )
		DebugAssert( _uniforms[id].type=type,"Invalid uniform type "+Int(_uniforms[id].type)+" expecting "+Int(type) )
		Return Cast<Float Ptr>( Varptr _uniforms[id].floatData )
	End
	
End
