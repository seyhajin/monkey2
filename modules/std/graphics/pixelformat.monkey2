
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

	RGBA16F
	RGBA32F
	
	Depth16
	Depth24
	Depth32

	'deprecated
	IA16=IA8
	RGB24=RGB8
	RGBA32=RGBA8

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
	Case PixelFormat.RGBA16F Return 8
	Case PixelFormat.RGBA32F Return 16
	Case PixelFormat.Depth16 Return 2
	Case PixelFormat.Depth24 Return 4
	Case PixelFormat.Depth32 Return 4
		
	'deprecated
	Case PixelFormat.IA16 Return 2
	Case PixelFormat.RGB24 Return 3
	Case PixelFormat.RGBA32 Return 4
		
	End
	
	Return PixelFormat.Unknown
End
