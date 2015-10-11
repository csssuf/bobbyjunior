%include "functions.s"
%include "memory.s"

kmain:
    mov cl, '!'
    push cx
    call print_char
    jmp $

hw: db 'Kernel loaded.',0
