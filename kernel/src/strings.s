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
        cmp ax, [bp + 8]          ; n == len
        je .strncmp_e
        ; Load characters into dx and cx
        mov bx, word [bp + 4]   ; bx = &str1
        add bx, ax              ; bx = bx + n
        mov dh, byte [bx]            ; dx = str1[n]
        cmp dh, 0               ; check for \0
        je .strncmp_ne

        mov bx, word [bp + 6]        ; bx = &str2
        add bx, ax              ; bx = bx + n
        mov ch, byte [bx]            ; cx = str2[n]
        cmp ch, 0               ; check for \0
        je .strncmp_ne

        inc ax
        ; compare str1[n] (in dx) with str2[n] (in cx)
        cmp dh, ch            ; str1[n] == str2[n]
        je .strncmp_loop        ; str1[n] == str2[n] -> strncmp_loop
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
