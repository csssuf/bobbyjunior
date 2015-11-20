SRCS := src/mbr.s src/brainfuck.s src/forth.s src/main.s src/string.s src/forth_prog.s
OUTS := $(patsubst src/%.s,bin/%.o,$(SRCS))

bin/mbr.bin: bin/mbr.elf
	objcopy -S -O binary bin/mbr.elf bin/mbr.bin

bin/mbr.elf: $(OUTS) src/mbr.ld
	ld -T src/mbr.ld -m elf_i386 $(OUTS) -o bin/mbr.elf

bin/%.o: src/%.s
	nasm -I src/ -f elf -o $@ $< 

src/forth_prog.s: src/prog.fs forthc/*.hs
	set -o pipefail ; \
	runhaskell forthc/ForthC.hs < src/prog.fs \
		| runhaskell forthc/ToAsm.hs forth_program \
		> src/forth_prog.s

.PHONY: clean
clean:
	rm bin/*
	rm src/forth_prog.s
