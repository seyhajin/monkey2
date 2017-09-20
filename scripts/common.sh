
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
	ted2_new="../src/ted2/ted2.buildv1.1.07/linux_release"
	ted2go_new="../src/ted2go/Ted2.buildv1.1.07/linux_release"
	
	launcher="../Monkey2 (Linux)"
	launcher_new="../src/launcher/launcher.buildv1.1.07/linux_release/launcher"
	
elif [ "$OSTYPE" = "linux-gnueabihf" ]
then
	host="raspbian"
	mx2cc="../bin/mx2cc_raspbian"
	
	ted2="../bin/ted2_raspbian"
	ted2_new="../src/ted2/ted2.buildv1.1.06/raspbian_release"
	ted2go_new="../src/ted2go/Ted2.buildv1.1.06/raspbian_release"
	
	launcher="../Monkey2 (Raspbian)"
	launcher_new="../src/launcher/launcher.buildv1.1.06/raspbian_release/launcher"
else
	host="macos"
	mx2cc="../bin/mx2cc_macos"
	
	ted2="../bin/ted2_macos.app"
	ted2_new="../src/ted2/ted2.buildv1.1.07/macos_release/ted2.app"
	ted2go_new="../src/ted2go/Ted2.buildv1.1.07/macos_release/Ted2.app"
	
	launcher="../Monkey2 (Macos).app"
	launcher_new="../src/launcher/launcher.buildv1.1.07/macos_release/launcher.app"
fi
