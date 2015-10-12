cpu 8086 ; forth regs
        ; ax: top of stack
        ; 
        ; cx: dstack pointer
        ; dx: rstack pointer

dstack: times 32 dw 0

bindings: ; binding: (symbol: (6*char), func: word)
        db '+'
        times 5 db 0
        dw forth_add

        db '.'
        times 5 db 0
        dw forth_print
        
        times 128 dw 0
endbindings:

thisword:       times 6 db 0
thischar:       db 0

forth_main:
        call nextchar
        mov [thisword], ax
main_loop:      
        call forth_read
        call forth_eval

        jmp main_loop

forth_read: ; ax: current char
        ; bx: thisword counter
        push ax
        push bx
        mov bx, 0

        mov ax, [thisword]

readloop:       
        cmp ax, ' '
        je readloop_done
        cmp ax, '\n'
        je readloop_done

        mov [thisword + bx], ax
        add bx, 2

        call nextchar
        jmp readloop
readloop_done:
        mov [thisword + bx], byte 0
        mov [thisword], ax
        pop bx
        pop ax
        ret

forth_eval:
        push ax
        push cx
        push dx

        mov al, byte [thisword]
        test al, '0'
        jne .lookup

        ; parse hex
        mov bx, thisword+2
        mov cx, 0
        mov dx, 0
        .parse_hex:
                mov al, byte [bx]
                cmp al, '0'
                jl .bad_num
                cmp al, '9'
                jg .athruf

                sub al, '0'

                jmp .parse_hex

        .athruf:
	        cmp al, 'A'
	        jl .bad_num
	        cmp al, 'F'
	        jg .bad_num
	        sub al, 'A'
        .parse_next:
                mov ah, 0
                mov cl, 4

                sar dx, cl
                add dx, ax

                add bx, 1
                cmp bx, thisword+6
                je .push_num

        .push_num:
	        mov bx, dx
	        
	        pop dx
	        pop cx
	        pop ax
                
                xchg cx, bx
	        mov [bx], ax
                xchg cx, bx

	        add cx, 2
	        mov ax, bx

	        ret

        .lookup:
        	mov ax, 6
	        push ax
	        lea ax, [bindings+bx]
	        push ax
	        mov ax, thisword
	        push ax

	        call strncmp
	        cmp ax, 0
	        je .found

	        add bx, 8
	        push bx
	        add bx, bindings
	        cmp bx, endbindings
	        je .notfound
	        pop bx
	        jmp .lookup

        .notfound:
                mov ax, .failmsg
                jmp panic

        .failmsg:
                db 'No such word', 0

        .bad_num:
                mov ax, .badnummsg
                jmp panic

        .badnummsg:
                db 'Bad number', 0

        .found:
                
        mov bx, [bx+6]
                
        

        
nextchar:
        push ax
        push cx
        push dx
        call get_char
        pop dx
        pop cx
        pop ax
        ret

forth_add:
        add ax, [bx]
        sub bx, 2
        ret

forth_print:
        push ax
        push cx
        push dx
        push ax
        call print_hex_number
        pop dx
        pop cx
        pop ax

panic:
        push ax
        call print_string
halt:   jmp halt
        
