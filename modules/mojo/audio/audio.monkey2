
#rem monkeydoc

Highly experimental audio module!

#end
Namespace mojo.audio

'jl added
#-
Const AL_EXT_STEREO_ANGLES:ALenum = 1
const AL_STEREO_ANGLES:ALenum = 4144'0x1030

const WAVE_SIN:int = 0
const WAVE_TRIANGLE:int = 1
const WAVE_SQUARE:int = 2
const WAVE_SAW:int = 3
const WAVE_NOISE:int = 4
		

const _pureNotes := New float[] (
	10.3, 10.915, 11.56, 12.25, 12.98, 13.75, 14.57, 15.435, 16.35, 17.325, 18.355, 19.445,
	20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87, 32.70, 34.65, 36.71, 38.89,
	41.20, 43.65, 46.25, 49.00, 51.91, 55.00, 58.27, 61.74, 65.41, 69.30, 73.42, 77.78,
	82.41, 87.31, 92.50, 98.00, 103.8, 110.0, 116.5, 123.5, 130.8, 138.6, 146.8, 155.6,
	164.8, 174.6, 185.0, 196.0, 207.7, 220.0, 233.1, 246.9, 261.6, 277.2, 293.7, 311.1,
	329.6, 349.2, 370.0, 392.0, 415.3, 440.0, 466.2, 493.9, 523.3, 554.4, 587.3, 622.3,
	659.3, 698.5, 740.0, 784.0, 830.6, 880.0, 932.3, 987.8, 1046.6, 1108.8, 1175, 1245,
	1319, 1397, 1480, 1568, 1661, 1760, 1865, 1976, 2093.2, 2217.6, 2349, 2489,
	2637, 2794, 2960, 3136, 3322, 3520, 3729, 3951, 4186.4, 4435.2, 4699, 4978,
	5274, 5588, 5920, 6272, 6645, 7040, 7459, 7902,  8372.8, 8870.4, 9398, 9956,
	10548, 11176, 11840, 12544, 13290, 14080, 14918, 15804, 16745.6, 17740.8, 18796, 19912 )

const _offsetNotes := New float[] (
	10.3, 10.915, 11.56, 12.25,      0.03125, 13.75, 14.57, 15.435, 16.35, 17.325, 18.355, 19.445,  '0..11
	20.60, 21.83, 23.12, 24.50,      0.0625,  27.50, 29.14, 30.87, 32.70, 34.65, 36.71, 38.89,      '12..23
	41.20, 43.65, 46.25, 49.00,      0.125,   55.00, 58.27, 61.74, 65.41, 69.30, 73.42, 77.78,      '24..35
	82.41, 87.31, 92.50, 98.00,      0.25,    110.0, 116.5, 123.5, 130.8, 138.6, 146.8, 155.6,      '36..47
	164.8, 174.6, 185.0, 196.0,      0.5,     220.0, 233.1, 246.9, 261.6, 277.2, 293.7, 311.1,      '48..59
	329.6, 349.2, 370.0, 392.0,      1,       1.08333, 466.2, 493.9, 523.3, 554.4, 587.3, 622.3,      '60..71 - 0.8333
	659.3, 698.5, 740.0, 784.0,      2,       880.0, 932.3, 987.8, 1046.6, 1108.8, 1175, 1245,      '72..83
	1319, 1397, 1480, 1568, 1661,    4,       1865, 1976, 2093.2, 2217.6, 2349, 2489,              '84..95
	2637, 2794, 2960, 3136, 3322,    8,       3729, 3951, 4186.4, 4435.2, 4699, 4978,              '96..107
	5274, 5588, 5920, 6272, 6645,    16,      7459, 7902,  8372.8, 8870.4, 9398, 9956,             '108..119
	10548, 11176, 11840, 12544,      31,      14080, 14918, 15804, 16745.6, 17740.8, 18796, 19912 ) '120..131


global _notes := New Double[11, 12]
global _notesHaveBeenSet:bool = false
function CreateNotes()
	Local j:Int
	Local k:Int
			
	Local freq:double
	Local count:Int = 0
	
	For k = 0 To 10
		For j = 0 To 11
			freq = _pureNotes[count]
			_notes[k, j] = freq / 220
			
			count = count + 1
		Next
	Next
	_notesHaveBeenSet = true
End function


function GetPitch:float( octave:int, note:int )
	If octave < 0 Then octave = 0
'	If note > 11 and note < 17 Then
'		octave += 1
'		note -= 12
	if octave > 9 Then octave = 9
	
	If note > 11 Then
		octave = note / 12
		note = note Mod 12
	Else If note < 0 Then
		Return _notes[octave, 0]
	End If
	
	Return _notes[octave, note]
End function

function GetPitch:float( note:int )
	If note < 0 Then note = 0
	Return _notes[note/12, note Mod 12]
End function

Function LoadALBuffer:AudioData( path:String )
	Local audio:AudioData = AudioData.Load( path )
	If Not audio Then
		Assert( audio, "Error Loading "+path )
'		Print "Error Loading "+path
		return Null
	End If
	
'	Print "bits = "+audio.Bits
	If audio.Bits = 8 Then
		if audio.Stereo Then
			Print "stereo convert"
			Local audio16:AudioData = New AudioData( audio.Length, AudioFormat.Stereo16, audio.Hertz )
			Local k:int
'jl modified
			For k = 0 To audio.Length-1
'			For k = 0 To audio.Length
				audio16.SetSample( k, audio.GetSample( k, 0 ), 0 )
				audio16.SetSample( k, audio.GetSample( k, 1 ), 1 )
			next
			audio16.SetSample( audio.Length, 0, 0 )
			audio16.SetSample( audio.Length, 0, 1 )
			Print "audio stereo Convert"
			Return audio16
		else
			Print "mono convert"
			Local audio16:AudioData = New AudioData( audio.Length, AudioFormat.Mono16, audio.Hertz )
			Local k:int
			For k = 0 To audio.Length-1
				audio16.SetSample( k, audio.GetSample( k ) )
			next
			Print "audio Convert"
			Return audio16
		End if
	End If

	Print "mojo/audio Loading... "+path
	If audio.Stereo Then Print "Stereo"
	If audio.Bits = 16 Then
		Print "16 bit"
	Else
		Print "8 bit"
	End if
	print "length "+audio.Length+"  "+(audio.Length / 128)
	Return audio
End
#-

#Import "native/bbmusic.cpp"

#Import "native/bbmusic.h"

Extern Private

Function playMusic:Int( file:libc.FILE ptr,callback:Int,source:Int )="bbMusic::playMusic"
Function getBuffersProcessed:Int( source:Int )="bbMusic::getBuffersProcessed"
Function endMusic:Void( source:Int )="bbMusic::endMusic"
	
Private

Const MUSIC_BUFFER_MS:=100
Const MUSIC_BUFFER_SECS:=0.1

Function ALFormat:ALenum( format:AudioFormat )
	Local alFormat:ALenum
	Select format
	Case AudioFormat.Mono8
		alFormat=AL_FORMAT_MONO8
	Case AudioFormat.Mono16
		alFormat=AL_FORMAT_MONO16
	Case AudioFormat.Stereo8
		alFormat=AL_FORMAT_STEREO8
	Case AudioFormat.Stereo16
		alFormat=AL_FORMAT_STEREO16
	End
	Return alFormat
End

Public

#rem monkeydoc Global instance of the AudioDevice class.
#end
Const Audio:=New AudioDevice

#rem monkeydoc The AudioDevice class.

An instance of the AudioDevice class is automatically created when an [[AppInstance]] is created, and can be accessed via the global [[Audio]] const.

#end
Class AudioDevice
	
	#rem monkeydoc Starts streaming audio playback.
	
	PlayMusic starts a piece of audio streaming from a file in the background.

	When the audio finishes, the optional `finished` function is invoked.
	
	The returned [[Channel]] instance is automatically discarded when the audio stops, so should not be discarded by your code.
	
	The audio file must be in .ogg format.
	
	#end
	Method PlayMusic:Channel( path:String,finished:Void()=Null,paused:Bool=False )

		'DO NOT use AutoDiscard here or music wont receive 'stop' signal!
		'		
		Local channel:=New Channel( ChannelFlags.Music )
		
		Local callback:=async.CreateAsyncCallback( Lambda()
			channel.Discard()
			endMusic( channel._alSource )
			finished()
		End,True )
		
		Local file:=filesystem.OpenCFile( path,"r" )
		
		Local sampleRate:=playMusic( file,callback,channel._alSource )
	
		If Not sampleRate
			async.DestroyAsyncCallback( callback )
			Return Null
		Endif
		
		channel._sampleRate=sampleRate
		
		Return channel
	End

	Internal
	
	Method Init()
	
		Local error:=""

		_alcDevice=alcOpenDevice( Null )
		If _alcDevice
			_alcContext=alcCreateContext( _alcDevice,Null )
			If _alcContext
				If alcMakeContextCurrent( _alcContext )
					Return
				Else
					error="Failed to make OpenAL current"
				Endif
			Else
				error="Failed to create OpenAL context"
			Endif
		Else
			error="Failed to create OpenAL device"
		Endif

	End
	
	Private
	
	Field _alcDevice:ALCdevice Ptr
	Field _alcContext:ALCcontext Ptr
	Field _error:String
	
End

#rem monkeydoc The Sound class.
#end
Class Sound Extends Resource
	'jl added
	field _data:float[] = New float[256]

	#rem monkeydoc Creates a new sound.
	#end
	Method New( data:AudioData )
		
		alGenBuffers( 1,Varptr _alBuffer )
		alBufferData( _alBuffer,ALFormat( data.Format ),data.Data,data.Size,data.Hertz )

'jl added
#-
		_format=data.Format
		_length=data.Length
		_hertz=data.Hertz
		_looped = data.Loop
		_loopStart = data.LoopStart
		_loopEnd = data.LoopEnd
		_filter = data.Filter
		_bitCount = data.BitCount

		Select data.Format
			Case AudioFormat.Mono8
				_stereo = False
				_bits8 = True
				
			Case AudioFormat.Mono16
				_stereo = False
				_bits8 = False
				
			Case AudioFormat.Stereo8
				_stereo = True
				_bits8 = True
				
			Case AudioFormat.Stereo16
				_stereo = True
				_bits8 = False
		End Select
		Mode1 = data.Mode1
		
		If _stereo Then
			Local diff:float = float(data.Length - 1) / 128
			Local k:int
			Local pos:int
			For k = 0 To 127
				pos = (k * diff)
				_data[k*2] = GetSample( data, pos )
			next
			For k = 0 To 127
				pos = (k * diff)
				_data[1+k*2] = GetSample( data, pos, 1 )
			next
		Else
			Local diff:float = float(data.Length - 1) / 256
			Local k:int
			Local pos:int
			For k = 0 To 255
				pos = (k * diff)
				_data[k] = GetSample( data, pos )
			Next
		End If
		Filename = data.Path

		If Not _notesHaveBeenSet Then CreateNotes()
#-		
	End

'jl added
#-
	#rem monkeydoc Creates a new sound.
	#end
	Method New( data:AudioData, length:int )
		alGenBuffers( 1, Varptr _alBuffer )
		
		'alBufferData(*bufferID, format, pcmData, sizeInBytes, bitRate);
		
		_format = data.Format
		_length = length
		_hertz = data.Hertz
		_looped = data.Loop
		_loopStart = data.LoopStart
		_loopEnd = data.LoopEnd
		_filter = data.Filter
		_bitCount = data.BitCount

		Select data.Format
			Case AudioFormat.Mono8
				_stereo = False
				_bits8 = True

				alBufferData( _alBuffer, ALFormat( data.Format ), data.Data, length, data.Hertz )
				
			Case AudioFormat.Mono16
				_stereo = False
				_bits8 = False

				alBufferData( _alBuffer, ALFormat( data.Format ), data.Data, length*2, data.Hertz )
				
			Case AudioFormat.Stereo8
				_stereo = True
				_bits8 = True

				alBufferData( _alBuffer, ALFormat( data.Format ), data.Data, length*2, data.Hertz )
				
			Case AudioFormat.Stereo16
				_stereo = True
				_bits8 = False

				alBufferData( _alBuffer, ALFormat( data.Format ), data.Data, length*4, data.Hertz )
				
		End Select
		
		If _stereo Then
			Local diff:float = float(length - 1) / 128
			Local k:int
			Local pos:int
			For k = 0 To 127
				pos = (k * diff)
				_data[k*2] = GetSample( data, pos )
			next
			For k = 0 To 127
				pos = (k * diff)
				_data[1+k*2] = GetSample( data, pos, 1 )
			next
		Else
			Local diff:float = float(length - 1) / 256
			Local k:int
			Local pos:int
			For k = 0 To 255
				pos = (k * diff)
				_data[k] = GetSample( data, pos )
			Next
		End If

		If Not _notesHaveBeenSet Then CreateNotes()
	End

	Method New( wave:int = 4, footage:int = 2, offset:int = 64, inDiff:int = 0, smooth:int = 0, rough:int = 0 )
		const Pi2:float = Pi * 2
		
		wave = Clamp( wave, 0, 4 )

		Local length:int
		Select footage
			Case 0 length = 2048
			Case 1 length = 1024
			Case 2 length = 512
			Case 3 length = 256
			Case 4 length = 128
		End Select	
		
		Local sine:UByte[] = New UByte[length]
		local sinData:AudioData = New AudioData( length, AudioFormat.Mono8, 44100, Cast<UByte Ptr>( sine.Data ) )

		Select wave
			Case 4 'noise
				_file = "Noise"
				For Local i := 0 Until length
					sine[i] = Rnd(255)
				Next

			Case 1 'tri
				_file = "Triangle"
				Local x1:int = length * .25
				Local x2:int = length * .5
				Local x3:int = length *.75
				Local div:float = float(255) / float(length)
				For Local i := 0 Until length
					If i < x1 Then
						sine[i] = 127 + (i * 2)*div
					Else If i < x3 Then
						sine[i] = 255 - ( (i-x1) * 2 ) * div
					Else
						sine[i] = ( (i-x3) * 2 ) * div
					End If
				Next

			Case 3 'saw
				_file = "Saw"
				Local div:float = float(255) / float(length)
				For Local i := 0 Until length
					sine[i] = i * div
				Next

			Case 2 'square
				_file = "Square"
				Local x2:int = length * .5
				For Local i := 0 Until length
					If i < x2 Then
						sine[i] = 255
					Else
						sine[i] = 0
					End If
				Next
				
			Case 0 'sin
				_file = "Sin"
				For Local i := 0 Until length
					sine[i] = Sin( Float(i)/length * Pi2 ) * 127.5 + 127.5
				Next
		End select

		If smooth > 0 Then
			Local sm:int
			Local i:int
			For sm = 1 To (smooth / 2)+1
				sine[length-1] = float(sine[length-1] + sine[0]) * .5
				For Local i := 1 Until length
					sine[i-1] = float(sine[i-1] + sine[i]) * .5
				Next
				For Local i := length-2 to 0 Step -1
					sine[i+1] = float(sine[i+1] + sine[i]) * .5
				Next
				sine[length-1] = float(sine[length-1] + sine[0]) * .5
			Next
		End If

		If inDiff > 0 and offset > 0 Then
			Local diff:int = inDiff
			For Local i := 0 Until length
				If i Mod offset = 0 Then diff -= inDiff
				sine[i] = sine[i] - diff
			Next
		End If

		If rough > 0 Then
			rough += rough
			For Local i := 0 Until length Step 2
				sine[i] = Clamp( float(sine[i] + Rnd(-rough, rough)), 0.0, 255.0)
			Next
		End if

		If smooth > 0 Then
			Local sm:int
			Local i:int
			For sm = 1 To (smooth / 2)+1
				sine[length-1] = float(sine[length-1] + sine[0]) * .5
				For Local i := 1 Until length
					sine[i-1] = float(sine[i-1] + sine[i]) * .5
				Next
				For Local i := length-2 to 0 Step -1
					sine[i+1] = float(sine[i+1] + sine[i]) * .5
				Next
				sine[length-1] = float(sine[length-1] + sine[0]) * .5
			Next
		End If

		If Not _notesHaveBeenSet Then CreateNotes()
		
		alGenBuffers( 1, Varptr _alBuffer )
		alBufferData( _alBuffer, ALFormat( sinData.Format ), sinData.Data, sinData.Size, sinData.Hertz )
		_format = sinData.Format
		_length = sinData.Length
		_hertz = sinData.Hertz

		_stereo = False
		_bits8 = True

		Local diff:float = float(length - 1) / 255
		Local k:int
		Local pos:int
		For k = 0 To 255
			pos = k * diff
'			Print "pos="+k+" linked to "+pos+" length "+length+" data "+GetSample( sinData, pos )
			_data[k] = GetSampleMono8( sinData, pos )
		Next

		sinData.Discard()
	End method


	Method GetSampleMono8:Float( data:AudioData, index:Int )
		Return data.Data[index]/128.0-1
	End

	Method GetSample:Float( data:AudioData, index:Int, channel:int = 0 )
		Select data.Format
			Case AudioFormat.Mono8
				Return data.Data[index]/128.0-1
			Case AudioFormat.Stereo8
				Return data.Data[index*2 + (channel&1)]/128.0-1
			Case AudioFormat.Mono16
				Return Cast<Short Ptr>( data.Data )[index]/32767.0
			Case AudioFormat.Stereo16
				Return Cast<Short Ptr>( data.Data )[index*2 + (channel&1)]/32767.0
		End Select
	
		Return 0
	End	


	method Draw( canvas:Canvas, x:float, y:float, width:float, height:float, showText:bool = true )
		Local halfHeight:float = height * .5
		Local x1:int = x + 4

		If showText Then
			canvas.Color = Color.LightGrey
			canvas.DrawText( _file, x1, y+height-16 )
		End if

		Local last:float = y+halfHeight
		Local curr:float
		Local xp:float = float(width) / 255
		
		Local k:int
		If _stereo Then

			Local quarterHeight:float = height * .25
			last = y+quarterHeight
			Local height2:float = height - quarterHeight
			Local last2:float = y+height2

			canvas.Color = Color.DarkGrey
			canvas.DrawLine( x, y+halfHeight, x+width, y+halfHeight )

			canvas.Color = Color.White*0.6
			canvas.DrawLine( x, y+quarterHeight, x+width, y+quarterHeight )
			canvas.DrawLine( x, y+height2, x+width, y+height2 )

			If showText Then
				canvas.Color = Color.Grey
				canvas.DrawText( "Left", x1, y )
				canvas.DrawText( "Right", x1, y+halfHeight )
			End if

			canvas.Color = Color.LightGrey

			Local wd:float = width / 256
			Local x1:float = x+1
			For k = 1 To 255
				If k Mod 2 =  0 Then
					curr = y+quarterHeight - ( _data[k] * quarterHeight )
					canvas.DrawLine( x, last, x1+wd, curr )
					last = curr
				Else
					curr = y+height2 - ( _data[k] * quarterHeight )
					canvas.DrawLine( x, last2, x1+wd, curr )
					last2 = curr
				End If
				x = x1
				x1 += wd
			Next
		Else
			canvas.Color = Color.White*0.6
			canvas.DrawLine( x, y+halfHeight, x+width, y+halfHeight )

			canvas.Color = Color.LightGrey

			Local wd:float = width / 256
			Local x1:float = x+1
			For k = 1 To 255
				curr = y+halfHeight - ( _data[k] * halfHeight )
				canvas.DrawLine( x, last, x1, curr )
				last = curr
				x = x1
				x1 += wd
			Next
			canvas.DrawLine( x, last, x1, y+halfHeight )
		End If
	End method
	
	
	Property Loop:bool()
		Return _looped
	Setter( loop:bool )
		_looped = loop
	End

	Property LoopStart:Int()
		Return _loopStart
	Setter( loopStart:int )
		_loopStart = loopStart
	End

	Property LoopEnd:int()
		Return _loopEnd
	Setter( loopEnd:int )
		_loopEnd = loopEnd
	End

	Property Filter:ubyte()
		Return _filter
	Setter( filter:ubyte )
		_filter = filter
	End

	#rem monkeydoc Returns true if a CMI Mode1 voice  has been detected
	#end	
	Property Mode1:bool()
		Return _mode1
	Setter( mode1:bool )
		_mode1 = mode1
	End

	#rem monkeydoc Returns true if a loaded or created sound sample is stereo
	#end	
	Property Stereo:bool()
		Return _stereo
	Setter( stereo:bool )
		_stereo = stereo
	End

	#rem monkeydoc Returns true if a loaded or created sound sample is 8bits
	#end	
	Property Bits8:bool()
		Return _bits8
	Setter( bits8:bool )
		_bits8 = bits8
	End

	#rem monkeydoc Returns the loading bit count 8/12/16/24/32
	#end	
	Property BitCount:int()
		Return _bitCount
	Setter( bitCount:int )
		_bitCount = bitCount
	End

	#rem monkeydoc The length, in samples, of the sound.
	#end
	Property Length:Int()
		Return _length
	End
	
	#rem monkeydoc The format of the sound.
	#end
	Property Format:AudioFormat()
		Return _format
	End
	
	#rem monkeydoc The playback rate of the sound.
	#end
	Property Hertz:Int()
		Return _hertz
	End
	
	#rem monkeydoc The duration, in seconds, of the sound.
	#end
	Property Duration:Double()
		Return Double(_length)/Double(_hertz)
	End


	Property Filename:String()
		Return _file
	setter( filename:string )
		_file = filename
	End
#-
	
	
	#rem monkeydoc Plays a sound through a temporary channel.
	
	The returned channel will be automatically discarded when it finishes playing or is stopped with [[Channel.Stop]].
	
	#end
	Method Play:Channel( loop:Bool=False )
	
		Local channel:=New Channel( ChannelFlags.AutoDiscard )
		
		'jl modified
'		channel.Play( Self, loop )
		If loop or Loop Then
			channel.Play( Self, true )
		Else
			channel.Play( Self )
		End if
		
		Return channel
	End
	
	#rem monkeydoc Loads a sound.
	#end
	Function Load:Sound( path:String )
	
		Local data:=AudioData.Load( path )
		If Not data Return Null
		
		Local sound:=New Sound( data )

		data.Discard()
		Return sound
	End
	
	Protected
	
	Method OnDiscard() Override
		
		If _alBuffer alDeleteBuffers( 1,Varptr _alBuffer )
			
		_alBuffer=0
	End
	
	Method OnFinalize() Override
		
		If _alBuffer alDeleteBuffers( 1,Varptr _alBuffer )
	End
	
	Private
	
	Field _alBuffer:ALuint
	Field _format:AudioFormat
	Field _length:Int
	Field _hertz:Int

'jl added
#-
	field _file:string = ""
	field _stereo:bool = False
	field _mode1:bool = false
	field _bits8:bool = False
	field _bitCount:int = 16
	
	field _looped:bool = false
	field _loopStart:int = 0
	field _loopEnd:int = 0
	
	field _filter:ubyte = 0
#-

End

#rem monkeydoc ChannelFlags enum.

| Flag			| Description
|:--------------|:-----------
| `AutoDiscard`	| Channel will be automatically discarded when it finishes playing, or when it is stopped using [[Channel.Stop]].

#end
Enum ChannelFlags
	
	AutoDiscard=1
	Music=2
End

Class Channel Extends Resource

	#rem monkeydoc Creates a new audio channel.
	
	If `flags` is ChannelFlags.AutoDiscard, then the channel will be automatically discarded when it finishes playing, or when it is
	stopped using [[Stop]].
	
	#end
	Method New( flags:ChannelFlags=Null )
	
		_flags=flags
	
		FlushAutoDiscard()
		
		alGenSources( 1,Varptr _alSource )
		
		If _flags & ChannelFlags.AutoDiscard _autoDiscard.Push( Self )
	End
	
	Property Flags:ChannelFlags()
	
		Return _flags
	End

'jl added
#-
	#rem monkeydoc True if channel is playing a stereo audio file.
	#end
	Property Stereo:bool()
		Return _stereo
	Setter( stereo:bool )
		_stereo = stereo
	End
#-
	
	#rem monkeydoc True if channel is playing audio.
	
	If the channel is playing audio but is in the paused state, this property will still return true.

	#end
	Property Playing:Bool()
		If Not _alSource Return False
		
		Local state:=ALState()
		Return state=AL_PLAYING Or state=AL_PAUSED
	End
	
	#rem monkeydoc True if channel is paused.
	#end
	Property Paused:Bool()
		If Not _alSource Return False
		
		Return ALState()=AL_PAUSED
		
	Setter( paused:Bool )
		If Not Playing Return
		
		If paused
			alSourcePause( _alSource )
		Else
			alSourcePlay( _alSource )
		Endif
	End
	
	#rem monkeydoc Channel volume in the range 0 to 1.
	#end
	Property Volume:Float()
		If Not _alSource Return 0
	
		Return _volume
		
	Setter( volume:Float )
		If Not _alSource Return
		
		_volume=Clamp( volume,0.0,1.0 )
		alSourcef( _alSource,AL_GAIN,_volume )
	End
	
	#rem monkeydoc Channel playback rate.
	#end	
	Property Rate:Float()
		If Not _alSource Return 0

		Return _rate
		
	Setter( rate:Float )
		If Not _alSource Return
		
		_rate=rate
		alSourcef( _alSource,AL_PITCH,_rate )
	End

'jl added
#-	
	#rem monkeydoc Channel playback rate.
	#end	
	Property Pitch:Float()
		If Not _alSource Return 0
		Return _rate
	Setter( pitch:Float )
		If Not _alSource Return
		
		_rate = pitch
		alSourcef( _alSource, AL_PITCH, _rate )
	End
#-
	
	#rem monkeydoc Channel pan in the range -1 (left) to 1 (right).
	#end	
	Property Pan:Float()
		If Not _alSource Return 0
	
		Return _pan
		
	Setter( pan:Float)
		If Not _alSource Return
		
		_pan=Clamp( pan,-1.0,1.0 )
		Local x:=Sin( _pan ),z:=-Cos( _pan )
		alSource3f( _alSource,AL_POSITION,x,0,z )
	End

'jl added
#-	
	#rem monkeydoc Channel playhead in samples.
	If the channel is playing audio this will return the position of the playhead in the played sound.
	#end
	Property Playhead:Double()
		If Not _alSource Return 0
	
'		Local proc:ALint
'		alGetSourcei( _alSource,AL_BUFFERS_PROCESSED,Varptr proc )
		
'		Print "processed: "+proc

		Local playhead:ALfloat
		
		alGetSourcef( _alSource, AL_SAMPLE_OFFSET, Varptr playhead )
		
		If playhead = _length Then Return 0
		
		Return (float(playhead) / _length)

'		local pos:float
'		return alGetSourcef( _alSource, AL_SAMPLE_OFFSET, Varptr pos )
	Setter( playhead:Double )
		If Not _alSource Return
		
		local _playhead:ALfloat = Clamp( float(playhead), 0.0, 1.0 )
		alSourcef( _alSource, AL_SAMPLE_OFFSET, _playhead )
	End
#-
	
	#rem monkeydoc Channel playhead sample offset.
	
	Gets or sets the sample offset of the sound currently playing.
	
	If the channel is playing when set, playback is immediately affected.
	
	If the channel is not playing when set, the offset will be applied when the Play method is invoked.
		
	#end
	Property PlayheadSample:Int()
		If Not _alSource Return 0
		
		Local sample:Int
		alGetSourcei( _alSource,AL_SAMPLE_OFFSET,Varptr sample )
		
		If _flags & ChannelFlags.Music
			
			Local samplesPerBuffer:=MUSIC_BUFFER_MS * _sampleRate / 1000
			
			Local buffersProcessed:=getBuffersProcessed( _alSource )
			
			sample+=samplesPerBuffer * buffersProcessed
			
			If sample<_sample
'				Print "Sample catch up:"+sample+"->"+_sample
				While sample<_sample
					sample+=samplesPerBuffer
				Wend
			Else
				_sample=sample
			Endif
		Endif
		
		Return sample
				
	Setter( sample:Int )
		If Not _alSource Return
		
		alSourcei( _alSource,AL_SAMPLE_OFFSET,sample )
	End
	
	#rem monkeydoc Channel playhead time offset.

	Gets or sets the time offset of the sound currently playing.
	
	If the channel is playing when set, playback is immediately affected.
	
	If the channel is not playing when set, the offset will be applied when the Play method is invoked.
		
	#end
	Property PlayheadTime:Float()
		If Not _alSource Return 0

		Local time:Float		
		alGetSourcef( _alSource,AL_SEC_OFFSET,Varptr time )
		
		If _flags & ChannelFlags.Music
			
			Local buffersProcessed:=getBuffersProcessed( _alSource )
			
			time+=MUSIC_BUFFER_SECS * buffersProcessed
			
			If time<_time
'				Print "Time catchup: "+time+"->"+_time
				While time<_time
					time+=MUSIC_BUFFER_SECS
				Wend
			Else
				_time=time
			Endif
		Endif
		
		Return time
		
	Setter( time:Float )
		If Not _alSource Return
		
		alSourcef( _alSource,AL_SEC_OFFSET,time )
	End
	
	#rem monkeydoc Plays a sound through the channel.
	#end
	Method Play( sound:Sound,loop:Bool=False )
		If Not _alSource Or Not sound Or Not sound._alBuffer Return
		
		'jl modded
'		alSourcei( _alSource,AL_LOOPING,loop ? AL_TRUE Else AL_FALSE )
		If loop or sound.Loop Then
			alSourcei( _alSource, AL_LOOPING, AL_TRUE )
		Else
			alSourcei( _alSource, AL_LOOPING, AL_FALSE )
		End if
		
		alSourcei( _alSource,AL_BUFFER,sound._alBuffer )
		
'jl added
#-
		_stereo = sound.Stereo
		_length = sound.Length
		_sound = sound
#-

		alSourcePlay( _alSource )
	End

	#if __TARGET__<>"emscripten"

	#rem monkeydoc @hidden - Highly experimental!!!!!
	#end
	Method WaitQueued( queued:Int )
	
		While _queued>queued
		
			FlushProcessed()
			
			If _queued<=queued Return
		
			_waiting=True
			
			_future.Get()
		
		Wend

	End
	
	#rem monkeydoc @hidden - Highly experimental!!!!!
	#end
	Method Queue( data:AudioData )
	
		Local buf:ALuint
		
		If Not _tmpBuffers
		
			_tmpBuffers=New Stack<ALuint>
			_freeBuffers=New Stack<ALuint>
			_future=New Future<Int>
			_waiting=False
			_queued=0
			
			_timer=New Timer( 60,Lambda()
				FlushProcessed()
			End )

		Endif		
		
		If _freeBuffers.Empty
			
			alGenBuffers( 1,Varptr buf )
			_tmpBuffers.Push( buf )
		
		Else
			buf=_freeBuffers.Pop()
		Endif
		
		alBufferData( buf,ALFormat( data.Format ),data.Data,data.Size,data.Hertz )
		
		alSourceQueueBuffers( _alSource,1,Varptr buf )
		_queued+=1
		
		Local state:=ALState()
		If state=AL_INITIAL Or state=AL_STOPPED alSourcePlay( _alSource )
	
	End
	
	#endif
	
	#rem monkeydoc Stops channel.
	#end
	Method Stop()
		If Not _alSource Return

		alSourceStop( _alSource )
		
		If _flags & ChannelFlags.AutoDiscard Discard()
	End
	
	Protected
	
	#rem monkeydoc @hidden
	#end
	Method OnDiscard() Override

		If _alSource alDeleteSources( 1,Varptr _alSource )
		
		_alSource=0
	End
	
	#rem monkeydoc @hidden
	#end
	Method OnFinalize() Override

		If _alSource alDeleteSources( 1,Varptr _alSource )
	End

	Private
	
	Field _flags:ChannelFlags
	Field _alSource:ALuint
	Field _volume:Float=1
	Field _rate:Float=1
	Field _pan:Float=0
	
'jladded
#-
	field _stereo:bool = false
	field _length:int = 0
	field _sound:Sound
#-

	Field _sampleRate:Int
	
	Field _time:float
	Field _sample:Int
	
	Global _autoDiscard:=New Stack<Channel>
	
	Method ALState:ALenum()
		Local state:ALenum
		alGetSourcei( _alSource,AL_SOURCE_STATE,Varptr state )
		Return state
	End
	
	Function FlushAutoDiscard()
	
		Local put:=0
		
		For Local chan:=Eachin _autoDiscard
			If Not chan._alSource Continue
		
			If chan.ALState()<>AL_STOPPED
				_autoDiscard[put]=chan;put+=1
				Continue
			Endif
			
			chan.Discard()
		Next

		_autoDiscard.Resize( put )
	End
	
	#if __TARGET__<>"emscripten"
	
	Field _tmpBuffers:Stack<ALuint>
	Field _freeBuffers:Stack<ALuint>
	Field _future:Future<Int>
	Field _waiting:Bool
	Field _queued:Int
	Field _timer:Timer
	
	Method FlushProcessed:Int()
	
		Local proc:ALint
		alGetSourcei( _alSource,AL_BUFFERS_PROCESSED,Varptr proc )
		
		If Not proc Return 0
		
		For Local i:=0 Until proc
		
			Local buf:ALuint
			
			alSourceUnqueueBuffers( _alSource,1,Varptr buf )
			_queued-=1
			
			If _tmpBuffers.Contains( buf ) _freeBuffers.Push( buf )
		Next

		If _waiting 
			_waiting=False
			_future.Set( proc )
		Endif
		
		Return proc

	End
	
	#endif
	
End
