
source common.sh

echo ""
echo "***** Updating mx2cc *****"
echo ""

$mx2cc makemods -config=release monkey libc miniz stb-image stb-image-write stb-vorbis std

$mx2cc makeapp -apptype=console -config=release -product=src/mx2cc/mx2cc.products/mx2cc_$host ../src/mx2cc/mx2cc.monkey2

cp ..\src\mx2cc\mx2cc.products\mx2cc_$host %mx2cc%
