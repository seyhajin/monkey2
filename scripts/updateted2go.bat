
echo off

call common.bat

echo.
echo ***** Updating ted2 *****
echo.

%mx2cc% makeapp -apptype=gui -build -config=release -target=desktop ../src/ted2go/ted2.monkey2
xcopy %ted2go_new%\assets %ted2%\assets /Q /I /S /Y
xcopy %ted2go_new%\*.dll %ted2% /Q /I /S /Y
xcopy %ted2go_new%\*.exe %ted2% /Q /I /S /Y

%mx2cc% makeapp -apptype=gui -build -config=release -target=desktop ../src/launcher/launcher.monkey2
copy %launcher_new% %launcher%
