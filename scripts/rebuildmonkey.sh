
source common.sh

echo ""
echo "***** Rebuilding monkey *****"
echo ""

$mx2cc makemods -clean -target=desktop -config=release monkey
$mx2cc makemods -clean -target=desktop -config=debug monkey
