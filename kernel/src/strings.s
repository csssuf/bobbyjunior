; compare two strings up to len
; strncmp(addr str1, addr str2, len)
strncmp:
    push bp
    mov bp, sp
    sub sp, 4

    mov word [bp - 2], bx   ; save bx into local
    mov ax, 0               ; counter n

    .strncmp_loop:
        ; check n == length
        cmp ax, [bp+8]
        je .strncmp_e
        ; load char from str1[n] into dx
        mov bx, word [bp + 4]   ; *str1 -> bx
        add bx, ax
        mov dx, [bx]
        ; get address for str2[n]
        mov bx, [bp + 6]
        add bx, ax
        ; compare str1[n] (in dx) with str2[n] (at [bx])
        cmp dx, [bx]
        add ax, 1 ; incrememnt n
        je .strncmp_loop
        ; we are not equal
        jmp .strncmp_ne
    .strncmp_ne:
        ; strings aren't equal, set ax to 1 and return
        mov ax, 1
        jmp .strncmp_ret
    .strncmp_e:
        mov ax, 0
        jmp .strncmp_ret
    .strncmp_ret:
        mov bx, word [bp - 2]   ; restore bx
        mov sp, bp
        pop bp
        ret
