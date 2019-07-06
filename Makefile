AS=nasm
ASFLAGS=-g -f macho64
ASFLAGS32=-g -f macho32
LD=ld
# -static: Don't use the dynamic linker (dyld), so that we don't have to link with the full libSystem
LDFLAGS=-arch x86_64 -macosx_version_min 10.14 -static
LDFLAGS32=-arch i386 -macosx_version_min 10.14 -static

all: exit exit_32 maximum power factorial toupper concatenate write-records read-records add-year add-year-error-exit hello-world-no-lib hello-world-lib printf-example write-records-lib read-records-alloc sbrk.asm sbrk_function.asm

clean:
	rm *.o exit exit_32 maximum power factorial toupper concatenate write-records read-records add-year add-year-error-exit hello-world-no-lib hello-world-lib printf-example read-records-alloc sbrk.asm sbrk_function.asm

exit_32.o: exit_32.asm
	$(AS) $(ASFLAGS32) exit_32.asm -o exit_32.o

exit_32: exit_32.o
	$(LD) $(LDFLAGS32) exit_32.o -o exit_32

write-records: write-record.o write-records.o
	$(LD) $(LDFLAGS) write-record.o write-records.o -o write-records

read-records: xnu.asm record-def.asm read-records.o count-chars.o read-record.o write-newline.o
	$(LD) $(LDFLAGS) read-records.o count-chars.o read-record.o write-newline.o -o read-records

add-year: xnu.asm record-def.asm add-year.o read-record.o write-record.o
	$(LD) $(LDFLAGS) add-year.o read-record.o write-record.o -o add-year

add-year-error-exit: xnu.asm record-def.asm add-year-error-exit.o read-record.o write-record.o  error-exit.o count-chars.o write-newline.o
	$(LD) $(LDFLAGS) add-year-error-exit.o read-record.o write-record.o error-exit.o count-chars.o write-newline.o -o add-year-error-exit

# Uses shared libraries
hello-world-lib: hello-world-lib.o
	$(LD) -lc -macosx_version_min 10.13.0 hello-world-lib.o -o hello-world-lib
printf-example: printf-example.o
	$(LD) -lc -macosx_version_min 10.13.0 printf-example.o -o printf-example
read-records-alloc: xnu.asm record-def.asm alloc.o read-records-alloc.o count-chars.o read-record.o write-newline.o
	$(LD) -lc -macosx_version_min 10.13.0 alloc.o read-records-alloc.o count-chars.o read-record.o write-newline.o -o read-records-alloc

# Creates shared libraries
librecord.dylib: writable.o write-record.o read-record.o
	$(LD) -dylib writable.o write-record.o read-record.o -o librecord.dylib
write-records-lib: write-record.o write-records.o librecord.dylib
	$(LD) -lSystem -L. -lrecord -macosx_version_min 10.13.0 write-records.o -o write-records-lib

# Reverse engineering GCC output
sbrk.asm: sbrk.c
	gcc -S -masm=intel -o sbrk.asm sbrk.c
sbrk_function.asm: sbrk_function.c
	gcc -S -masm=intel -o sbrk_function.asm sbrk_function.c

%: %.o
	$(LD) $(LDFLAGS) -o $@ $<

%.o: %.asm $(DEPS)
	$(AS) $(ASFLAGS) -o $@ $<
