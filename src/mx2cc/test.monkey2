#Import "<std>"

Function SearchMods:String[](path:String)
	
	Local result:=New std.collections.List<String>
	
	Return result.ToArray<Int>()
End

Function Main()
	
	SearchMods("")
End