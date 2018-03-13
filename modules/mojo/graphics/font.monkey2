
Namespace mojo.graphics

Using std.resource

#rem monkeydoc @hidden The Glyph struct.

Glyph are used to store the individual character data for fonts.

#end
Struct Glyph

	Field rect:Recti
	Field offset:Vec2f
	Field advance:Float

	#rem monkeydoc Creates a new glyph.
	#end
	Method New( rect:Recti,offset:Vec2f,advance:Float )
		Self.rect=rect
		Self.offset=offset
		Self.advance=advance
	End

End

#rem monkeydoc @hidden
#end
Class GlyphPage

	Field image:Image
	Field glyphs:Glyph[]

End

#rem monkeydoc The Font class.

Fonts are used when drawing text to a canvas using [[Canvas.DrawText]].

To load a font, use the [[Font.Load]] function. Fonts should be in .otf, .ttf or .fon format.

Once a font is loaded it can be used with a canvas via the [[Canvas.Font]] property.

#end
Class Font Extends Resource

	#rem monkeydoc The font height in pixels.
	#end
	Property Height:Float()
	
		Return _height
	End
	
	#rem monkeydoc Measures the width of some text when rendered by the font.
	#end
	Method TextWidth:Float( text:String )
		Local w:=0.0
		For Local char:=Eachin text
			w+=GetGlyph( char ).advance
		Next
		Return w
	End

	#rem monkeydoc @hidden
	
	Gets the glyph page for a given char.
	
	Returns null if char does not have a glyph.
	
	#end	
	Method GetGlyphPage:GlyphPage( char:Int )
		Local page:=char Shr 8
		If page<0 Or page>=_pages.Length Return Null
		
		Local gpage:=_pages[page]
		If Not gpage Return Null
		
		If Not gpage.image OnLoadGlyphPage( page,gpage )
				
		Local index:=char & 255
		If index>=gpage.glyphs.Length Return Null
		
		Return gpage
	End
	
	#rem monkeydoc @hidden
	
	Gets the glyph for a given char.

	#end
	Method GetGlyph:Glyph( char:Int )
		Local page:=char Shr 8
		If page<0 Or page>=_pages.Length Return _nullGlyph

		Local gpage:=_pages[page]
		If Not gpage Return _nullGlyph

		If Not gpage.image OnLoadGlyphPage( page,gpage )
				
		Local index:=char & 255
		If index>=gpage.glyphs.Length Return _nullGlyph
		
		Return gpage.glyphs[index]
	End
	
	#rem monkeydoc Loads a font from a file.
	
	For the constructor with a `fontPath` parameter, the font must be a valid .ttf, .otf or .fon format font.
		
	For the constructor with an `imagePath` parameter, the font must be a valid image file containing a fixed size font with the characters laid out in left-to-right, top-to-bottom order.
		
	#end
	Function Load:Font( fontPath:String,height:Float,shader:Shader=Null,textureFlags:TextureFlags=TextureFlags.FilterMipmap )
	
		If Not shader shader=Shader.GetShader( "font" )
		
		Local font:=FreeTypeFont.Load( fontPath,height,shader,textureFlags )
		If Not font And Not ExtractRootDir( fontPath ) font=FreeTypeFont.Load( "font::"+fontPath,height,shader,textureFlags )
		
		Return font
	End
	
	Function Load:Font( imagePath:String,charWidth:Int,charHeight:Int,firstChar:Int=32,numChars:Int=96,padding:Int=1,shader:Shader=Null,textureFlags:TextureFlags=TextureFlags.FilterMipmap )
		
		Local pixmap:=Pixmap.Load( imagePath,Null,True )
		
		If Not pixmap And Not ExtractRootDir( imagePath )
			pixmap=Pixmap.Load( "font::"+imagePath,Null,True )
			If Not pixmap Return Null
		Endif
		
		Local charsPerRow:=pixmap.Width/charWidth
		Local numRows:=(numChars-1)/charsPerRow+1
		
		Local ipixmap:Pixmap
		If padding
			ipixmap=New Pixmap( charsPerRow*(charWidth+padding),numRows*(charHeight+padding),pixmap.Format )
			ipixmap.Clear( Color.None )
		Endif
		
		Local npages:=((firstChar+numChars-1) Shr 8)+1
		
		Local pages:=New GlyphPage[npages]
		
		Local page:GlyphPage,spos:=New Vec2i,gpos:=New Vec2i,gsize:=New Vec2i( charWidth,charHeight )
		
		For Local char:=firstChar Until firstChar+numChars
			
			If Not page Or (char & 255)=0
				page=New GlyphPage
				page.glyphs=New Glyph[256]
				pages[char Shr 8]=page
			Endif
			
			Local glyph:=New Glyph( New Recti( gpos,gpos+gsize ),Null,charWidth )
			
			page.glyphs[char&255]=glyph
			
			If ipixmap
				Local src:=pixmap.Window( spos.x,spos.y,charWidth,charHeight )
				ipixmap.Paste( src,gpos.x,gpos.y )
			Endif
			
			spos.x+=charWidth
			gpos.x+=charWidth+padding
			If spos.x+charWidth>pixmap.Width
				spos.y+=charHeight
				gpos.y+=charHeight+padding
				spos.x=0
				gpos.x=0
			Endif
		Next
		
		If Not pages[0]
			page=New GlyphPage
			page.glyphs=New Glyph[1]
			pages[0]=page
		Endif
		
		pages[0].glyphs[0]=pages[firstChar Shr 8].glyphs[firstChar & 255]
		
		Local image:=New Image( ipixmap ?Else pixmap,textureFlags,shader )
		For Local page:=Eachin pages
			page?.image=image
		Next
		
		Local font:=New Font
		
		font.InitFont( charHeight,pages )
		
		Return font
	End
	
	Protected
	
	Method OnLoadGlyphPage( page:Int,gpage:GlyphPage ) Virtual
	End
	
	Method InitFont( height:Float,pages:GlyphPage[] )
	
		_height=height
		_pages=pages
		
		_nullGlyph=GetGlyph( 0 )
	End
	
	Method OnDiscard() Override

		For Local page:=Eachin _pages
			If page.image page.image.Discard()
		Next
		
		_pages=Null
	End
	
	Private
	
	Field _height:Float

	Field _pages:GlyphPage[]
	
	Field _nullGlyph:Glyph
End

Class ResourceManager Extension

	Method OpenFont:Font( path:String,height:Float,shader:Shader=Null,textureFlags:TextureFlags=TextureFlags.FilterMipmap )
	
		Local slug:="Font:name="+StripDir( StripExt( path ) )+"&height="+height+"&shader="+(shader ? shader.Name Else "")+"&textureFlags="+Int(textureFlags)
		
		Local font:=Cast<Font>( OpenResource( slug ) )
		If font Return font
		
		font=Font.Load( path,height,shader,textureFlags )
		
		AddResource( slug,font )
		Return font
	End

End

