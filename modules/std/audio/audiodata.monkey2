
Namespace std.audio

#rem monkeydoc The AudioData class.
#end
Class AudioData Extends Resource

	#rem monkeydoc Creates a new AudioData object
	#end
	Method New( length:Int,format:AudioFormat,hertz:Int )
		_length=length
		_format=format
		_hertz=hertz
		_owned=True
		_data=Cast<UByte Ptr>( GCMalloc( BytesPerSample( format )*length ) )
	End

	Method New( length:Int,format:AudioFormat,hertz:Int,data:Void Ptr )
		_length=length
		_format=format
		_hertz=hertz
		_owned=false
		_data=Cast<UByte Ptr>( data )
	End

	'jl new
#-
	Method New( audio:AudioData )
		_locked = true
		_length = audio.Length
		_format = audio.Format
		_hertz = audio.Hertz
		_looped = audio.Loop
		_loopStart = audio.LoopStart
		_loopEnd = audio.LoopEnd
		_filter = audio.Filter
		_path = audio.Path
		_bitCount = audio.BitCount

		_vol = audio.Volume
		_vol2 = audio.Volume2
		_echo = audio.Echo
		_porta = audio.Porta
		_portaSpeed = audio.PortaSpeed
		_startSeg = audio.StartSeg

		_owned = True
		_data = Cast<UByte Ptr>( GCMalloc( BytesPerSample( _format )*_length ) )
		
		Select _format
			Case AudioFormat.Mono8, AudioFormat.Mono16
				Local k:int
				For k = 0 Until _length
					SetSample( k, audio.GetSample( k ) )
				Next

			Case AudioFormat.Stereo8, AudioFormat.Stereo16
				Local k:int
				For k = 0 Until _length
					SetSample( k, audio.GetSample( k, 0 ), 0 )
					SetSample( k, audio.GetSample( k, 1 ), 1 )
				Next
		End
		_locked = False
	End
	
	Method New( audio:AudioData, length:int )
		_locked = true
		_length = length
		_format = audio.Format
		_hertz = audio.Hertz
		_looped = audio.Loop
		_loopStart = audio.LoopStart
		_loopEnd = audio.LoopEnd
		_filter = audio.Filter
		_path = audio.Path
		_bitCount = audio.BitCount
		_owned = True

		_vol = audio.Volume
		_vol2 = audio.Volume2
		_echo = audio.Echo
		_porta = audio.Porta
		_portaSpeed = audio.PortaSpeed
		_startSeg = audio.StartSeg

		_data = Cast<UByte Ptr>( GCMalloc( BytesPerSample( _format )*_length ) )
		
		Select _format
			Case AudioFormat.Mono8, AudioFormat.Mono16
				Local k:int
				For k = 0 Until _length
					SetSample( k, audio.GetSample( k ) )
				Next

			Case AudioFormat.Stereo8, AudioFormat.Stereo16
				_data = Cast<UByte Ptr>( GCMalloc( BytesPerSample( _format )*_length ) )
				
				Local k:int
				For k = 0 Until _length
					SetSample( k, audio.GetSample( k, 0 ), 0 )
					SetSample( k, audio.GetSample( k, 1 ), 1 )
				Next

		End
		_locked = false
	End
	
	property Locked:bool()
		Return _locked
	End
#-
	
	#rem monkeydoc The length, in samples, of the audio.
	#end
	Property Length:Int()
		Return _length
	End
	
	#rem monkeydoc The format of the audio.
	#end
	Property Format:AudioFormat()
		Return _format
	End
	
	#rem monkeydoc The playback rate of the audio.
	#end
	Property Hertz:Int()
		Return _hertz
	End

	#rem monkeydoc The duration, in seconds, of the audio.
	#end
	Property Duration:Double()
		Return Double(_length)/Double(_hertz)
	End

	#rem monkeydoc The actual audio data.
	#end	
	Property Data:UByte Ptr()
		Return _data
	End

	#rem monkeydoc The size, in bytes of the audio data.
	#end	
	Property Size:Int()
		Return BytesPerSample( _format ) * _length
	End

'jl added
#-
	#rem monkeydoc The bitsize, this will be either 8 or 16.
	#end	
	property Bits:int()
		if _format = AudioFormat.Mono8 or _format = AudioFormat.Stereo8 Then
			Return 8
		End If
		Return 16
	End

	#rem monkeydoc The original bitcount 8/12/16/24/32
	#end	
	property BitCount:int()
		Return _bitCount
	Setter( bitCount:int )
		_bitCount = bitCount
	End
	
	#rem monkeydoc Is the ausio Stereo? This will be either true for stereo or false for mono.
	#end	
	property Stereo:bool()
		if _format = AudioFormat.Stereo16 or _format = AudioFormat.Stereo8 Then
			Return True
		End If
		Return False
	End
	
	
	#rem monkeydoc Returns true if a loop has been set
	#end	
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


	Property Volume:ubyte()
		Return _vol
	Setter( vol:ubyte )
		_vol = vol
	End
	Property Volume2:ubyte()
		Return _vol2
	Setter( vol2:ubyte )
		_vol2 = vol2
	End

	Property Echo:ubyte()
		Return _echo
	Setter( echo:ubyte )
		_echo = echo
	End

	Property StartSeg:ubyte()
		Return _startSeg
	Setter( startSeg:ubyte )
		_startSeg = startSeg
	End

	Property PortaSpeed:ubyte()
		Return _portaSpeed
	Setter( speed:ubyte )
		_portaSpeed = speed
	End

	Property Porta:bool()
		Return _porta
	Setter( porta:bool )
		_porta = porta
	End

	#rem monkeydoc Returns true if a CMI Mode1 voice  has been detected
	#end	
	Property Mode1:bool()
		Return _mode1
	Setter( mode1:bool )
		_mode1 = mode1
	End

	Property Path:string()
		Return _path
	Setter( path:string )
		_path = path
	End
#-
	
	#rem monkeydoc Sets a sample at a given sample index.

	`index` must be in the range [0,Length).
	
	#end
	Method SetSample( index:Int,sample:Float,channel:Int=0 )
		'jl added
		If index < 0 or index >= _length Then Return

		DebugAssert( index>=0 And index<_length )
		Select _format
		Case AudioFormat.Mono8
			_data[index]=Clamp( sample * 128.0 + 128.0,0.0,255.0 )
		Case AudioFormat.Stereo8
			_data[index*2+(channel&1)]=Clamp( sample * 128.0 + 128.0,0.0,255.0 )
		Case AudioFormat.Mono16
			Cast<Short Ptr>( _data )[index]=Clamp( sample * 32768.0,-32768.0,32767.0 )
		Case AudioFormat.Stereo16
			Cast<Short Ptr>( _data )[index*2+(channel&1)]=Clamp( sample * 32768.0,-32768.0,32767.0 )
		End
	End
	
	#rem monkeydoc Gets a sample at a given sample index.
	
	`index` must be in the range [0,Length).
	
	#end
	Method GetSample:Float( index:Int,channel:Int=0 )
		'jl added
		If index < 0 or index >= _length Then Return 0

		
		'Ok, note that this never returns quite +1.0 as there is one less int above 0 than below
		'eg: range of signed ints is [-128,+127]
		'
		DebugAssert( index>=0 And index<_length )
		Select _format
		Case AudioFormat.Mono8
			Return ( _data[index] - 128.0 ) / 128.0
		Case AudioFormat.Stereo8
			Return ( _data[index*2+(channel&1)] - 128.0 ) / 128.0
		Case AudioFormat.Mono16
			Return Cast<Short Ptr>( _data )[index]/32768.0
		Case AudioFormat.Stereo16
			Return Cast<Short Ptr>( _data )[index*2+(channel&1)]/32768.0
		End
		Return 0
	End

'jl added
#-
	Method Copy:AudioData()
		_locked = true
		Select _format
			Case AudioFormat.Mono8
				Local audio:AudioData = New AudioData( _length, _format, 44100 )
				audio.Loop = Loop
				audio.LoopStart = LoopStart
				audio.LoopEnd = LoopEnd
				audio.Filter = Filter
				audio.Mode1 = Mode1
				audio.Path = _path
				audio.BitCount = BitCount

				audio.Volume = _vol
				audio.Volume2 = _vol2
				audio.Echo = _echo
				audio.Porta = _porta
				audio.PortaSpeed = _portaSpeed
				audio.StartSeg = _startSeg
				
				Local k:int
				For k = 0 Until _length
					audio.SetSampleMono8( k, GetSampleMono8( k ) )
				Next
				
				_locked = False
				Return audio

			Case AudioFormat.Mono16
				Local audio:AudioData = New AudioData( _length, _format, 44100 )
				audio.Loop = Loop
				audio.LoopStart = LoopStart
				audio.LoopEnd = LoopEnd
				audio.Mode1 = Mode1
				audio.Path = _path
				audio.BitCount = BitCount

				audio.Volume = _vol
				audio.Volume2 = _vol2
				audio.Echo = _echo
				audio.Porta = _porta
				audio.PortaSpeed = _portaSpeed
				audio.StartSeg = _startSeg
				
				Local k:int
				For k = 0 Until _length
					audio.SetSampleMono16( k, GetSampleMono16( k ) )
				Next
				
				_locked = False
				Return audio
				
			Case AudioFormat.Stereo8
				Local audio:AudioData = New AudioData( _length, _format, 44100 )
				audio.Loop = Loop
				audio.LoopStart = LoopStart
				audio.LoopEnd = LoopEnd
				audio.Mode1 = Mode1
				audio.Path = _path
				audio.BitCount = BitCount
				
				audio.Volume = _vol
				audio.Volume2 = _vol2
				audio.Echo = _echo
				audio.Porta = _porta
				audio.PortaSpeed = _portaSpeed
				audio.StartSeg = _startSeg
				
				Local k:int
				For k = 0 Until _length
					audio.SetSampleStereo8( k, GetSampleStereo8( k, 0 ), 0 )
					audio.SetSampleStereo8( k, GetSampleStereo8( k, 1 ), 1 )
				Next
				
				_locked = False
				Return audio

			Case AudioFormat.Stereo16
				Local audio:AudioData = New AudioData( _length, _format, 44100 )
				audio.Loop = Loop
				audio.LoopStart = LoopStart
				audio.LoopEnd = LoopEnd
				audio.Mode1 = Mode1
				audio.Path = _path
				audio.BitCount = BitCount
				
				audio.Volume = _vol
				audio.Volume2 = _vol2
				audio.Echo = _echo
				audio.Porta = _porta
				audio.PortaSpeed = _portaSpeed
				audio.StartSeg = _startSeg
				
				Local k:int
				For k = 0 Until _length
					audio.SetSampleStereo16( k, GetSampleStereo16( k, 0 ), 0 )
					audio.SetSampleStereo16( k, GetSampleStereo16( k, 1 ), 1 )
				Next
				
				_locked = False
				Return audio
		End

		_locked = False
		Return Null
	End method

	Method GetSampleMono8:ubyte( index:Int )
		return _data[index]
	End method


	Method Clear()
		Select _format
			Case AudioFormat.Mono8
				Local k:int
				For k = 0 Until _length
					SetSampleMono8( k, 0 )
				Next

			Case AudioFormat.Mono16
				Local k:int
				For k = 0 Until _length
					SetSampleMono16( k, 0 )
				Next
				
			Case AudioFormat.Stereo8
				Local k:int
				For k = 0 Until _length
					SetSampleStereo8( k, 0, 0 )
					SetSampleStereo8( k, 0, 1 )
				Next

			Case AudioFormat.Stereo16
				Local k:int
				For k = 0 Until _length
					SetSampleStereo16( k, 0, 0 )
					SetSampleStereo16( k, 0, 1 )
				Next
		End
	End method


	Method GetSampleStereo8:ubyte( index:Int, channel:int )
		return _data[index*2+(channel&1)]
	End method
	
	Method GetSampleMono16:short( index:Int )
		return Cast<Short Ptr>( _data )[index]
	End method

	Method GetSampleStereo16:short( index:int, channel:int )
		return Cast<Short Ptr>( _data )[index*2+(channel&1)]
	End method

	Method SetSampleMono8( index:Int, sample:ubyte )
		_data[index] = sample
	End method

	Method SetSampleStereo8( index:Int, sample:ubyte, channel:int )
		_data[index*2+(channel&1)] = sample
	End method
	
	Method SetSampleMono16( index:Int, sample:Short )
		Cast<Short Ptr>( _data )[index] = sample
	End method

	Method SetSampleStereo16( index:Int, sample:short, channel:int )
		Cast<Short Ptr>( _data )[index*2+(channel&1)] = sample
	End method
#-
	
	#rem monkeydoc Loads audio data from a file.
	
	The file must be in "wav" or ".ogg" format.
	
	#end
	Function Load:AudioData( path:String )
	
		Select ExtractExt( path ).ToLower()
		Case ".wav" Return LoadAudioData_WAV( path )
		Case ".ogg" Return LoadAudioData_OGG( path )
		End
		
		Return Null
	End
	
	Protected
	
	#rem monkeydoc @hidden
	#end
	Method OnDiscard() Override
		
		If _owned GCFree( _data )
			
		_data=Null
	End
	
	#rem monkeydoc @hidden
	#end
	Method OnFinalize() Override
		
		If _owned GCFree( _data )
	End
	
	Private
	
	Field _length:Int
	Field _format:AudioFormat
	Field _hertz:Int
	Field _owned:Bool

	Field _data:UByte Ptr

'jl added
#-	
	field _bitCount:int = 16
	
	Field _looped:Bool
	Field _loopStart:int
	Field _loopEnd:int
	Field _filter:ubyte = 16

	field _vol:ubyte = 128
	field _vol2:ubyte = 128
	field _echo:ubyte
	field _porta:bool
	field _portaSpeed:ubyte
	field _startSeg:ubyte
	
	field _locked:bool = false

	field _path:String = ""
	field _mode1:bool = false
#-	
	
End
