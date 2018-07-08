; PURPOSE:  Count the characters until a null byte is reached
;
; INPUT:    The address of the character string
;
; OUTPUT:   Returns the count in rax
;
; PROCESS: 
;   Registers used
;       rcx - character count
;       al - current character
;       rdx - current character address
    section .text
    global count_chars

    ST_STRING_START_ADDRESS equ 16

count_chars:
    push rbp
    mov rbp, rsp

    ; Counter starts at zero
    mov rcx, 0
    mov rdx, [rbp + ST_STRING_START_ADDRESS]

count_loop_begin:
    ; Grab the current character
    mov al, [rdx]
    ; Is it null?
    cmp al, 0
    ; If yes, we're done
    je count_loop_end
    ; Otherwise increment the counter and pointer
    inc rcx
    inc rdx
    ; Go back to the beginning of the loop
    jmp count_loop_begin

count_loop_end:
    ; We're done, move the count into rax
    ; and return
    mov rax, rcx
    
    pop rbp
    ret
