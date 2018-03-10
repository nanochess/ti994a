*
* Astro Cube for TI99/4A
*
* by Oscar Toledo G.
* http://nanochess.org/
*
* Creation date: Mar/08/2018.
* Revision date: Mar/09/2018. Game completed.
* Revision date: Mar/10/2018. Corrections. Added geometrical city. Thicker sprites.
*

*
* Geometrical figures have a war with you, apparently because you
* don't draw them correctly. Shoot or a heptagon can fall over
* your head.
*
* Press Space to fire, S and D to move left and right.
*
* Squares - 1 point
* Triangles - 2 points
* Pentagons and hexagons - 3 points
* Heptagons - 5 points
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

* Next label: L47

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
        BYTE 10     * Name length
        TEXT 'ASTRO CUBE'    * Name

WRKSP   EQU >8300    * Workspace 
PSG     EQU >8400
VDPWD   EQU >8C00
VDPWA   EQU >8C02

TABLE   EQU >8320    * Sprite attribute table (16 sprites x 4)
FRAME   EQU >8360    * Current frame
RAND    EQU >8362    * Current random number
LEVEL   EQU >8364    * Current level
NEXT    EQU >8366    * Time for next square to appear
REMAIN  EQU >8368    * Number of squares remaining
EXIT    EQU >836A    * Time to exit
ENTER   EQU >836C    * Time to enter
LIVES   EQU >836E    * Lives remaining
SCORE   EQU >8370    * Score
SE1     EQU >8372    * Sound effect 1
SE2     EQU >8374    * Sound effect 2

MAIN
        LIMI 0       * disable interrupts
        LWPI WRKSP   * set default workspace

        LI R0,>4400  * Bitmaps address (plus WR bit)
        BL @SETVDP

        LI R1,SPRITES
        LI R2,256
L1      MOVB *R1+,@VDPWD
        DEC R2
        JNE L1

        LI R0,>4BF8  * Bitmaps address (plus WR bit)
        BL @SETVDP

        LI R1,BITMAPS
        LI R2,16
L6      MOVB *R1+,@VDPWD
        DEC R2
        JNE L6

        LI R0,>8701  * R7 = $01 (black border)
        BL @SETVDP

        LI R0,>81C2  * R1 = $C2 (16x16 sprites)
        BL @SETVDP

        LI R0,>4380  * Color address (plus WR bit)
        BL @SETVDP

        LI R1,COLORS
        LI R2,32
L2      MOVB *R1+,@VDPWD
        DEC R2
        JNE L2

TITLE
        LI R0,>9F00
        MOVB R0,@PSG
        LI R0,>BF00
        MOVB R0,@PSG
        LI R0,>DF00
        MOVB R0,@PSG
        LI R0,>FF00
        MOVB R0,@PSG
        CLR R0
        MOV R0,@SE1
        MOV R0,@SE2

        LI R0,>4300  * Color address (plus WR bit)
        BL @SETVDP

        LI R1,>D100
        LI R2,128
L42     MOVB R1,@VDPWD
        DEC R2
        JNE L42

        LI R0,>4000  * Screen address (plus WR bit)
        BL @SETVDP

        LI R1,>2000
        LI R2,704
L3      MOVB R1,@VDPWD
        DEC R2
        JNE L3

        LI R1,>7F00
        LI R2,32
L4      MOVB R1,@VDPWD
        DEC R2
        JNE L4

        LI R0,>410B
        BL @SETVDP
        LI R1,MSG1
        BL @WRTMSG

        LI R0,>414B
        BL @SETVDP
        LI R1,MSG2
        BL @WRTMSG

        LI R0,>41AB
        BL @SETVDP
        LI R1,MSG3
        BL @WRTMSG

L43
        BL @RANDOM
        
        MOV @FRAME,R1
        SRL R1,8
        ANDI R1,7
        AI R1,SAVER
        MOVB *R1,R0
        SRL R0,8
        AI R0,>8700
        BL @SETVDP

        CLR R1         * Test column 0
        LI R12,>0024   * Address for column selection
        LDCR R1,3      * Select column
        LI R12,>0006   * Address to read rows
        STCR R1,8
        ANDI R1,>0200  * Mask all irrelevant bits (zero = Space pressed)
        JNE L43

        LI R0,>410B
        BL @SETVDP
        LI R1,>2000
        LI R2,192
L44     MOVB R1,@VDPWD
        DEC R2
        JNE L44

*
* Create the great geometrical empire
*
        LI R4,>0
L61     BL @RANDOM2
        MOV @RAND,R2
        ANDI R2,7
        INC R2
        MOV R4,R0
        AI R0,>42A0
        LI R1,>8000
L62     BL @SETVDP
        AI R0,>FFE0
        MOVB R1,@VDPWD
        DEC R2
        JNE L62
        INC R4
        CI R4,32
        JNE L61

        LI R2,>A178
        MOV R2,@TABLE

        LI R0,>8701  * R7 = $01 (black border)
        BL @SETVDP

        LI R0,1
        MOV R0,@LEVEL
        LI R0,4
        MOV R0,@LIVES
        CLR R0
        MOV R0,@SCORE
        MOV R0,@SCORE+2
        MOV R0,@SCORE+4

RESTART
        MOV @LEVEL,R0
        SLA R0,1
        AI R0,10
        MOV R0,@REMAIN
        MOV @RAND,R0
        ANDI R0,31
        LI R1,31
        S @LEVEL,R1
        JOC L45
        CLR R1
L45     A R1,R0
        MOV R0,@NEXT
        LI R2,>880E
        MOV R2,@TABLE+2
        LI R1,TABLE+4
        LI R3,30
L7      LI R2,>D100
        MOV R2,*R1+
        DEC R3
        JNE L7
        LI R0,60
        MOV R0,@ENTER
        LI R0,>42EC
        BL @SETVDP
        LI R1,MSG4
        BL @WRTMSG
        MOV @LIVES,R1
        SLA R1,8
        AI R1,>3000
        BL @WRTVDP
        MOV @LEVEL,R0
        LI R0,>42F8
        BL @SETVDP
        LI R1,MSG5
        BL @WRTMSG
        MOV @LEVEL,R0
        LI R1,>2F00
L34     AI R1,>0100
        AI R0,>FFF6
        JOC L34
        AI R0,>003A
        SLA R0,8
        BL @WRTVDP
        MOV R0,R1
        BL @WRTVDP
        BL @UPDSCO

MAINLOOP
        BL @RANDOM

        LI R0,>4300  * Screen address (plus WR bit)
        BL @SETVDP

        LI R1,TABLE
        LI R2,64
L8      MOVB *R1+,@VDPWD
        DEC R2
        JNE L8
        LI R1,>D000
        MOVB R1,@VDPWD

*
* Check if it's time to create a new enemy
*
        MOV @ENTER,R0
        JEQ L33
        DEC @ENTER
        LI R1,>A000
        MOVB R1,@PSG
        LI R1,>0A00
        MOVB R1,@PSG
        SRL R0,5
        LI R0,>B100
        JOC L56
        LI R0,>BF00
L56     MOVB R0,@PSG
        JMP L16

L33     MOV @REMAIN,R0
        JEQ L16
        DEC @NEXT
        JNE L16
        MOV @RAND,R0
        ANDI R0,31
        LI R1,31
        S @LEVEL,R1
        JOC L46
        CLR R1
L46     A R1,R0
        MOV R0,@NEXT
        DEC @REMAIN
        LI R1,TABLE+8
        LI R2,14
L17     CLR R3
        MOVB *R1,R3
        CI R3,>D100
        JEQ L18
        AI R1,4
        DEC R2
        JNE L17
        JMP L16

L18     MOV @RAND,R0
        ANDI R0,>FC
        AI R0,>F100    * For smooth entry from top
        MOV R0,*R1+
        MOV @RAND,R0
        ANDI R0,>03
        AI R0,>800B
        MOV @RAND,R2
        ANDI R2,>0700
        JEQ L50
        MOV @RAND,R2
        ANDI R2,>0300
        JNE L37
        MOV @RAND,R2
        ANDI R2,>0400
        JEQ L39
        AI R0,>1800    * Hexagon
        JMP L35
L39
        AI R0,>1400    * Pentagon
        JMP L35

L50     AI R0,>1C00    * Heptagon
        JMP L35

L37     ANDI R2,>0100
        JEQ L35
        AI R0,>1000    * Triangle
L35
        MOV R0,*R1+
L16
        
*
* Check for collision of enemies vs bullet/player
*
        CLR R5
        MOVB @TABLE+4,R5
        CLR R6
        MOVB @TABLE+5,R6
        CLR R7
        LI R1,TABLE+8
        LI R2,14
L25     CLR R3
        MOVB *R1,R3
        CI R3,>D100
        JEQ L26
        INC R7
        INC R1
        CLR R4
        MOVB *R1,R4
        DEC R1
        CI R3,>9200
        JL L29
        CI R3,>B000
        JH L29
        SB @TABLE+1,R4
        CI R4,>F400
        JHE L32
        CI R4,>0C00
        JHE L26
L32     CLR R1
        MOVB @TABLE+2,R3
        CI R3,>8C00        * Already explosion?
        JEQ L26
        LI R3,>8C0A        * Start explosion
        MOV R3,@TABLE+2
        LI R3,90
        MOV R3,@EXIT
        JMP L28

L29     SB R6,R4
        CI R4,>F700
        JHE L27
        CI R4,>0900
        JHE L26
L27     SB R5,R3
        CI R3,>F400
        JL L26
        INCT R1
        CLR R3
        MOVB *R1,R3
        CI R3,>8C00        * Already explosion?
        JEQ L59
        BL @ADDSCO
        BL @UPDSCO
        LI R3,>8C06        * Start explosion
        MOV R3,*R1
        LI R1,>D100        * Remove bullet
        MOVB R1,@TABLE+4
        LI R1,>E400
        MOV R1,@PSG
        LI R1,>F000
        MOV R1,@PSG
        JMP L28

L59     DECT R1
L26     AI R1,4
        DEC R2
        JNE L25
L28

        CI R7,0            * Something in screen?
        JNE L31            * Yes, jump
        MOV @REMAIN,R0
        JNE L31
        INC @LEVEL
        B @RESTART
L31

*
* Move enemies
*
        LI R1,TABLE+8
        LI R2,14
L19     CLR R3
        MOVB *R1,R3
        CI R3,>D100
        JEQ L20
        INCT R1
        CLR R4
        MOVB *R1,R4
        CI R4,>8000    * Square
        JEQ L22
        CI R4,>8C00    * Explosion
        JEQ L23
        CI R4,>9000    * Square
        JEQ L36
        CI R4,>9400    * Pentagon
        JEQ L38
        CI R4,>9800    * Hexagon
        JEQ L40

*
* Handle heptagon
*
L51     DEC R1
        MOVB *R1,R4
        CLR R5
        MOVB @TABLE+1,R5
        C R5,R4
        JEQ L53
        JH L52
        AI R4,>FF00
        MOVB R4,*R1
        INC R1
        JMP L36
   
L52     AI R4,>0100
        MOVB R4,*R1
L53     INC R1
        JMP L36

*
* Handle hexagon
*
L40     DEC R1
        MOVB *R1,R4
        AI R4,>0100
        MOVB R4,*R1
        INC R1
        JMP L36

*
* Handle pentagon
*
L38     DEC R1
        MOVB *R1,R4
        AI R4,>FF00
        MOVB R4,*R1
        INC R1
        JMP L36

*
* Handle triangle
*

L36     DECT R1
        AI R3,>0100
        CI R3,>A100
        JEQ L24
        JMP L21

*
* Handle explosion
*
L23     INC R1
        MOVB *R1,R4
        AI R4,>0100
        MOVB R4,*R1
        DEC R1
        DECT R1
        CI R4,>0F00
        JNE L20
        LI R4,>FF00
        MOV R4,@PSG
        JMP L24

*
* Handle square
*
L22     DECT R1
        MOV @FRAME,R4
        SRL R4,1
        JOC L20
        AI R3,>0100
        CI R3,>A100
        JNE L21
L24     LI R3,>D100
L21     MOVB R3,*R1
L20     AI R1,4
        DEC R2
        JNE L19

*
* Move player
*
        MOV @EXIT,R1
        JEQ L30
        CI R1,90
        JNE L55
        LI R2,>E500
        MOV R2,@PSG
L55     SLA R1,4
        LI R2,>F700
        XOR R2,R1
        MOV R1,@PSG    * Explosion noise
        LI R2,>9F00
        MOV R2,@PSG    * Turn off shoot

        MOV @EXIT,R1
        ANDI R1,8
        SRL R1,1
        AI R1,6
        SLA R1,8
        MOVB R1,@TABLE+3   * Flashing explosion

        DEC @EXIT
        JEQ L57
        B @MAINLOOP
L57
        LI R2,>FF00
        MOV R2,@PSG    * Turn off noise
        MOV @LIVES,R1
        JEQ GAMEOVER
        DEC @LIVES
        LI R2,>A178    * Reposition in X
        MOV R2,@TABLE
        B @RESTART
L30
        LI R1,>0100    * Test column 1
        LI R12,>0024   * Address for column selection
        LDCR R1,3      * Select column
        LI R12,>0006   * Address to read rows
        STCR R1,8
        ANDI R1,>2000  * Mask all irrelevant bits (zero = S pressed)
        JNE L9
        CLR R1
        MOVB @TABLE+1,R1
        CI R1,>0200    * Already at leftmost position?
        JLE L9         * Yes, jump
        AI R1,>FF00    * Move one pixel left
        MOVB R1,@TABLE+1
L9

        LI R1,>0200    * Test column 2
        LI R12,>0024   * Address for column selection
        LDCR R1,3      * Select column
        LI R12,>0006   * Address to read rows
        STCR R1,8
        ANDI R1,>2000  * Mask all irrelevant bits (zero = D pressed)
        JNE L10
        CLR R1
        MOVB @TABLE+1,R1
        CI R1,>EE00    * Already at rightmost position?
        JHE L10        * Yes, jump
        AI R1,>0100    * Move one pixel right
        MOVB R1,@TABLE+1
L10

        CLR R1         * Test column 0
        LI R12,>0024   * Address for column selection
        LDCR R1,3      * Select column
        LI R12,>0006   * Address to read rows
        STCR R1,8
        ANDI R1,>0200  * Mask all irrelevant bits (zero = Space pressed)
        JNE L12
        CLR R1
        MOVB @TABLE+4,R1
        CI R1,>D100    * Shot already flying?
        JNE L12        * Yes, jump
        LI R1,>0099    * Starting Y-position
        MOVB @TABLE+1,R1  * Take spaceship X-position
        SWPB R1 
        MOV R1,@TABLE+4   * Setup shot
        LI R1,>8407
        MOV R1,@TABLE+6
L12
*
* Move shot
*
        CLR R1
        MOVB @TABLE+4,R1
        CI R1,>D100    * Shot moving?
        JEQ L54        * No, jump
        AI R1,>FE00    * Move two pixels upwards
        CI R1,>FF00
        JNE L15
        LI R1,>D100
        MOVB R1,@TABLE+4
        JMP L54

L15     MOVB R1,@TABLE+4
        SRL R1,9
        AI R1,>40
        MOV R1,R2
        ANDI R2,>0F
        AI R2,>80
        SLA R2,8
        MOVB R2,@PSG
        SRL R1,4
        SLA R1,8
        MOVB R1,@PSG
        LI R1,>9200
        MOVB R1,@PSG
        JMP L14

L54     LI R1,>9F00
        MOVB R1,@PSG
L14

        B @MAINLOOP

GAMEOVER
        LI R0,>410B
        BL @SETVDP
        LI R1,>4700
        BL @WRTVDP
        LI R1,>4100
        BL @WRTVDP
        LI R1,>4D00
        BL @WRTVDP
        LI R1,>4500
        BL @WRTVDP
        LI R1,>2000
        BL @WRTVDP
        LI R1,>2000
        BL @WRTVDP
        LI R1,>4F00
        BL @WRTVDP
        LI R1,>5600
        BL @WRTVDP
        LI R1,>4500
        BL @WRTVDP
        LI R1,>5200
        BL @WRTVDP
        LI R4,>200
L41     BL @RANDOM
        MOV R4,R5
        LI R6,>0097
        ANDI R5,>10
        JEQ L58
        LI R6,>00A0
L58     MOV @RAND,R0
        ANDI R0,>03
        A R6,R0
        MOV R0,R1
        ANDI R1,>0F
        SLA R1,8
        AI R1,>8000
        MOVB R1,@PSG
        MOV R0,R1
        SRL R1,4
        SLA R1,8
        MOVB R1,@PSG

        SLA R0,1
        MOV R0,R1
        ANDI R1,>0F
        SLA R1,8
        AI R1,>A000
        MOVB R1,@PSG
        MOV R0,R1
        SRL R1,4
        SLA R1,8
        MOVB R1,@PSG

        SLA R0,1
        MOV R0,R1
        ANDI R1,>0F
        SLA R1,8
        AI R1,>C000
        MOVB R1,@PSG
        MOV R0,R1
        SRL R1,4
        SLA R1,8
        MOVB R1,@PSG

        LI R1,>9000
        MOVB R1,@PSG
        LI R1,>B100
        MOVB R1,@PSG
        LI R1,>D200
        MOVB R1,@PSG
        DEC R4
        JNE L41
        B @TITLE
        
ADDSCO
        MOVB *R1,R3
        LI R2,>0100  * 1 point
        CI R3,>80    * Square
        JEQ L47
        LI R2,>0200  * 2 points
        CI R3,>90    * Triangle
        JEQ L47
        LI R2,>0500  * 5 points
        CI R3,>9C    * Heptagon
        JEQ L47
        LI R2,>0300  * 3 points
L47     LI R3,SCORE
L48     AB R2,*R3
        MOVB *R3,R2
        CI R2,>0A00
        JL L49
        LI R2,>F600
        AB R2,*R3
        LI R2,>0100
        INC R3
        C R3,@SCORE+6
        JNE L48
L49
      

UPDSCO
        MOV R11,R10
        MOV R1,R9
        LI R0,>42E0
        BL @SETVDP
        MOVB @SCORE+5,R1
        AI R1,>3000
        BL @WRTVDP
        MOVB @SCORE+4,R1
        AI R1,>3000
        BL @WRTVDP
        MOVB @SCORE+3,R1
        AI R1,>3000
        BL @WRTVDP
        MOVB @SCORE+2,R1
        AI R1,>3000
        BL @WRTVDP
        MOVB @SCORE+1,R1
        AI R1,>3000
        BL @WRTVDP
        MOVB @SCORE,R1
        AI R1,>3000
        BL @WRTVDP
        LI R1,>3000
        BL @WRTVDP
        MOV R9,R1
        B *R10

RANDOM
        LI R0,>0180
L11     DEC R0
        JNE L11

RANDOM2
        INC @FRAME
        MOV @RAND,R1
        MOV R1,R2
        MOV R2,R3
        SLA R3,2
        XOR R3,R2
        SLA R3,2
        XOR R3,R2
        SLA R3,1
        XOR R3,R2
        SRL R2,15
        SLA R1,1
        XOR R2,R1
        XOR @FRAME,R1
        MOV R1,@RAND
        B *R11

SETVDP
        SWPB R0
        MOVB R0,@VDPWA
        SWPB R0
        MOVB R0,@VDPWA
        B *R11

WRTVDP
        MOVB R1,@VDPWD
        B *R11

*
* Write a message to screen
* Input: R1 = Address of message (first length then text)
*
WRTMSG  MOVB *R1+,R2
        SRL R2,8
L60     MOVB *R1+,@VDPWD
        DEC R2
        JNE L60
        B *R11

BITMAPS BYTE >F0,>F0,>0F,>0F,>00,>00,>00,>00
        BYTE >08,>1C,>3E,>7F,>80,>C1,>E3,>F7

SPRITES BYTE >FF,>FF,>C0,>C0,>C0,>C0,>C0,>C0
        BYTE >C0,>C0,>C0,>C0,>C0,>C0,>FF,>FF
        BYTE >FF,>FF,>03,>03,>03,>03,>03,>03
        BYTE >03,>03,>03,>03,>03,>03,>FF,>FF

        BYTE >00,>00,>00,>00,>00,>01,>00,>01
        BYTE >00,>01,>00,>01,>00,>00,>00,>00
        BYTE >00,>00,>00,>00,>80,>00,>80,>00
        BYTE >80,>00,>80,>00,>00,>00,>00,>00

        BYTE >01,>01,>01,>03,>03,>03,>03,>07
        BYTE >0e,>1E,>3F,>7F,>FF,>1C,>1C,>08
        BYTE >80,>80,>80,>C0,>C0,>C0,>C0,>e0
        BYTE >70,>78,>FC,>FE,>FF,>38,>38,>10

        BYTE >00,>03,>01,>00,>00,>C0,>30,>00
        BYTE >00,>00,>0C,>30,>00,>00,>01,>01
        BYTE >00,>00,>80,>08,>10,>00,>00,>00
        BYTE >0C,>03,>00,>00,>30,>18,>00,>00

        BYTE >00,>01,>03,>03,>06,>06,>0C,>0C
        BYTE >18,>18,>30,>30,>60,>60,>FF,>FF
        BYTE >00,>80,>C0,>C0,>60,>60,>30,>30
        BYTE >18,>18,>0C,>0C,>06,>06,>FF,>FF

        BYTE >01,>07,>1E,>78,>C0,>C0,>C0,>60
        BYTE >60,>60,>30,>30,>30,>18,>1F,>1F
        BYTE >80,>E0,>78,>1E,>03,>03,>03,>06
        BYTE >06,>06,>0C,>0C,>0C,>18,>F8,>F8

        BYTE >0F,>1F,>18,>30,>30,>60,>60,>C0
        BYTE >C0,>60,>60,>30,>30,>18,>1F,>0F
        BYTE >F0,>F8,>18,>0C,>0C,>06,>06,>03
        BYTE >03,>06,>06,>0C,>0C,>18,>F8,>F0

        BYTE >01,>07,>1E,>38,>30,>60,>60,>C0
        BYTE >C0,>60,>60,>30,>30,>18,>1F,>0F
        BYTE >80,>E0,>78,>1C,>0C,>06,>06,>03
        BYTE >03,>06,>06,>0C,>0C,>18,>F8,>F0

COLORS  BYTE >60,>60,>60,>60,>60,>60,>50,>50
        BYTE >90,>90,>90,>90,>60,>60,>60,>80
        BYTE >40,>60,>60,>60,>60,>60,>60,>60
        BYTE >60,>60,>60,>60,>60,>60,>60,>60

SAVER   BYTE >0C,>04,>06,>01,>0D,>02,>0E,>01

MSG1    BYTE 10
        TEXT "ASTRO CUBE"
MSG2    BYTE 10
        TEXT "@NANOCHESS"
MSG3    BYTE 10
        TEXT "PUSH SPACE"
MSG4    BYTE 6
        TEXT "LIVES "
MSG5    BYTE 6
        TEXT "LEVEL "
        END	
