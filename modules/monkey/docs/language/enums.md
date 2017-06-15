### Enums

`Enum` is a data type containing a set of UInt constants.

By default the members will receive  values starting from zero and incemented by one for each new member. You can assign a chosen value to each member when declaring them.

```
Enum myBasicEnum
	a,b,c 'a=0, b=1, c=2
End
```
```
Enum myCustomEnum
	a=7
	b=31,c,d 'c=32, d=33
End
```
The values can be accessed with the postfix member acces operator (`.`).
Enums values are implicitely converted to integral values when assigned to it.
```
Local i:UInt=myCustomEnum.b
```

You can also create `Enum` variables. An `Enum` variable contains a variable Uint value in addition to it's constant members (default value is zero). This value is of the Uint type.

Bitwise operators (|,&,~) can be used with Enums variables and Enums members to compute combinations. Such Enums most often contain powers of 2 numbers as members! (1,2,4,8,16,32,64,... and 0 if needed).

A bitmask Enum example:
```
Enum Flags 'a classic Enum. (4 bits bitmask)
	None=0
  A=$0001 'bin OOOI dec 1
  B=$0002 'bin OOIO dec 2
  C=$0004 'bin OIOO dec 4
  D=$0008 'bin IOOO dec 8
End
```
An enum with modifiers example (in this case the bitwise operators should be used with at least one modifier):
```
Enum Foo '(modifiers on 5th and 6th bit)
	None=0
	A=1,B,C,D,E,F,G,H,J,K,L,M ' max 15 because the 5th bit is used for modifier
	Modifier_A=$0010 'bin IOOOO dec 16
	Modifier_B=$0020 'bin IOOOOO dec 32
End
```

Some operations examples:
```
Local flags1:=Flags.A | Flags.B
Local flags2:=flags1 | Flags.C
Local flags3:=Flags.B & (flags1 ~ flags3.D)
```

If needed, you can 'extract' the variable value by simply assigning your `Enum` variable to a `UInt`.

```
Local i:UInt=flags1
```
