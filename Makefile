all: exit maximum

maximum: maximum.asm
	nasm -f macho64 maximum.asm -o maximum.o
	ld maximum.o -o maximum

exit: exit.asm
	nasm -f macho64 exit.asm -o exit.o
	nasm -f macho32 exit_32.asm -o exit_32.o
	ld exit.o -o exit
	ld exit_32.o -o exit_32

clean:
	rm exit exit.o exit_32 exit_32.o maximum maximum.o
