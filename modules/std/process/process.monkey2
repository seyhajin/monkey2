
Namespace std.process

#If __TARGET__<>"emscripten"

#Import "native/process.cpp"
#Import "native/procutil.cpp"
#Import "native/process.h"

Extern

#rem The Process class.

Note that stderr output handling is not yet implemented.

#end
Class Process="bbProcess"

	#rem monkeydoc Invoked when process has finished executing.
	#end
	Field Finished:Void()="finished"
	
	#rem monkeydoc Invoked when process has written to stdout.
	#end
	Field StdoutReady:Void()="stdoutReady"
	
	#rem monkeydoc Invoked when proces has written to stderr (TODO).
	#end
	Field StderrReady:Void()="stderrReady"
	
	#rem monkeydoc Process exit code.
	#end
	Property ExitCode:Int()="exitCode"

	#rem monkeydoc Process stdout bytes available to read.
	#end	
	Property StdoutAvail:Int()="stdoutAvail"

	#rem monkeydoc Process stder bytes available to read (TODO).
	#end	
	Property StderrAvail:Int()="stderrAvail"
	
	#rem monkeydoc Starts a new process.
	#end
	Method Start:Bool( cmd:String )="start"

	#rem monkeydoc Read process stdout.
	#end	
	Method ReadStdout:String()="readStdout"
	
	Method ReadStdout:Int( buf:Void Ptr,count:Int )="readStdout"

	#rem monkeydoc Read process stderr (TODO).
	#end	
	Method ReadStderr:String()="readStderr"
	
	Method ReadStderr:Int( buf:Void Ptr,count:Int )="readStderr"

	#rem monkeydoc Write process stdin.
	#end
	Method WriteStdin( str:String )="writeStdin"
	
	Method WriteStdin:Int( buf:Void Ptr,count:Int )="writeStdin"

	#rem monkeydoc Send break signal to process.
	#end	
	Method SendBreak()="sendBreak"
	
	#rem monkeydoc Terminate process.
	#end
	Method Terminate:Void()="terminate"

End

#Endif
