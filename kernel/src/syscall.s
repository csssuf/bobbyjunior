    [BITS 16]
    cpu 8086

    extern print_line

; Handler for the syscall interrupt (0x60).
_syscall_inthandler:
    cmp ah, 0 ; Null syscall
    je  .syscall_zero

    cmp ah, 1 ; For testing, print 'Hello, syscall 1'
    je  .syscall_one

.syscall_one:
    mov dx, _syscall_one_data
    push dx
    call print_line ; and fall through to syscall_zero
    add sp, 2

.syscall_zero:
    iret

; Sets up the syscall interrupt.
global init_syscall
init_syscall:
    push bp
    mov bp, sp
    sub sp, 8

    mov word [bp - 2], es
    mov word [bp - 4], ax
    mov word [bp - 6], bx
    mov bx, 0
    mov es, bx

    mov al, 0x60
    mov bl, 0x4
    imul bl
    mov bx, ax

    mov cx, _syscall_inthandler
    mov [es:bx], cx
    add bx, 2
    mov cx, 0
    mov [es:bx], cx

    mov bx, word [bp - 6]
    mov ax, word [bp - 4]
    mov es, word [bp - 2]
    mov sp, bp
    pop bp
    ret

_syscall_one_data:  db 'Hello, syscall 1',0
