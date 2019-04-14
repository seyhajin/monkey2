
. ./common.sh

echo ""
echo "***** Updating mx2cc *****"
echo ""

$mx2cc makemods -config=release monkey libc miniz stb-image stb-image-write stb-vorbis zlib std

$mx2cc makeapp -apptype=console -config=release -product=scripts/mx2cc.products/mx2cc_$host ../src/mx2cc/mx2cc.monkey2

cp mx2cc.products/mx2cc_$host $mx2cc
