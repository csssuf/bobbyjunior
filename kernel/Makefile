SRCS := src/mbr.s src/brainfuck.s src/forth.s src/main.s src/string.s
OUTS := $(patsubst src/%.s,bin/%.o,$(SRCS))

bin/mbr.bin: bin/mbr.elf
	objcopy -S -O binary bin/mbr.elf bin/mbr.bin

bin/mbr.elf: $(OUTS)
	ld -T src/mbr.ld -m elf_i386 $(OUTS) -o bin/mbr.elf

bin/%.o: src/%.s
	nasm -I src/ -f elf -o $@ $< 

.PHONY: clean
clean:
	rm bin/*
