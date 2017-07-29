@manpage Keywords

#### Abstract

Used while declaring classes: class cannot be instantiated with `New`, it must be extended.
<br>
<a href="javascript:void('monkey:user-types#classes')" onclick="openDocsPage('monkey:user-types#classes')">See Classes.</a>
&nbsp;

#### Alias

Used for convenience types. For example `Vec2i` is a convenience type alias for `Vec2<Int>`.

Used to import extern typedefs too.
<br>
<a href="javascript:void('monkey:user-types#extensions')" onclick="openDocsPage('monkey:user-types#extensions')">See Alias.</a>
&nbsp;


#### Array

`Array` is not currently used but is reserved for future use.

<br>
<a href="javascript:void('monkey:arrays#arrays')" onclick="openDocsPage('monkey:arrays#arrays')">See arrays.</a>
&nbsp;

#### Case

To be combined with with the `Select` statement.

<br>
<a href="javascript:void('monkey:conditional-statements#select')" onclick="openDocsPage('monkey:conditional-statements#select')">See Select.</a>
&nbsp;

#### Cast

Allows you to cast custom pointers.

<br>
<a href="javascript:void('monkey:pointers#casting')" onclick="openDocsPage('monkey:pointers#casting')">See pointer casting.</a>
&nbsp;

#### Catch

The `Catch` keyword is part of the Try/Catch exception-handling construct.

<br>
<a href="javascript:void('monkey:error-handling#error-handling')" onclick="openDocsPage('monkey:error-handling#error-handling')">See error handling.</a>
&nbsp;

#### Class

Marks the start of a class object definition.

<br>
<a href="javascript:void('monkey:arrays#arrays')" onclick="openDocsPage('monkey:arrays#arrays')">See Arrays.</a>
&nbsp;

#### Const

Allows you to declare a constant.

<br>
<a href="javascript:void('monkey:arrays#arrays')" onclick="openDocsPage('monkey:arrays#arrays')">See Arrays.</a>
&nbsp;

#### Continue

Used to skip a loop.

<br>
<a href="javascript:void('monkey:loop-statements#loop-statements')" onclick="openDocsPage('monkey:loop-statements#loop-statements')">See loops.</a>
&nbsp;

#### CString

Reserved keyword.
C style String for external string parameters.

#### Default

Marks the start of the default code block of a `Select` statement.

<br>
<a href="javascript:void('monkey:conditional-statements#select')" onclick="openDocsPage('monkey:conditional-statements#select')">See Select.</a>
&nbsp;

#### Delete

`Delete` is not currently used but is reserved for future use.

#### Eachin

Allows you to use `For` loop with collections.

<br>
<a href="javascript:void('monkey:loop-statements#for--eachin')" onclick="openDocsPage('monkey:loop-statements#for--eachin')">See For(Eachin).</a>
&nbsp;

#### Else

To be combined with the `If` statement.

/linkto Conditional-statements.If \linkto

#### Elseif

To be combined with the `If` statement.

/linkto Conditional-statements.If \linkto

#### End

Ends all kind of declarations/statements

#### Endif

Ends `If` statement.

/linkto Conditional-statements.If \linkto

#### Enum

??? not documented

#### Exit

Used to terminate a loop.

/linkto Loop-statements \linkto

#### Extends

Used for class declaration.

/linkto User-defined-types \linkto

#### Extension

Used to add some features to an existing user defined type without inheritance.

??? not documented

/linkto User-defined-types \linkto

#### Extern

Marks the start of definitions for C/C++ imports.

/linkto Integration-with-native-code \linkto

#### False

Boolean False value

#### Field

Fields are variables that live inside the memory allocated for an instance of a class or struct.

/linkto User-defined-types \linkto

#### Final

Methods declared as `Final` are non-virtual and cannot be overridden by a subclass method.

/linkto User-defined-types \linkto

#### For

Merks the start of a `For` loop

/linkto Loop-statements \linkto

#### Forever

Used at the end of a `Repeat` loop. The loop will loop forever unless `Exit` is called.

/linkto Loop-statements \linkto

#### Friend

`Friend` is not currently used but is reserved for future use.

#### Function

Used to declare a function within a struct, a class or at global scope.

/linkto Functions \linkto

/linkto User-defined-types \linkto

#### Getter

`Getter` is not currently used but is reserved for future use.

#### Global

Global variables live in global memory and exist for the lifetime of the application.

/linkto Variables \linkto

#### If

The `If` statement allows you to conditionally execute a block of statements depending on the result of a series of boolean expressions.

/linkto Conditional-statements \linkto

#### Implements

Used to declare classes implementing an interface.
`Implements` can also be combined with `where` to check type constrain on generics.

/linkto User-defined-types \linkto

#### Import

Assets and code files can be imported with 'Import'

/linkto Modules-and-Applications \linkto
/linkto ???Assets??? \linkto

#### Inline

`Inline` is not currently used but is reserved for future use.

#### Interface

Interfaces are Class models definition. It's a pure abstract object to be implemented by a `Class`.

/linkto User-defined-types \linkto

#### Internal

`Internal` is not currently used but is reserved for future use.

#### Lambda

A lambda function is a special type of function that can be declared in the middle of an expression.

/linkto Functions \linkto

#### Local

Local variables live on the stack. They are lost once their scope is exited.

/linkto Variables \linkto

#### Method

A Method is special type of function that lives with a Class or a Struct. It can acces the object fields.

/linkto User-defined-types \linkto

#### Namespace

All identifiers declared in a monkey2 program file end up inside a 'namespace'.

/linkto Namespaces-and-Using \linkto

#### New

`New` calls a Class, Struct or Array constructor. It must be called before using a Class or an Array. It is advised to call it before using a struct.

#### Next

Used at the end of a `For` loop.

/linkto Loop-statements \linkto

#### Operator

`Operator` is used to declare special methods using a set of available expressions (+,-,/,<>,...)

/linkto User-defined-types \linkto
/linkto Expressions \linkto

#### Override

Used to override a virtual method when declaring a sub-Class.
/linkto User-defined-types \linkto

#### Print

Prints a String or a numeric Value to the output console.

#### Private

Sets the acces control of a Class or Struct members to "Private". Private members can only be accessed by the original class OR by any code within the same .monkey2 file.

/linkto User-defined-types \linkto

#### Property

Property is a special type of field that may include some getter/setter additionnal code if desired.

/linkto User-defined-types \linkto

#### Protected

Sets the acces control of a Class or Struct members to "Protected". Protected members can only be accessed by the original class and subclasses OR by any code within the same .monkey2 file.

/linkto User-defined-types \linkto

#### Protocol

`Protocol` is not currently used but is reserved for future use.

#### Public

Sets the acces control of a Class or Struct members to "Public". Public members can be accessed from anywhere. It's the default level.

/linkto User-defined-types \linkto

#### Repeat

Used to start a `Repeat` loop

/linkto Loop-statements \linkto

#### Return

Used to end and send the expected value of a `Function`, `Method` or `Operator`

/linkto Functions \linkto
/linkto User-defined-types \linkto

#### Select

The Select statement allows you to execute a block of statements depending on a series of comparisons. `Select` combines with `Case` and `Default`

/linkto Conditional-statements.Select \linkto

#### Setter

Marks the start of a Property setter definition.

/linkto User-defined-types \linkto

#### Static

`Static` is not currently used but is reserved for future use.

#### Step

Defines the incrementation step for `Next` loops.

/linkto Loop-statements \linkto

#### Struct

Used to declare a `Struct`

/linkto User-defined-types \linkto

#### Then

Facultative keyword used in combination with the `If` keyword.

/linkto Loop-statements \linkto

#### Throw

The `Throw` keyword is part of the Try/Catch exception-handling construct.

/linkto Error-handling \linkto

#### Throwable

The Throwable class must be extended by all classes that are intended to be used with `Throw`.

/linkto Error-handling \linkto

#### To

Defines range of values to be assigned to the index variable in a For/Next loop.

/linkto Loop-statements \linkto

#### Try

Declares the start of a Try/Catch block.

/linkto Error-handling \linkto

#### TypeInfo

Returns the type of a variable/object.

/linkto Reflection \linkto

#### Until

Marks the end of a Repeat/Until loop. The `Until` keyword is also found as a modifier in For/Next loops.

/linkto Loop-statements \linkto

#### Using

The `Using` directive provides a way to add namespace 'search paths' for locating identifiers.

/linkto Namespaces-and-Using \linkto

#### Var

`Var` is not currently used but is reserved for future use.

#### Variant

The `Variant` type is a primitive type that can be used to 'box' values of any type.

/linkto Variants \linkto

#### Varptr

`Varptr` is used to reference pointers.

/linkto Pointers \linkto

#### Virtual

`Virtual` is not currently used but is reserved for future use. A virtual method is a method that can be overriden.

/linkto User-defined-types \linkto

#### Wend

Wend, short for While [loop] End, marks the end of a While loop.

/linkto Loop-statements \linkto

#### Where

`Where` allows generic type constrains.

/linkto Reflection \linkto

#### While

Marks the start of a While loop.

/linkto Loop-statements \linkto
