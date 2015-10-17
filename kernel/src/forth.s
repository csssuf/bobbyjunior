    [BITS 16]
    cpu 8086
    extern strncmp
    extern get_char
    extern print_hex_number
    extern print_string
        ; forth regs
        ; ax: top of stack
        ; bx: instruction pointer
        ; si: dstack pointer
        ; sp: rstack pointer

dstack: times 32 dw 0

thisword:       times 6 db 0
thischar:       db 0

forth_main:
    mov ax, 0
    mov cx, thisword

forth_read: ; ax: current char
            ; bx: thisword counter
    push ax
    push bx
    mov bx, 0

    mov ax, [thisword]

readloop:
    cmp ax, ' '
    je readloop_done
    cmp ax, '\n'
    je readloop_done

    mov [thisword + bx], ax
    add bx, 2

    call nextchar
    jmp readloop
readloop_done:
    mov [thisword + bx], byte 0
    mov [thisword], ax
    pop bx
    pop ax
    ret

nextchar:
    push ax
    push cx
    push dx
    call get_char
    pop dx
    pop cx
    pop ax
    ret

forth_cycle: ; dx: current instruction 
    mov dx, [bx]
    add bx, 2

    add dx, forth_insts
    jmp dx
    
forth_insts:
    dw f_add
    dw f_print
    dw f_const
    dw halt
    
f_add:
    add ax, [si]
    sub si, 2

f_print:
    push ax
    push cx
    push dx
    push ax

    call print_char

    add sp, 2
    pop dx
    pop cx
    pop ax

f_const:
    add si, 2
    mov [si], ax
    mov ax, [bx]
    add bx, 2

panic:
    push ax
    call print_string
halt:   jmp halt
