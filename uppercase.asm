; PURPOSE: This program converts an input file to an output file 
; with all letters converted to uppercase.

; PROCESSING: 1) Open the input file
;             2) Open the output file
;             3) While we're not at the end of the input file
;               a) read part of file into our memory buffer
;               b) go through each byte of memory
;                   if the byte is a lower case letter
;                   convert it to uppercase
;               c) write the memory buffer to output file

; CONSTANTS
    section .data
; System call numbers
SYS_OPEN    equ 0x2000005
SYS_WRITE   equ 0x2000004
SYS_READ    equ 0x2000003
SYS_CLOSE   equ 0x2000006
SYS_EXIT    equ 0x2000001

; Options for open
O_RDONLY                equ 0
O_CREAT_WRONLY_TRUNC    equ 03101

; Standard file descriptors
STDIN  equ 0
STDOUT equ 1
STDERR equ 2

EOF              equ 0
NUMBER_ARGUMENTS equ 2

    section .bss
; Buffer - this is where the data is loaded into
;          from the data file and written from into
;          the output file. This should never exceed 16,000
;          for various reasons
BUFFER_SIZE equ 8
buffer:
    resb BUFFER_SIZE

; Stack positions
ST_SIZE_RESERVE equ 16  ; Stack size to reserve for file descriptors
ST_FD_IN        equ -8
ST_FD_OUT       equ -16
ST_ARGC         equ 0   ; Number of arguments
ST_ARGV_0       equ 8   ; Name of program
ST_ARGV_1       equ 16  ; Input file name
ST_ARGV_2       equ 24  ; Output file name

    section .text
    global start
start:
    mov rbp, rsp

    ; Allocate space for our file descriptions
    ; on the stack
    sub rsp, ST_SIZE_RESERVE

open_files:
open_fd_in:
    ; open syscall
    mov rax, SYS_OPEN
    mov rdi, [rbp + ST_ARGV_1]  ; user_addr_t path
    mov rsi, O_RDONLY           ; int flags
    mov rdx, 0666               ; int mode
    syscall

store_fd_in:
    mov [rbp + ST_FD_IN], rax

open_fd_out:
    ; open syscall
    mov rax, SYS_OPEN
    mov rdi, [rbp + ST_ARGV_2]      ; path
    mov rsi, O_CREAT_WRONLY_TRUNC   ; flags
    mov rdx, 0666                   ; mode
    syscall

store_fd_out:
    mov [rbp + ST_FD_OUT], rax

; Begin main loop
read_loop_begin:
    mov rax, SYS_READ
    mov rdi, [rbp + ST_FD_IN]
    mov rsi, buffer
    mov rdx, BUFFER_SIZE
    syscall

; Exit if we reached the end
    cmp rax, EOF
    jle end_loop

continue_read_loop:
    lea rsi, [rel buffer]
    push rsi
    push rax
    call convert_to_upper
    pop rax
    add rsp, 8

; Write the block out to the output file
    mov rdx, rax                ; buffer size (from read return), last arg to write
    mov rax, SYS_WRITE
    mov rdi, [rbp + ST_FD_OUT]
    mov rsi, buffer
    syscall

; Continue the loop
    jmp read_loop_begin

end_loop:
    ; Close the files
    mov rax, SYS_CLOSE
    mov rdi, [rbp + ST_FD_IN]
    syscall
    mov rax, SYS_CLOSE
    mov rdi, [rbp + ST_FD_OUT]
    syscall

    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

; PURPOSE:  This function actually does the conversion to upper case for a block
;           conversion to upper case for a block
; INPUT:    The first parameter is the location
;           of the block of memory to convert
;           The second parameter is the length of that buffer
; OUTPUT:   This function overwrites the current buffer with the uppercase version.
;
; VARIABLES
;           rax - Beginning of buffer
;           rbx - Length of buffer
;           rdi - Current buffer offset
;           cl - Current byte being examined (first part of ecx)

LOWERCASE_A equ 'a'
LOWERCASE_Z equ 'z'
UPPER_CONVERSION equ 'A' - 'a'

ST_BUFFER_LEN equ 16
ST_BUFFER     equ 24

convert_to_upper:
    push rbp
    mov rbp, rsp

    mov rax, [rbp + ST_BUFFER]
    mov rbx, [rbp + ST_BUFFER_LEN]
    mov rdi, 0

    cmp rbx, 0
    je end_convert_loop

convert_loop:
    mov cl, [rax + rdi]
    cmp cl, LOWERCASE_A
    jl next_byte
    cmp cl, LOWERCASE_Z
    jg next_byte

    add cl, UPPER_CONVERSION
    mov [rax + rdi], cl
next_byte:
    inc rdi
    cmp rbx, rdi
    jne convert_loop

end_convert_loop:
    mov rsp, rbp
    pop rbp
    ret

