
@manpage Strings

### Strings

Values of type String are used to represent sequences of characters, such as text. The exact size of each character in a string value is target dependent, but is at least 8 bits.

String variables are declared using the type name `String`, for example:

```
Local test:String="Hello World"
```

String literals are sequences of characters enclosed in "" (quotation marks). String literals may also include escape sequences, special sequences of characters used to represent unprintable characters.

You can use the following escape sequences in string literals:

| Escape sequence	| Character code
|:------------------|:--------------
|~q					| 34 (quotation mark ")
|~n					| 10 (newline)
|~r					| 13 (return)
|~t					| 9 (tab)
|~z					| 0 (null)
|~~	 				| 126 (tilde ~)

For example, to include literal quotation marks in a string...

```
Local test:="~qHello World~q" 
```

You can index a string using the `[]' operator, eg:
```
Local str:="Hello World"
For Local i:=0 Until str.Length
	Print str[i]
Next
```

Indexing a string will return the character code at a given string index as an int.

You can iterate through the characters in a string using `Eachin`, eg:

```
For Local chr:=Eachin "Hello World"
	Print chr
Next
```

For more information on strings, please see the [[types.String|String]] API reference.
