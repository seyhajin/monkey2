
@manpage Miscellaneous

### Miscellaneous

@#### Inline Code comments

Inline comments can be done with the `'` character.
```
Print "hello!" 'this line prints hello! on the output console
```

Multiline comments can be made with the `#Rem` preprocessor. See [[language-reference.preprocessor|preprocessor]]

@#### Line breaks in code

Lines can currently only be split after ‘[‘, ‘(‘ or ‘,’ tokens.

```
Local myArray:Int[] = New Int[](
    0,
    1,
    2)

Local myarray2:String[,] = New String[
    10,
    10]
```

@#### Print

Writes a String or a numeric value to the output console.

```
Print "Hello world" 'printing a String
Print myFloat 'printing a Float
```

@#### $ Hexadecimal

Hexadecimal numbers can be entered using the $ symbol
```
Local i:=$A0F
```

@#### File privacy levels

Privacy levels can be set at file scope:

-`Public` can be accessed from anywhere. It is the default level.

-`Private` can be accessed within the file only.

-`Internal` can be accessed from the same module only.

