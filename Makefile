AS=nasm
ASFLAGS=-f macho64

all: exit exit_32 maximum power factorial uppercase concatenate

clean:
	rm exit exit_32 maximum power factorial uppercase concatenate

%: %.o
	ld $< -o $@

%.o: %.asm $(DEPS)
	$(AS) $(ASFLAGS) -o $@ $<
