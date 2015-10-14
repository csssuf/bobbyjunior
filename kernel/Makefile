SRCS := src/mbr.s src/brainfuck.s src/forth.s src/main.s src/string.s
OUTS := $(patsubst src/%.s,bin/%.o,$(SRCS))

bin/%.o: src/%.s
	nasm -I src/ -f elf -o $@ $< 

mbr.out: $(OUTS)
	ld $(OUTS) -o mbr.out
