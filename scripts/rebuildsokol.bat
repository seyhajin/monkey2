
echo off

echo.
echo ***** Rebuilding Sokol *****
echo.

..\bin\mx2cc_windows makemods -clean -config=release -target=desktop sokol
..\bin\mx2cc_windows makemods -clean -config=debug -target=desktop sokol
