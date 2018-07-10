AS=nasm
ASFLAGS=-f macho64

all: exit exit_32 maximum power factorial toupper concatenate write-records read-records add-year add-year-error-exit hello-world-no-lib hello-world-lib

clean:
	rm *.o exit exit_32 maximum power factorial toupper concatenate write-records read-records add-year add-year-error-exit hello-world-no-lib hello-world-lib

write-records: write-record.o write-records.o
	ld write-record.o write-records.o -o write-records

read-records: xnu.asm record-def.asm read-records.o count-chars.o read-record.o write-newline.o
	ld read-records.o count-chars.o read-record.o write-newline.o -o read-records

add-year: xnu.asm record-def.asm add-year.o read-record.o write-record.o
	ld add-year.o read-record.o write-record.o -o add-year

add-year-error-exit: xnu.asm record-def.asm add-year-error-exit.o read-record.o write-record.o  error-exit.o count-chars.o write-newline.o
	ld add-year-error-exit.o read-record.o write-record.o error-exit.o count-chars.o write-newline.o -o add-year-error-exit

# Uses shared libraries
hello-world-lib: hello-world-lib.o
	ld -lc -macosx_version_min 10.13.0 hello-world-lib.o -o hello-world-lib

%: %.o
	ld $< -o $@

%.o: %.asm $(DEPS)
	$(AS) $(ASFLAGS) -o $@ $<
