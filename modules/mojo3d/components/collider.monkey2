
Namespace mojo3d

#Import "native/internaledges.cpp"
#Import "native/internaledges.h"

Extern Private
 
Function CreateInternalEdgeInfo( mesh:btBvhTriangleMeshShape )="bbBullet::createInternalEdgeInfo"
	
Public
	
Class Entity Extension
	
	Property Collider:Collider()
		
		Return Cast<Collider>( GetComponent( Collider.Type ) )
	End
	
End

Class Collider Extends Component
	
	Const Type:=New ComponentType( "Collider",10,ComponentTypeFlags.Singleton )
	
	Method New( entity:Entity )
		
		Super.New( entity,Type )
	End
	
	Property Margin:Float()
		
		Return Validate().getMargin()
	
	Setter( margin:Float )
		
		Validate().setMargin( margin )
	End

	Method CalculateLocalInertia:Vec3f( mass:Float )
		
		Return Validate().calculateLocalInertia( mass )
	End
	
	Method Validate:btCollisionShape()

		If Not _btshape _btshape=OnCreate()
	
		Return _btshape
	End
	
Protected

	Method OnCreate:btCollisionShape() Abstract
	
	Method Invalidate()
		
		If Not _btshape Return
		
		_btshape.destroy()
		
		_btshape=Null
		
		Entity.RigidBody?.ColliderInvalidated()
	End
	
	function SetOrigin:btCollisionShape( shape:btCollisionShape,origin:Vec3f )
		
		If origin=Null Return shape
		
		Local tshape:=New btCompoundShape( False,1 )
		
		tshape.addChildShape( AffineMat4f.Translation( origin ),shape )
		
		Return tshape
	End
	
	Private
	
	Field _btshape:btCollisionShape
	
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
		_vertices=New btScalar[vertices.Length*3]
		
		For Local i:=0 Until vertices.Length
			_vertices[i*3]=vertices[i].position.x
			_vertices[i*3+1]=vertices[i].position.y
			_vertices[i*3+2]=vertices[i].position.z
		Next
		
		Local indices:=_mesh.GetAllIndices()
		_indices=New Int[indices.Length]
		
		For Local i:=0 Until indices.Length Step 3
			_indices[i+0]=indices[1]
			_indices[i+1]=indices[i+1]
			_indices[i+2]=indices[i+2]
		Next
		
		_btmesh=New btTriangleIndexVertexArray( _indices.Length/3,_indices.Data,12,_vertices.Length,_vertices.Data,12 )
		
		Local shape:=New btBvhTriangleMeshShape( _btmesh,True,True )
		
'		CreateInternalEdgeInfo( shape )
		
		Return shape
	End
	
	Private
	
	Field _mesh:Mesh
	Field _vertices:btScalar[]
	'Field _vertices:btVector3[]
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
