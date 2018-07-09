%include "xnu.asm"

extern count_chars
extern write_newline

ST_ERROR_CODE equ 16
ST_ERROR_MSG equ 24

    global error_exit

    section .text
error_exit:
    push rbp
    mov rbp, rsp

    ; Write out error code
    push qword [rbp + ST_ERROR_CODE]
    call count_chars
    pop rsi             ; cbuf
    mov rdi, STDERR     ; fd
    mov rdx, rax        ; nbytes
    mov rax, SYS_WRITE  ; write
    syscall

    ; Write out error message
    push qword [rel rbp + ST_ERROR_MSG]
    call count_chars
    pop rsi             ; cbuf
    mov rdi, STDERR     ; fd
    mov rdx, rax        ; nbytes
    mov rax, SYS_WRITE  ; write
    syscall

    push qword STDERR
    call write_newline
    pop rdi

    ; Exit with status 1
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

