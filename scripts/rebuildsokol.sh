
source common.sh

echo ""
echo "***** Rebuilding Sokol *****"
echo ""

$mx2cc makemods -clean -target=desktop -config=release sokol
$mx2cc makemods -clean -target=desktop -config=debug sokol
