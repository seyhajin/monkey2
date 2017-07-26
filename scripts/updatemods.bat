
echo off

call common.bat

echo.
echo ***** Updating modules *****
echo.

%mx2cc% makemods -config=release

%mx2cc% makemods -config=debug
