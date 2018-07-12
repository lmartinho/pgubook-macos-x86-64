%include "xnu.asm"

    extern _exit
    extern _printf

    section .data
first_string:
    db `Hello! %s is a %s who loves the number %d\n`, 0
name:
    db `Luis`, 0
person:
    db `person`, 0
number:
    dw 3

    section .text
    global _main                ; We use _main instead of start because of the C std lib
_main:                          ; main()
    push rbp                    ; Standard function stuff, although only the push seems to be required
    mov rbp, rsp                ; Not required, as we won't be using it

    ; The C standard library available in on my system uses System V AMD64 ABI
    ; and not the x86 cdecl, so we use registers like on the other system calls
    lea rdi, [rel first_string]
    lea rsi, [rel name]
    lea rdx, [rel person]
    mov rcx, [rel number]
    call _printf

    mov rdi, 1
    call _exit