### Enums

`Enum` is a data type containing a set of integer constants. These constants can be combined (added) with the \| token.

By default the members will receive integer values starting from zero and incemented by one for each new member. You can assign a chosen value to each member when declaring them.

```
Enum myEnum
	a,b,c 'a=0, b=1, c=2
End
```

```
Enum myDecimalEnum
	a=1
	b=10
	c=100
End
Local i:int= myDecEnum.b|myDecEnum.c  'i=110'
```

You can also create a new enum variable. It can contain a default 'combination' value.

```
Local e:myDecimalEnum
e=e.a|e.c 'e has now the a and c as default combination
i=e
print i 'prints 101
i=e.b 'e still contains all the set of constants
print i 'prints 10
```

Combining twice the same member has no effect.
