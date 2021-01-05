
echo off

echo.
echo ***** Rebuilding modules *****
echo.

..\bin\mx2cc_windows makemods -clean -config=release -target=desktop mojo
..\bin\mx2cc_windows makemods -clean -config=debug -target=desktop mojo
