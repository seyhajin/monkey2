
Namespace mojo.app

#rem monkeydoc The View class.
#end
Class View

	#rem monkeydoc Invoked when a view becomes visible and active.
	#end
	Field Activated:Void()

	#rem monkeydoc Invoked when a view is no longer visible or active.
	#end
	Field Deactivated:Void()

	Method New()
		
		If Not _themeSeq
			_themeSeq=1
			App.ThemeChanged+=Lambda()
				_themeSeq+=1
				If _themeSeq=$40000000 _themeSeq=1
			End
		Endif
		
		_style=New Style( App.Theme.DefaultStyle )
		
		_styleSeq=_themeSeq
		
		InvalidateStyle()
	End

	#rem monkeydoc View visibility state.
	#end
	Property Visible:Bool()
	
		Return _visible
	
	Setter( visible:Bool )
		If visible=_visible Return
	
		_visible=visible
		
		RequestRender()
		
		UpdateActive()
	End
	
	#rem monkeydoc View enabled state.
	#end
	Property Enabled:Bool()
	
		Return _enabled And (Not _parent Or _parent.Enabled)
	
	Setter( enabled:Bool )
		If enabled=_enabled Return
	
		_enabled=enabled
		
		InvalidateStyle()
		
		UpdateActive()
	End

	#rem monkeydoc View active state.
	
	A view is active it is visible, enabled, attached to a window and all its parents are also active.
	
	Events are only sent to active windows.
	
	#end	
	Property Active:Bool()
	
		Return _active
	End
	
	#rem monkeydoc Whether the view accepts key events.
	#end
	Property AcceptsKeyEvents:Bool()
	
		Return _acceptsKeyEvents
	
	Setter( acceptsKeyEvents:Bool )
	
		_acceptsKeyEvents=acceptsKeyEvents
	End
	
	#rem monkeydoc Whether the view accepts mouse events.
	#end
	Property AcceptsMouseEvents:Bool()
	
		Return _acceptsMouseEvents
	
	Setter( acceptsMouseEvents:Bool )
	
		_acceptsMouseEvents=acceptsMouseEvents
	End

'------------------------------------------------------------
'jl added
	#rem monkeydoc Whether the view accepts touch events.
	#end
	Property AcceptsTouchEvents:Bool()
		Return _acceptsTouchEvents
	Setter( acceptsTouchEvents:Bool )
		_acceptsTouchEvents = acceptsTouchEvents
	End
'------------------------------------------------------------	
	
	#rem monkeydoc View style.
	#end
	Property Style:Style()
	
		Return _style
		
	Setter( style:Style )
		If style=_style Return
	
		_style=style
		
		InvalidateStyle()
	End
	
	#rem monkeydoc View style state.
	#end
	Property StyleState:String()
	
		Return _styleState
	
	Setter( styleState:String )
		If styleState=_styleState Return

		_styleState=styleState
		
		InvalidateStyle()
	End
	
	#rem monkeydoc View render style.
	
	This is the style used to render the view, and is dependant on [[Style]] and [[StyleState]].
	
	#end
	Property RenderStyle:Style()
	
		ValidateStyle()
		
		Return _rstyle
	End
	
	#rem monkeydoc Layout mode.
	
	The following layout modes are supported
	
	| Layout mode		| Description
	|:------------------|:-----------
	| "fill"			| View is resized to fit its layout frame.
	| "float"			| View floats within its layout frame according to the view [[Gravity]].
	| "fill-x"			| View is resized on the x axis and floats on the y axis.
	| "fill-y"			| View is resized on the y axis and floats on the x axis.
	| "stretch"			| View is stretched non-uniformly to fit its layout frame.
	| "letterbox"		| View is uniformly stretched on both axii and centered within its layout frame.
	| "letterbox-int"	| View is uniformly stretched on both axii and centered within its layout frame. Scale factors are integrized.

	#end
	Property Layout:String()

		Return _layout

	Setter( layout:String )
		If layout=_layout Return

		_layout=layout
	End

	#rem monkeydoc View frame rect.
	
	The 'frame' the view is contained in.
	
	Note that the frame rect is in parent space coordinates, and is usually set by the parent view when layout occurs.
	
	#end	
	Property Frame:Recti()
	
		Return _frame
	
	Setter( frame:Recti )
	
		_frame=frame
	End
	
	#rem monkeydoc Gravity for floating views.
	
	#end
	Property Gravity:Vec2f()

		Return _gravity

	Setter( gravity:Vec2f )
		If gravity=_gravity Return

		_gravity=gravity
	End

	#rem monkeydoc @hidden
	#end	
	Property Offset:Vec2i()
	
		Return _offset
		
	Setter( offset:Vec2i )
		If offset=_offset Return
			
		_offset=offset
	End
	
	#rem monkeydoc Minimum view size.
	#end
	Property MinSize:Vec2i()
	
		Return _minSize
	
	Setter( minSize:Vec2i )
	
		_minSize=minSize
	End
	
	#rem monkeydoc Maximum view size.
	#end
	Property MaxSize:Vec2i()
	
		Return _maxSize
	
	Setter( maxSize:Vec2i )
	
		_maxSize=maxSize
	End
	
	#rem monkeydoc View content rect.
	
	The content rect represents the rendering area of the view.
	
	The content rect is in view local coordinates and its origin is always (0,0).
	
	#end
	Property Rect:Recti()
	
		Return _rect
	End
	
	#rem monkeydoc Width of the view content rect.
	#end
	Property Width:Int()

		Return _rect.Width
	End
	
	#rem monkeydoc Height of the view content rect.
	#end
	Property Height:Int()
	
		Return _rect.Height
	End
	
	#rem monkeydoc @hidden
	#end
	Property Bounds:Recti()
	
		Return _bounds
	End
	
	#rem monkeydoc Mouse location relative to the view.
	#end
	Property MouseLocation:Vec2i()

		Return TransformPointFromView( App.MouseLocation,Null )
	End
	
	#rem monkeydoc View clip rect.
	
	The clip rect represents the part of the content rect NOT obscured by an parent views.
	
	The clip rect is in view local coordinates.
	
	#end
	Property ClipRect:Recti()
	
		Return _clip
	End
	
	#rem monkeydoc @hidden
	#end
	Property RenderRect:Recti()
	
		Return _rclip
	End
	
	#rem monkeydoc @hidden
	#end
	Property RenderBounds:Recti()
	
		Return _rbounds
	End
	
	#rem monkeydoc @hidden
	#end
	Property LocalMatrix:AffineMat3f()
	
		Return _matrix
	End
	
	#rem monkeydoc @hidden
	#end
	Property RenderMatrix:AffineMat3f()
	
		Return _rmatrix
	End
	
	#rem monkeydoc The parent view of this view.
	#end
	Property Parent:View()
	
		Return _parent
	End
	
	#rem monkeydoc The Window this view is attached to, if any.
	#end
	Property Window:Window()
	
		Return _window
	End

'jl added
'------------------------------------------------------------	
	#rem monkeydoc @hidden
	#end
	Property Container:View() Virtual
		Return Self
	End


	#rem monkeydoc @hidden
	#end
	Method AddChild( view:View )
		If Not view Return
		
		Assert( Not view._parent )
		
		_children.Add( view )
		
		view._parent=Self
	End


	#rem monkeydoc @hidden
	#end
	Method RemoveChild( view:View )
		If Not view Return
		
		Assert( view._parent=Self )
		
		_children.Remove( view )
		
		view._parent=Null
	End


	#rem monkeydoc @hidden
	#end
	Method FindWindow:Window() Virtual
		If _parent Return _parent.FindWindow()
		
		Return Null
	End
'------------------------------------------------------------
	
	#rem monkeydoc Gets a style.
	
	This is a convenience method equivalent to App.Theme.GetStyle( name ).
	
	#end
	Method GetStyle:Style( name:String )
	
		Return App.Theme.GetStyle( name )
	End
	
	#rem monkeydoc Adds a child view to this view.
	
	AddChildView is normally used internally by 'layout' views. However you can also add a child view to any view directly by calling this method.
	
	If you use this method to add a child view to a view, it is your responsiblity to also manage the child view's frame using the [[Frame]] property.

	#end
	Method AddChildView( view:View )
	
		If Not view Return
		
		Assert( Not view._parent,"View already has a parent" )

		Assert( Not Cast<Window>( view ),"Windows cannot be child views" )
	
		view._parent=Self
		view.SetWindow( _window )
		_children.Add( view )
		
		RequestRender()
		
		view.UpdateActive()
	End
	
	#rem monkeydoc Removes a child view from this view.
	#end
	Method RemoveChildView( view:View )
	
		If Not view Return
		
		Assert( view._parent=Self,"View is not a child view" )

		view._parent=Null
		view.SetWindow( Null )
		_children.Remove( view )
		
		RequestRender()
		
		view.UpdateActive()
	End
	
	#rem monkeydoc @hidden
	#end
	Method FindViewAtWindowPoint:View( point:Vec2i )
	
		If Not _visible Return Null
		
		If Not _rbounds.Contains( point ) Return Null
		
		For Local i:=0 Until _children.Length
		
			Local child:=_children[_children.Length-i-1]

			Local view:=child.FindViewAtWindowPoint( point )
			If view Return view
		
		Next
		
		Return Self
	End
	
	#rem monkeydoc Transforms a point to another view.
	
	Transforms `point` in coordinates local to this view to coordinates local to `view`.
	
	@param point The point to transform.
	
	@param view View to transform point to.
	
	#end
	Method TransformPointToView:Vec2i( point:Vec2i,view:View )
	
		Local t:=_rmatrix * New Vec2f( point.x,point.y )
		
		If view t=-view._rmatrix * t
		
		Return New Vec2i( Round( t.x ),Round( t.y ) )
	End
	
	#rem monkeydoc Transforms a point from another view.
	
	Transforms `point` in coordinates local to 'view' to coordinates local to this view.
	
	@param point The point to transform.
	
	@param view View to transform point from.
	
	#end
	Method TransformPointFromView:Vec2i( point:Vec2i,view:View )
	
		Local t:=New Vec2f( point.x,point.y )
		
		If view t=view._matrix * t
		
		t=-_rmatrix * t
		
		Return New Vec2i( Round( t.x ),Round( t.y ) )
	End
	
	#rem monkeydoc Transforms a rect to another view.
	
	Transforms `rect` from coordinates local to this view to coordinates local to `view`.
	
	@param rect The rect to transform.

	@param view View to transform rect to.
	
	#end
	Method TransformRectToView:Recti( rect:Recti,view:View )
	
		Return New Recti( TransformPointToView( rect.min,view ),TransformPointToView( rect.max,view ) )
	End
	
	#rem monkeydoc Transforms a rect from another view.
	
	Transform `rect` from coordinates local to `view` to coordinates local to this view.
	
	@param rect The rect to transform.
	
	@param view The view to transform rect from.
	
	#end
	Method TransformRectFromView:Recti( rect:Recti,view:View )
	
		Return New Recti( TransformPointFromView( rect.min,view ),TransformPointFromView( rect.max,view ) )
	End
	
	#rem monkeydoc Transforms a point in window coordinates to view coordinates.

	Transforms `point` in window coordinates to coordinates local to this view.
	
	@param point The point to transform.
	
	@return The transformed point.
	
	#end
	Method TransformWindowPointToView:Vec2i( point:Vec2i )
	
		Local t:=-_rmatrix * New Vec2f( point.x,point.y )
		
		Return New Vec2i( Round( t.x ),Round( t.y ) )
	End
	
	#rem monkeydoc Makes this view the key view.
	
	The key view is the view that receives keyboard events.
	
	#end
	Method MakeKeyView()

		Local oldKeyView:=App.KeyView
		If oldKeyView=Self Return
		
		If Not Active Return
		
		App.KeyView=Self
		
		If oldKeyView oldKeyView.OnKeyViewChanged( oldKeyView,Self )
		
		OnKeyViewChanged( oldKeyView,Self )
	End
	
	#rem monkeydoc Sends a key event to the view.
	#end
	Method SendKeyEvent( event:KeyEvent )
	
		If _acceptsKeyEvents
		
			OnKeyEvent( event )
			
			If event.Eaten Return
		Endif
		
		If _parent _parent.SendKeyEvent( event )
	End
	
	#rem monkeydoc Sends a mouse event to the view.
	#end
	Method SendMouseEvent( event:MouseEvent )
	
		If _acceptsMouseEvents
		
			event=event.TransformToView( Self )
			
			OnMouseEvent( event )
		
			If event.Eaten Return
		Endif
		
		If _parent _parent.SendMouseEvent( event )
	End
	
	#rem monkeydoc Checks if the view is a child of another view.
	#end
	Method IsChildOf:Bool( view:View )
		
		If view=Self Return True
		
		If _parent Return _parent.IsChildOf( view )
		
		Return False
	End
	
	#rem monkeydoc @hidden
	#end
	Method RequestRender()
	
		App.RequestRender()
	End

	#rem monkeydoc @hidden
	#end
	Method InvalidateStyle()
	
		_styleSeq|=$40000000
		
		App.RequestRender()
	End
	
	#rem monkeydoc @hidden
	#end
	Method ValidateStyle()
	
		If _styleSeq=_themeSeq Return
		
		Local themeChanged:=(_styleSeq & $3fffffff<>_themeSeq)
		
		_styleSeq=_themeSeq
	
		_rstyle=_style
		
		If Enabled
			_rstyle=_style.GetState( _styleState )
		Else
			_rstyle=_style.GetState( "disabled" )
		Endif
		
		_styleBounds=_rstyle.Bounds
		
		If themeChanged OnThemeChanged()
		
		OnValidateStyle()
	End
	
	Method MeasureLayoutSize:Vec2i()
	
		Measure()
		
		Return _layoutSize
	End
	
	Protected
'------------------------------------------------------------
	'jl added
	field _shiftDown:bool = False
	field _altDown:bool = False
	field _controlDown:bool = False
	field _commandDown:bool = false
'------------------------------------------------------------
	
	#rem monkeydoc @hidden
	#end
	Method Measure()

'		If Not _visible Return
		
		For Local view:=Eachin _children
			view.Measure()
		Next
		
		ValidateStyle()
		
		Local size:=OnMeasure()
		
		Local scale:=App.Theme.Scale
		
		If _minSize.x size.x=Max( size.x,Int( _minSize.x*scale.x ) )
		If _minSize.y size.y=Max( size.y,Int( _minSize.y*scale.y ) )
		If _maxSize.x size.x=Min( size.x,Int( _maxSize.x*scale.x ) )
		If _maxSize.y size.y=Min( size.y,Int( _maxSize.y*scale.y ) )
		
		_measuredSize=size
		
		_layoutSize=size+_styleBounds.Size
	End
	
	#rem monkeydoc @hidden
	#end
	Method UpdateLayout()
	
		_rect=New Recti( 0,0,_measuredSize )
		
		_bounds=_rect+_styleBounds
		
		_matrix=New AffineMat3f
		
		If _parent _matrix=_matrix.Translate( _frame.min.x,_frame.min.y )
		
		_matrix=_matrix.Translate( _offset.x,_offset.y )
		
		Select _layout
		Case "fill","resize"
		
			_rect=New Recti( 0,0,_frame.Size-_styleBounds.Size )

			_bounds=_rect+_styleBounds
			
		Case "fill-x"
		
			_rect.max.x=_frame.Width-_styleBounds.Width
			
			_bounds.min.x=_rect.min.x+_styleBounds.min.x
			_bounds.max.x=_rect.max.x+_styleBounds.max.x
			
			_matrix=_matrix.Translate( 0,(_frame.Height-_bounds.Height)*_gravity.y )
			
		Case "fill-y"
		
			_rect.max.y=_frame.Height-_styleBounds.Height
			
			_bounds.min.y=_rect.min.y+_styleBounds.min.y
			_bounds.max.y=_rect.max.y+_styleBounds.max.y
			
			_matrix=_matrix.Translate( (_frame.Width-_bounds.Width)*_gravity.x,0 )
			
		Case "float"
		
			_matrix=_matrix.Translate( (_frame.Width-_bounds.Width)*_gravity.x,(_frame.Height-_bounds.Height)*_gravity.y )
			
			_matrix.t.x=Round( _matrix.t.x )
			_matrix.t.y=Round( _matrix.t.y )
			
		Case "stretch"
		
			Local sx:=Float(_frame.Width)/_bounds.Width
			Local sy:=Float(_frame.Height)/_bounds.Height
			_matrix=_matrix.Scale( sx,sy )

		Case "stretch-int"
		
			Local sx:=Float(_frame.Width)/_bounds.Width
			Local sy:=Float(_frame.Height)/_bounds.Height

			If sx>1 sx=Floor( sx )
			If sy>1 sy=Floor( sy )
			
			_matrix=_matrix.Scale( sx,sy )
			
		Case "scale","letterbox"
		
			Local sx:=Float(_frame.Width)/_bounds.Width
			Local sy:=Float(_frame.Height)/_bounds.Height
			
			If sx<sy
				_matrix=_matrix.Translate( 0,(_frame.Height-_bounds.Height*sx)*_gravity.y )
				_matrix=_matrix.Scale( sx,sx )
			Else
				_matrix=_matrix.Translate( (_frame.Width-_bounds.Width*sy)*_gravity.x,0 )
				_matrix=_matrix.Scale( sy,sy )
			Endif
			
		Case "scale-int","letterbox-int"
		
			Local sx:=Float(_frame.Width)/_bounds.Width
			Local sy:=Float(_frame.Height)/_bounds.Height
			
			If sx>1 sx=Floor( sx )
			If sy>1 sy=Floor( sy )
			
			Local sc:=Min( sx,sy )
			_matrix=_matrix.Translate( (_frame.Width-_bounds.Width*sc)*_gravity.x,(_frame.Height-_bounds.Height*sc)*_gravity.y )
			_matrix=_matrix.Scale( sc,sc )
			
		End
		
		_matrix=_matrix.Translate( -_bounds.min.x,-_bounds.min.y )
		
		If _parent _rmatrix=_parent._rmatrix * _matrix Else _rmatrix=_matrix
		
		_rclip=TransformRecti( _rect,_rmatrix )
		
		_rbounds=TransformRecti( _bounds-_rstyle.Margin,_rmatrix )
		
		If _parent
			_rclip&=_parent._rclip
			_rbounds&=_parent._rclip
			_clip=TransformRecti( _rclip,-_rmatrix )
		Else
			_clip=_rclip
		End
		
		OnLayout()
		
		For Local view:=Eachin _children
			view.UpdateLayout()
		Next
	End

	#rem monkeydoc @hidden
	#end
	Method Render( canvas:Canvas )
	
		If Not _visible Return
		
		canvas.BeginRender( _bounds,_matrix )
		
		_rstyle.Render( canvas,New Recti( 0,0,_bounds.Size ) )
		
		canvas.Viewport=_rect
		
		OnRender( canvas )

		For Local view:=Eachin _children
			view.Render( canvas )
		Next
		
		canvas.EndRender()
	End

	Protected
	
	#rem monkeydoc Called during layout if theme has changed.
	
	This is called immediately before [[OnValidateStyle]] if the theme has changed.

	#end
	Method OnThemeChanged() Virtual
	End
	
	#rem monkeydoc Called during layout if [[Style]] or [[StyleState]] have changed.

	Views can use this method to cache [[RenderStyle]] properties if necessary.
		
	#end
	Method OnValidateStyle() Virtual
	End
	
	#rem monkeydoc Called during layout to measure the view.
	
	Overriding methods should return their preferred content size.
	
	#end
	Method OnMeasure:Vec2i() Virtual
		Return New Vec2i( 0,0 )
	End
	
	#rem monkeydoc Called during layout when the view needs to update its child views.
	
	Overriding methods should set the [[Frame]] property of any child views they are resposible for.
	
	#end
	Method OnLayout() Virtual
	End
	
	#rem monkeydoc Called when the view needs to render itself.
	#end
	Method OnRender( canvas:Canvas ) Virtual
	End
	
	#rem monkeydoc Called when the key view changes.
	
	This method is invoked on both the old key view and new key view when the key view changes.
	
	#end
	Method OnKeyViewChanged( oldKeyView:View,newKeyView:View ) Virtual
	End
	
	#rem monkeydoc Keyboard event handler.
	Called when a keyboard event is sent to this view.
	#end
'	Method OnKeyEvent( event:KeyEvent ) Virtual
'	End
	
	#rem monkeydoc Mouse event handler.
	Called when a mouse event is sent to this view.
	#end
'	Method OnMouseEvent( event:MouseEvent ) Virtual
'	End

'jl added/modified
'------------------------------------------------------------	
	#rem monkeydoc Keyboard event handler.
	Called when a keyboard event is sent to this view.
	#end
	Method OnKeyEvent( event:KeyEvent ) Virtual
		_shiftDown = event.Modifiers & Modifier.Shift
		_altDown = event.Modifiers & Modifier.Alt
		_controlDown = event.Modifiers & Modifier.Control
		_commandDown = event.Modifiers & Modifier.Gui

		Select event.Type
			Case EventType.KeyUp
				OnKeyUp( event.Key )
			case EventType.KeyDown
				OnKeyDown( event.Key )
		End Select
	End

	#rem monkeydoc Keyboard down event handler.
	Called when a keyboard down event is sent to this view.
	#end
	Method OnKeyDown(  KeyDown:Key ) Virtual
	End

	#rem monkeydoc Keyboard up event handler.
	Called when a keyboard up event is sent to this view.
	#end
	Method OnKeyUp(  KeyUp:Key ) Virtual
	End

	field _mouseX:int
	field _mouseY:int
	field _oldMouseX:int
	field _oldMouseY:int
	field _mouseDown:bool
	field _clickMouse:bool
	field _clickMouseX:int
	field _clickMouseY:int
	
	#rem monkeydoc Mouse event handler.
	Called when a mouse event is sent to this view.
	#end
	Method OnMouseEvent( event:MouseEvent ) Virtual
		_oldMouseX = _mouseX
		_oldMouseY = _mouseY
		_mouseX = event.Location.X
		_mouseY = event.Location.Y
		
		if not Mouse.ButtonDown( MouseButton.Left ) Then _mouseDown = False

		Select event.Type
			Case EventType.MouseUp
				If _clickMouse Then
					local abx:int = Abs(_mouseX - _clickMouseX)
					local aby:int = Abs(_mouseY - _clickMouseY)
'					Print abx+" "+aby
					If (abx + aby) < 3 Then
						_mouseX = _clickMouseX
						_mouseY = _clickMouseY
					End if
				End If
				_clickMouse = false
			Case EventType.MouseClick
				_clickMouse = True
				_clickMouseX = _mouseX
				_clickMouseY = _mouseY
			Case EventType.MouseMove
				If _clickMouse Then
					local abx:int = Abs(_mouseX - _clickMouseX)
					local aby:int = Abs(_mouseY - _clickMouseY)
'					Print abx+" "+aby
					If (abx + aby) < 3 then Return
				End If
			Default
				_clickMouse = false
		End Select

		Select event.Type
			Case EventType.MouseWheel
				OnMouseWheel( event.Wheel.X, event.Wheel.Y)
			Case EventType.MouseDown
				_mouseDown = True
				OnMouseDown()
			Case EventType.MouseUp
				_mouseDown = false
				OnMouseUp()
			Case EventType.MouseEnter
				_mouseDown = False
				OnMouseEnter()
			Case EventType.MouseLeave
				_mouseDown = False
				OnMouseLeave()
			Case EventType.MouseMove
				OnMouseMove()
		End Select
	End

	
	#rem monkeydoc Mouse X position in the view.
	#end
	Property MouseX:Int()
		Return _mouseX
	End


	#rem monkeydoc Mouse Y position in the view.
	#end
	Property MouseY:Int()
		Return _mouseY
	End


	#rem monkeydoc Mouse X position (from 0 to 1).
	#end
	Property MouseFX:float()
		Return float(_mouseX) / Width
	End


	#rem monkeydoc Mouse Y position (from 0 to 1).
	#end
	Property MouseFY:float()
		Return float(_mouseY) / Height
	End


	#rem monkeydoc the status of the main mouse button.
	#end
	Property MouseDown:bool()
		Return _mouseDown
	End


	#rem monkeydoc Mouse wheel event handler.
		Called when a mouse wheel event is sent to this view.
	#end
	method OnMouseWheel( x:float, y:float) Virtual
	End method


	#rem monkeydoc MouseUp event handler.
		Called when a mouseup event is sent to this view.
	#end
	method OnMouseUp() Virtual
	End method


	#rem monkeydoc MouseDown event handler.
		Called when a mousedown event is sent to this view.
	#end
	method OnMouseDown() Virtual
	End method


	#rem monkeydoc MouseEnter  event handler.
		Called when a mouseenter event is sent to this view.
	#end
	method OnMouseEnter() Virtual
	End method


	#rem monkeydoc MouseLeaver  event handler.
		Called when a mouseleave event is sent to this view.
	#end
	method OnMouseLeave() Virtual
	End method


	#rem monkeydoc MouseMove  event handler.
		Called when a mousemover event is sent to this view.
	#end
	method OnMouseMove() Virtual
	End method

'------------------------------------------------------------	

	
	#rem monkeydoc The last size returned by OnMeasure.
	#end
	Property MeasuredSize:Vec2i()
	
		Return _measuredSize
	End
	
	#rem monkeydoc MeasuredSize plus the current [[RenderStyle]] bounds size.
	
	Use this instead of MeasuredSize when calculating layout size for child views.
	
	#end
	Property LayoutSize:Vec2i()
	
		Return _layoutSize
	End
	
	#rem monkeydoc The current [[RenderStyle]] bounds rect.
	#end
	Property StyleBounds:Recti()
	
		Return _styleBounds
	End
	
	'***** INTERNAL *****
	
	#rem monkeydoc @hidden
	
	For height-dependant-on-width views - clean me up!
	
	#end
	Method OnMeasure2:Vec2i( size:Vec2i ) Virtual
		Return New Vec2i( 0,0 )
	End
	
	#rem monkeydoc @hidden
	
	For height-dependant-on-width views - clean me up!
	
	#end
	Method Measure2:Vec2i( size:Vec2i )
		size=OnMeasure2( size-_styleBounds.Size )
		If size.x And size.y _layoutSize=size+_styleBounds.Size
		Return _layoutSize
	End

	#rem monkeydoc @hidden
	#end
	Method SetWindow( window:Window )
	
		_window=window
		
		For Local view:=Eachin _children
			view.SetWindow( window )
		Next
	End
	
	#rem monkeydoc @hidden
	#end
	Method UpdateActive()
	
		'Note: views are activated top-down, deactivated bottom-up.
		'	
		Local active:=_visible And _enabled And _window And (Not _parent Or _parent._active )
		
		Local changed:=active<>_active
		
		If changed
			_active=active
			If Not _active Deactivated()
		Endif
		
		For Local child:=Eachin _children
			child.UpdateActive()
		Next
		
		If changed And _active Activated()
	End
	
	Private
	
	Global _themeSeq:Int
	
	Field _styleSeq:Int=0
	
	Field _parent:View
	Field _window:Window
	Field _children:=New Stack<View>
	
	Field _visible:Bool=True
	Field _enabled:Bool=True
	Field _active:Bool=False
	Field _acceptsKeyEvents:Bool=True
	Field _acceptsMouseEvents:Bool=True
'------------------------------------------------------------	
	'jl added
	Field _acceptsTouchEvents:Bool=True
'------------------------------------------------------------	
	
	Field _style:Style
	Field _styleState:String
	
	Field _layout:String="fill"
	Field _gravity:=New Vec2f( .5,.5 )
	Field _offset:=New Vec2i( 0,0 )

	Field _minSize:Vec2i
	Field _maxSize:Vec2i
	
	Field _frame:Recti
	
	'After measuring...
	Field _rstyle:Style
	Field _styleBounds:Recti
	Field _measuredSize:Vec2i
	Field _layoutSize:Vec2i
	
	'After layout..
	Field _rect:Recti
	Field _bounds:Recti
	Field _matrix:AffineMat3f
	Field _rmatrix:AffineMat3f
	Field _rbounds:Recti
	Field _rclip:Recti
	Field _clip:Recti
End
