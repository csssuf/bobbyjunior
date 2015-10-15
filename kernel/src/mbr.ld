ENTRY(boot)

MEMORY
{
       ram : ORIGIN = 0x500, LENGTH = 0x10000
}

SECTIONS
{
    .text 0x7c00 : {
           bin/mbr.o
           bin/main.o
           bin/string.o
           bin/brainfuck.o
           bin/forth.o  
    }
}
