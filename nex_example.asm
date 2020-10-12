/* nex_example.asm

This ZX Spectrum Next demo demonstrates creating .NEX files in Zeus, running NextBASIC commands from asm, calling
the esxDOS and NextZXOS APIs, printing using NextBASIC 51 column mode from asm, using Zeus to append private data to
a .NEX file, and reading that private data from asm. Plus several other neat Zeus features. RVG 21/02/2019

Currently assembles with a pre-release version of Zeus, available at http://www.desdes.com/products/oldfiles/zeustest.exe

View the .NEX file with the supplied tzx_display.exe. Latest version at http://www.desdes.com/products/oldfiles/tzx_display.exe

NOTE - This .NEX file uses V1.2 format features, and requires a recent version of the NEXLOAD dot command to load it.
Obtain this from here: https://gitlab.com/thesmog358/tbblue/raw/master/dot/NEXLOAD?inline=false and copy it into
the DOT directory on your Next SD card, overwriting the file already there.
*/

zeusemulate             "Next", "RAW"                   ; RAW prevents Zeus from adding some BASIC emulator-friendly
zoLogicOperatorsHighPri = false                         ; data like the stack and system variables. Not needed because
zxAllowFloatingLabels   = false                         ; this only runs on the Next, and everything is already present.
optionsize 5
Cspect optionbool 15, -15, "Cspect", false              ; Zeus GUI option to launch CSpect
UploadNext optionbool 80, -15, "Next", false            ; Zeus GUI option to upload to Next FLashAir wifi SD card

org $8000                                               ; This should keep our code clear of NextBASIC sysvars
Main                    proc                            ; (Necessary for making NextZXOS API calls)
                        di
                        nextreg $07, %11                ; Next Turbo 28MHz
                        Border(7)

                        OpenOutputChannel(2)            ; ROM: Open channel to upper screen (channel 2)

                        ld b, 0                         ; IN: B=0, tokenise BASIC line
                        ld c, 4                         ; IN: C=8K bank containing buffer for untokenised BASIC line
                        ld hl, UnokenizedBAS-$8000      ; IN: HL=offset in bank of buffer for untokenised line
                        M_P3DOS($01D8, 0)               ; API IDE_TOKENIZE ($01D8, Bank 0) (see NextZXOS_and_esxDOS_APIs.pdf page 22)
                        jr nc, Error                    ; If Carry flag unset, tokenize failed
                        jr z, Error                     ; If Zero flag set, tokenize failed
                                                        ; OUT: HL=address of tokenized BASIC command(s), terminated w/ $0D

                                                        ; IN: HL=address of tokenized BASIC command(s), terminated w/ $0D
                        M_P3DOS($01C0, 0)               ; API IDE_BASIC ($01C0, Bank 0) (see NextZXOS_API.pdf page 18)
                        PrintAt(0, 0)                   ; Equivalent to PRINT AT 0, 0

                        ld bc, 2                        ; Read two bytes
                        F_READ(TextBuffer.Length)       ; from the current position in the .NEX file.
                                                        ; This should correspond to the NexDataLength variable below.
                        ld bc, (TextBuffer.Length)      ; Set length of remaining private data to read,
                        F_READ(TextBuffer.Start)        ; and read it from the new current position in the file.

                        call Pointer.Init
NextLine:               ld a, (hl)                      ; Read line length
                        cp -1
                        jp z, EndOfText                 ; If length is -1 (255) we are finished
                        ld c, a
                        ld b, 0                         ; bc = characters to print
                        inc hl                          ; Advance to the first character of the line
                        ex de, hl                       ; de = starting from this address
                        call $203C                      ; ROM $203C PR_STRING: Print BC characters starting at DE
                        call Pointer.NextLine           ; Position to the next line
NewLine:                PrintChar(13)                   ; Print a CR,
                        jp NextLine                     ; then process the next line
EndOfText:
                        jr EndOfText                    ; Stop here forever. We should think about closing the open
                                                        ; .NEX file, but in this case the only way to exit is to reset
pend                                                    ; the Next with F4 or F1, which closes all open files anyway.

Error                   proc
                        Border(2)                       ; Set border red (2)
                        jr $-2                          ; Go into an endless loop
pend

Pointer                 proc                            ; This procedure encapsulates the pointer logic. Who needs OOP!
Init:                   ld hl, TextBuffer.Start         ; Set the pointer
                        ld (Value), hl                  ; to the start of the text buffer
                        ret
Inc:                    ld hl, [Value]0                 ; Use Zeus data label to store variable inline (SMC saves space)
                        inc hl                          ; Advance the pointer
                        ld (Value), hl                  ; Save the new pointer position
NextLine:
                        ld hl, (Value)                  ; Current position is length of current line
                        ld a, (hl)                      ; Read the length
                        inc a                           ; Add 1 for the length byte itself
                        add hl, a                       ; Calculate new length (ADD HL, A is a Next-only instruction!)
                        ld (Value), hl                  ; Save the new pointer position
                        ret
pend

UnokenizedBAS           proc                            ; Untokenized NextBASIC to switch into 51 column mode:
                        db "LAYER %1,%1:CLS:"
                        db "PRINT CHR$ 30;CHR$ 5;", 13
pend

FileHandle:             db 0                            ; This byte is automagically poked here by the .NEX loader
                                                        ; because of "pu8NEXFileHandle = Main.FileHandle" below
TextBuffer              proc
Length:                 dw 0                            ; We will read the length into here
Start:                                                  ; We will not allocate any space for the buffer with ds NN,
                                                        ; because all space after this is free. In a larger program
pend                                                    ; we would allocate anyway, just to be safe.

OpenOutputChannel       macro(Channel)                  ; Semantic macro to call a 48K ROM routine
                        ld a, Channel                   ; 2 = upper screen
                        call $1601                      ; ROM 1601: THE 'CHAN-OPEN' SUBROUTINE
mend

PrintChar               macro(Char)                     ; Semantic macro to call a 48K ROM routine
                        ld a, Char
                        rst $10                         ; ROM 0010: THE 'PRINT A CHARACTER' RESTART
mend

PrintAt                 macro(X, Y)                     ; Semantic macro to call a 48K ROM routine
                        PrintChar(22)
                        PrintChar(Y)                    ; X and Y are reversed order, i.e.
                        PrintChar(X)                    ; PRINT AT Y, X
mend

Border                  macro(Colour)                   ; Semantic macro to call a 48K ROM routine
                        if Colour=0
                          xor a
                        else
                          ld a, Colour
                        endif
                        out ($FE), a                    ; Change border colour immediately
                        if Colour<>0
                          ld a, Colour*8
                        endif
                        ld (23624), a                   ; Makes the ROM respect the new border colour
mend

esxDOS                  macro(Command)                  ; Semantic macro to call an esxDOS routine
                        rst $08                         ; rst $08 is the instruction to call an esxDOS API function.
                        noflow                          ; Zeus normally warns when data might be executed, suppress.
                        db Command                      ; For esxDOS API calls, the data byte is the command number.
mend

M_P3DOS                 macro(Command, Bank)            ; Semantic macro to call an NextZXOS routine via the esxDOS API
                        exx                             ; M_P3DOS: See NextZXOS_API.pdf page 37
                        ld de, Command                  ; DE=+3DOS/IDEDOS/NextZXOS call ID
                        ld c, Bank                      ; C=RAM bank that needs to be paged (usually 7, but 0 for some calls)
                        esxDOS($94)                     ; esxDOS API: M_P3DOS ($94)
mend

F_READ                  macro(Address)                  ; Semantic macro to call an esxDOS routine
                                                        ; In: BC=bytes to read
                        ld a, (FileHandle)              ; A=file handle
                        ld ix, Address                  ; IX=address
                        esxDOS($9D)
mend

; Raise an assembly-time error if the expression evaluates false
zeusassert zeusver>=74, "Upgrade to Zeus v4.00 (TEST ONLY) or above, available at http://www.desdes.com/products/oldfiles/zeustest.exe"

; Generate a NEX file                                   ; Instruct the .NEX loader to write the file handle to this
pu8NEXFileHandle = FileHandle                           ; address, and keep the file open for further use by us.
output_nex      "nex_example.nex", $FF40, Main          ; Generate the file, with SP argument followed PC
                                                        ; Zeus "just knows" which 16K banks to include in the .NEX file,
                                                        ; making generation a one-liner if you don't want loading screens
                                                        ; or external palette files. See History/Documentation in Zeus
                                                        ; for complete instructions and syntax.

; Append some private structured data to the nex file.
; This will be read at the start of the program,
; and copied into a buffer before printing it
output_nex_data "nex_example.nex", dw  NexDataLength       ; Prepending full length of extra data allows easy file read
output_nex_data "nex_example.nex", dbl "LEDA AND THE SWAN" ; dbl prepends a length byte (0..254)
output_nex_data "nex_example.nex", dbl ""                  ; Empty lines are prepended with length byte 0
output_nex_data "nex_example.nex", dbl "A sudden blow: the great wings beating still"
output_nex_data "nex_example.nex", dbl "Above the staggering girl, her thighs caressed"
output_nex_data "nex_example.nex", dbl "By the dark webs, her nape caught in his bill,"
output_nex_data "nex_example.nex", dbl "He holds her helpless breast upon his breast."
output_nex_data "nex_example.nex", dbl ""
output_nex_data "nex_example.nex", dbl "How can those terrified vague fingers push"
output_nex_data "nex_example.nex", dbl "The feathered glory from her loosening thighs?"
output_nex_data "nex_example.nex", dbl "And how can body, laid in that white rush,"
output_nex_data "nex_example.nex", dbl "But feel the strange heart beating where it lies?"
output_nex_data "nex_example.nex", dbl ""
output_nex_data "nex_example.nex", dbl "A shudder in the loins engenders there"
output_nex_data "nex_example.nex", dbl "The broken wall, the burning roof and tower"
output_nex_data "nex_example.nex", dbl "And Agamemnon dead. Being so caught up,"
output_nex_data "nex_example.nex", dbl "So mastered by the brute blood of the air,"
output_nex_data "nex_example.nex", dbl "Did she put on his knowledge with his power"
output_nex_data "nex_example.nex", dbl "Before the indifferent beak could let her drop?"
output_nex_data "nex_example.nex", dbl ""
output_nex_data "nex_example.nex", dbl "W B YEATS (1922)"
output_nex_data "nex_example.nex", db -1                ; No lines are >254 long, so expediently -1 is our end marker
                                                        ; (If they were, we could use dblw for word-prefixed lengths)

; Read the total length of data appended (less the count word itself), so we can
; write it into the appended data itself on the next pass. Forward-reference magic!
NexDataLength = output_nex_data("nex_example.nex")-2

; Copy .NEX file to wifi-enabled SD card
if enabled UploadNext
  zeusinvoke "upload.bat", "", false                    ; Uncomment this to use
endif

; Launch .NEX file in CSpect
if enabled Cspect                                       ; In CSpect.bat there is a hardcoded path to CSpect
  zeusinvoke "cspect.bat", "", false                    ; and to the SD image file file container.
endif                                                   ; Change these to reflect your own paths and filenames.

; To set this up, create a file called upload.bat in the same directory as this source file,
; with the following contents (everything inside the /* */ block comments):
/*
:: Set current directory
C:
CD %~dp0

copy nex_example.nex Q:\*.*
*/
; This assumes your Toshiba FlashAir has WebDav (W-03 and W-04 versions do), and is mapped to your Q: drive.
; Example FlashAir card: https://www.amazon.co.uk/dp/B073M1FTWV

