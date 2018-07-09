%include "xnu.asm"

extern count_chars

ST_ERROR_CODE equ 16
ST_ERROR_MSG equ 24

    global error_exit

    section .text
error_exit:
    push rbp
    mov rbp, rsp

    ; Write out error code
    lea rsi, [rel rbp + ST_ERROR_CODE]
    push rsi
    call count_chars
    pop rsi             ; cbuf
    mov rdi, STDERR     ; fd
    mov rdx, rax        ; nbytes
    mov rax, SYS_WRITE  ; write
    syscall

    ; ...
    ; Exit with status 1
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

