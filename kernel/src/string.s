    [BITS 16]
; compare two strings up to len
; strncmp(addr str1, addr str2, len)
global strncmp
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
global memset
memset:
    ; setup out stack frame
    push bp
    mov bp, sp
    sub sp, 4

    mov word [bp-2], bx ; save bx into a local var
    ; grab out args
    mov bx, [bp + 4]    ; address
    mov cx, [bp + 6]    ; CL = character
    mov dx, [bp + 8]    ; len
    mov ax, 0           ; n (the counter)

    .memset_loop:
        mov [bp-4], ax
        add bx, [bp-4]
        mov byte [bp-4], cl
        inc ax
        cmp ax, dx
        jne .memset_loop

    mov bx, word [bp-2]
    mov sp, bp
    pop bp
    ret

; Copy one location in memory to another
; memcpy(int16 src, int16 dest, int16 len)
global memcpy
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

; Prints a single character.
; Arguments: (top of stack first)
; - Character to print
global print_char
print_char:
    push bp         ; save callers bp
    mov bp, sp      ; mv sp into bp
    sub sp, 4       ; make room for local vars

    mov ax, word [bp+4]  ; move first arg into ax
    mov word [bp-2], bx  ; store bx in a local stack var

    mov ah, 0x0e
    mov bl, 0x07
    mov bh, 0x00
    int 0x10

    mov bx, word [bp-2]
    mov sp, bp
    pop bp
    ret

; Prints a null-terminated string.
; Arguments (top of stack first)
; - Address of null-terminated string to print
global print_string
print_string:
    push bp
    mov bp, sp
    sub sp, 4

    mov word [bp - 2], bx
    mov bx, word [bp + 4]
    
_print_string_loop:
    mov byte al, [bx]
    cmp al, 0
    je _print_string_done

    push ax
    call print_char
    add sp, 2

    inc bx
    jmp _print_string_loop

_print_string_done:
    mov bx, word [bp - 2]
    mov sp, bp
    pop bp
    ret

; Prints a null-terminated string, followed by a new line and carriage return
; Arguments (top of stack first):
; - Address of null-terminated string to print
global print_line
print_line:
    push bp
    mov bp, sp
    sub sp, 4
    
    mov ax, word [bp + 4]

    push ax
    call print_string
    add sp, 2

    mov ax, 0xD
    push ax
    call print_char
    add sp, 2

    mov ax, 0xA
    push ax
    call print_char
    add sp, 2

    mov sp, bp
    pop bp
    ret

; Prints a hex number.
; Arguments (top of stack first):
; - Number to print
global print_hex_number
print_hex_number:
    push bp
    mov bp, sp
    sub sp, 2

    mov [bp - 2], bx

    mov ax, 0x30
    push ax
    call print_char
    add sp, 2

    mov ax, 0x78
    push ax
    call print_char
    add sp, 2

    mov cx, 0xC ; i = 12
_print_hex_number_loop:
    mov ax, [bp + 4] ; dx = n
    sar ax, cl ; dx >>= i
    and ax, 0xF ; dx &= 0xF
    xor ah, ah ; dh = 0
    mov bx, ax
    add bx, _hex_vals
    mov bx, [bx]
    push bx
    call print_char
    add sp, 2
    sub cx, 4
    cmp cx, 0
    jge _print_hex_number_loop

    mov sp, bp
    pop bp
    ret

global get_char
get_char:
    push bp         ; save callers bp
    mov bp, sp      ; mv sp into bp
    sub sp, 2       ; make room for local vars

    mov word [bp-2], bx  ; store bx in a local stack var

    mov ah, 0x00
    int 0x16        ; ah = scan code, al = char [This blocks]

    mov bx, word [bp-2]
    mov sp, bp
    pop bp
    ret

_hex_vals: db 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66

