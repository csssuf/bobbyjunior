[BITS 16]
cpu 8086
extern print_line
extern print_string
extern print_char
extern print_hex_number
extern get_char
extern memset


%macro defn 2
    %1:
    push bp
    mov bp, sp
    sub sp, %2
    mov [bp - 2], bx
%endmacro

%macro endfn 0
    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret
%endmacro

global bf_main


defn bf_main, 2
    ; Print out our intro
    mov ax, bf_intro
    push ax
    call print_line
    add sp, 2
    .loop:
        call bf_prompt
        call bf_eval
        jmp .loop
endfn


; Prompt the user for a line of brainfuck
defn bf_prompt, 2
    mov ax, bf_prompt_str
    push ax
    call print_string   ; print the prompt
    add sp, 2

    call bf_grab_line   ; grab 76 characters of brainfuck
endfn

; Extension to print the current pointer as hex
defn bf_print_pointer, 2
    mov ax, word [bf_pointer]  ; bx = bf_pointer
    push word ax            ; &bf_pointer++
    call print_hex_number
    add sp, 2
    call new_line
endfn


; Extension to print value at pointer as hex
defn bf_print_value, 2
    mov bx, word [bf_pointer]
    mov al, byte [bf_array + bx]
    mov ah, byte 0
    push ax
    call print_hex_number
    add sp, 2
    call new_line
endfn


; brain fuck loop open: [
defn bf_loop_start, 2
    mov bx, [bf_pointer]
    cmp byte [bf_array + bx] , 0
    je .loop_skip
    jmp .bf_loop_start_ret
    .loop_skip: ; grab the matching bf_line_pointer for the end of the loop
        mov bx, [bf_line_pointer]
        mov ax, [bf_loops + bx]     ; end of loop pointer
        mov [bf_line_pointer], ax
    .bf_loop_start_ret:
endfn


; brain fuck loop close: ]
defn bf_loop_end, 2
    mov bx, [bf_pointer]
    cmp byte [bf_array + bx] , 0
    je .bf_loop_end_ret
    .bf_loop_loop:          ; loop de loop!
        mov bx, [bf_line_pointer]
        mov ax, [bf_loops + bx]     ; end of loop pointer
        dec ax                      ; make sure we execute loop start again
        mov [bf_line_pointer], ax
    .bf_loop_end_ret:
endfn


; brain fuck pointer increment: >
defn bf_pointer_inc, 2
    inc word [bf_pointer]            ; *bf_pointer++
    cmp word [bf_pointer], 300
    je .upper_bound
    xor ax, ax
    jmp .bf_pointer_inc_ret
    .upper_bound:
        mov ax, 1                       ; return value 1, we are out of bounds
        dec word [bf_pointer]
    .bf_pointer_inc_ret:
endfn


; brain fuck pointer decrement: <
defn bf_pointer_dec, 2
    cmp word [bf_pointer], 0
    je .lower_bound
    dec word [bf_pointer] ; *bf_pointer--
    xor ax, ax
    jmp .bf_pointer_dec_ret
    .lower_bound:
        mov ax, 1                       ; return value 1, we are out of bounds
    .bf_pointer_dec_ret:
endfn


; brain fuck value increment: +
defn bf_byte_inc, 2
    mov bx, [bf_pointer]    ; bx = *bf_pointer (the actual pointer)
    inc byte [bf_array + bx]
endfn


; brain fuck value decrement: -
defn bf_byte_dec, 2
    mov bx, [bf_pointer]    ; bx = *bf_pointer (the actual pointer)
    dec byte [bf_array + bx]
endfn


; brain fuck output: .
defn bf_byte_out, 2
    mov bx, [bf_pointer]    ; bx = *bf_pointer (the actual pointer)
    xor ax, ax
    mov al, byte [bf_array + bx]    ; dl = bf_array[bf_pointer]
    push ax
    call print_char
    add sp, 2
endfn


; brain fuck user input: ,
defn bf_byte_in, 2
    call get_char           ; al = <user input>
    mov bx, [bf_pointer]    ; bx = *bf_pointer (the actual pointer)
    mov byte [bf_array + bx], al
endfn


; Grab a line's worth of brainfuck program
defn bf_grab_line, 2
    ; reset bf_line_pointer to 0
    mov word [bf_line_pointer], 0
    ;call memset to reset our line memory
    mov ax, 76
    push ax         ; len=76
    mov al, 0
    push ax         ; char=\0
    mov ax, bf_line
    push ax         ; addr=bf_line
    call memset
    sub sp, 6

    .bfgl_loop:
        call get_char                   ; al = char
        push ax
        call print_char                 ; echo
        pop ax

        cmp al, 0x0D                    ; check if we hit enter
        je .bfgl_end
        cmp al, 0x08
        je .bfgl_bs                     ; did we backspace?

        mov bx, [bf_line_pointer]       ; bx = *bf_line_pointer
        mov byte [bf_line + bx], al     ; update line buffer
        cmp al, '['                     ; is this a loop start?
        je .loop_start

        cmp al, ']'                     ; is this a loop end?
        je .loop_end
        jmp .bfgl_loop_end

        .loop_start:
            push word bx                ; push the current line pointer value
            jmp .bfgl_loop_end
        .loop_end:
            pop dx                      ; get the value of the last loop start
            mov [bf_loops + bx], dx     ; current bflp -> last loop start
            xchg bx, dx
            mov [bf_loops + bx], dx     ; last loop start -> current bflp
            jmp .bfgl_loop_end
        .bfgl_bs:
            sub word [bf_line_pointer], 2    ; push us back 2 so we can inc again
        .bfgl_loop_end:
            inc word [bf_line_pointer]           ; bf_line_pointer++
            cmp word [bf_line_pointer], 76       ; have we reached the end?
            je .bfgl_end
            jmp .bfgl_loop
    .bfgl_end:
        push ax
        mov ax, 0x0A
        push ax
        call print_char
        pop ax
        pop ax
        mov ax, [bf_line_pointer]
        mov [bf_line_len], ax
endfn


; evalulate Brain fuck in bf_line
defn bf_eval, 2
    ; reset bf_line_pointer to 0
    mov word [bf_line_pointer], 0
    xor bx, bx
    xor dx, dx

    .loop:
        mov bx, word [bf_line_pointer]
        mov al, byte [bf_line + bx] ; dx = bf_line[n]

        cmp al, '>'
        je .eval_ip

        cmp al, '<'
        je .eval_dp

        cmp al, '+'
        je .eval_ibp

        cmp al, '-'
        je .eval_dbp

        cmp al, '.'
        je .eval_otbp

        cmp al, ','
        je .eval_inbp

        cmp al, '?'
        je .eval_pp

        cmp al, '#'
        je .eval_pv

        cmp al, '['
        je .eval_ls

        cmp al, ']'
        je .eval_le

        cmp al, 0
        je .bf_eval_end

        jmp .loop_end
        .eval_pv:
            call bf_print_value
            jmp .loop_end
        .eval_ls:
            call bf_loop_start
            jmp .loop_end
        .eval_le:
            call bf_loop_end
            jmp .loop_end
        .eval_ip:   ; inc pointer
            call bf_pointer_inc
            cmp ax, 1
            je .panic
            jmp .loop_end

        .eval_dp:   ; dec pointer
            call bf_pointer_dec
            cmp ax, 1
            je .panic
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
            call new_line
            mov ax, bf_panic
            push ax
            call print_line
            add sp, 2
            jmp .bf_eval_end
        .loop_end:
            inc word [bf_line_pointer]
            mov ax, [bf_line_len]
            cmp word [bf_line_pointer], ax
            je .bf_eval_end
            jmp .loop
    .bf_eval_end:
        call new_line
endfn


; Function to print a new line (\r\n)
defn new_line, 2
    mov ax, 0xD
    push ax
    call print_char
    add sp, 2

    mov ax, 0xA
    push ax
    call print_char
endfn


bf_prompt_str:      db 'bf> ',0         ; prompt for input
bf_line_pointer:    dw 0                ; where are we in the bf_line buffer
bf_line_len:        dw 0                ; how long our line is
bf_line:            times 76 db 0       ; storage for a single line of input
bf_loops:           times 76 db 0       ; storage for loop bf_line_pointer locs
bf_intro:           db 'Welcome to CSH BF!', 0
bf_panic:           db 'Tisk Tisk, you went out of bounds', 0
bf_array:           times 300 db 0  ; our brain fuck array
bf_pointer:         dw 0            ; the brainfuck pointer
