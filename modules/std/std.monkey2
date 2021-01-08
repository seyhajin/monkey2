
Namespace std

#Import "<libc>"
#Import "<zlib>"
#Import "<miniz>"
#Import "<stb-image>"
#Import "<stb-image-write>"
#import "<stb-vorbis>"

#If __TARGET__="emscripten"
#Import "<emscripten>"
#ElseIf __TARGET__="android"
#Import "<android>"
#ElseIf __TARGET__="ios"
'#Import "<ios>"
#Endif

#Import "collections/container"
#Import "collections/stack"
#Import "collections/list"
#Import "collections/map"
#Import "collections/deque"

#Import "resource/resource"

#Import "stream/stream"
#Import "stream/filestream"

'#If __MOBILE_TARGET__
'#Import "stream/sdl_rwstream.monkey2"
'#Endif

#Import "memory/byteorder"
#Import "memory/databuffer"
#Import "memory/datastream"

#Import "geom/affinemat3"
#Import "geom/affinemat4"
#Import "geom/axis"
#Import "geom/box"
#Import "geom/line"
#Import "geom/mat3"
#Import "geom/mat4"
#Import "geom/plane"
#Import "geom/quat"
#Import "geom/rect"
#Import "geom/vec2"
#Import "geom/vec3"
#Import "geom/vec4"

#Import "geom/plane"
#Import "geom/box"
#Import "geom/line"

#Import "graphics/pixelformat"
#Import "graphics/pixmap"
#Import "graphics/pixmaploader"
#Import "graphics/pixmapsaver"
#Import "graphics/color"

#import "audio/audioformat"
#import "audio/audiodata"
#import "audio/load_wav"
#import "audio/load_vorbis"

#Import "async/async"
#Import "time/time"
#Import "time/time-parser"
#Import "time/timer"
#Import "fiber/fiber"
#Import "fiber/future"
#Import "process/process"
#Import "process/processstream"
#Import "filesystem/filesystem"

#Import "misc/random"
#Import "misc/chartype"
#Import "misc/stringio"
#Import "misc/json"
#Import "misc/jsonify"
#Import "misc/zipfile"
#Import "misc/base64"
#Import "misc/digest"

#Import "socket/socket"
#Import "socket/socketstream"

#Import "requesters/requesters"

#Import "permissions/permissions"

'jl added
''------------------------------------------------------------
global DEV:bool = DesktopDir().Find("lucifer_9") > -1
global DEBUG:bool = AppDir().Find("debug") > -1
global RELEASE:bool = not DEBUG

'Private

'function  Lerp:float( fromValue:float, toValue:float, position:float )
'	local value:float = toValue - fromValue
'	if value = 0 then return fromValue
'	return fromValue + (value * position)
'end function
'
'function  Lerp:double( fromValue:double, toValue:double, position:double )
'	local value:double = toValue - fromValue
'	if value = 0 then return fromValue
'	return fromValue + (value * position)
'end function

'very efficiant and order independant!!!
function PointInTriangle:bool( px:float,  py:float, p0x:float, p0y:float, p1x:float, p1y:float, p2x:float, p2y:float )
	local dX:float = px - p2x
	local dY:float = py - p2y
	Local dX21:float = p2x - p1x
	Local dY12:float = p1y - p2y
	Local D:float = dY12 * (p0x - p2x) + dX21 * (p0y - p2y)
	Local s:float = dY12 * dX + dX21 * dY
	Local t:float = (p2y - p0y) * dX + (p0x - p2x) * dY
	
	if D < 0 Then
		return s <= 0 And t <= 0 And s + t >= D
	End If
	
	return s >= 0 And t >= 0 And s + t <= D
End function

function PointInQuad:bool( px:float,  py:float, p0x:float, p0y:float, p1x:float, p1y:float, p2x:float, p2y:float, p3x:float, p3y:float )
	local tri1:bool = PointInTriangle( px, py,  p0x, p0y, p1x, p1y, p2x, p2y )
	If tri1 Then Return True
	return PointInTriangle( px, py,  p2x, p2y, p3x, p3y, p0x, p0y )
End function

function Length:float( x:float,  y:float,  z:float,  x1:float,  y1:float, z1:float )
	x -= x1
	y -= y1
	z -= z1
	Return Sqrt( x*x + y*y + z*z )
End
	
function Length:float( x:float,  y:float,  x1:float,  y1:float )
	x -= x1
	y -= y1
	Return Sqrt( x*x + y*y )
End

function Length:float( x:int,  y:int,  z:int,  x1:int,  y1:int, z1:int )
	x -= x1
	y -= y1
	z -= z1
	Return Sqrt( x*x + y*y + z*z )
End
	
function Length:float( x:int,  y:int,  x1:int,  y1:int )
	x -= x1
	y -= y1
	Return Sqrt( x*x + y*y )
End

function Length:float( x:double,  y:double,  z:double,  x1:double,  y1:double, z1:double )
	x -= x1
	y -= y1
	z -= z1
	Return Sqrt( x*x + y*y + z*z )
End
	
function Length:float( x:double,  y:double,  x1:double,  y1:double )
	x -= x1
	y -= y1
	Return Sqrt( x*x + y*y )
End

function Length:float( x:int, y:int )
	Return Sqrt( x*x + y*y )
End

function Length:float( x:float, y:float )
	Return Sqrt( x*x + y*y )
End

function Length:Double( x:double, y:double )
	Return Sqrt( x*x + y*y )
End

function Length:float( x:int, y:int, z:int )
	Return Sqrt( x*x + y*y + z*z )
End

function Length:float( x:float, y:float, z:float )
	Return Sqrt( x*x + y*y + z*z )
End

function Length:Double( x:double, y:double, z:double )
	Return Sqrt( x*x + y*y + z*z )
End

Function Asc:Int( input:String, index:Int = 0 )
	Return input[index]
End


private

Function Chr:String( character:Int )
    Return String.FromChar(character)
End
 
''------------------------------------------------------------

Private

Function Main()

	'Capture app start time
	'
	std.time.Now()

	'Add stream handlers
	'
	Stream.OpenFuncs["file"]=Lambda:Stream( proto:String,path:String,mode:String )

		Return FileStream.Open( path,mode )
	End
	
	Stream.OpenFuncs["asset"]=Lambda:Stream( proto:String,path:String,mode:String )
	
		Return FileStream.Open( filesystem.AssetsDir()+path,mode )
	End
	
#If __MOBILE_TARGET__
	
	Stream.OpenFuncs["internal"]=Lambda:Stream( proto:String,path:String,mode:String )
	
		Return FileStream.Open( filesystem.InternalDir()+path,mode )
	End

	Stream.OpenFuncs["external"]=Lambda:Stream( proto:String,path:String,mode:String )
	
		Return FileStream.Open( filesystem.ExternalDir()+path,mode )
	End

#endif
	
	Stream.OpenFuncs["memory"]=Lambda:Stream( proto:String,path:String,mode:String )
	
		Return DataStream.Open( path,mode )
	End
	
#If __DESKTOP_TARGET__

	Stream.OpenFuncs["process"]=Lambda:Stream( proto:String,path:String,mode:String )

		Return std.process.ProcessStream.Open( path,mode )
	End
	
#Endif
	
End
