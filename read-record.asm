%include "record-def.asm"
%include "xnu.asm"

; PURPOSE:  This function reads a record from the file descriptor
;
; INPUT:    The file descriptor and a buffer
;
; OUTPUT:   This function writes the data to the buffer
;           and returns a status code

; STACK LOCAL VARIABLES
    ST_READ_BUFFER  equ 16
    ST_FILEDES      equ 24

    section .text
    global read_record
read_record:
    push rbp
    mov rbp, rsp

    mov rdi, [rbp + ST_FILEDES]
    mov rsi, [rbp + ST_READ_BUFFER]
    mov rdx, RECORD_SIZE
    mov rax, SYS_READ
    syscall

    mov rsp, rbp
    pop rbp
    ret
