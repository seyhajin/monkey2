
echo off

echo.
echo ***** Rebuilding PortMidi *****
echo.

..\bin\mx2cc_windows makemods -clean -config=release -target=desktop portmidi
..\bin\mx2cc_windows makemods -clean -config=debug -target=desktop portmidi
