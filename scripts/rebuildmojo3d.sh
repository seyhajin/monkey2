
source common.sh

echo ""
echo "***** Rebuilding mojo3d *****"
echo ""

$mx2cc makemods -clean -target=desktop -config=release mojo3d
$mx2cc makemods -clean -target=desktop -config=debug mojo3d
