%include "xnu.asm"

    global write_newline

    section .data
; Don't know why this 0 byte is necessary, to make the open syscall
; in the read-records.asm work, and that makes me sad.
writable:
    db 0

newline:
    db `\n`

    section .text
ST_FILEDES equ 8

write_newline:
    push rbp
    mov rbp, rsp

    mov rax, SYS_WRITE
    mov rdi, [rbp + ST_FILEDES]
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rsp, rbp
    pop rbp
    ret
