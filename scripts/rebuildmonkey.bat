
echo off

echo.
echo ***** Rebuilding monokey *****
echo.

..\bin\mx2cc_windows makemods -clean -config=release -target=desktop monkey
..\bin\mx2cc_windows makemods -clean -config=debug -target=desktop monkey
