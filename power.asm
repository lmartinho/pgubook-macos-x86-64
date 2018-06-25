; PURPOSE: Program to illustrate how functions work
; This program will compute the value of
; 2^3 + 5^2
;
; Everything in the main program is stored in registers,
; so the data section doesn’t have anything.
    section .data
writable:
    db 0

    section .text

    global start
start:
    push 3                      ; push second argument
    push 2                      ; push first argument
    call power                  ; call the function
    add esp, 8                  ; move the stack pointer back (clearing the function args)
    push rax                    ; save the function result in the stack frame

    push 2                      ; push second argument
    push 5                      ; push first argument
    call power                  ; call the function
    add esp, 8                  ; move the stack pointer back (clearing the function args)

    pop rdi                     ; second answer is already in eax (return by convention)
                                ; we saved the first answer onto the stack, so we can just pop it
                                ; out into edi

    add rdi, rax                ; add them together, result is in edi
    mov rax, 0x2000001 
    syscall

; PURPOSE: This function is used to compute
; the value of a number raised to
; a power.
;
; INPUT: First argument - the base number
; Second argument - the power to
; raise it to
;
; OUTPUT: Will give the result as a return value
;
; NOTES: The power must be 1 or greater
; 
; VARIABLES:
; ebx - holds the base number
; ecx - holds the power
;
; -4[ebp] - holds the current result
;
; eax is used for temporary storage
;
    global power
power:
    mov eax, [ebp]
    ret