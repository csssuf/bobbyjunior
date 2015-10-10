[BITS   16]
[ORG    0x7c00]

boot:
    ; 0 out all our segment registers
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x1500 ; stack starts at 0x500 +4k grows down towards 0x500
    call print_mem
    jmp $

print_char:
    mov ah, 0x0e
    mov bl, 0x07
    mov bh, 0x00
    int 0x10
    ret

print_mem:
    clc
    int 0x12
    mov cx, ax ; store mem in cx (ax is needed for 0x10)
    ; convert high and low bytes to ascii
    add cl, 48
    add ch, 48

    mov al, cl
    call print_char
    mov al, ch
    call print_char
    ret

times 510-($-$$) db 0
db 0x55
db 0xaa
