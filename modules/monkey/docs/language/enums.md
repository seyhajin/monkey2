### Enums

`Enum` is a data type containing a set of integer constants.

By default the members will receive integer values starting from zero and incemented by one for each new member. You can assign a chosen value to each member when declaring them.

```
Enum myBasicEnum
	a,b,c 'a=0, b=1, c=2
End
```
```
Enum myCustomEnum
	a=7
	b=31
End
```
The values can be accessed with the postfix member acces operator (`.`).
```
Local i:Int=myCustomEnum.b
```

You can also create `Enum` variables. An `Enum` variable contains a 'combination' value in addition to it's constant members (default value is zero).

Bitwise operators (|,&,~) can be used with Enums variables and Enums members to define such combinations. It is higly advised to have single non-zero bit numbers as members!(i.e. powers of 2: 1,2,4,8,16,32,64,...not 0!)

A bitmask Enum example:
```
Enum Flags 'a classic Enum. (4 bits bitmask)
  A=$0001 'bin OOOI dec 1
  B=$0002 'bin OOIO dec 2
  C=$0004 'bin OIOO dec 4
  D=$0008 'bin IOOO dec 8
End
```
Some operations examples:
```
Local flags1:=Flags.A | Flags.B
Local flags2:=flags1 | Flags.C
Local flags3:=Flags.B & (flags1 ~ flags3.D)
```

You can 'extract' the 'combination' value by simply assigning your Enum variable to an integer.

```
Local i:Int=flags1
```
