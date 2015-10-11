%include "functions.s"
%include "memory.s"

kmain:
    mov dx, hw
    push dx
    call print_line
    add sp, 2

    ; do a thing (console typing)
    .console_loop:
        call get_char
        add sp, 2
        push ax ; push result of get_char on to stack for print_char
        call print_char
        jmp .console_loop
    jmp $

hw: db 'Kernel loaded.',0
