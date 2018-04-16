TI99/4A examples suite.
by Oscar Toledo G. http://nanochess.org/

Here you'll find some samples of code I've wrote for
the TI99/4A.

This computer is based on the TMS9900 processor but has
a TMS9918 video processor and SN76489 sound chip just
like the Colecovision, though the TI99 has only 256
bytes of internal memory.

The cartridges are loaded typically at >6000 thru >7FFF

  hello.asm      A simple Hello program

  astrocube.asm  Astro Cube game written for the 4K compo
                 at Atariage, won 5th place of 9.
                 http://atariage.com/forums/topic/276364-4k-shortnsweet-game-contest-submissions/
                 https://www.youtube.com/watch?v=0vg2Msq2pCM

You'll find a short resume of TI99/4A hardware at the
start of each example.

Also I've took note of the default VDP/VRAM configuration
after starting a cartridge, because this saves bytes and
time preparing the system.

I found the TMS9900 16-bits processor not so different of
Intellivision CP1610 processor.

The TMS9900 has 16 registers named R0-R15, you need to
setup a workspace because registers are preserved in RAM,
called scratchspace because is a very high-speed memory.

The stack pointer is recommended in R10, the Link Pointer
is in R11 (Branch & Link instruction)

The memory is addressed in bytes.

My main reference for assembler programming was this one:

  http://www.unige.ch/medecine/nouspikel/ti99/assembly.htm

Comments are started by an asterisk, these should be
separated by at least two spaces from mnemonics or operands.

Hexadecimal numbers are preceded with >

Labels must carry a @ symbol to distinguish them from
registers, except in immediate instructions like LI, AI
and CI.

Same as Intellivision and 6502, substraction carry sense
is reversed. (Carry set equals no carry)
