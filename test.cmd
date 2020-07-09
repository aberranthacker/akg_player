OUTPUT_FORMAT("binary")
OUTPUT_ARCH(pdp11)

INPUT(test.o)
OUTPUT(TEST.SAV)

PPU_PPDONE = PPDONE / 2;

SECTIONS
{
    . = 0;
.text :
    {
        test.o (.text)
    }
.data :
    {
        test.o (.data)
    }
.bss :
    {
        test.o (.bss)
    }
}
