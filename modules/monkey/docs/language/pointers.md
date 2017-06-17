
### Pointers

Pointers are special variables containing a memory adress.
In Monkey2 pointers are mainly used with external C/C++ code.
It is not advised to use pointers if not necessary. It can lead to bug if the pointed adress is not kept "alive". Pointer to globals are safe for example.  
You must have acces to the memory you try to reach or you'll have a (fatal) memory acces violation.

A pointer can point to any kind of type, even garbage collected types. This can lead to bad things too as the garbage collector is not 'aware' of pointers.

#### Declaration

Use the `Ptr` keyword to declare a pointer.


```
Local myPtr:int Ptr

Local anotherPtr:Void Ptr
```

#### Referencing

Use the `VarPtr` operator to reference a pointer

```
Local i:int=1
Local myPtr:int Ptr

myPtr=VarPtr i
```
The myPtr pointer now points to the variable i

#### Dereferencing with []

You can access the pointed value(s) with the `[]` index operator

```
Local i:int=1
Local myPtr:int Ptr

myPtr=VarPtr i
Print myPtr[0]
```
Will print 1, the value of i.
Note you can use pointer arythmetics with the index operator([]) but you have to be sure you have access to that part of the memory or you'll get a memory acces violation!

#### Dereferencing with ->

You can acces user defined types fields, methods,.. with the `->` operator. It is equivalent to `[0].`

```
Struct str
	Field i:Int=1
End

Function Main()
   Local s:=New str
   Local strPtr:str Ptr
   strPtr=VarPtr s

   Print strPtr->i
End
```
will show the value of the struct's field i

#### Casting

You can Cast a pointer and do some explicit conversions with the `Cast` operator.

`Cast`<_Type_>(_adress_)

An example with a useless conversion from Int to Void to Int:
```
Local i:int=1
Local myVoidPtr:Void Ptr

myVoidPtr=Cast<Void Ptr>(VarPtr i)

Local j:int
Local myIntPtr:Int Ptr

myIntPtr=Cast<Int Ptr>(myVoidPtr)
j=myIntPtr[0]
```
j receives to value of i but does not have the same adress.
myIntPtr and myVoidPtr both points to the same adress(VarPtr i) but have different types.
