[BITS   16]
[ORG    0x7C00]

boot:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ax, 0
    mov ss, ax
    mov sp, 0x7C00 ; stack lives at 0x7C00, grows towards 0x500
reset_drive:
    mov ax, 0
    mov dl, 0
    int 0x13
    jc reset_drive
read_drive:
    mov ax, 0x7E00
    mov es, ax
    mov bx, 0
    mov ah, 2
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0
    int 0x13
    jc read_drive

    jmp kmain

times 510-($-$$) db 0
db 0x55
db 0xaa

%include "main.s"
