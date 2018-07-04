AS=nasm
ASFLAGS=-f macho64

all: exit exit_32 maximum power factorial toupper concatenate write-records

clean:
	rm exit exit_32 maximum power factorial toupper concatenate write-records

write-records: write-record.o write-records.o
	ld write-record.o write-records.o -o write-records

%: %.o
	ld $< -o $@

%.o: %.asm $(DEPS)
	$(AS) $(ASFLAGS) -o $@ $<
