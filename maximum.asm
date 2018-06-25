; PURPOSE: This program finds the maximum number of a set of data items.
; VARIABLES:
; rsi - Holds the address of the array, due to problems with the effective address using the data_items label.
; rbx - Holds the index of the data item being examined
; edi - Largest data item found
; eax - Current data item
;
; The following memory locations are used:
;
; data_items - contains the item data. A 0 is used
; to terminate the data
;   

    section .data

data_items:
    array dd 3,67,34,222,45,75,54,34,44,33,22,11,66,0

    section .text

    global start
start:
    mov rbx, 0                  ; move 0 into the index register
    lea rsi, [rel data_items]   ; store the array address (relative to the instruction pointer) in rsi
    mov eax, [rsi + rbx * 4]    ; fetch the current item
    mov edi, eax                ; set the current item as the max

start_loop:
    cmp eax, 0                  ; check to see if we've hit the end
    je loop_exit
    inc rbx                     ; load next value
    mov eax, [rsi + rbx * 4]
    cmp eax, edi                ; compare current max and current value
    jle start_loop              ; jump to loop beginning if the new one isn't bigger

    mov edi, eax                ; make current the new max
    jmp start_loop              ; jump to loop beginning

loop_exit:
    mov rax, 0x2000001 
    syscall
