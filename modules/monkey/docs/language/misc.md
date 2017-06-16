### Miscellaneous

#### Encapsulation

There are three Levels of encapsulation in monkey2: `Public`, `Protected` and `Private`. `Public` and `Private` are applicable to variables, functions, structs, classes, interfaces. `Protected` can only be used inside a class, struct or interface.

`Public` can be accessed from anywhere. It is the default encapsulation level.

`Protected` members can only be accessed by the base class and the derived ones or by class/struct extentions. Code existing in the same source file have acces to `Protected` too.

`Private` members can only be accessed by the base class. Code existing in the same source file have acces to `Private`.


#### Code lines splitting

Lines can currently only be split after ‘[‘, ‘(‘ or ‘,’ tokens.

#### $ Hexadecimal

Hexadecimal numbers can be entered using the $ symbol
```
Local i:=$A0F
```
