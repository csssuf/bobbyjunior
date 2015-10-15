    [BITS 16]
        
    extern print_line
    extern print_string
    extern print_char
    extern get_char
    extern memset

global bf_main
bf_main:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    mov dx, bf_intro
    push dx
    call print_line
    .loop:
        call bf_prompt
        call bf_eval
        jmp .loop

; Prompt the user for a line of brainfuck
bf_prompt:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    mov dx, bf_prompt_str
    push dx
    call print_string   ; print the prompt
    call bf_grab_line   ; grab 76 characters of brainfuck

    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret

bf_dump_line:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    mov dx, bf_line
    call print_line

    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret

bf_print_pointer:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    mov bx, [bf_pointer]  ; bx = bf_pointer
    add bx, 48
    push word bx            ; &bf_pointer++
    call print_char

    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret

; brain fuck: >
bf_pointer_inc:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    inc word [bf_pointer]            ; &bf_pointer++

    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret

; brain fuck: <
bf_pointer_dec:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    dec word [bf_pointer]            ; &bf_pointer--

    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret

; brain fuck: +
bf_byte_inc:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    mov bx, [bf_pointer]    ; bx = *bf_pointer (the actual pointer)
    inc byte [bf_array + bx]

    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret

; brain fuck: -
bf_byte_dec:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    mov bx, [bf_pointer]    ; bx = *bf_pointer (the actual pointer)
    dec byte [bf_array + bx]

    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret

; brain fuck: .
bf_byte_out:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    mov ax, 0xD
    push ax
    call print_char
    add sp, 2

    mov ax, 0xA
    push ax
    call print_char
    add sp, 2

    mov bx, [bf_pointer]    ; bx = *bf_pointer (the actual pointer)
    mov dl, byte [bf_array + bx]    ; dl = bf_array[bf_pointer]
    push dx
    call print_char

    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret

; brain fuck: ,
bf_byte_in:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    mov bx, [bf_pointer]    ; bx = *bf_pointer (the actual pointer)
    call get_char           ; al = <user input>
    mov byte [bf_array + bx], al

    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret

; Grab a line's worth of brainfuck program
bf_grab_line:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    ; reset bf_line_pointer to 0
    mov word [bf_line_pointer], 0
    ;call memset to reset our line memory
    mov dx, 76
    push dx
    mov dl, 0
    push dx
    mov dx, bf_line
    push dx
    call memset

    .bfgl_loop:
        call get_char                   ; al = char
        push ax
        call print_char
        pop ax
        cmp al, 0x0D                    ; check if we hit enter
        je .bfgl_end
        mov bx, [bf_line_pointer]       ; bx = *bf_line_pointer
        mov byte [bf_line + bx], al     ; update line buffer
        inc word [bf_line_pointer]           ; bf_line_pointer++
        cmp word [bf_line_pointer], 76       ; have we reached the end?
        je .bfgl_end
        jmp .bfgl_loop
    .bfgl_end:
        mov ax, 0xD
        push ax
        call print_char
        add sp, 2

        mov ax, 0xA
        push ax
        call print_char

        mov bx, [bp - 2]
        mov sp, bp
        pop bp
        ret



; evalulate Brain fuck in bf_line
bf_eval:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    ; reset bf_line_pointer to 0
    mov word [bf_line_pointer], 0
    xor bx, bx
    xor dx, dx

    .loop:
        mov bx, word [bf_line_pointer]
        mov dl, byte [bf_line + bx] ; dx = bf_line[n]
        cmp dl, '>'
        je .eval_ip
        cmp dl, '<'
        je .eval_dp
        cmp dl, '+'
        je .eval_ibp
        cmp dl, '-'
        je .eval_dbp
        cmp dl, '.'
        je .eval_otbp
        cmp dl, ','
        je .eval_inbp
        cmp dl, '?'
        je .eval_pp
        cmp dl, '#'
        je .eval_dl
        cmp dl, 0
        je .bf_eval_end
        jmp .panic
        .eval_dl:    ; dump line
            call bf_dump_line
            jmp .loop_end
        .eval_ip:   ; inc pointer
            call bf_pointer_inc
            jmp .loop_end
        .eval_dp:   ; dec pointer
            call bf_pointer_dec
            jmp .loop_end
        .eval_ibp:  ; inc byte @ pointer
            call bf_byte_inc
            jmp .loop_end
        .eval_dbp:  ; dec byte @ pointer
            call bf_byte_dec
            jmp .loop_end
        .eval_otbp:   ; output byte @ pointer
            call bf_byte_out
            jmp .loop_end
        .eval_inbp:   ; input byte @ pointer
            call bf_byte_in
            jmp .loop_end
        .eval_pp:
            call bf_print_pointer
            jmp .loop_end
        .panic:
            mov dx, bf_panic_intro
            push dx
            call print_string

            mov bx, [bf_line_pointer]
            mov dx, [bf_line + bx]
            push dx
            call print_char

            mov dx, bf_panic_mid
            push dx
            call print_string

            mov dx, [bf_line_pointer]
            add dx, 48
            push dx
            call print_char

            mov ax, 0xD
            push ax
            call print_char
            add sp, 2

            mov ax, 0xA
            push ax
            call print_char

            jmp .bf_eval_end
        .loop_end:
            inc word [bf_line_pointer]
            cmp word [bf_line_pointer], 76
            je .bf_eval_end
            jmp .loop
    .bf_eval_end:
        mov bx, [bp - 2]
        mov sp, bp
        pop bp
        ret

bf_prompt_str: db 'bf> ',0         ; prompt for input
bf_line: times 76 db 0      ; storage for a single line of input
bf_line_pointer: dw 0       ; where are we in the bf_line buffer
bf_intro: db 'Welcome to CSH Brain Fuck!', 0
bf_panic_intro: db '[Panic] Unknown char "', 0
bf_panic_mid: db '" at ', 0
bf_array: times 300 db 0  ; our brain fuck array
bf_pointer: dw 0            ; the brainfuck pointer
