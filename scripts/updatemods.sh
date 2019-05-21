
. ./common.sh

echo ""
echo "***** Updating modules *****"
echo ""

$mx2cc makemods -config=release

$mx2cc makemods -config=debug