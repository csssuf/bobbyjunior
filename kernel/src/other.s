other_entry:
    mov ax, hw2
    call print_string
    ret

hw2: db 0xA,0xD,'This is also a string',0
