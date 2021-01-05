
source common.sh

echo ""
echo "***** Rebuilding SDL2 *****"
echo ""

$mx2cc makemods -clean -target=desktop -config=release sdl2
$mx2cc makemods -clean -target=desktop -config=debug sdl2
