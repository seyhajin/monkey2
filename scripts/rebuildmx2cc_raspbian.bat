echo off

call common.bat

echo.
echo ***** Rebuilding mx2cc *****
echo.

%mx2cc% makeapp -build -clean -apptype=console -config=release -target=raspbian ../src/mx2cc/mx2cc.monkey2
if %errorlevel% neq 0 exit /b %errorlevel%

copy %mx2cc_raspbian_new% ..\bin\mx2cc_raspbian
if %errorlevel% neq 0 exit /b %errorlevel%
