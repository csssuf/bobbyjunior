[BITS   16]
[ORG    0x7C00]

boot:
    mov ax, cs ; initialize segment registers
    mov ds, ax
    mov es, ax
    mov ax, 0
    mov ss, ax
    mov sp, 0x7C00 ; stack lives at 0x7C00, grows towards 0x500
reset_drive:
    mov ax, 0
    mov dl, 0 ;drive 0
    int 0x13
    jc reset_drive ;if failure, try again
read_drive:
    mov ax, 0x07E0 ; load to immediately after MBR
    mov es, ax
    mov bx, 0

    mov ah, 2 ; load to ES:BX
    mov al, 8 ; load 1 sector
    mov ch, 0 ; cylinder 0
    mov cl, 2 ; sector 2
    mov dh, 0 ; head 0
    mov dl, 0 ; drive 0
    int 0x13
    jc read_drive ; if failure, try again

    jmp kmain

times 510-($-$$) db 0
db 0x55
db 0xaa

%include "main.s"
