_print_hex:
.1:
db	0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66
push	bp
mov	bp,sp
push	di
push	si
add	sp, -4
mov	ax, 0xC
mov	[bp - 8],ax
jmp .4
.5:
mov	ax,[bp + 4]
mov	cx,[bp-8]
sar	ax,cl
and	al,0xF
xor	ah,ah
mov	[bp-6],ax
mov	bx,[bp-6]
mov	byte al,[bx+.1]
xor	ah,ah
push	ax
call	print_char
inc	sp
inc	sp
.3:
mov	ax,[bp-8]
add	ax,-0x4
mov	[bp-8],ax
.4:
mov	ax,[bp-8]
test	ax,ax
jge	.5
.6:
.2:
add	sp,0x4
pop	si
pop	di
pop	bp
ret
