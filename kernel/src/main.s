%include "string.s"
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
    mov dx, logo8
    push dx
    call print_line
    mov dx, logo9
    push dx
    call print_line

    add sp, 2

    ; Test strncmp
    mov dx, 12
    push dx
    mov dx, logo1
    push dx
    mov dx, logo9
    push dx
    call strncmp
    cmp ax, 0
    je .success
    jmp .failure

    .success:
        mov dx, succ
        push dx
        call print_line
        jmp .forth_entry
    .failure:
        mov dx, fail
        push dx
        call print_line
        jmp .forth_entry
    .forth_entry:
        jmp forth_main
        jmp $

hw: db 'Kernel loaded.',0
logo1: db '=========  =',0
logo2: db '=       =  =',0
logo3: db '= =====    =',0
logo4: db '= =     =  =',0
logo5: db '= ===== ====',0
logo6: db '=     = =  =',0
logo7: db '= =====    =',0
logo8: db '=       =  =',0
logo9: db '=========  =',0
succ: db 'Success!',0
fail: db 'Failure!',0
