
echo off

echo.
echo ***** Rebuilding module std *****
echo.

..\bin\mx2cc_windows makemods -clean -config=release -target=desktop std
..\bin\mx2cc_windows makemods -clean -config=debug -target=desktop std
