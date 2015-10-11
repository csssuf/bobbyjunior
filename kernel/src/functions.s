; Prints a single character.
; Arguments: (top of stack first)
; - Character to print
print_char:
    mov ax, bx ; save bx to ax
    pop bx
    push ax ; push ax to stack
    mov ah, 0x0e
    mov bl, 0x07
    mov bh, 0x00
    int 0x10
    pop bx ; restore bx
    ret

; Prints a null-terminated string.
; Arguments (top of stack first)
; - Address of null-terminated string to print
print_string:
    pop ax
    push bx
    mov bx, ax
    mov ch, 0
_print_string_loop:
    mov byte al, [bx]
    mov cl, al
    jcxz _print_string_done
    call print_char
    inc bl
    jmp _print_string_loop
_print_string_done:
    pop bx
    ret

; Prints a null-terminated string, followed by a new line and carriage return
; Arguments (top of stack first):
; - Address of null-terminated string to print
print_line:
    call print_string
    mov al, 0xD
    call print_char
    mov al, 0xA
    call print_char
    ret

; NOTE: pusha and popa do not save/restore bx, since it is a callee saved register.
pusha:
    push ax
    push cx
    push dx
    ret

popa:
    pop dx
    pop cx
    pop ax
    ret
