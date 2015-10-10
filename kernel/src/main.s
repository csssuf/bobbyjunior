%include "functions.s"

kmain:
    mov ax, hw
    call print_line
    jmp $

hw: db 'Kernel loaded.',0
