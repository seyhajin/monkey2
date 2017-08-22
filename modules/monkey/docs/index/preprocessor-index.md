@manpage Preprocessor

#### #If
The `#If` directive allows you to conditionally execute a block of statements depending on the result of a series of boolean expressions.
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
Used to import modules, code or assets.

<br>
<a href="javascript:void('monkey:modules#importing-modules')" onclick="openDocsPage('monkey:modules#importing-modules')">See modules.</a>
&nbsp;
<br>
<a href="javascript:void('monkey:assets-management#importing-assets')" onclick="openDocsPage('monkey:assets-management#importing-assets')">See assets.</a>
&nbsp;
<br>
<a href="javascript:void('monkey:multifile-projects#multifile-projects-and--import')" onclick="openDocsPage('monkey:multifile-projects#multifile-projects-and--import')">See multifile projects.</a>
&nbsp;
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
