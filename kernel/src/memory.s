; memset(addr, char, len)
memset:
    pop ax ; move int16 addr from stack to reg
    pop cx ; move int16 char from stack to reg
    pop dl ; move int8 len from stack to reg
    mov dh, 0 ; counter
    .memset_loop
        add ax, dh
        mov dword [ax], cl
        add dh, 1
        cmp dh, dl
        jne .memset_loop
    ret
