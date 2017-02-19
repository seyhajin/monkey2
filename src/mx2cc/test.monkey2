
#Import "<std>"
#Import "<mojo>"
#Import "<mojox>"
#Import "test2"

Using std..
Using mojo..
Using mojox..

Class MyWindow Extends Window
	Method Testing()
		
		'Local dummy:=New CheckButton( "" ) ' uncomment this to 'fix' error
		
		Local widgets:=New Widgets
		Local v:View=widgets.checkBox
		
	End
End

Function Main()

	New AppInstance
	New MyWindow
	App.Run()	
End

