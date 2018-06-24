all: exit.asm
	nasm -f macho64 exit.asm -o exit.o
	ld exit.o -o exit

clean:
	rm exit exit.o
