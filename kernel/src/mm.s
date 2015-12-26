[BITS 16]
cpu 8086


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


; new_array(u16 addr, u16 size, u16 len) -> void
; new_array([bp + 4], [bp + 6], [bp + 8]) -> void
global new_array
defn new_array, 2
    ; write array header
    mov bx, [bp + 4] ; addr
    mov ax, [bp + 6] ; size
    mov cx, [bp + 8] ; len
    mov [bx], ax     ; Save size to [addr]
    mov [bx+2], cx   ; Save len to [addr+2]
endfn

; array_get(u16 addr, u16 index) -> ptr
; array_get([bp + 4], [bp + 6]) -> ptr
; Get a ptr to an element in this array
global array_get
defn array_get, 2
    mov bx, [bp + 4] ; addr
    mov ax, [bp + 6] ; index
    mov cx, [bx]    ; cx = [size]
    mul cx      ; offset = (index * size)
    add ax, 2       ; offset = (offset + 2)
    add ax, bx      ; <array ptr> + offset
endfn

; array_end(u16 addr) -> ptr
; array_end([bp + 4]) -> ptr
; Useful if you have a bunch of arrays one after another
global array_end
defn array_end, 2
    mov bx, [bp + 4] ; addr
    mov ax, [bx + 2] ; ax = [len]
    add ax, 1        ; len += 1
    mul word [bx]     ; ax = size * len
endfn

; bitmap_init(u16 addr, u16 entries)
; bitmap_init([bp + 4], [bp + 6])
; Create a bitmap and set all bits to 0
global bitmap_init
defn bitmap_init, 2
    mov word [bp - 4], di ; save di
    mov di, [bp + 4] ; di = addr
    mov cx, [bp + 6] ; cx = entries
    mov ax, 8        ; 8 bits == 1 byte
    div cx           ; entires / 8 bits = num bytes
    mov cx, ax       ; cx is our counter
    mov ax, 0        ; we want to store 0
    .loop:
        stosb
        loop .loop
    mov di, word [bp-4]
endfn

; bitmap_set(u16 addr, u16 index)
; bitmap_set([bp + 4], [bp + 6])
global bitmap_set
defn bitmap_set, 2
    mov al, 8           ; al = CHAR_BITS
    ; al=quotient, ah=remainder
    div word [bp + 6]   ; index / CHAR_BITS
    mov cl, ah     ; store the byte offset in cl for shl later
    ; calculate address
    add [bp + 4], al          ; ax = addr + index
    mov bx, ax          ; put our new absolute addr into bx
    ; bitmap[index] l|= (1 << n)
    mov dl, 1
    shl dl, cl              ; dl = (1 << n[cl])
    or byte [bx], dl
endfn

; bitmap_get(u16 addr, u16 index) -> bool
; bitmap_get([bp + 4], [bp + 6])  -> al
global bitmap_get
defn bitmap_get, 2
    mov al, 8           ; al = CHAR_BITS
    ; al=quotient, ah=remainder
    div word [bp + 6]   ; index / CHAR_BITS
    mov cl, ah     ; store the byte offset in cl for shl later
    ; calculate address
    add [bp + 4], al          ; ax = addr + index
    mov bx, ax          ; put our new absolute addr into bx
    ; al = bitmap[index] & (1 << n)
    mov dl, 1
    shl dl, cl              ; dl = (1 << n[cl])
    mov al, byte [bx]
    or al, dl
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
