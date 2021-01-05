
source common.sh

echo ""
echo "***** Rebuilding modules *****"
echo ""

$mx2cc makemods -clean -target=desktop -config=release mojo
$mx2cc makemods -clean -target=desktop -config=debug mojo
