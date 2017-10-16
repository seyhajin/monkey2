
mx2cc=""
mx2cc_new=""
ted2=""
ted2_new=""
launcher=""
launcher_new=""

if [ "$OSTYPE" = "linux-gnu" ]
then

	host="linux"
	mx2cc="../bin/mx2cc_linux"
	ted2="../bin/ted2_linux"
	launcher="../Monkey2 (Linux)"
	
elif [ "$OSTYPE" = "linux-gnueabihf" ]
then

	host="raspbian"
	mx2cc="../bin/mx2cc_raspbian"
	ted2="../bin/ted2_raspbian"
	launcher="../Monkey2 (Raspbian)"
	
else

	host="macos"
	mx2cc="../bin/mx2cc_macos"
	ted2="../bin/ted2_macos.app"
	launcher="../Monkey2 (Macos).app"
	
fi
