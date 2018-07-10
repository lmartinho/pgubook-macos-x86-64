%include "xnu.asm"

    extern _exit
    extern _printf

    section .data
hello_world:
    db `Hello World\n`, 0

    section .text
    global start
    global _main                ; to appease GCC
start:
_main:                          ; to appease GCC
    lea rdi, [rel hello_world]
    push rdi
    call _printf

    push qword 0
    call _exit
