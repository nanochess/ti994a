*
* Hello program for TI99/4A
*
* by Oscar Toledo G.
* http://nanochess.org/
*
* Creation date: Mar/08/2018.
*

*
* Built with xdt99 TI 99 Cross-Development Tools (requires Python)
* https://endlos99.github.io/xdt99/
*
* Command-line: xas99.py -b -R hello.asm --base 0x6000
* Run with Open Cartridge: http://js99er.net/
*
* For Classic99 emulator please uncomment the SAVE directive and reassemble
* (requires 8K BIN image)
*
* TMS9900 processor reference:
* http://www.unige.ch/medecine/nouspikel/ti99/assembly.htm
*

*
* Comments only at start of line, or 2 spaces after mnemonic+operand
*
* Default VDP settings:
*  R0 = >00 Graphics I mode
*  R1 = >E0
*  R2 = >F0 pattern memory at 0000 (filled with >20)
*  R3 = >0E color table at 0380 (32 bytes, filled with >17)
*  R4 = >F9 character bitmaps table at 0800-0fff (>0b00 - >0fff filled with zero)
*  R5 = >86 sprite table at 0300 (128 bytes, filled with zero)
*  R6 = >F8 sprite bitmaps table at 0000-07ff (>03a0 - >07ff filled with zero)
*  R7 = >07 border color
*
* Only uppercase ASCII table (>20->5F)
* 
* Special characters: (TI logo)
*     >01 >02 >03
*     >04 >05 >06
*     >07 >08 >09
*
*     >0a = Copyright symbol
*

*
* Information built from data at http://www.unige.ch/medecine/nouspikel/ti99/titechpages.htm
*
* Valid GROM start addresses:
*   >2000
*   >6000
*   >8000
*   >a000
*   >c000
*   >e000
*
* TMS9918, write data at >8C00, write address at >8C02
* TMS9918, read data at >8800, read status at >8802
* Sound chip is compatible with SN76489A of Colecovision, write data at >8400
*
* Note bit order is 0 (left side) to 15 (right side) in datasheets.
* Note bytes are preserved in bits 0-7 (this would be high-byte in Z80)
*
*      Column
* R12 address  0  1  2  3  4  5   6    7  A-lock
*   >0006 7    =  .  ,  M  N  / Fire Fire
*   >0008 6 Space L  K  J  H  ; Left Left
*   >000A 5 Enter O  I  U  Y  P Right Right
*   >000C 4       9  8  7  6  0 Down Down
*   >000E 3 Fctn  2  3  4  5  1  Up   Up  A-lock
*   >0010 2 Shift S  D  F  G  A
*   >0012 1 Ctrl  W  E  R  T  Q
*   >0014 0       X  C  V  B  Z
*
*   CLR R1         * Test column 0
*   LI R12,>0024   * Address for column selection
*   LDCR R1,3      * Select column
*   LI R12,>0006   * Address to read rows
*   STCR R1,8
*   ANDI R1,>0800  * Mask all irrelevant bits (zero = Space pressed)
*

*       SAVE >6000,>8000   * Round it to 8K for GROM to work with Classic99

        AORG >6000

*
* GROM header (cartridge header)
* 
GRMHDR  BYTE >AA    * Indicates a standard header
        BYTE 1      * Version number
        BYTE 1      * Number of programs
        BYTE 0      * Not used
        DATA >0000  * Pointer to power-up list (name length and name not required)
        DATA PROG   * Pointer to program data
        DATA >0000  * Pointer to DSR list
        DATA >0000  * Pointer to subprogram list 
        BYTE 0,0,0,0

PROG    DATA >0000  * Link to next item
        DATA MAIN   * Point to start address
        BYTE 8      * Name length
        TEXT 'EXAMPLE!'    * Name

WRKSP   EQU >8300    * Workspace 
VDPWD   EQU >8C00
VDPWA   EQU >8C02

*
* This following code based on example at https://github.com/leachim6/hello-world/blob/master/a/assembler_tms9900_ti99_4a.asm
*

MAIN
        LIMI 0       * disable interrupts
        LWPI WRKSP   * set default workspace

        LI R0,>4000  * Screen address (plus WR bit)
        SWPB R0
        MOVB R0,@VDPWA
        SWPB R0
        MOVB R0,@VDPWA

        LI R1,HELLO
        LI R2,6
L1      MOVB *R1+,@VDPWD
        DEC R2
        JNE L1

L2      JMP L2

HELLO
        TEXT 'HELLO!'
        BYTE 0

        END	
