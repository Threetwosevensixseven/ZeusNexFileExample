# ZeusNexFileExample
[ZX Spectrum Next](https://www.specnext.com/) demo demonstrating creating `.NEX` files in the [Zeus](http://www.desdes.com/products/oldfiles/) assembler.

## Introduction
This ZX Spectrum Next demo demonstrates:
* Creating `.NEX` files in Zeus  
* Running NextBASIC commands from asm
* Calling the esxDOS and NextZXOS APIs  
* Tokenizing plain text into NextBASIC from asm
* Executing tokenized NextBASIC from asm
* Printing using NextBASIC 51 column mode from asm  
* Using Zeus to append some private structured data to a `.NEX` file  
* Keeping a `.NEX` file open after loading for use in the program  
* Reading that private data from asm  
* Several other neat Zeus features.

Note that the NextZXOS ```IDE_BASIC``` API call has slightly changed since this example was originally written. It used to accept tokenized numbers without six byte embedded floats, but now requires the embedded floats to be present. 

The example has been rewritten to call the ```IDE_TOKENIZE``` API call with a plain text version of the BASIC statements, and pass the result to ```IDE_BASIC```. This has the advantage of always using the same tokenization rules the current version of NextZXOS uses.

## Screenshot
![Screenshot](https://github.com/Threetwosevensixseven/ZeusNexFileExample/raw/master/nexdemo.png)

## Assembly
Currently assembles with a pre-release version of Zeus for Windows, available [here](http://www.desdes.com/products/oldfiles/zeustest.exe).

## `.NEX` File Loader
**NOTE:** This `.NEX` file uses V1.2 format features, and requires a recent version of the `NEXLOAD` dot command to load it.
Obtain this from [here](https://gitlab.com/thesmog358/tbblue/raw/master/dot/NEXLOAD?inline=false). Copy it into
the `DOT` directory on your Next SD card, overwriting the file already there.

## TZX_Display
Parse and inspect the `.NEX` file with Simon Brattel's `tzx_display.exe`. Latest version is always available [here](http://www.desdes.com/products/oldfiles/tzx_display.exe).

## Thanks
[Garry Lancaster](http://www.worldofspectrum.org/zxplus3e/), [Simon Brattel](http://www.desdes.com/), [Allen Albright](https://github.com/z88dk/z88dk/wiki), [Jim Bagley](http://www.jimbagley.co.uk/) and [W B Yeats](https://en.wikipedia.org/wiki/W._B._Yeats).

## Licence
[Apache 2.0](https://github.com/Threetwosevensixseven/ZeusNexFileExample/blob/master/LICENSE)
