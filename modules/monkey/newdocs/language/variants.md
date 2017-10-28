
@manpage Variants

### Variants

The Variant type is a primitive type that can be used to 'box' values of any type.

The easiest way to create a variant is to cast a value to Variant (much like casting an Int to String etc), eg:

`Local v:=Variant( 10 )`

An uninitialized variant will contain a 'null' value (of type Void) until you assign something to it:

```
Local v:Variant
v=10				'variant now contains an int 10.
v="hello"			'variant now contains a string "hello".
```

A variant is 'true' if it contains any value with a non-void type (including a bool false value!) and 'false' if it is uninitialized and has no (void) type.

Any type of value can be implicitly converted to a variant, so you can easily pass anything to a function with variant parameters:

```
Function Test( v:Variant )
End

Function Main()
	Test( 1 )
	Test( "Hello" )
	Test( New Int[] )
	Test( Main )
End
```

To retrieve the value contained in a variant, you must explicitly cast the variant to the desired type:

```
Local v:=Variant( 100 )
Print Cast<Int>( v )
```

Note that the cast must specify the exact type of the value already contained in the variant, or a runtime error will occur:

```
Local v:=Variant( 10 )
Print Cast<String>( v )	'Runtime error! Variant contains an Int not a String!
```

The one exception to this is if the Variant contains a class object, in which case you can cast the variant to any valid base class of the object.
