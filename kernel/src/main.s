[BITS   16]

kmain:
    mov ax, hw
    call print_string
    call other_entry
    jmp $

print_char:
    push bx
    mov ah, 0x0e
    mov bl, 0x07
    mov bh, 0x00
    int 0x10
    pop bx
    ret

print_string:
    mov bx, ax
    mov ch, 0
print_string_loop:
    mov byte al, [bx]
    mov cl, al
    jcxz print_string_done
    call print_char
    inc bl
    jmp print_string_loop
print_string_done:
    ret

hw: db 'Hello, world',0

%include "other.s"
