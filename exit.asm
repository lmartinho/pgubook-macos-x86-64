;
; Simple program that exits and returns a status code back to the XNU kernel
; Check using `echo $?` after running the program. Return code should be 2.
;
; Performs a call to the exit syscall, using the 64-bit XNU ABI.
; From https://opensource.apple.com/source/xnu/xnu-3248.60.10/bsd/kern/syscalls.master.auto.html
; 1	AUE_EXIT	ALL	{ void exit(int rval) NO_SYSCALL_STUB; } 
; From https://opensource.apple.com/source/xnu/xnu-4570.41.2/osfmk/mach/i386/syscall_sw.h.auto.html
; #define SYSCALL_CLASS_UNIX	2	/* Unix/BSD */

    global start    ; linker tag is called start instead of _start

    ; For 64-bit, dyld requires you to have a writable data segment with content
    ; @see: https://stackoverflow.com/questions/9882253/64-bit-assembly-on-mac-os-x-runtime-errors-dyld-no-writable-segment-and-tra
    section .data
writable:
    db 0

    section .text
start:
    mov rax, 0x2000001  ; 1 is the exit syscall (AUE_EXIT), 2 is for BSD calls (SYSCALL_CLASS_UNIX)
    mov rdi, 2          ; 2 is the rval for exit
    syscall             ; perform the call (instead of int 0x80)
