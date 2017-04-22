
#Import "<libc>"

Namespace std.audio

Private

Using std.stream

Struct WAV_Header
	'
	Field RIFF:Int
	Field len:Int
	Field WAVE:Int
	'
End

Struct FMT_Chunk
	
	Field compType:Short
	Field numChannels:Short
	Field samplesPerSec:Int
	Field avgBytesPerSec:Int
	Field blockalignment:Short
	Field bitsPerSample:Short
	
End

Function ReadWAV:AudioData( stream:std.stream.Stream )

	Local wav:=New WAV_Header
	Local wav_sz:=libc.sizeof( wav )
	
	If stream.Read( Varptr wav,wav_sz )<>wav_sz Return Null

	If wav.RIFF<>$46464952 Return Null
	If wav.WAVE<>$45564157 Return Null
	
	Local format:AudioFormat
	Local hertz:Int
	
	While Not stream.Eof
		
		Local tag:=stream.ReadInt()
		Local size:=stream.ReadInt()
		
		Select tag
		Case $20746d66		'FMT
			
			Local fmt:=New FMT_Chunk
			Local fmt_sz:=sizeof( fmt )
			
			If stream.Read( Varptr fmt,fmt_sz )<>fmt_sz Return Null
			
			Local n:=size-fmt_sz
			If n>0 And stream.Skip( n )<>n Return Null
			
			If fmt.compType<>1 Return Null
			
			If fmt.numChannels=1 And fmt.bitsPerSample=8
				format=AudioFormat.Mono8
			Else If fmt.numChannels=1 And fmt.bitsPerSample=16
				format=AudioFormat.Mono16
			Else If fmt.numChannels=2 And fmt.bitsPerSample=8
				format=AudioFormat.Stereo8
			Else If fmt.numChannels=2 And fmt.bitsPerSample=16
				format=AudioFormat.Stereo16
			Else
				Return Null
			Endif
			
			hertz=fmt.samplesPerSec

			Continue
			
		Case $61746164		'DATA
			
			If Not format Return null

			Local data:=New AudioData( size/BytesPerSample( format ),format,hertz )

			stream.Read( data.Data,size )
			
			Return data
		
		End
		
		stream.Skip( size )
		
	Wend
	
	Return null

End

Public

Function LoadAudioData_WAV:AudioData( path:String )

	Local stream:=std.stream.Stream.Open( path,"r" )
	If Not stream Return Null
	
	Local data:=ReadWAV( stream )
	
	stream.Close()
	Return data

End
