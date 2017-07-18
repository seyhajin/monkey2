
Namespace mojo3d.physics

#Import "native/internaledges.cpp"
#Import "native/internaledges.h"

Extern

Function CreateInternalEdgeInfo( mesh:btBvhTriangleMeshShape )="bbBullet::createInternalEdgeInfo"
	
Public

Class Collider
	
	Property Margin:Float()
		
		Return _btshape.getMargin()
	
	Setter( margin:Float )
		
		_btshape.setMargin( margin )
	End

	Property btShape:btCollisionShape()
	
		Return _btshape
	End

Protected

	Field _btshape:btCollisionShape
	
	Method SetOrigin( origin:Vec3f )
		
		If origin=Null Return
		
		Local shape:=New btCompoundShape( False,1 )
		
		shape.addChildShape( AffineMat4f.Translation( origin ),_btshape )
		
		_btshape=shape
	End
	
End

Class ConvexCollider Extends Collider
	
End

Class BoxCollider Extends ConvexCollider
	
	Method New( box:Boxf )
	
		_btshape=New btBoxShape( box.Size/2 )
		
		SetOrigin( box.Center )
	End
	
End

Class SphereCollider Extends ConvexCollider
	
	Method New( radius:Float,origin:Vec3f=Null )
		
		_btshape=New btSphereShape( radius )
		
		SetOrigin( origin )
	End
	
End

Class CylinderCollider Extends ConvexCollider
	
	Method New( radius:Float,length:Float,axis:Axis,origin:Vec3f=Null )
		
		Select axis
		case Axis.X
			_btshape=New btCylinderShapeX( New btVector3( length/2,radius,radius ) )
		Case Axis.Y
			_btshape=New btCylinderShape ( New btVector3( radius,length/2,radius ) )
		case Axis.Z
			_btshape=New btCylinderShapeZ( New btVector3( radius,radius,length/2 ) )
		Default
			RuntimeError( "Invalid Cylinder Axis" )
		End
		
		SetOrigin( origin )
	End

End

Class CapsuleCollider Extends ConvexCollider
	
	Method New( radius:Float,length:Float,axis:Axis,origin:Vec3f=Null )
		
		Select axis
		Case Axis.X
			_btshape=New btCapsuleShapeX( radius,length )
		Case Axis.Y
			_btshape=New btCapsuleShape ( radius,length )
		Case Axis.Z
			_btshape=New btCapsuleShapeZ( radius,length )
		Default
			RuntimeError( "Invalid Capsule Axis" )
		End
		
		SetOrigin( origin )
	End
	
End

Class ConeCollider Extends ConvexCollider
	
	Method New( radius:Float,length:Float,axis:Axis,origin:Vec3f=Null )
		
		Select axis
		Case Axis.X
			_btshape=New btConeShapeX( radius,length )
		Case Axis.Y
			_btshape=New btConeShape ( radius,length )
		Case Axis.Z
			_btshape=New btConeShapeZ( radius,length )
		Default
			RuntimeError( "Invalid Cone Axis" )
		End
		
		SetOrigin( origin )
	End

End

Class ConcaveCollider Extends Collider
End

Class MeshCollider Extends ConcaveCollider

	Method New( mesh:Mesh )
	
		Local vertices:=mesh.GetVertices()
		_vertices=New btVector3[vertices.Length]
		
		For Local i:=0 Until vertices.Length
			_vertices[i].x=vertices[i].position.x
			_vertices[i].y=vertices[i].position.y
			_vertices[i].z=vertices[i].position.z
		Next
		
		Local indices:=mesh.GetAllIndices()
		_indices=New Int[indices.Length]
		For Local i:=0 Until indices.Length
			_indices[i]=indices[i]
		Next
		
		_btmesh=New btTriangleIndexVertexArray( _indices.Length/3,_indices.Data,12,_vertices.Length,Cast<btScalar Ptr>( _vertices.Data ),16 )
		
		Local shape:=New btBvhTriangleMeshShape( _btmesh,True,True )
		
		CreateInternalEdgeInfo( shape )
		
		_btshape=shape
	End
	
	Private
	
	Field _vertices:btVector3[]
	Field _indices:Int[]
	
	Field _btmesh:btTriangleIndexVertexArray
	
End

Class TerrainCollider Extends ConcaveCollider

	Method New( box:Boxf,data:Pixmap )
	
		Local shape:=New btHeightfieldTerrainShape( data.Width,data.Height,data.Data,1.0/255.0,0.0,1.0,1,PHY_UCHAR,False )
		
		shape.setUseDiamondSubdivision( True )
		
		_btshape=shape
		
		_btshape.setLocalScaling( New Vec3f( box.Width/data.Width,box.Height,box.Depth/data.Height ) )
		
		SetOrigin( box.Center )
	End

End
