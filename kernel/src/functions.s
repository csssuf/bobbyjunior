print_char:
    call pusha
    mov ah, 0x0e
    mov bl, 0x07
    mov bh, 0x00
    int 0x10
    call popa
    ret

print_string:
    call pusha
    mov bx, ax
    mov ch, 0
_print_string_loop:
    mov byte al, [bx]
    mov cl, al
    jcxz _print_string_done
    call print_char
    inc bl
    jmp _print_string_loop
_print_string_done:
    call popa
    ret

print_line:
    call pusha
    call print_string
    mov al, 0xD
    call print_char
    mov al, 0xA
    call print_char
    call popa
    ret

pusha:
    push ax
    push bx
    push cx
    push dx
    ret

popa:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
