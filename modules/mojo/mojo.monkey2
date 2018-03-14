
Namespace mojo

#Import "assets/"

#Import "<emscripten>"
#Import "<std>"
#Import "<sdl2>"
#Import "<opengl>"
#Import "<openal>"
#Import "<freetype>"

Using emscripten..
Using std..
Using sdl2..
Using opengl..
Using openal..
Using mojo..

#Import "app/app"
#Import "app/event"
#Import "app/skin"
#Import "app/style"
#Import "app/theme"

#Import "app/view"
#Import "app/window"
#Import "app/glwindow"

'core graphics stuff
'#Import "graphics/glexts/glexts"
#Import "graphics/glutil"
#Import "graphics/graphicsdevice"
#Import "graphics/uniformblock"
#Import "graphics/rendertarget"
#Import "graphics/vertexbuffer"
#Import "graphics/indexbuffer"
#Import "graphics/vertex2f"
#Import "graphics/vertex3f"
#Import "graphics/texture"
#Import "graphics/shader"

'2d graphics stuff
#Import "graphics/canvas"
#Import "graphics/image"
#Import "graphics/font"
#Import "graphics/freetypefont"
#Import "graphics/imagefont"
#Import "graphics/angelfont"
#Import "graphics/shadowcaster"

#Import "input/keyboard"
#Import "input/mouse"
#Import "input/touch"
#Import "input/joystick"
#Import "input/gamecontroller"
#Import "input/keycodes"

#Import "audio/audio"

Private

Function Use( type:TypeInfo )
End

Function Main()

	Use( Typeof(app.App) )

	Stream.OpenFuncs["font"]=Lambda:Stream( proto:String,path:String,mode:String )
	
		Return Stream.Open( "asset::fonts/"+path,mode )
	End
		
	Stream.OpenFuncs["image"]=Lambda:Stream( proto:String,path:String,mode:String )
	
		Return Stream.Open( "asset::images/"+path,mode )
	End

	Stream.OpenFuncs["theme"]=Lambda:Stream( proto:String,path:String,mode:String )
	
		Return Stream.Open( "asset::themes/"+path,mode )
	End
	
End
