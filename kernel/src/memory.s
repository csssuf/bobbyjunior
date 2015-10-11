; memset(addr, char, len)
memset:
    pop dx; move len from stack to reg, use DX
    pop cx ; move char from stack to reg, use CX
    pop ax ; move addr from stack to reg, use AX

    push bx ; dafuck? you can only do indirect addressing with bx
    mov bx, ax ; see ab

    sub dx, 1 ; 0 indexed
    .memset_loop:
        add bx, dx
        mov word [bx], cx
        sub dx, 1
        clc
        cmp dx, 0
        jl .memset_loop
    ret
