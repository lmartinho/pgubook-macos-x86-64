; PURPOSE: More compact implementation of the `cat` UNIX command.

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

; Standard file descriptors
STDOUT equ 1

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
ST_SIZE_RESERVE equ 16  ; Stack size to reserver for file descriptors
ST_FD_IN        equ -4
ST_FD_OUT       equ -8
ST_ARGC         equ 0   ; Number of arguments
ST_ARGV_0       equ 8   ; Name of program
ST_ARGV_1       equ 16  ; Input file name

    section .text
    global start
start:
    mov rbp, rsp

    ; Allocate space for our file descriptions
    ; on the stack
    sub rsp, ST_SIZE_RESERVE

open_fd_in:
    ; open syscall
    mov rax, SYS_OPEN
    mov rdi, [rbp + ST_ARGV_1]
    mov rsi, O_RDONLY
    mov rdx, 0666
    syscall

store_fd_in:
    mov [rbp + ST_FD_IN], rax

; Begin main loop
read_loop_begin:
    mov rax, SYS_READ
    mov rdi, [rbp + ST_FD_IN]
    mov rsi, buffer
    mov rdx, BUFFER_SIZE
    syscall

; Exit if we reached the end
    cmp rax, EOF                ; We've reached the end when read return EOF (0)
    jle end_loop

; Write the block out to the output file
    mov rdx, rax                ; buffer size (from read return)
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, buffer
    syscall

; Continue the loop
    jmp read_loop_begin

end_loop:
    ; Close the input file
    mov rax, SYS_CLOSE
    mov rdi, [rbp + ST_FD_IN]
    syscall

    mov rax, SYS_EXIT
    mov rdi, 0
    syscall