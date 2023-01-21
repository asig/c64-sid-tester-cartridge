# README

I'm a happy owner of a few C64s, but unfortunately, the SIDs are degrading
a *lot* as time goes by. While researching which SID alternative I should
use, I stumbled over Adrian's awesome Youtube video
["I bought a C64 SID chip from AliExpress!"](https://www.youtube.com/watch?v=QwJNCy4ZYmI),
in which he also showcased Andrew Challis' [SID Tester](https://hackjunk.com/2017/11/07/commodore-64-sid-tester).

Such a SID tester would be *very* handy when testing boards, but it only
exists as a BASIC program, and I am too lazy to hook up an SD2IEC and
load the program when testing a board. So, I wrote a small assembler
wrapper that allows me to start the BASIC program from a cartridge :-)

## How it works

The cartridge code is quite simple. The whole BASIC program is
stored on the cartridge as-is, and is copied to the regular
BASIC storage on startup. This happens in 2 phases:

### Phase 1: Cold start
On cold start, the standard C64 reset code is executed, but before
it jumps into BASIC's cold start routine (via `jmp ($a000)`), a small
trampoline `jmp run_prg` is installed in an unsued area of the zero
page, and `sys251` is put into the keyboard buffer. As soon as BASIC
returns to the input loop, this `SYS` is executed, starting phase 2.

### Phase 2: Copy and run the BASIC program
In phase 2, the whole BASIC program is copied from cartridge memory
to the regular BASIC memory at $801, and the variable storage start
is updated. Then, `rU` is put into the keyboard buffer, so that the
program is started autmatically after we return from the `SYS` call.

This code is also executed during a warm start.

It's probably not the most elegant code, but it allows me to
just include the original sidetester prg without any modifications.

## How to build and burn

### Build your own images
To build sid-tester-cartridge, you need the following tools:
   - `make`
   - [VICE](https://vice-emu.sourceforge.io/)
   - [cbmasm](https://github.com/asig/cbmasm)

Then, just run `make`. This will generate `sidtester.bin` and
`sidtester.crt`.

### Use a prebuilt image
Alternatively, you can also just use the prebuilt images that come
with the project: `prebuilt/sidtester.bin' and 'prebuilt/sidtester.crt`.

### Using the images
`sidtester.crt` is a C64 Cartridge image that works with your emulator,
and `sidtester.bin` is a raw binary that you can burn to an EPROM or
EEPROM. I use a cheap TL866 II from Aliexpress, and a
[Versa64Cart](https://github.com/bwack/Versa64Cart); they work
like a charm :-)

## License
Cartridge wrapper Copyright (c) 2022 Andreas Signer.
Licensed under [GPLv3](https://www.gnu.org/licenses/gpl-3.0).

SID Tester Copyright (c) 2017 Andrew Challis.
