
%include "xnu.asm"

    extern _exit
    extern _printf

    section .data
hello_world:
    db `Hello World\n`, 0

    section .text
    global _main                ; We use _main instead of start because of the C std lib
_main:
    push rbp                    ; Not sure why this is required, but it is

    ; Call printf using the System V AMD64 ABI
    lea rdi, [rel hello_world]
    call _printf

    xor rdi, rdi
    call _exit