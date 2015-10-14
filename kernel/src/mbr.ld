

MEMORY
{
       ram : ORIGIN = 0x0, LEN = 0x10000
}

SECTIONS
{
        .mbr: { mbr.o }
        .text : { *(.text) }
}
