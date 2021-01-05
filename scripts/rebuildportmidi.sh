
source common.sh

echo ""
echo "***** Rebuilding PortMidi *****"
echo ""

$mx2cc makemods -clean -target=desktop -config=release portmidi
$mx2cc makemods -clean -target=desktop -config=debug portmidi
