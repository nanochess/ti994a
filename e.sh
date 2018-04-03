# generate BIN file (works with js99er.net and FinalGROM99)
../../xdt99/xas99.py -b -R $1.asm --base 0x6000
# generate RPK file (works with MAME)
../../xdt99/xas99.py -D RPK -c -R $1.asm
