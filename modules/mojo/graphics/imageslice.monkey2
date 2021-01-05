
Namespace mojo.graphics

#rem monkeydoc The ImageSlice class.

An imageslice is a rectangular array of pixels that can be drawn by [Canvas.DrawQuadImageSlice] methods

You can load an image from a file using one of the [[Load]] function.

#end

class ImageSlice

	Method New( )
	End method

	Method New( image:string )
		ImportPngSlices( image )
	End method

	
	property ImagePath:string()
		Return _imagePath
	setter( imagePath:string )
		ImportPngSlices( imagePath )
	end

	property Image:Image()
		Return _image
	end

	property Width:int()
		Return _sliceX
	End

	property Height:int()
		Return _sliceY
	End
	
	property FrameCount:int()
		Return _frames
	end

	property SliceXCount:int()
		Return _sliceXCount
	End

	property SliceYCount:int()
		Return _sliceYCount
	end

	property SliceCount:int()
		Return _sliceCount
	end


	field _sliceLive:bool[, ] = New bool[ 12, 42 ]
	field _sliceTexCoords:Rectf[, ] = New Rectf[ 12, 42 ]
	
private
	
	method ImportPngSlices( filePath:string )
		_imagePath = ""
		If Not filePath Return
		if ExtractExt( filePath ).ToLower() <> ".png" Then Return
		
		Local fStream:Stream = Stream.Open( filePath, "r" )
		If not fStream Then
			Print filePath + " not opened"
			Return
		End If
		fStream.Close()
		
		Local file:string = StripDir(filePath)
		If file.Find("_") < 0 Then Return

'		Print file+" ok"
		
'		Print "png ok"
		Local Split:String[] = file.Split("_")
		Local SplitL:string = Split[Split.Length - 1]
		If SplitL.Contains("x") And SplitL.Contains(".png") Then
			_image = Image.Load( filePath )
			If Not _image Then
				Print "Can't load image"
				Return
			End If
			_imagePath = filePath

			Local hezKind:bool = SplitL.Mid( SplitL.Length-6, 1 ) = "x"

			Local maxX:int = Int(SplitL.Split("x")[0])
			Local maxY:int = Int(SplitL.Split("x")[1])

			Local maxZ:int
			Local mz:string = SplitL.Split("x")[2]
			If hezKind Then
				maxZ = int( mz.Split("x")[0] )
'				Print "hezkind"
			Else
				maxZ = int( mz.Split("f")[0] )
			End If

'			_frames = int( SplitL.Mid( SplitL.Length-5, 1 ) )
			Local f1:string = SplitL.Mid( SplitL.Length-6, 1 )
			Local f2:string = SplitL.Mid( SplitL.Length-6, 2 )
			_frames = int( f1 )
			If f2.Right( 1 ) <> "." Then _frames = int( f2 )
			If _frames = 0 Then _frames = int( SplitL.Mid( SplitL.Length-5, 1 ) )

			if _frames < 1 Then _frames = 1
			If maxZ < 1 Then maxZ = 1
'			Print "contains  maxx="+maxX+" maxy="+maxY+" maxz(height)="+maxZ+" frames="+_frames
			
			_frameWidth = _image.Width / _frames
'			Print "image width="+_image.Width+" height="+_image.Height+" frameWidth="+_frameWidth

			Local pixImage:Pixmap = Pixmap.Load( filePath )
			If Not pixImage Then
				Print "Can't load pixmap"
				Return
			End If

			
			_sliceX = maxX
			_sliceXCount = _frameWidth / maxX
			_sliceY = maxY
			_sliceYCount = _image.Height / maxY
			_sliceCount = maxZ -1


			Local x:int
			Local y:int
			Local xp:int
			Local yp:int
			Local slice:int
			Local col:Color
			Local sx:int
			Local sy:int
			Local frame:int
			Local frameX:int
			
			Local liveSlice:bool
			
			If hezKind Then

				For frame = 0 To _frames -1
					For slice = 0 until maxZ

						liveSlice = false

						For y = 0 Until maxY
							For x = 0 until maxX
								col = pixImage.GetPixel( xp+x, yp+y )
	'							Print col.r+" "+col.g+" "+col.b+" "+col.a
								If col.a > 0 Then
									If col.a > 0 Then
										liveSlice = true
									End If
								End If
							Next
						Next

						_sliceLive[frame, slice] = liveSlice
'						If liveSlice Then
'							Print "slice "+slice+" live"
'						Else
'							Print "slice "+slice+" -"
'						End If

						xp += maxX
						If xp >= pixImage.Width Then
							xp = 0
							yp += maxY
						End If
					Next
				next

			Else
				frameX = 0
				For frame = 0 To _frames -1
				
					sx = 0
					sy = 0
				
					For slice = 0 until maxZ
						yp = sy

						liveSlice = false

						For y = 0 Until maxY
							xp = sx
							For x = 0 until maxX
								If xp + frameX < pixImage.Width And yp < pixImage.Height Then
									col = pixImage.GetPixel( xp + frameX, yp )
		'							Print col.r+" "+col.g+" "+col.b+" "+col.a
									If col.a > 0 Then
										liveSlice = true
									End If
								End if
								xp += 1
							Next
							yp += 1
						Next
						
						_sliceLive[frame, slice] = liveSlice
'						If liveSlice Then
'							Print "slice "+slice+" live"
'						Else
'							Print "slice "+slice+" -"
'						End If

						_sliceTexCoords[frame, slice] = Image.TexCoords
						local frameWidth:double = (_sliceTexCoords[frame, slice].max.x - _sliceTexCoords[frame, slice].min.x) / FrameCount
						Local wd:double = frameWidth / SliceXCount
						Local ht:double = 1.0 / SliceYCount
				
						_sliceTexCoords[frame, slice].min.x = _sliceTexCoords[frame, slice].min.x + ((slice Mod SliceXCount) * wd) + (frameWidth * frame)
						_sliceTexCoords[frame, slice].max.x = _sliceTexCoords[frame, slice].min.x + wd
				
						_sliceTexCoords[frame, slice].min.y = _sliceTexCoords[frame, slice].min.y + (int(slice / SliceXCount) * ht)
						_sliceTexCoords[frame, slice].max.y = _sliceTexCoords[frame, slice].min.y + ht
				
						_sliceTexCoords[frame, slice].min.x += 0.0001
						_sliceTexCoords[frame, slice].max.x -= 0.0001
						_sliceTexCoords[frame, slice].min.y += 0.0001
						_sliceTexCoords[frame, slice].max.y -= 0.0001
						
						sx += maxX
						If sx >= _frameWidth Then
							sx = 0
							sy += maxY
						End If
					Next
					
					frameX += _frameWidth
				next
			End If
			


			pixImage.Discard()
		End If
	End method

	field _frames:int
	field _frameWidth:int
	
	field _sliceX:int
	field _sliceXCount:int
	field _sliceY:int
	field _sliceYCount:int
	field _sliceCount:int

	Field _image:Image
	field _imagePath:string
End
