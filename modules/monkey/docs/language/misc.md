### Miscellaneous

#### File Encapsulation

There are two Levels of encapsulation at .monkey2 source files scope: `Public`and `Private` (`Protected` can only be used inside a class, struct or interface).

`Public` can be accessed from anywhere. It is the default encapsulation level. Code existing in the same source file have also acces to expressions declared as `Private`.

example:
```
Namespace myapp
#Import "<std>"
Using std..

Function Main()
	SayHello()
End

Private 'this section won't be accessible in other imported files

Function SayHello()
  Print "Hello"
End
```

#### Code lines splitting

Lines can currently only be split after ‘[‘, ‘(‘ or ‘,’ tokens.

#### $ Hexadecimal

Hexadecimal numbers can be entered using the $ symbol
```
Local i:=$A0F
```
