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

; Set memory to a specified char
; memset(int16 addr, char, len)
memset:
    ; setup out stack frame
    push bp
    mov bp, sp
    sub sp, 4

    ; grab out args
    mov ax, [bp + 4]    ; address
    mov cx, [bp + 6]    ; character
    mov dx, [bp + 8]    ; len

    mov word [bp-2], bx ; save bx into a local var
    mov bx, ax          ; our address needs to be in bx

    sub dx, 1           ; memory is 0 indexed
    .memset_loop:
        add bx, dx
        mov word [bx], cx
        sub dx, 1
        clc
        cmp dx, 0
        jge .memset_loop

    mov bx, word [bp-2]
    mov sp, bp
    pop bp
    ret

; Copy one location in memory to another
; memcpy(int16 src, int16 dest, int16 len)
memcpy:
    push bp
    sub sp, 4
    mov ax, [bp + 4]    ; src address
    mov cx, [bp + 6]    ; dest address
    mov dx, [bp + 8]    ; len

    mov word [bp-2], bx ; store bx for later
    mov bx, ax          ; move src into bx

    sub dx, 1
    mov word [bp-4], dx ; put len here so we can reuse dx
    .memcpy_loop:
        add bx, word [bp-4]
        mov dx, [bx]    ; load src word from memory into dx

        mov bx, cx      ; get the dest addr into bx
        add bx, word [bp-4]

        mov [bx], dx    ; copy

        sub word [bp-4], 1  ; sub 1 from our counter

        clc
        cmp word [bp-4], 0
        jge .memcpy_loop
    mov bx, word [bp-2]
    mov sp, bp
    pop bp
    ret

    pop bx
    sub sp, 4
