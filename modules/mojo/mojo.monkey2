
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

'jl added
#Import "graphics/imageslice"


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
	
	'***** Bizarro issue #87c *****
	'
	'The first OpenFunc here gets ignored, but ONLY in release+threaded mode and ONLY on my nvidia shield tablet (so far, emulators OK)
	'
	'Damn straight this took a while to find! No idea what's causing it, but this dummy entry is the workaround for now.
	'
	'Original symptom was fonts failing to load.
	'	
	Stream.OpenFuncs["::"]=Lambda:Stream( proto:String,path:String,mode:String )
	
		Return Null
	End
	
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
