%include "xnu.asm"
%include "record-def.asm"

extern write_record

    section .data
; Constant data of the records we want to write
; Each text datum is padded to the proper 
; length with null (i.e. 0) bytes.

; .rept is used to pad each item. .rept tells
; the assembler to repeat the section between 
; the .rept and .endr the number of times specified.
; This is used in this program to add extra null
; characters at the end of each field to fill
; it up
record1:
    db 'Frederick', 0
    %rep 30 ; padding to 40 bytes
    db 0
    %endrep

    db 'Bartlett', 0
    %rep 31; padding to 40 bytes
    db 0
    %endrep

    db `4242 S Prairie\nTulsa, OK 555550`, 0
    %rep 208 ; padding to 240 bytes
    db 0
    %endrep

    dd 45

record2:
    db 'Marilyn', 0
    %rep 32 ; padding to 40 bytes
    db 0
    %endrep

    db 'Taylor', 0
    %rep 33 ; padding to 40 bytes
    db 0
    %endrep

    db `2224 S Johannan St\nChicago, IL 12345`, 0
    %rep 203 ; padding to 240 bytes
    db 0
    %endrep

    dd 29

record3:
    db 'Derrick', 0
    %rep 32 ; padding to 40 bytes
    db 0
    %endrep

    db 'McIntire', 0
    %rep 31 ; padding to 40 bytes
    db 0
    %endrep

    db `500 W Oakland\nSan Diego, CA 54321`, 0
    %rep 206 ; padding to 240 bytes
    db 0
    %endrep 

    dd 36

; This is the name of the file we will write to
file_name:
    db 'test.dat'

ST_FILE_DESCRIPTOR equ -8

    section .text
    global start
    global _main                ; Required when you specify the macosx version to the linker
start:
_main:
    ; Copy stack pointer to base pointer
    mov rbp, rsp 
    ; Allocate space to hold the file descriptor
    sub rsp, 8      

    ; Open the file
    mov rax, SYS_OPEN
    lea rdi, [rel file_name]
    mov rsi, 0101
    mov rdx, 0666
    syscall

    ; Store the file descriptor away
    mov [rbp + ST_FILE_DESCRIPTOR], rax

    ; Write the first record
    push qword [rbp + ST_FILE_DESCRIPTOR]
    lea rsi, [rel record1]
    push rsi
    call write_record

    ; Write the second record
    push qword [rbp + ST_FILE_DESCRIPTOR]
    lea rsi, [rel record2]
    push rsi
    call write_record

    ; Write the third record
    push qword [rbp + ST_FILE_DESCRIPTOR]
    lea rsi, [rel record3]
    push rsi
    call write_record

    ; Close the file descriptor
    mov rax, SYS_CLOSE
    mov rdi, [rbp + ST_FILE_DESCRIPTOR]
    syscall

    ; Exit the program
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
