set architecture i8086
set disassembly-flavor intel
layout split
layout regs
target remote localhost:1234
b *0x7c00
c
