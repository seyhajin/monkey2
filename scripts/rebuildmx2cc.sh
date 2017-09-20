
source common.sh

echo ""
echo "***** Rebuilding mx2cc *****"
echo ""

mkdir mx2cc.products

$mx2cc makemods -clean -config=release monkey libc miniz stb-image stb-image-write stb-vorbis std

$mx2cc makeapp -clean -apptype=console -config=release -product=scripts/mx2cc.products/mx2cc_$host ../src/mx2cc/mx2cc.monkey2

copy mx2cc.products/mx2cc_$host $mx2cc
