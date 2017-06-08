
echo off

call common.bat

echo.
echo ***** Rebuilding mx2cc *****
echo.

%mx2cc% makemods -clean -config=release monkey libc miniz stb-image stb-image-write stb-vorbis std
%mx2cc% makeapp -clean -config=release -apptype=console ../src/mx2cc/mx2cc.monkey2
copy %mx2cc_new% %mx2cc%
