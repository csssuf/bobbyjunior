; Prints a single character.
; Arguments: (top of stack first)
; - Character to print
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
print_string:
    push bp
    mov bp, sp
    sub sp, 4

    mov word [bp - 2], bx
    mov bx, word [bp + 4]
    
    mov ch, 0

_print_string_loop:
    mov byte al, [bx]
    mov cl, al
    jcxz _print_string_done

    push ax
    call print_char
    add sp, 2

    inc bl
    jmp _print_string_loop

_print_string_done:
    mov bx, word [bp - 2]
    mov sp, bp
    pop bp
    ret

; Prints a null-terminated string, followed by a new line and carriage return
; Arguments (top of stack first):
; - Address of null-terminated string to print
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

; NOTE: _pusha and _popa do not save/restore bx, since it is a callee saved register.
_pusha:
    push ax
    push cx
    push dx
    ret

_popa:
    pop dx
    pop cx
    pop ax
    ret


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

