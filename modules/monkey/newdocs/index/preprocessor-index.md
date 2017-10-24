
@manpage Preprocessor directives and symbols

#Preprocessor directive and symbols


This section list the directives and symbols that can be used with the [[preprocessor|preprocessor]].


@### Preprocessor directives


@#### #If

The `#If` directive allows you to conditionally execute a block of statements depending on the result of a series of boolean expressions.


@#### #Else if

To be combined with #if


@#### #Else

To be combined with #if


@#### #EndIf

Ends an #if


@#### #Rem

Used to for multiline comments


@#### #End

Ends an #if or #rem


@#### #Import

Used to import modules, code or assets.

See [[modules-and-applications|Modules and applications]] and [[asset-management|Asset management]].


@### Preprocessor symbols

@#### __TARGET__

The __TARGET__ symbol is set to the current build target and will be one of the following values: “windows”, “macos”, “linux”, “emscripten”, “android” or “ios” – ie: the precise build target.


@#### __CONFIG__

The __CONFIG__ symbol is set to the current build config and will be set to either "debug" or "release".


@#### __DESKTOP_TARGET__

True if the current build target is desktop (“windows”, “macos” or “linux”), false otherwise.


@#### __MOBILE_TARGET__

True if the current build target is mobile (“android” or “ios”), false otherwise.


@#### __WEB_TARGET__

True if the current build target is web (“emscripten”), false otherwise.


@#### __DEBUG__

True if the current build config is "debug", false otherwise.


@#### __RELEASE__

Truw if the current build config is "release", false otherwsie.


@#### __MAKEDOCS__

True if mx2cc is currently making docs, false otherwise.
