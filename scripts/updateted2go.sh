
. ./common.sh

echo ""
echo "***** Updating ted2go *****"
echo ""

$mx2cc makeapp -apptype=gui -build -config=release -product=scripts/ted2go.products/$host/ted2 ../src/ted2go/Ted2.monkey2

$mx2cc makeapp -apptype=gui -build -config=release -product=scripts/launcher.products/$host/launcher ../src/launcher/launcher.monkey2

if [ "$OSTYPE" = "linux-gnu" ]
then

	rm -r -f $ted2
	mkdir $ted2
	cp -R ./ted2go.products/$host/assets $ted2/assets
	cp ./ted2go.products/$host/ted2 $ted2/ted2
	
	rm -r -f "$launcher"
	cp ./launcher.products/$host/launcher "$launcher"

elif [ "$OSTYPE" = "linux-gnueabihf" ]
then

	rm -r -f $ted2
	mkdir $ted2
	cp -R ./ted2go.products/$host/assets $ted2/assets
	cp ./ted2go.products/$host/ted2 $ted2/ted2
	
	rm -r -f "$launcher"
	cp ./launcher.products/$host/launcher "$launcher"

else

	rm -r -f $ted2
	cp -R ./ted2go.products/macos/ted2.app $ted2

	cp ../src/ted2go/info.plist "$ted2/Contents"
	cp ../src/launcher/Monkey2logo.icns "$ted2/Contents/Resources"
	
	rm -r -f "$launcher"
	cp -R ./launcher.products/macos/Launcher.app "$launcher"
	
	cp ../src/launcher/info.plist "$launcher/Contents"
	cp ../src/launcher/Monkey2logo.icns "$launcher/Contents/Resources"

fi
