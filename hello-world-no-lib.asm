%include "xnu.asm"

    section .data
hello_world:
    db `Hello World\n`, 0
hello_world_end:
    hello_world_len equ hello_world_end - hello_world

    section .text
    global start
start:
    mov rdi, STDOUT
    lea rsi, [rel hello_world]
    mov rdx, hello_world_len
    mov rax, SYS_WRITE
    syscall

    mov rdi, 0
    mov rax, SYS_EXIT
    syscall
