
echo off

call common.bat

echo.
echo ***** Rebuilding mx2cc *****
echo.

%mx2cc% makemods -clean -config=release monkey libc miniz stb-image stb-image-write stb-vorbis std
if %errorlevel% neq 0 exit /b %errorlevel%

%mx2cc% makeapp -clean -apptype=console -config=release -product=scripts/mx2cc.products/mx2cc_windows.exe ../src/mx2cc/mx2cc.monkey2
if %errorlevel% neq 0 exit /b %errorlevel%

copy mx2cc.products\mx2cc_windows.exe %mx2cc%
if %errorlevel% neq 0 exit /b %errorlevel%
