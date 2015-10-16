[BITS 16]
extern print_line
extern print_string
extern print_char
extern print_hex_number
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
    add sp, 2
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
    add sp, 2
    call bf_grab_line   ; grab 76 characters of brainfuck

    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret

bf_print_pointer:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    mov bx, word [bf_pointer]  ; bx = bf_pointer
    push word bx            ; &bf_pointer++
    call print_hex_number
    add sp, 2

    mov ax, 0xD
    push ax
    call print_char
    add sp, 2

    mov ax, 0xA
    push ax
    call print_char
    add sp, 2

    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret

; brain fuck: [
bf_loop_start:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    mov bx, [bf_pointer]

    cmp byte [bf_array + bx] , 0
    je .loop_skip
    jmp .bf_loop_start_ret
    .loop_skip: ; grab the matching bf_line_pointer for the end of the loop
        mov bx, [bf_line_pointer]
        mov ax, [bf_loops + bx]     ; end of loop pointer
        mov [bf_line_pointer], ax
    .bf_loop_start_ret:
        mov bx, [bp - 2]
        mov sp, bp
        pop bp
        ret

; brain fuck: ]
bf_loop_end:
    push bp
    mov bp, sp
    sub sp, 2
    mov [bp - 2], bx

    mov bx, [bf_pointer]

    cmp byte [bf_array + bx] , 0
    je .bf_loop_end_ret
    .bf_loop_loop:          ; loop de loop!
        mov bx, [bf_line_pointer]
        mov ax, [bf_loops + bx]     ; end of loop pointer
        dec ax                      ; make sure we execute loop start again
        mov [bf_line_pointer], ax
    .bf_loop_end_ret:
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

    inc word [bf_pointer]            ; *bf_pointer++

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

    dec word [bf_pointer] ; *bf_pointer--

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
    add sp, 2

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

    call get_char           ; al = <user input>
    mov bx, [bf_pointer]    ; bx = *bf_pointer (the actual pointer)
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
    push dx         ; len=76
    mov dl, 0
    push dx         ; char=\0
    mov dx, bf_line
    push dx         ; addr=bf_line
    call memset
    sub sp, 6

    .bfgl_loop:
        call get_char                   ; al = char
        push ax
        call print_char                 ; echo
        pop ax

        cmp al, 0x0D                    ; check if we hit enter
        je .bfgl_end

        mov bx, [bf_line_pointer]       ; bx = *bf_line_pointer
        mov byte [bf_line + bx], al     ; update line buffer
        cmp al, '['                     ; is this a loop start?
        je .loop_start
        cmp al, ']'                     ; is this a loop end?
        je .loop_end
        .loop_start:
            push word [bf_line_pointer]
            jmp .bfgl_loop_end
        .loop_end:
            pop dx
            mov [bf_loops + bx], dx     ; current bflp -> last loop start
            xchg bx, dx
            mov [bf_loops + bx], dx     ; last loop start -> current bflp
            jmp .bfgl_loop_end
        .bfgl_loop_end:
            inc word [bf_line_pointer]           ; bf_line_pointer++
            cmp word [bf_line_pointer], 76       ; have we reached the end?
            je .bfgl_end
            jmp .bfgl_loop
    .bfgl_end:
        mov ax, [bf_line_pointer]
        mov [bf_line_len], ax
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

        cmp dl, '['
        je .eval_ls

        cmp dl, ']'
        je .eval_le

        cmp dl, 0
        je .bf_eval_end

        jmp .panic
        .eval_ls:
            call bf_loop_start
            jmp .loop_end
        .eval_le:
            call bf_loop_end
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
            add sp, 2

            mov bx, [bf_line_pointer]
            mov dx, [bf_line + bx]
            push dx
            call print_char
            add sp, 2

            mov dx, bf_panic_mid
            push dx
            call print_string
            add sp, 2

            mov dx, [bf_line_pointer]
            add dx, 48
            push dx
            call print_char
            add sp, 2

            mov ax, 0xD
            push ax
            call print_char
            add sp, 2

            mov ax, 0xA
            push ax
            call print_char
            add sp, 2


            jmp .bf_eval_end
        .loop_end:
            inc word [bf_line_pointer]
            mov ax, [bf_line_len]
            cmp word [bf_line_pointer], ax
            je .bf_eval_end
            jmp .loop
    .bf_eval_end:
        mov bx, [bp - 2]
        mov sp, bp
        pop bp
        ret

bf_prompt_str:      db 'bf> ',0         ; prompt for input
bf_line_pointer:    dw 0                ; where are we in the bf_line buffer
bf_line_len:        dw 0                ; how long our line is
bf_line:            times 76 db 0       ; storage for a single line of input
bf_loops:           times 76 db 0       ; storage for loop bf_line_pointer locs
bf_intro:           db 'Welcome to CSH Brain Fuck!', 0
bf_panic_intro:     db '[Panic] Unknown char "', 0
bf_panic_mid:       db '" at ', 0
bf_array:           times 300 db 0  ; our brain fuck array
bf_pointer:         dw 0            ; the brainfuck pointer
