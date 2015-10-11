        ; forth regs
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
        mov [thisword], ax
        pop bx
        pop ax
        ret

forth_eval:
        push dx
        push ax
        mov ax, 0
        mov bx, bindings+6
lookup: ; ax: string index, bx: bindings index, dx: bindings addr
        mov dx, [bx]
        cmp [thisword+bx], dx

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
        call print_hex
        pop dx
        pop cx
        pop ax

        
