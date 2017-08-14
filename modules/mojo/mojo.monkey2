
Namespace mojo

#Import "assets/"

#Import "<emscripten>"
#Import "<std>"
#Import "<sdl2>"
#Import "<gles20>"
#Import "<openal>"
#Import "<freetype>"

#Import "app/app"
#Import "app/event"
#Import "app/skin"
#Import "app/style"
#Import "app/theme"

#Import "app/view"
#Import "app/window"
#Import "app/glwindow"

'core graphics stuff
#Import "graphics/glexts/glexts"
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
#Import "graphics/font"
#Import "graphics/freetypefont"
#Import "graphics/image"
#Import "graphics/shadowcaster"

#Import "input/device"
#Import "input/keyboard"
#Import "input/mouse"
#Import "input/touch"
#Import "input/joystick"
#Import "input/keycodes"

#Import "audio/audio"

Using emscripten..
Using std..
Using sdl2..
Using gles20..
Using openal..
Using mojo..

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
