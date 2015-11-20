    [BITS 16]
    cpu 8086
    extern strncmp
    extern get_char
    extern print_hex_number
    extern print_string
    extern print_char
    extern forth_program
        ; forth regs
        ; ax: top of stack
        ; bx: instruction pointer
        ; si: dstack pointer
        ; sp: rstack pointer

dstack: times 32 dw 0

thisword:       times 6 db 0
thischar:       db 0

global forth_main
forth_main:
    mov ax, 0
    mov bx, forth_program
    mov si, dstack
    call forth_cycle

forth_read: ; ax: current char
            ; bx: thisword counter
    push ax
    push bx
    mov bx, 0

    mov ax, [thisword]

    .loop:
    	cmp ax, ' '
	    je .done
	    cmp ax, '\n'
	    je .done

	    mov [thisword + bx], ax
	    add bx, 2

	    call nextchar
	    jmp .loop

    .done:
    
    mov [thisword + bx], byte 0
	mov [thisword], ax
	pop bx
	pop ax
	ret

nextchar:
    push ax
    push cx
    push dx
    call get_char
    pop dx
    pop cx
    pop ax
    ret

forth_cycle: ; di: current instruction
    mov di, [bx]
    and di, 0xFF
    add bx, 1

    add di, di
    mov dx, [di+forth_insts]
    jmp dx
    
forth_insts:
    dw f_add                    ;0
    dw f_sub                    ;1
    dw f_mul                    ;2
    dw f_divmod                 ;3
    dw f_call                   ;4
    dw f_jmp                    ;5
    dw f_0branch                ;6
    dw f_fromRet                ;7
    dw f_toRet                  ;8
    dw f_and                    ;9
    dw f_or                     ;10
    dw f_xor                    ;11
    dw f_lt                     ;12
    dw f_ult                    ;13
    dw f_const                  ;14

    dw f_print                  ;15
    dw halt                     ;16
    
f_add:
    add ax, [si]
    sub si, 2
    jmp forth_cycle

f_sub:
    sub ax, [si]
    sub si, 2
    jmp forth_cycle

f_mul:
    imul word [si]
    sub si, 2
    jmp forth_cycle

f_divmod:
    mov dx, 0
    idiv word [si]
    mov [si], dx
    jmp forth_cycle
    
f_call:
    add bx, 2
    push bx
    mov bx, [bx-2]
    jmp forth_cycle
    
f_jmp:
    mov bx, [bx]
    jmp forth_cycle
    
f_0branch:
    cmp ax, 0
    jne forth_cycle
    mov bx, [bx]
    jmp forth_cycle

f_fromRet:
f_toRet:
f_and:
f_or:
f_xor:
f_lt:
f_ult:

f_const:
    add si, 2
    mov [si], ax
    mov ax, [bx]
    add bx, 2

    jmp forth_cycle

f_print:
    push ax
    push cx
    push dx
    push ax

    call print_char

    add sp, 2
    pop dx
    pop cx
    pop ax

    jmp forth_cycle

halt:   jmp halt    

panic:
    push ax
    call print_string
