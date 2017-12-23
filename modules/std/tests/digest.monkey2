
#Import "<std>"

Using std..

Function Main()
	Print ""
	Print "==== MD5 ===="
	Print MD5("The quick brown fox jumps over the lazy dog")
	Print "9e107d9d372bb6826bd81d3542a419d6 <- Should be this"
	Print ""
	Print "===== SHA-1 ====="
	Print SHA1("The quick brown fox jumps over the lazy dog")
	Print "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12 <- Should be this"
	Print ""
	Print "===== SHA-256 ====="
	Print SHA256("The quick brown fox jumps over the lazy dog")
	Print "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592 <- Should be this"
End
