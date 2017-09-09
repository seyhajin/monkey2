
Namespace mojo3d.graphics

#rem monkeydoc The Entity class.
#end
Class Entity Extends DynamicObject
	
	#rem monkeydoc Copied signal.
	
	Invoked after an entity is copied.
	
	#end
	Field Copied:Void( copy:Entity )

	#rem monkeydoc Destroyed signal.
	
	Invoked after an entity is destroyed.
	
	#end
	Field Destroyed:Void()
	
	#rem monkeydoc Hidden signal.
	
	Invoked after an entity is hidden.
	
	#end
	Field Hidden:Void()
	
	#rem monkeydoc Shown signal.
	
	Invoked after an entity is shown.
	
	#end
	Field Shown:Void()
	
	#rem monkeydoc Creates a new entity.
	#end
	Method New( parent:Entity=Null )
		
		_parent=parent
		
		If _parent 
			_scene=_parent._scene
			
			_parent._children.Add( Self )
		Else
			_scene=Scene.GetCurrent()
			
			_scene.RootEntities.Add( Self )
		Endif
			
		Invalidate()
	End
	
	#rem monkeydoc Creates a copy of the entity.
	#end
	Method Copy:Entity( parent:Entity=Null ) Virtual
		
		Local copy:=New Entity( Self,parent )

		CopyComplete( copy )
		
		Return copy
	End
	
	#rem monkeydoc @hidden
	#end
	Property Seq:Int()
		
		Return _seq
	End
	
	#rem monkeydoc Entity name.
	#end
	Property Name:String()
		
		Return _name
	
	Setter( name:String )
		
		_name=name
	End

	#rem monkeydoc @hidden
	#end
	Property Scene:Scene()
	
		Return _scene
	End
	
	#rem monkeydoc Parent entity.
	#end
	Property Parent:Entity()
		
		Return _parent
	
	Setter( parent:Entity )
		
		Assert( Not parent Or parent._scene=_scene )
		
		If _parent
			_parent._children.Remove( Self )
		Else
			_scene.RootEntities.Remove( Self )
		Endif
		
		_parent=parent
		
		If _parent 
			_parent._children.Add( Self )
		Else
			_scene.RootEntities.Add( Self )
		Endif
			
		Invalidate()
	End
	
	#rem monkeydoc Number of child entities.
	#end
	Property NumChildren:Int()
		
		Return _children.Length
	End
	
	#rem monkeydoc Array of child entities.
	#end
	Property Children:Entity[]()
		
		Return _children.ToArray()
	End

	#rem monkeydoc Visibility flag.
	#end
	Property Visible:Bool()
		
		Return _visible
	
	Setter( visible:Bool )
		
		If visible Show() Else Hide()
	End

	#rem monkeydoc Entity animator.
	#end	
	Property Animator:Animator()
		
		Return _animator
	
	Setter( animator:Animator )
		
		_animator=animator
	End
	
	'***** World space properties *****
	
	#rem monkeydoc World space transformation matrix.
	
	The world matrix combines the world position, basis matrix and scale of the entity into a single affine 4x4 matrix.
	
	#end
	Property Matrix:AffineMat4f()
		
		If _dirty & Dirty.W
			_W=_parent ? _parent.Matrix * LocalMatrix Else LocalMatrix
			_dirty&=~Dirty.W
		Endif
		
		Return _W
	End
	
	#rem monkeydoc Inverse world space transformation matrix.
	#end
	Property InverseMatrix:AffineMat4f()
		
		If _dirty & Dirty.IW
			_IW=-Matrix
			_dirty&=~Dirty.IW
		Endif
		
		Return _IW
	End
	
	#rem monkeydoc World space position.
	#end
	Property Position:Vec3f()
		
		Return Matrix.t
		
	Setter( position:Vec3f )
		
		_t=_parent ? _parent.InverseMatrix * position Else position
		
		Invalidate()
	End
	
	#rem monkeydoc World space basis matrix.

	A basis matrix is a 3x3 matrix representation of an orientation.
	
	A basis matrix is orthogonal (ie: the i,j,k members are perpendicular to each other) and normalized (ie: the i,j,k members all have unit length).
	
	#end
	Property Basis:Mat3f()
		
		Return _parent ? _parent.Basis * _r Else _r
	
	Setter( basis:Mat3f )
		
		_r=_parent ? ~_parent.Basis * basis Else basis
		
		Invalidate()
	End
	
	#rem monkeydoc World space scale.
	#end	
	Property Scale:Vec3f()
		
		Return _parent ? _s * _parent.Scale Else _s
	
	Setter( scale:Vec3f )
		
		_s=_parent ? scale / _parent.Scale Else scale
		
		Invalidate()
	End
	
	'***** Local space properties *****

	#rem monkeydoc Local space transformation matrix.
	
	The local matrix combines the local position, orientation and scale of the entity into a single affine 4x4 matrix.
	
	#end
	Property LocalMatrix:AffineMat4f()
		
		If _dirty & Dirty.M
			_M=New AffineMat4f( _r.Scale( _s ),_t )
			_dirty&=~Dirty.M
		Endif
		
		Return _M
	End

	#rem monkeydoc Local space position.
	#end
	Property LocalPosition:Vec3f()

		Return _t
		
	Setter( position:Vec3f )
		
		_t=position
		
		Invalidate()
	End
	
	#rem monkeydoc Local space basis matrix.
	
	A basis matrix is a 3x3 matrix representation of an orientation.

	A basis matrix is orthogonal (ie: the i,j,k members are perpendicular to each other) and normalized (ie: the i,j,k members all have unit length).
	
	#end
	Property LocalBasis:Mat3f()
		
		Return _r
	
	Setter( basis:Mat3f )
		
		_r=basis
		
		Invalidate()
	End

	#rem monkeydoc Local space scale.
	#end	
	Property LocalScale:Vec3f()
		
		Return _s
	
	Setter( scale:Vec3f )
		
		_s=scale
		
		Invalidate()
	End
	
	#rem monkeydoc Hides the entity and all of its children
	#end
	Method Hide()
		
		If _visible
			_visible=False
			OnHide()
		Endif
		
		For Local child:=Eachin _children
			child.Hide()
		Next
	End
	
	#rem monkeydoc Shows the entity and all of its children
	#end
	Method Show()
		
		If Not _visible
			_visible=True
			OnShow()
		Endif

		For Local child:=Eachin _children
			child.Show()
		Next
	End
	
	#rem monkeydoc Destroys the entity and all of its children.
	#end
	Method Destroy()
		
		While Not _children.Empty
			_children.Top.Destroy()
		Wend
		
		If _visible
			_visible=False
			 OnHide()
		Endif

		If _parent
			_parent._children.Remove( Self )
		Else
			_scene.RootEntities.Remove( Self )
		Endif
		
		_parent=Null
		_scene=Null
		
		Destroyed()
	End
	
Protected

	#rem monkeydoc @hidden
	#end
	Method New( entity:Entity,parent:Entity )
		Self.New( parent )
		
		_t=entity._t
		_r=entity._r
		_s=entity._s
		
		Invalidate()
	End
	
	#rem monkeydoc @hidden
	#end
	Method OnShow() Virtual
	End
	
	#rem monkeydoc @hidden
	#end
	Method OnHide() Virtual
	End
		
	#rem monkeydoc @hidden
	#end
	Method CopyComplete( copy:Entity )
	
		For Local child:=Eachin _children
			child.Copy( copy )
		Next

		Copied( copy )
	End

Private
	
	Enum Dirty
		M=1
		W=2
		IW=4
		All=7
	End
	
	Field _name:String
	Field _scene:Scene
	Field _parent:Entity
	Field _children:=New Stack<Entity>
	Field _visible:Bool
	Field _animator:Animator
	
	Field _t:Vec3f=New Vec3f
	Field _r:Mat3f=New Mat3f
	Field _s:Vec3f=New Vec3f(1)
	Field _seq:Int=1
	
	Field _dirty:Dirty=Dirty.All
	Field _M:AffineMat4f
	Field _W:AffineMat4f
	Field _IW:AffineMat4f
	
	Method InvalidateWorld()
		
		If _dirty & _dirty.W Return
		
		_dirty|=Dirty.W|Dirty.IW
		
		For Local child:=Eachin _children
			
			child.InvalidateWorld()
		Next
		
		_seq+=1
	End
		
	Method Invalidate()
		
		_dirty|=Dirty.M
		
		InvalidateWorld()
	End

End
