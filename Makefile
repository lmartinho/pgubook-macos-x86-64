AS=nasm
ASFLAGS=-f macho64

all: exit exit_32 maximum power factorial toupper concatenate

clean:
	rm exit exit_32 maximum power factorial toupper concatenate

%: %.o
	ld $< -o $@

%.o: %.asm $(DEPS)
	$(AS) $(ASFLAGS) -o $@ $<
