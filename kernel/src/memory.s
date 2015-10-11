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
