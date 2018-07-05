AS=nasm
ASFLAGS=-f macho64

all: exit exit_32 maximum power factorial toupper concatenate write-records read-records

clean:
	rm exit exit_32 maximum power factorial toupper concatenate write-records read-records

write-records: write-record.o write-records.o
	ld write-record.o write-records.o -o write-records

read-records: xnu.asm record-def.asm read-records.o count-chars.o read-record.o write-newline.o
	ld read-records.o count-chars.o read-record.o write-newline.o -o read-records

%: %.o
	ld $< -o $@

%.o: %.asm $(DEPS)
	$(AS) $(ASFLAGS) -o $@ $<
