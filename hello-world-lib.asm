%include "xnu.asm"

    extern _exit
    extern _printf

    section .data
hello_world:
    db `Hello World\n`, 0

    section .text
    global _main                ; We use _main instead of start because of the C std lib
_main:
    lea rdi, [rel hello_world]
    push rdi
    call _printf
    pop rdi

    push dword 0                ; FIXME: 32 is being returned instead
    call _exit