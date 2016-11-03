
Class OptionsView Extends View

	Method AddInt( text:String,value:Int,modified:Int( value:Int ) )
	End
	
	Method AddString( text:String,value:String,modified:String( value:String ) )
	End
	
	Method AddFilePath( text:String,value:String )
	End
	
	Method AddDirectoryPath( text:String,value:String )
	End
	
	Private
	
	Class Option
	
		Field label:Label
		Field view:View
		
		Method New( text:String )
		End
		
	End
	
	Class IntField Extends Option
	End
	
	Class StringField Extends Option
	End
	
	Class FilePathField Extends Option
	End
	
	Class DirectoryPathField Extends Option
	End
	
	Protected
	
	Method OnMeasure:Vec2i() Override
	
		Local w0:=0,w1:=0,h:=0
		
		For Local opt:=Eachin _options
			w0=Max( w0,opt.label.MeasuredSize.x )
			w1=Max( w1,opt.view.MeasuredSize.x )
			h+=Max( opt.label.MeasuredSize.y,opt.view.MeasuredSize.y )
		Next
		
		_w0=w0
		_w1=w1
		
		Return New Vec2i( w0+w1,h )
	End
	
	Method OnLayout() Override
	
		For Local opt:=Eachin _options
		
			opt.Frame=New Recti( x,y,x+_w0,y
		
		Next
	
	End
	
	Private
	
	Field _w0:Int,_w1:Int
	
	Field _options:=New Stack<Option>

End

Class ObjectView Extends View

	Method New( obj:Object )
	
		
	End

End
