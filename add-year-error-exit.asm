%include "xnu.asm"
%include "record-def.asm"

extern error_exit
extern read_record
extern write_record

    section .data
input_file_name:
    ; Null-terminated string as the user_addr_t path parameter of
    ; the open syscall
    db 'test.dat', 0
output_file_name:
    db 'testout.dat', 0

age:
    dw 0

    section .bss
record_buffer:
    resb RECORD_SIZE

    section .text
    global start
start:
    ; These are the locations on the stack
    ; we will store the input and output descriptors
    ; (FYI - we could have used memory addresses in 
    ; a .data section instead)
    ST_INPUT_DESCRIPTOR equ -8
    ST_OUTPUT_DESCRIPTOR equ -16

    ; Copy the stack pointer to rbp
    mov rbp, rsp
    ; Allocate space to store the file descriptors
    sub rsp, 16

    ; Open the input file
    mov rax, SYS_OPEN
    lea rdi, [rel input_file_name]
    mov rsi, O_RDONLY
    mov rdx, 0666
    syscall

    ; Test in book is whether rax is negative.
    ; I'm actually checking if rax (the file descriptor number) is greater than 2
    ; since 2 represents STDERR.
    ; If the condition holds, it will jump to continue_processing.
    ; Otherwise it will handle the error condition that the invalid number represents
    cmp rax, 2
    jg continue_processing

    ; Send the error
    section .data
no_open_file_code:
    db '0001: ', 0
no_open_file_message:
    db `Can't Open Input File`, 0

    section .text
    lea rdi, [rel no_open_file_message]
    push rdi
    lea rdi, [rel no_open_file_code]
    push rdi
    call error_exit

continue_processing:
    ; Save the file descriptor
    mov [rbp + ST_INPUT_DESCRIPTOR], rax

    ; Open the output file
    mov rax, SYS_OPEN
    lea rdi, [rel output_file_name]
    mov rsi, 0101
    mov rdx, 0666
    syscall

    ; @lmartinho: Check if open was successful
    cmp rax, 2
    je exit_failed_open

    ; Save the file descriptor
    mov [rbp + ST_OUTPUT_DESCRIPTOR], rax

record_read_loop:
    push qword [rbp + ST_INPUT_DESCRIPTOR]
    lea rdi, [rel record_buffer]
    push rdi
    call read_record
    add rsp, 16

    ; Returns the number of bytes read.
    ; If it isn't the same number we 
    ; requested, then it's either an 
    ; end-of-file, or an error, so we're
    ; quitting
    cmp rax, RECORD_SIZE
    jne finished_reading

    ; Increment the age, in place
    inc dword [rel record_buffer + RECORD_AGE]

    ; Write the record to disk
    push qword [rbp + ST_OUTPUT_DESCRIPTOR]
    lea rdi, [rel record_buffer]
    push rdi
    call write_record
    add rsp, 16

    jmp record_read_loop

finished_reading:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

exit_failed_open:
    mov rax, SYS_EXIT
    mov rdi, 254
    syscall