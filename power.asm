; PURPOSE: Program to illustrate how functions work.
; This program will compute the value of 2^3 + 5^2,
; which is curiously 33, my age when writing this.
;
; Everything in the main program is stored in registers, however, for 64-bit, 
; dyld requires you to have a writable data segment with content.
    section .data
writable:
    db 0

    section .text

    global start
start:
    push 3                      ; push second argument
    push 2                      ; push first argument
    call power                  ; call the function
    add rsp, 16                 ; move the stack pointer back (clearing the function args)
    push rax                    ; save the function result in the stack frame

    push 2                      ; push second argument
    push 5                      ; push first argument
    call power                  ; call the function
    add rsp, 16                 ; move the stack pointer back (clearing the function args)

    pop rdi                     ; second answer is already in rax (return by convention)
                                ; we saved the first answer onto the stack, so we can just pop it
                                ; out into rdi

    add rdi, rax                ; add them together, result is in rdi
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
; rbx - holds the base number
; rcx - holds the power
;
; [rbp - 8] - holds the current result
;
; rax is used for temporary storage
;
    global power
power:
    push rbp                    ; save old base pointer
    mov rbp, rsp                ; make stack pointer the base pointer
    sub rsp, 8                  ; get room for our local storage

    mov rbx, [rbp + 8 + 8 * 1]  ; put base in rbx
    mov rcx, [rbp + 8 + 8 * 2]  ; put power in rcx

    mov [rbp - 8], rbx          ; store current result

power_loop_start:
    cmp rcx, 1
    je end_power
    mov rax, [rbp - 8]
    imul rbx
    mov [rbp - 8], rax
    dec rcx
    jmp power_loop_start

end_power:
    mov rax, [rbp - 8]
    mov rsp, rbp
    pop rbp
    ret