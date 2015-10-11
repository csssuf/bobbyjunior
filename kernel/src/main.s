%include "functions.s"
%include "memory.s"
%include "forth.s"

kmain:
    mov dx, hw
    push dx
    call print_line

    mov dx, logo1
    push dx
    call print_line
    mov dx, logo2
    push dx
    call print_line
    mov dx, logo3
    push dx
    call print_line
    mov dx, logo4
    push dx
    call print_line
    mov dx, logo5
    push dx
    call print_line
    mov dx, logo6
    push dx
    call print_line
    mov dx, logo7
    push dx
    call print_line

    add sp, 2

    jmp forth_main

hw: db 'Kernel loaded.',0
logo1: db '===========  =',0
logo2: db '=  =====  =  =',0
logo3: db '=  =      =  =',0
logo4: db '=  =====  ====',0
logo5: db '=      =  =  =',0
logo6: db '=  =====  =  =',0
logo7: db '===========  =',0

