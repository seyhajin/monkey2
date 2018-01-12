
echo off

echo.
echo ***** Rebuilding modules *****
echo.

..\bin\mx2cc_windows makemods -clean -config=release -target=desktop
if %errorlevel% neq 0 exit /b %errorlevel%

..\bin\mx2cc_windows makemods -clean -config=debug -target=desktop
if %errorlevel% neq 0 exit /b %errorlevel%
