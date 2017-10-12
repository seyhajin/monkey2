
echo off

call common.bat

echo.
echo ***** Updating mx2cc *****
echo.

%mx2cc% makemods -config=release monkey libc miniz stb-image stb-image-write stb-vorbis std

%mx2cc% makeapp -apptype=console -config=release -product=scripts/mx2cc.products/mx2cc_windows.exe ../src/mx2cc/mx2cc.monkey2

copy mx2cc.products\mx2cc_windows.exe %mx2cc%
