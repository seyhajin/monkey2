
### Preprocessor

Monkey2 include a simple preprocessor that allows you to conditionally compile code depending on a number of build setttings.

The preprocessor supports the following statements: #If, #Else, #ElseIf, #EndIf, #Rem, #End. Preprocessor statements must begin on a new line.

Preprocessor expressions may only use the 'And', 'Or' and comparison operators.

The following symbols may be used in preprocessor expressions:

| Symbol			| Type		| Meaning
|:------------------|:----------|--------
|__TARGET__			| String	| The current build target. One of: "windows", "macos", "linux", "android", "ios", "emscripten"
|__CONFIG__			| String	| The current build config. One of: "release", "debug"
|__DESKTOP_TARGET__	| Bool		| True if the current build target is windows, macos or linux.
|__MOBILE_TARGET__	| Bool		| True if the current build target is android or ios.
|__WEB_TARGET__		| Bool		| True if the current build target is emscripten.
|__DEBUG__			| Bool		| True if the current build config is debug.
|__RELEASE__		| Bool		| True if the current build config is release.

For example, to include code in debug builds only, use something like:

```
#If __DEBUG__
Print "This code is only included in debug builds."
#Endif
```

To include code on desktop or mobile builds, use:

```
#If __DESKTOP_TARGET__ Or __MOBILE_TARGET__
Print "This code is only include in desktop and mobile builds."
#Endif
