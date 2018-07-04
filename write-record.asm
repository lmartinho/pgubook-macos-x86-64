%include "record-def.asm"
%include "xnu.asm"

; PURPOSE:  This function writes a record to the given file descriptor
;
; INPUT:    The file descriptor and a buffer
;
; OUTPUT:   This function produces a status code
;
; STACK LOCAL VARIABLES
    ST_WRITE_BUFFER equ 16
    ST_FILEDES equ 24

    section .text
    global write_record
write_record:
    push rbp
    mov rbp, rsp

    mov rax, SYS_WRITE
    mov rdi, [rbp + ST_FILEDES]
    mov rsi, [rbp + ST_WRITE_BUFFER]
    mov rdx, RECORD_SIZE
    syscall

; NOTE - rax has the return value, which will give back to our calling program
    mov rsp, rbp
    pop rbp
    ret