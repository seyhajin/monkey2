
Namespace mojo3d

Class Entity Extension
	
	Property Collider:Collider()
		
		Return GetComponent<Collider>()
	End
	
End

Class Collider Extends Component
	
	Const Type:=New ComponentType( "Collider",-1,ComponentTypeFlags.Singleton )
	
	Method New( entity:Entity )
		
		Super.New( entity,Type )
	End
	
	Property Margin:Float()
		
		Return btShape.getMargin()
	
	Setter( margin:Float )
		
		btShape.setMargin( margin )
	End

	Method CalculateLocalInertia:Vec3f( mass:Float )
		
		Return btShape.calculateLocalInertia( mass )
	End

	Property btShape:btCollisionShape()
		
		If Not _btshape _btshape=OnCreate()
	
		Return _btshape
	End
	
	Property Seq:Int()
		
		Return _seq
	End

Protected

	Method OnCreate:btCollisionShape() Abstract
	
	Method Invalidate()
		
		If Not _btshape Return
		
		_btshape.destroy()
		_btshape=Null
		
		_gseq+=1
		_seq=_gseq
	End

	function SetOrigin:btCollisionShape( shape:btCollisionShape,origin:Vec3f )
		
		If origin=Null Return shape
		
		Local tshape:=New btCompoundShape( False,1 )
		
		tshape.addChildShape( AffineMat4f.Translation( origin ),shape )
		
		Return tshape
	End
	
	Private
	
	Global _gseq:Int

	Field _btshape:btCollisionShape
	
	Field _seq:Int
	
End

Class ConvexCollider Extends Collider
	
	Method New( Entity:Entity )
		Super.New( Entity )
	End
	
End

Class BoxCollider Extends ConvexCollider
	
	Method New( Entity:Entity )
		Super.New( Entity )
		
		Box=New Boxf( -1,1 )
	End
	
	Property Box:Boxf()
		
		Return _box
	
	Setter( box:Boxf )
		
		_box=box
		
		Invalidate()
	End
	
	Protected
	
	Method OnCopy:BoxCollider( entity:Entity ) Override
		
		Local collider:=New BoxCollider( entity )
		
		collider.Box=Box
		
		Return collider
	End
	
	Method OnCreate:btCollisionShape() Override
		
		Local shape:=New btBoxShape( _box.Size/2 )
		
		Return SetOrigin( shape,_box.Center )
	End
	
	Private
	
	Field _box:=New Boxf( -1,1 )
End

Class SphereCollider Extends ConvexCollider
	
	Method New( Entity:Entity )
		Super.New( Entity )
	End
	
	Property Radius:Float()
		
		Return _radius
	
	Setter( radius:Float )
		
		_radius=radius
		
		Invalidate()
	End
	
	Property Origin:Vec3f()
		
		Return _origin
		
	Setter( origin:Vec3f )
		
		_origin=origin
		
		Invalidate()
	End
	
	Protected
	
	Method OnCopy:SphereCollider( entity:Entity ) Override
		
		Local collider:=New SphereCollider( entity )
		
		collider.Radius=Radius
		collider.Origin=Origin
		
		Return collider
	End
	
	Method OnCreate:btCollisionShape() Override
		
		Local shape:=New btSphereShape( _radius )
		
		return SetOrigin( shape,_origin )
	End
	
	Private
	
	Field _radius:Float=1
	
	Field _origin:Vec3f
	
End

Class CylinderCollider Extends ConvexCollider
	
	Method New( entity:Entity )
		Super.New( entity )
	End
	
	Property Radius:Float()
		
		Return _radius
		
	Setter( radius:Float )
		
		_radius=radius
		
		Invalidate()
	End
	
	Property Length:Float()
		
		Return _length
		
	Setter( length:Float )
		
		_length=length
		
		Invalidate()
	End
	
	Property Axis:Axis()
		
		Return _axis
		
	Setter( axis:Axis )
		
		_axis=axis
		
		Invalidate()
	End
	
	Property Origin:Vec3f()
		
		Return _origin
	
	Setter( origin:Vec3f )
		
		_origin=origin
		
		Invalidate()
	End

	Protected

	Method OnCopy:CylinderCollider( entity:Entity ) Override
		
		Local collider:=New CylinderCollider( entity )
		
		collider.Radius=Radius
		collider.Length=Length
		collider.Axis=Axis
		collider.Origin=Origin
		
		Return collider
	End
	
	Method OnCreate:btCollisionShape() Override

		Local shape:btCollisionShape
		
		Select _axis
		case Axis.X
			shape=New btCylinderShapeX( New btVector3( _length/2,_radius,_radius ) )
		Case Axis.Y
			shape=New btCylinderShape ( New btVector3( _radius,_length/2,_radius ) )
		case Axis.Z
			shape=New btCylinderShapeZ( New btVector3( _radius,_radius,_length/2 ) )
		Default
			RuntimeError( "Invalid Cylinder Axis" )
		End
		
		Return SetOrigin( shape,_origin )
	End
	
	Private
	
	Field _radius:Float=0.5
	Field _length:Float=1.0
	Field _axis:Axis=geom.Axis.Y
	Field _origin:Vec3f

End

Class CapsuleCollider Extends ConvexCollider
	
	Method New( entity:Entity )
		Super.New( entity )
	End
	
	Property Radius:Float()
		
		Return _radius
		
	Setter( radius:Float )
		
		_radius=radius
		
		Invalidate()
	End
	
	Property Length:Float()
		
		Return _length
		
	Setter( length:Float )
		
		_length=length
		
		Invalidate()
	End
	
	Property Axis:Axis()
		
		Return _axis
		
	Setter( axis:Axis )
		
		_axis=axis
		
		Invalidate()
	End
	
	Property Origin:Vec3f()
		
		Return _origin
	
	Setter( origin:Vec3f )
		
		_origin=origin
		
		Invalidate()
	End

	Protected
	
	Method OnCopy:CapsuleCollider( entity:Entity ) Override
		
		Local collider:=New CapsuleCollider( entity )
		
		collider.Radius=Radius
		collider.Length=Length
		collider.Axis=Axis
		collider.Origin=Origin
		
		Return collider
	End
	
	Method OnCreate:btCollisionShape() Override
		
		Local shape:btCollisionShape
		
		Select _axis
		Case Axis.X
			shape=New btCapsuleShapeX( _radius,_length )
		Case Axis.Y
			shape=New btCapsuleShape ( _radius,_length )
		Case Axis.Z
			shape=New btCapsuleShapeZ( _radius,_length )
		Default
			RuntimeError( "Invalid Capsule Axis" )
		End
		
		Return SetOrigin( shape,_origin )
	End
	
	Private
	
	Field _radius:Float=0.5
	Field _length:Float=1.0
	Field _axis:Axis=geom.Axis.Y
	Field _origin:Vec3f

End

Class ConeCollider Extends ConvexCollider
	
	Method New( entity:Entity )
		Super.New( entity )
	End
	
	Property Radius:Float()
		
		Return _radius
		
	Setter( radius:Float )
		
		_radius=radius
		
		Invalidate()
	End
	
	Property Length:Float()
		
		Return _length
		
	Setter( length:Float )
		
		_length=length
		
		Invalidate()
	End
	
	Property Axis:Axis()
		
		Return _axis
		
	Setter( axis:Axis )
		
		_axis=axis
		
		Invalidate()
	End
	
	Property Origin:Vec3f()
		
		Return _origin
	
	Setter( origin:Vec3f )
		
		_origin=origin
		
		Invalidate()
	End

	Protected
	
	Method OnCopy:ConeCollider( entity:Entity ) Override
		
		Local collider:=New ConeCollider( entity )
		
		collider.Radius=Radius
		collider.Length=Length
		collider.Axis=Axis
		collider.Origin=Origin
		
		Return collider
	End
	
	Method OnCreate:btCollisionShape() Override
		
		Local shape:btCollisionShape
		
		Select _axis
		Case Axis.X
			shape=New btConeShapeX( _radius,_length )
		Case Axis.Y
			shape=New btConeShape ( _radius,_length )
		Case Axis.Z
			shape=New btConeShapeZ( _radius,_length )
		Default
			RuntimeError( "Invalid Cone Axis" )
		End

		Return SetOrigin( shape,_origin )
	End
	
	Private
	
	Field _radius:Float=0.5
	Field _length:Float=1.0
	Field _axis:Axis=geom.Axis.Y
	Field _origin:Vec3f
	
End

Class ConcaveCollider Extends Collider

	Method New( entity:Entity )
		Super.New( entity )
	End
	
End

Class MeshCollider Extends ConcaveCollider
	
	Method New( entity:Entity )
		Super.New( entity )
	End
	
	Property Mesh:Mesh()
		
		Return _mesh
	
	Setter( mesh:Mesh ) 
		
		_mesh=mesh
		
		Invalidate()
	End

	Protected
	
	Method OnCopy:MeshCollider( entity:Entity ) Override
		
		Local collider:=New MeshCollider( entity )
		
		collider.Mesh=Mesh
		
		Return collider
	End
	
	Method OnCreate:btCollisionShape() Override
		
		Local vertices:=_mesh.GetVertices()
		_vertices=New btVector3[vertices.Length]
		
		For Local i:=0 Until vertices.Length
			_vertices[i].x=vertices[i].position.x
			_vertices[i].y=vertices[i].position.y
			_vertices[i].z=vertices[i].position.z
		Next
		
		Local indices:=_mesh.GetAllIndices()
		_indices=New Int[indices.Length]
		For Local i:=0 Until indices.Length
			_indices[i]=indices[i]
		Next
		
		_btmesh=New btTriangleIndexVertexArray( _indices.Length/3,_indices.Data,12,_vertices.Length,Cast<btScalar Ptr>( _vertices.Data ),16 )
		
		Local shape:=New btBvhTriangleMeshShape( _btmesh,True,True )
		
		'CreateInternalEdgeInfo( shape )
		
		Return shape
	End
	
	Private
	
	Field _mesh:Mesh
	Field _vertices:btVector3[]
	Field _indices:Int[]
	Field _btmesh:btTriangleIndexVertexArray
	
End

#rem
Class TerrainCollider Extends ConcaveCollider

	Method New( box:Boxf,data:Pixmap )
	
		Local shape:=New btHeightfieldTerrainShape( data.Width,data.Height,data.Data,1.0/255.0,0.0,1.0,1,PHY_UCHAR,False )
		
		shape.setUseDiamondSubdivision( True )
		
		_btshape=shape
		
		_btshape.setLocalScaling( New Vec3f( box.Width/data.Width,box.Height,box.Depth/data.Height ) )
		
		SetOrigin( box.Center )
	End

End
#end
