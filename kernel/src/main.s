%include "functions.s"
%include "memory.s"

kmain:
    mov dx, hw
    push dx
    call print_line
    add sp, 2
    jmp $

hw: db 'Kernel loaded.',0
