[BITS 16]
cpu 8086

extern print_line

%macro defn 2
    %1:
    push bp
    mov bp, sp
    sub sp, 2
    sub sp, %2
    mov [bp - 2], bx
%endmacro

%macro endfn 0
    mov bx, [bp - 2]
    mov sp, bp
    pop bp
    ret
%endmacro


; bitmap_init(u16 addr, u16 entries)
; bitmap_init([bp + 4], [bp + 6])
; Create a bitmap and set all bits to 0
global bitmap_init
defn bitmap_init, 2
    mov word [bp - 4], di ; save di
    mov di, [bp + 4]      ; di = addr
    mov ax, [bp + 6]      ; ax = entries

    mov cx, 8             ; 8 bits == 1 byte
    xor dx, dx            ; clear dx
    div cx                ; entries / 8 bits = num bytes
    mov cx, ax            ; cx is our counter
    xor ax, ax            ; we want to store 0, so clear ax
    cld                   ; clear direction flag
    .loop:
        stosb
        loop .loop
    mov di, word [bp - 4]
endfn

; bitmap_set(u16 addr, u16 index)
; bitmap_set([bp + 4], [bp + 6])
global bitmap_set
defn bitmap_set, 2
    xor dx, dx
    mov ax, [bp + 6]    ; ax = index
    ; al=quotient, ah=remainder
    mov cl, 8
    div cl   ; index / CHAR_BITS
    mov cl, ah     ; store the byte offset in cl for shl later
    ; calculate address

    mov bx, [bp + 4]
    mov ah, 0           ; extend al to full 16 bit
    add bx, ax          ; bx = addr + index

    ; bitmap[index] l|= (1 << n)
    mov dl, 1
    shl dl, cl              ; dl = (1 << n[cl])

    xor ax, ax
    mov al, byte [bx]
    or al, dl
    mov byte [bx], al
endfn

; bitmap_get(u16 addr, u16 index) -> bool
; bitmap_get([bp + 4], [bp + 6])  -> al
global bitmap_get
defn bitmap_get, 2
    xor dx, dx
    mov ax, word [bp + 6]   ; ax = index
    ; al=quotient, ah=remainder
    mov cl, 8
    div cl     ; index / CHAR_BITS
    mov cl, ah     ; store the byte offset in cl for shl later
    ; calculate address
    mov bx, [bp + 4]
    mov ah, 0
    add bx, ax          ; ax = addr + index
    ; al = bitmap[index] & (1 << n)
    xor dx, dx
    mov dl, 1
    shl dl, cl              ; dl = (1 << n[cl])
    xor ax, ax

    mov al, byte [bx]
    and al, dl
endfn


; slab_init(u16 addr, u16 length, u16 csize)
; slab_init([bp + 4], [bp + 6], [bp + 8])
; Given a memory address initialize all the metadata to handle the slab.
global slab_init
defn slab_init, 2
    mov bx, [bp + 4]
    mov ax, [bp + 6]
    mov [bx+2], ax  ; addr+2 = length
    mov ax, [bp + 8]
    mov [bx+4], ax  ; addr+4 = csize
    mov cx, [bp + 6]
    div cx
    mov [bx+6], ax  ; addr+6 = nchunks

global bitmap_test
defn bitmap_test, 2
    mov ax, startmsg
    push ax
    call print_line
    add sp, 2

    ; initialize the bitmap
    mov ax, 16
    push ax,
    mov ax, bmtest
    push ax
    call bitmap_init    ; bitmap_init(bmtest, 16)
    add sp, 4

    mov ax, initdone
    push ax
    call print_line
    add sp, 2

    ; get the first bit pre-test
    mov ax, 9
    push ax
    mov ax, bmtest
    push ax
    call bitmap_get
    add sp, 4

    cmp al, 0
    je pre_test_succ
    ; pre failure
    mov ax, prefailure
    push ax
    call print_line
    add sp, 2
    jmp pre_end
    pre_test_succ:
        mov ax, presuccess
        push ax
        call print_line
        add sp, 2
    pre_end:

    ; set the first bit
    mov ax, 9
    push ax
    mov ax, bmtest
    push ax
    call bitmap_set     ; bitmap_set(bmtest, 0)
    add sp, 4

    ; get the first bit
    mov ax, 9
    push ax
    mov ax, bmtest
    push ax
    call bitmap_get
    add sp, 4
    cmp al, 0
    jne post_test_succ
    ; post failure
    mov ax, postfailure
    push ax
    call print_line
    add sp, 2
    jmp end
    post_test_succ:
        mov ax, postsuccess
        push ax
        call print_line
        add sp, 2
    end:
endfn


; empty space for testing the bitmaps
bmtest: times 10 db 0
startmsg: db 'Starting bitmap_test', 0
initdone: db 'Finished bitmap_init', 0
presuccess: db 'PRE SUCC: bitmap_get(bmtest, 0) = false', 0
prefailure: db 'PRE FAIL: bitmap_get(bmtest, 0) = true', 0

postsuccess: db 'POST SUCC: bitmap_get(bmtest, 0) = true', 0
postfailure: db 'POST FAIL: bitmap_get(bmtest, 0) = false', 0
