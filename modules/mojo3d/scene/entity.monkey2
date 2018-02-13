
Namespace mojo3d

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
	
	#rem monkeydoc Collided signal.
	
	After after an entity has collided with a rigidbody.
	
	#end
	Field Collided:Void( rigidBody:RigidBody )
	
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
		
		CopyTo( copy )
		
		return copy
	End
	
	#rem monkeydoc Sequence id.
	
	The sequence id is an integer that is incremented whenever the entity's matrix is modified.
	
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
		
		Local matrix:AffineMat4f=parent ? LocalMatrix Else Matrix
		
		If _parent
			_parent._children.Remove( Self )
		Else
			matrix=Matrix
			_scene.RootEntities.Remove( Self )
		Endif
		
		_parent=parent
		
		If _parent 
			_parent._children.Add( Self )
			LocalMatrix=matrix
		Else
			_scene.RootEntities.Add( Self )
			Matrix=matrix
		Endif
		
		UpdateVisibility()
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
		
		If visible=_visible Return
		
		_visible=visible
		
		UpdateVisibility()
	End
	
	#rem monkeydoc True if entity and all parents are visible.
	#end
	Property ReallyVisible:Bool()
		
		Return _rvisible
	End

	#rem monkeydoc Last copy.
	#end
	Property LastCopy:Entity()
		
		Return _lastCopy
	End
	
	#rem monkeydoc Master color.
	#end
	Property Color:Color()
		
		Return _color
		
	Setter( color:Color )
			
		_color=color
	End
	
	#rem monkeydoc Master alpha.
	#end
	Property Alpha:Float()
		
		Return _alpha
		
	Setter( alpha:Float )
		
		_alpha=alpha
	End
	
	'***** World space properties *****
	
	#rem monkeydoc World space transformation matrix.
	
	The world matrix combines the world position, basis matrix and scale of the entity into a single affine 3x4 matrix.
	
	#end
	Property Matrix:AffineMat4f()
		
		If _dirty & Dirty.W
			_W=_parent ? _parent.Matrix * LocalMatrix Else LocalMatrix
			_dirty&=~Dirty.W
		Endif
		
		Return _W
	
	Setter( matrix:AffineMat4f )
		
		Local scale:=matrix.m.GetScaling()
		
		Basis=matrix.m.Scale( 1/scale.x,1/scale.y,1/scale.z )
		Position=matrix.t
		Scale=scale
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
		
	Setter( matrix:AffineMat4f )
		
		Local scale:=matrix.m.GetScaling()
		
		LocalBasis=matrix.m.Scale( 1/scale.x,1/scale.y,1/scale.z )
		LocalPosition=matrix.t
		LocalScale=scale
		
		Invalidate()
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

	#rem monkeydoc Destroys the entity and all of its children.
	#end
	Method Destroy()
		
		While Not _children.Empty
			_children.Top.Destroy()
		Wend
		
		While Not _components.Empty
			_components.Top.Destroy()
		Wend

		_visible=False
		
		UpdateVisibility()
		
		If _parent
			_parent._children.Remove( Self )
		Else
			_scene.RootEntities.Remove( Self )
		Endif
		
		_parent=Null
		_scene=Null
		
		Destroyed()
	End

	#rem monkeydoc Gets the number of components of a given type attached to the entity.
	#end
	Method NumComponents:Int( type:ComponentType )
		
		Local n:=0
		For Local c:=Eachin _components
			If c.Type=type n+=1
		Next
		Return n
	End

	Method NumComponents<T>:Int() Where T Extends Component
		
		Return NumComponents( T.Type )
	End

	#rem monkeydoc Gets a component of a given type attached to the entity.
	
	If there is not exactly one component of the given type attached to the entity, null is returned.

	#end	
	Method GetComponent:Component( type:ComponentType )

		Local t:Component
				
		For Local c:=Eachin _components
			If c.Type<>type Continue
			If t Return Null
			t=c
		Next
		
		Return t
	End
	
	Method GetComponent<T>:T() Where T Extends Component
		
		Return Cast<T>( GetComponent( T.Type ) )
	End
	
	#rem monkeydoc Attaches a component to the entity.
	#end
	Method AddComponent<T>:T() Where T Extends Component
		
		Local c:=New T( Self )
		
		Return c
	End
	
	Protected

	#rem monkeydoc Copy constructor
	#end
	Method New( entity:Entity,parent:Entity )
		Self.New( parent )
		
		_t=entity._t
		_r=entity._r
		_s=entity._s
		
		Invalidate()
	End
	
	#rem monkeydoc Invoked when entity transitions from hidden->visible.
	#end
	Method OnShow() Virtual
	End
	
	#rem monkeydoc Invoked when entity transitions from visible->hidden.
	#end
	Method OnHide() Virtual
	End
	
	#rem monkeydoc Helper method for copying an entity.
	
	1) Recursively copies all child entities.
	
	2) Invokes OnCopy for each component attached to this entity.
	
	3) Copies visibility.
	
	4) Invokes Copied signal.
	
	#end
	Method CopyTo( copy:Entity )
		
		_lastCopy=copy
		
		For Local child:=Eachin _children
			child.Copy( copy )
		Next
		
		'should really be different pass...ie: ALL entities should be copied before ANY components?
		For Local c:=Eachin _components
			c.OnCopy( copy )
		Next
		
		copy.Visible=Visible
		
		copy.Alpha=Alpha
		
		Copied( copy )
	End
	
	Internal
	
	Method AddComponent( c:Component )
		
		Local type:=c.Type
			
		For Local i:=0 Until _components.Length
			
			If type.Flags & ComponentTypeFlags.Singleton And _components[i].Type=type
				RuntimeError( "Duplicate component" )
			Endif
			
			If type.Priority>_components[i].Type.Priority
				_components.Insert( i,c )
				Return
			Endif
		Next

		_components.Add( c )
	End
	
	Method RemoveComponent( c:Component )
		
		_components.Remove( c )
	End

	'bottom up
	Method BeginUpdate()

		For Local e:=Eachin _children
			e.BeginUpdate()
		Next
		
		For Local c:=Eachin _components
			c.OnBeginUpdate()
		Next
		
	End
	
	'top down
	Method Update( elapsed:Float )
		
		For Local c:=Eachin _components
			c.OnUpdate( elapsed )
		End
		
		For Local e:=Eachin _children
			e.Update( elapsed )
		Next
	End
	
	Method Collide( body:RigidBody )
		
		For Local c:=Eachin _components
			c.OnCollide( body )
		Next
		
		Collided( body )
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
	Field _components:=New Stack<Component>
	Field _lastCopy:Entity
	Field _rvisible:Bool
	Field _visible:Bool
	Field _color:Color=std.graphics.Color.White
	Field _alpha:Float=1
	
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
	
	Method UpdateVisibility()
		
		Local rvisible:=_visible And (Not _parent Or _parent._rvisible)
		
		If rvisible=_rvisible Return
		
		_rvisible=rvisible
		
		If _rvisible
			
			OnShow()
			
			For Local c:=Eachin _components
				
				c.OnShow()
			Next
		
		Else
			
			OnHide()
			
			For Local c:=Eachin _components
				
				c.OnHide()
			Next
		Endif
		
		For Local child:=Eachin _children
			
			child.UpdateVisibility()
		Next
	
	End
End
