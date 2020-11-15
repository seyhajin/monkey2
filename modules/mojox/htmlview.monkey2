
Namespace mojox

#rem monkeydoc The HtmlView class.
#end
Class HtmlView Extends ScrollableView

	#rem monkeydoc Invoked when an anchor is clicked.
	#end
	Field AnchorClicked:Void( url:String )

	#rem monkeydoc Creates a new HtmlView.
	#end
	Method New()
		Layout="fill"
		
		Style=GetStyle( "HtmlView" )

		_context=New litehtml.context
		_context.load_master_stylesheet( stringio.LoadString( "theme::htmlview_master_css.css" ) )

		_container=New document_container( Self )
		
		_baseUrl=filesystem.CurrentDir()
		
		AnchorClicked=Go
	End
	
	#rem monkeydoc Base URL.
	
	This is used as the root directory for relative anchors in the page.
	
	#end
	Property BaseUrl:String()
		Return _baseUrl
	Setter( baseUrl:String )
		If Not baseUrl.EndsWith( "/" ) baseUrl+="/"
		_baseUrl=baseUrl
	End
	
	#rem monkeydoc HTML source.
	#end
	Property HtmlSource:String()
		Return _source
	Setter( htmlSource:String )
		_source=htmlSource
		_document=New litehtml.document( _source,_container,_context )
		_layoutSize=Null
		_renderSize=Null
		RequestRender()
	End
	
	#rem monkeydoc Goto a url.
	#end
	Method Go( url:String )
	
		If url.Contains( "#" )
			Return
		Endif
		
		Local root:=ExtractRootDir( url )
		
		If root="http://" Or root="https://"
		
#If __DESKTOP_TARGET__			
			requesters.OpenUrl( url )
#Endif

			Return
		Endif
		
		If Not root
			url=BaseUrl+url
		Endif
		
		Local src:=stringio.LoadString( url )
		
		If ExtractExt( url )=".md"
			src=hoedown.MarkdownToHtml( src )
			Local wrapper:=stringio.LoadString( "theme::markdown_wrapper.html" )
			src=wrapper.Replace( "${CONTENT}",src )
		End
		
		BaseUrl=ExtractDir( url )
		
		HtmlSource=src
	End
	
	Private
	
	Field _context:litehtml.context
	Field _container:litehtml.document_container
	Field _anchorClicked:String
	
	Field _baseUrl:String
	Field _source:String
	Field _document:litehtml.document
	Field _layoutSize:Vec2i
	Field _renderSize:Vec2i
	
	Method OnThemeChanged() Override
		_document=New litehtml.document( _source,_container,_context )
		_layoutSize=Null
		_renderSize=Null
	End

	Method OnMeasureContent2:Vec2i( size:Vec2i ) Override
	
		If Not _document Return New Vec2i( 0,0 )
		
		If size.x=_layoutSize.x Return _renderSize
		
		_layoutSize=size
		
		_document.render( size.x )
		
		_renderSize=New Vec2i( _document.width(),_document.height() )
		
		Return _renderSize
	End
	
	Method OnRenderContent( canvas:Canvas ) Override
	
		If Not _document Return
		
		Local clip:litehtml.position

		clip.x=VisibleRect.X           ' Draw only visible rect, not the
		clip.y=VisibleRect.Y           ' whole virtual page.
		clip.width=VisibleRect.Width   ' *Fixes* slow scrolling with large pages.
		clip.height=VisibleRect.Height '

		_document.draw( canvas,0,0,Varptr clip )
	End

	Method OnContentMouseEvent( event:MouseEvent ) Override
	
		If Not _document Return
	
		Local x:=event.Location.X
		Local y:=event.Location.Y
		
		_anchorClicked=""
		
		Select event.Type
		Case EventType.MouseDown
		
			_document.on_lbutton_down( x,y,x,y )
			
		Case EventType.MouseMove
		
			_document.on_mouse_over( x,y,x,y )
			
		Case EventType.MouseUp
		
			_document.on_lbutton_up( x,y,x,y )
			
			_document.on_mouse_leave()
			
		Case EventType.MouseWheel

			Return
		End
		
		event.Eat()
		
		RequestRender()	'Not ideal, but necessary for link highlighting...
		
		If _anchorClicked AnchorClicked( _anchorClicked )
	End
	
End

Class document_container Extends litehtml.document_container

	Field _view:HtmlView
	
	Method ToFont:Font( hfont:Object )
	
		Return Cast<Font>( hfont )
	End
	
	Method ToCanvas:Canvas( hdc:Object )
	
		Return Cast<Canvas>( hdc )
	End
	
	Method GetImage:Image( src:String )
	
		Return App.Theme.OpenImage( src )
	End
	
	Method New( view:HtmlView )
	
		_view=view
	End
	
	Method set_color( canvas:Canvas,color:litehtml.web_color )
	
		canvas.Color=New Color( color.red/255.0,color.green/255.0,color.blue/255.0,1 )
	End
	
	Method make_url:String( href:String )
	
		Return _view._baseUrl+href
	End

	Method create_font:Object( faceName:String,size:Int,weight:Int,style:litehtml.font_style,decoration:UInt,fm:litehtml.font_metrics Ptr ) Override
	
		Local face:="DejaVuSans"
		
		If faceName.Contains( "monospace" ) face+="Mono"
		
		Local font:=App.Theme.OpenFont( face,size )
		
		Local height:=font.Height

		fm->height=height
		fm->ascent=height
		fm->descent=0
		fm->x_height=height
		fm->draw_spaces=True
		
		Return font
	End

	Method delete_font( font:Object ) Override
	End
	
	Method text_width:Int( text:String,hfont:Object ) Override
	
		Local font:=ToFont( hfont )
		
		Return font.TextWidth( text )
	End
	
	Method draw_text( hdc:Object,text:String,hfont:Object,color:litehtml.web_color Ptr,pos:litehtml.position Ptr ) Override
	
		Local canvas:=ToCanvas( hdc )
		
		Local font:=ToFont( hfont )
		
		canvas.Font=font

		set_color( canvas,color[0] )
		
		canvas.DrawText( text,pos->x,pos->y )
		
		Return
	End
	
	Method pt_to_px:Int( pt:Int ) Override
	
		Return 0
	End
	
	Method get_default_font_size:Int() Override
	
		Return 16 * App.Theme.Scale.y
	End
	
	Method get_default_font_name:String() Override
	
		Return "DejaVuSans"
	End
	
	Method draw_list_marker( hdc:Object,marker:litehtml.list_marker Ptr ) Override
	
		If marker->marker_type=litehtml.list_style_type_none Return
	
		Local canvas:=ToCanvas( hdc )
	
		set_color( canvas,marker->color )
		
		Select marker->marker_type
		Case litehtml.list_style_type_disc
			canvas.DrawOval( marker->pos.x,marker->pos.y,marker->pos.width,marker->pos.height )
		Default
			canvas.DrawRect( marker->pos.x,marker->pos.y,marker->pos.width,marker->pos.height )
		End
	End
	
	Method load_image( src:String,baseurl:String,redraw_on_ready:Bool ) Override
	
		GetImage( src )
	End
	
	Method get_image_size( src:String,baseurl:String,sz:litehtml.size Ptr ) Override
	
		Local image:=GetImage( src )
		If Not image Return
	
		sz->width=image.Width
		sz->height=image.Height
	End

	Method draw_background( hdc:Object,img_src:String,img_baseurl:String,bg:litehtml.background_paint Ptr ) Override
	
		Local canvas:=ToCanvas( hdc )
		
		Local image:=GetImage( img_src )
		If image
			canvas.Color=Color.White
			canvas.DrawImage( image,bg->position_x,bg->position_y )
			Return
		Endif

		set_color( canvas,bg->color )
		
'		canvas.DrawRect( bg->clip_box.x,bg->clip_box.y,bg->clip_box.width,bg->clip_box.height )
		canvas.DrawRect( bg->border_box.x,bg->border_box.y,bg->border_box.width,bg->border_box.height )

	End
	
	Method draw_border( canvas:Canvas,border:litehtml.border,x:Int,y:Int,w:Int,h:Int )

		If border.style<>litehtml.border_style_solid Or border.width<1 Return
		
		set_color( canvas,border.color )
		
		canvas.DrawRect( x,y,w,h )
	End
	
	Method draw_borders( hdc:Object,borders:litehtml.borders Ptr,pos:litehtml.position Ptr,root:Bool ) Override
	
		Local canvas:=ToCanvas( hdc )
		
		Local x:=pos->x,y:=pos->y
		
		Local w:=pos->width,h:=pos->height
		
		draw_border( canvas,borders->left,x,y,1,h )
		
		draw_border( canvas,borders->top,x,y,w,1 )
		
		draw_border( canvas,borders->right,x+w-1,y,1,h )
		
		draw_border( canvas,borders->bottom,x,y+h-1,w,1 )
	End

	Method set_caption( caption:String ) Override
	End
	
	Method set_base_url( baseurl:String ) Override
	End
	
	Method on_anchor_click( url:String ) Override
	
		_view._anchorClicked=url
	End
		
	Method set_cursor( cursor:String ) Override
	End
	
	Method import_css:String( url:String,baseurl:String ) Override
	
		Local css:=stringio.LoadString( make_url( url ) )
		Return css
	End
	
	Method set_clip( pos:litehtml.position Ptr,radiuses:litehtml.border_radiuses Ptr ) Override
	End
	
	Method del_clip() Override
	End
	
	Method get_client_rect( client:litehtml.position Ptr ) Override
'		If _view._rendering Print "get client rect"
		client->x=0
		client->y=0
		client->width=_view._layoutSize.x
		client->height=_view._layoutSize.y
	End
	
	Method get_media_features( media:litehtml.media_features Ptr ) Override
'		If _view._rendering Print "get media features"
		media->type=litehtml.media_type_screen
		media->width=_view._layoutSize.x
		media->height=_view._layoutSize.y
		media->device_width=1920
		media->device_height=1080
		media->color=8
		media->color_index=0
		media->monochrome=0
		media->resolution=96
	End
	
	Method get_language:String() Override
		Return ""
	End
	
	Method get_culture:String() Override
		Return ""
	End
	
End
