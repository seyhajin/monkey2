
@manpage Arrays

### Arrays

An array is a linear sequence of values that can be addressed using one or more integer indices.

Each array has an associated element type. That is, the type of the values actually stored in the array. An array's element type is a purely static property. It is only known at compile time so arrays cannot be 'downcast' at runtime.

The syntax used for declaring values and variables of array type is: 

_ElementType_ `[` [`,`...] `]`

An array can also be multidimensional, in which case the '[]' will contain 1 or more commas.

Here are some example of declaring array variables:

```
Local ints:Int[]			'One dimensional int array.
Local map[,]				'Two dimension int array.
Local funcs:Int()[]			'One dimensional array of functions of type Int().
Local stacks:Stack<Int>[]	'One dimensional array of stacks of type Int.
```

@#### Creating arrays

Declaring an array does not actually create an array. To do that you must use `New`.

`New` can be used to create either an unintialized or preinitialized array. The syntax for creating an uninitialized array is:

`New` _ElementType_ `[` _DimensionSizes_ `]`

(Note: the elements of an 'uninitialized' array are actually initialized to 'Null'!)

The syntax for creating an initialized array is:

`New` _ElementType_[]( _Element0_`,`_Element1_`,`...etc )

Here are some examples:

```
Local ints:Int[]=New Int[10]				'Creates a ten element integer array.
Local flts:=New Float[]( 1.0,3,5.1,7,9.2 )	'Creates a 5 element float array initialized to 1.0,3,5.1,7,9.2 
```

@#### Iterating through arrays

You can iterate through the elements of an array using `Eachin`, eg:

```
Local arr:=New Int[]( 1,3,5,7,9 )
For Local i:=Eachin arr
	Print i
Next
```

@#### Slicing arrays

One dimensional arrays can be sliced using the `Slice` method, eg:

```
Local ints:=New Int[]( 1,3,5,7,9 )
ints=ints.Slice( 1,4 )	'ints now contains 3,5,7
```

For more information, see the [[Array.Slice]] API documentation.


@#### Resizing arrays

One dimensional arrays can be resized using the `Resize` method, eg:

```
Local ints:=New Int[]( 1,2,3 )
ints=ints.Resize( 5 )	'ints now contains 1,2,3,0,0
```

(Note that resize does not actually resize the array! It actually returns a resized *copy* of the array.)

Note that mutidimensional arrays cannot currently be sliced or resized, and you cannot create an initialized multidimensional arrays. These features are planned for the future though.

For more information, see the [[types.Array.Resize|Array.Resize]] API documentation.
