[BITS   16]
[ORG    0x7C00]

boot:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00 ; stack lives at 0x1500, grows towards 0x500
    jmp kmain

times 510-($-$$) db 0
db 0x55
db 0xaa

%include "main.s"
