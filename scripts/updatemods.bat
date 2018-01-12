
echo off

call common.bat

echo.
echo ***** Updating modules *****
echo.

%mx2cc% makemods -config=release
if %errorlevel% neq 0 exit /b %errorlevel%

%mx2cc% makemods -config=debug
if %errorlevel% neq 0 exit /b %errorlevel%