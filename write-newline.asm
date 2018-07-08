%include "xnu.asm"

    global write_newline

    section .data
newline:
    db `\n`

    section .text
ST_FILEDES equ 16

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
