# Ultralight module for Monkey2 

Ultralight is a lighter, faster option to integrate HTML UI in your app.

*WIP:* this module has been tested on Windows 10 x64 with **MinGW-GCC x86 6.2.0** (provided by default with  Monkey2).

Only releases binaries are included in repository because too large files for debug configuration. Please take a debug binaries from <https://github.com/ultralight-ux/Ultralight> and place that into folders respectively.

## How to install

#### Prequisities

* Git client
* Monkey2 (obviously)

#### Clone the repository to your 'modules' directory

Launch a shell.

Go to your Monkey2 modules directory : `cd <MONKEY2_DIR>\modules`.

 Launch `git clone https://github.com/seyhajin/ultralight-monkey2.git ultralight` and wait...

#### Compile and build 'ultralight' module 

Use **mx2cc** with these parameters `makemods ultralight`.

#### Build and run 'sample.monkey2' in bananas directory in module

Build and run `bananas\sample.monkey2`