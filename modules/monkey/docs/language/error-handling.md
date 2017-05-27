### Error handling

A Try/Catch block is an error-handling construct that allows custom code to be executed in situations which may otherwise cause undesirable behaviour.

The Try/Catch block opens with Try and closes with End (or End Try). The code to be executed within must be followed by at least one Catch section.

In the event of an error occurring within the Try/Catch block, an exception object (based on the native Throwable class) should be 'thrown' via the Throw instruction.

If an exception occurs, program flow jumps to a Catch section declared explicitly for the given exception type. The exception object is 'caught' and the relevant error-handling code is executed.

You can declare multiple exception classes to handle different types of exception and should create a matching Catch section for each one.

After an exception is caught and handled, program flow exits the Try/Catch block and continues.

When a try block has multiple catch blocks and an exception is thrown, the first catch block capable of handling the exception is executed. If no suitable catch block can be found, the exception is passed to the next most recently executed try block, and so on.

If no catch block can be found to catch an exception, a runtime error occurs and the application is terminated.

The Try/Catch method of error-handling allows code to be written without the need to manually check for errors at each step, provided an exception has been set up to handle any errors that are likely to be encountered.

Syntax:

`Try`
code (sould contain at least one `throw`)
`Catch` exception
error handling code
`End`

Example code:

```
#Import "<std>"
Using std..

Class custoEx Extends Throwable
	Field msg:String

  Method New (mesag:String)
   Self.msg = mesag
  End
End

Function Main()
	Local somethingWrong:=True
	Try
		If somethingWrong=True Then Throw New custoEx ("Custom Exception detected")
	Catch err:custoEx
		Print err.msg
	End
End
```
