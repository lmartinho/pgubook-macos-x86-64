all: exit maximum power

exit: exit.asm
	nasm -f macho64 exit.asm -o exit.o
	nasm -f macho32 exit_32.asm -o exit_32.o
	ld exit.o -o exit
	ld exit_32.o -o exit_32

maximum: maximum.asm
	nasm -f macho64 maximum.asm -o maximum.o
	ld maximum.o -o maximum

power: power.asm
	nasm -f macho64 power.asm -o power.o
	ld power.o -o power

clean:
	rm *.o exit exit_32 maximum power
