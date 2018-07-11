%include "xnu.asm"

    extern _exit
    extern _printf

    section .data
first_string:
    db `Hello! %s is a s who loves the number d\n`, 0
name:
    db "Jonathan", 0
person_string:
    db "person", 0
; This could also have been an equ, but we decided to give it
; a real memory location just for kicks
number_loved:
    dw 3

    section .text
    global _main                ; We use _main instead of start because of the C std lib
_main:
    ; Note that the parameters are passed in the
    ; reverse order that they are listed in the 
    ; function's prototype
    push qword [rel number_loved]
    lea rdi, [rel person_string]
    push rdi
    lea rdi, [rel name]
    push rdi
    lea rdi, [rel first_string]
    push rdi
    call _printf
    sub rsp, 32

    push dword 0                ; FIXME: 32 is being returned instead
    call _exit