
'a console app is the simplest kind of app.
'It has no window and just responds via the console

'namespace is what we call the app.
'Other files with the same namespace will behave as if they are a single unified file
Namespace myConsoleApp

'we need to import the standard library <std>
#Import "<std>"

'using means we dont have to preface commands with std. all the time
Using std..


'here is the main function which is called. and the simplest text "hello world" is outputted to the console
Function Main()
	Print "Hello World"
End