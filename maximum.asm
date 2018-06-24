; PURPOSE: This program finds the maximum number of a set of data items.
; VARIABLES:
; rbx - Holds the index of the data item being examined
; rdi - Largest data item found
; rcx - Holds the address of the array, due to problems with the effective address using the data_items label. I believe there is a better way to do this.
; rax - Current data item
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
    mov rbx, 0              ; move 0 into the index register
    ;mov rax, [data_items + 4 * rbx] results in "Mach-O 64-bit format does not support 32-bit absolute addresses"
    mov rcx, data_items     ; store the array address in rcx
    mov rax, [rcx + 4 * rbx]; fetch the current item
    mov rdi, rax            ; set the current item as the max

start_loop:
    cmp rax, 0              ; check to see if we've hit the end
    je loop_exit
    inc rbx                 ; load next value
    mov rax, [rcx + 4 * rbx]
    cmp rax, rdi            ; compare current max and current value
    jle start_loop          ; jump to loop beginning if the new one isn't bigger

    mov rdi, rax            ; make current the new max
    jmp start_loop          ; jump to loop beginning

loop_exit:
    mov rax, 0x2000001      ; exit(max)
    syscall
