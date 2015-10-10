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
    ; convert high and low bytes to decimal
    .div_loop:
        mov cx, 16              ; cx stores 16 so we can divide
        mov dx, 0

        div cx                  ; divide by 16
        mov cx, ax              ; store quotent

        mov al, dh              ; get high byte of the reminader
        add al, 48
        call print_char         ; print high digit

        mov al, dl              ; get low byte of remainder
        add al, 48
        call print_char         ; print low digit

        mov al, ' '
        call print_char
        mov ax, cx              ; move quotent back into ax
        clc
        cmp ax, 0               ; is the quotient 0?
        jnz .div_loop          ; if its not go back to div_loop
    ret

times 510-($-$$) db 0
db 0x55
db 0xaa
