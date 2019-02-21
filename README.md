# ZeusNexFileExample
[ZX Spectrum Next](https://www.specnext.com/) demo demonstrating creating .NEX files in the [Zeus](http://www.desdes.com/products/oldfiles/) assembler.

## Introduction
This ZX Spectrum Next demo demonstrates:
* Creating .NEX files in Zeus  
* Running NextBASIC commands from asm
* Calling the esxDOS and NextZXOS APIs  
* Printing using NextBASIC 51 column mode from asm  
* Using Zeus to append some private structured data to a .NEX file  
* Keeping a .NEX file open after loading for use in the program  
* Reading that private data from asm  
* Several other neat Zeus features.

## Screenshot
![Screenshot](https://github.com/Threetwosevensixseven/ZeusNexFileExample/raw/master/nexdemo.png)

## Assembly
Currently assembles with a pre-release version of Zeus for Windows, available [here](http://www.desdes.com/products/oldfiles/zeustest.exe).

## .NEX file Loader
NOTE - This .NEX file uses V1.2 format features, and requires a recent version of the NEXLOAD dot command to load it.
Obtain this from here: https://gitlab.com/thesmog358/tbblue/raw/master/dot/NEXLOAD?inline=false and copy it into
the DOT directory on your Next SD card, overwriting the file already there.

## Thanks
[Garry Lancaster](http://www.worldofspectrum.org/zxplus3e/) and [Simon Brattel](http://www.desdes.com/).

## Licence
[Apache 2.0](https://github.com/Threetwosevensixseven/ZeusNexFileExample/blob/master/LICENSE)
