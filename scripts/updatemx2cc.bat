
echo off

echo.
echo ***** Updating mx2cc *****
echo.

..\bin\mx2cc_windows makeapp -apptype=console -config=release ../src/mx2new/mx2cc.monkey2
copy ..\src\mx2new\mx2cc.buildv010\desktop_release_windows\mx2cc.exe ..\bin\mx2cc_windows.exe
