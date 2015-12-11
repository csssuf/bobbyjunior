[BITS 16]
cpu 8086


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
