; PURPOSE - Given a number, this program computes the
; factorial. For example, the factorial of
; 3 is 3 * 2 * 1, or 6. The factorial of
; 4 is 4 * 3 * 2 * 1, or 24, and so on.

; Everything in the main program is stored in registers, however, for 64-bit, 
; dyld requires you to have a writable data segment with content.
    section .data
writable:
    db 0

    section .text

    global start
start:
    push 4
    call factorial
    add rsp, 8                 ; move the stack pointer back (clearing the function arg)

    mov rdi, rax
    mov rax, 0x2000001 
    syscall

; This is the actual function definition
    global factorial
factorial:
    push rbp                    ; standard function stuff - we have to
                                ; restore %ebp to its prior state before
                                ; returning, so we have to push it
    mov rbp, rsp                ; this is because we don’t want to modify
                                ; the stack pointer, so we use %ebp
    mov rax, [rbp + 16]         ; rbp+8 holds the return address, rbp+16 holds the first argument

    cmp rax, 1                  ; base case
    je end_factorial

    dec rax                     ; recursive call: factorial of our parameter - 1
    push rax
    call factorial
    add rsp, 8

    mov rbx, [rbp + 16]         ; reload our parameter into rbx
    imul rbx                    ; multiply our parameter by the return of the recursive call in rax

end_factorial:
    mov rsp, rbp                ; standard function return stuff - we have to restore rbp and rsp to    
    pop rbp                     ; where they were before the function started
    ret                         ; return to the function (this pops the return value too)
