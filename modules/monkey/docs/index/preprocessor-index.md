@manpage Preprocessor

Monkey2 Preprocessor Index
--

#### #If
Used to check preprocessor variables and modify your code depending on your options.

#### #Else if
To be combined with #if

#### #Else
To be combined with #if

#### #EndIf

Ends an #if

#### #Rem
Used to for multiline comments

#### #End
Ends an #if or #rem

#### #Import
Used to import modules, code or assets. See "Modules and Applications" section

#### __TARGET__
Is set to one of the following values: “windows”, “macos”, “linux”, “emscripten”, “android” or “ios” – ie: the precise target.

#### __DESKTOP_TARGET__

`True` if target is desktop(“windows”, “macos”, “linux”), False otherwise.

#### __MOBILE_TARGET__

True if target is mobile(“android” or “ios”), False otherwise.

#### __WEB_TARGET__

True if target is web (“emscripten”), False otherwise.

#### __CONFIG__
Is set to one of the following values: "debug" or "release"

#### __DEBUG__
`True` if the current build config is debug.

#### __RELEASE__
`True` if the current build config is release.
