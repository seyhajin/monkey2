
***** Welcome to Monkey2! *****

If you are reading this on github, please note there are prebuilt versions of monkey2 (with complete source code) available from https://blitzresearch.itch.io/monkey2.


***** Building monkey2 on Windows *****

1) Unless you are using one of the prebuilt releases, you will need to install the mingw-64 compiler. There is a self-extracting archive of mingw-64 that has been tested with monkey2 here:

http://monkeycoder.co.nz/get-file?file=i686-6.2.0-posix-dwarf-rt_v5-rev1.exe

If you install this to the monkey2 'devtools' directory, the following steps should 'just work' (ha!).

2) Open a command prompt and change to the 'monkey2\scripts' directory.

3) Enter 'rebuildall' and hit return. Wait...

4) If all went well, you should end up with a 'Monkey2 (Windows)' exe in the monkey2 directory. Run this to launch the Ted2go IDE.

5) You should now be able to build and run monkey2 apps. There are some sample apps in the monkey2/bananas directory.


***** Building monkey2 on MacOS/Linux *****

1) On MacoS, install the xcode command line tools. You can do this by entering 'xcode-select --install' in a shell.

2) Open a shell and change to the 'monkey2/scripts' directory.

3) Enter './rebuildall.sh' and hit return. Wait...

4) If all went well, you should end up with a 'Monkey2 (...)' app in the monkey2 directory. Run this to launch the Ted2go IDE.

5) You should now be able to build and run monkey2 apps. There are some sample apps in the monkey2/bananas directory.


***** More information *****

Monkey2 development blog: http://monkeycoder.co.nz/

Monkey2 itch.io page: https://blitzresearch.itch.io/monkey2

Monkey2 github page: https://github.com/blitz-research/monkey2

Ted2go github page: https://github.com/engor/Ted2Go
