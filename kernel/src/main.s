    [BITS 16]
    cpu 8086
        
    extern print_line
    extern print_string
    extern print_char
    extern get_char
    extern bf_main
    extern memcpy1

    global kmain
kmain:
    mov dx, hw
    push dx
    call print_line

    ;; push 13
    ;; push logo1
    ;; push 0x9000
    ;; call memcpy1
    ;; sub sp, 6
    
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

    .bf_entry:
        call bf_main
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

