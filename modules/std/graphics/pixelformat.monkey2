
Namespace std.graphics

#rem monkeydoc Pixel formats supported by pixmaps.

| PixelFormat	| Description
|:--------------|:-----------
| `Unknown`		| Unknown pixel format.
| `I8`			| 8 bit intensity.
| `A8`			| 8 bit alpha.
| `IA8`			| 8 bit intensity, alpha.
| `RGB8`		| 8 bit red, green, blue.
| `RGBA8`		| 8 bit red, green, blue, alpha.

Note: The `IA16`, `RGB24` and `RGBA32` formats have been deprecated in favor of `IA8`, `RGB8` and `RGBA8`.

#end
Enum PixelFormat

	Unknown
	
	I8
	A8
	IA8
	RGB8
	RGBA8

	I16F
	A16F
	IA16F
	RGB16F
	RGBA16F
	
	I32F
	A32F
	IA32F
	RGB32F
	RGBA32F
	
	Depth16
	Depth24
	Depth32

	'jl added
	Depth32F
	
	RGBE8
	
	'deprecated
	IA16=IA8
	RGB24=RGB8
	RGBA32=RGBA8

End

Function IsAlphaPixelFormat:Bool( format:PixelFormat )
	Select format
	Case PixelFormat.A8,PixelFormat.IA8,PixelFormat.RGBA8 Return True
	Case PixelFormat.A16F,PixelFormat.IA16F,PixelFormat.RGBA16F Return True
	Case PixelFormat.A32F,PixelFormat.IA32F,PixelFormat.RGBA32F Return True
	End
	Return False
End

Function IsDepthPixelFormat:Bool( format:PixelFormat )
	Return Int( format )>=Int( PixelFormat.Depth16 ) And Int( format )<=Int( PixelFormat.Depth32 )
End

Function IsFloatPixelFormat:Bool( format:PixelFormat )
	Return Int( format )>=Int( PixelFormat.I16F ) And Int( format )<=Int( PixelFormat.RGBA32F )
End

#rem monkeydoc Gets the number of bytes per pixel for a particular pixel format.
#end
Function PixelFormatDepth:Int( format:PixelFormat )

	Select format
		
	Case PixelFormat.I8 Return 1
	Case PixelFormat.A8 Return 1
	Case PixelFormat.IA8 Return 2
	Case PixelFormat.RGB8 Return 3
	Case PixelFormat.RGBA8 Return 4
		
	Case PixelFormat.I16F Return 2
	Case PixelFormat.A16F Return 2
	Case PixelFormat.IA16F Return 4
	Case PixelFormat.RGB16F Return 6
	Case PixelFormat.RGBA16F Return 8
		
	Case PixelFormat.I32F Return 4
	Case PixelFormat.A32F Return 4
	Case PixelFormat.IA32F Return 8
	Case PixelFormat.RGB32F Return 12
	Case PixelFormat.RGBA32F Return 16

	Case PixelFormat.Depth16 Return 2
	Case PixelFormat.Depth24 Return 4
	Case PixelFormat.Depth32 Return 4

		'jl added
		Case PixelFormat.Depth32F Return 4

	Case PixelFormat.RGBE8 Return 4
		
	End
	
	Return 0
End
