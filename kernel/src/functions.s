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
