;
; https://opensource.apple.com/source/xnu/xnu-3248.60.10/bsd/kern/syscalls.master.auto.html
; 1	AUE_EXIT	ALL	{ void exit(int rval) NO_SYSCALL_STUB; } 
;
        global start

        section .text
start:  push dword 2    ; int rval (dword is 32 bits / 4 bytes)
        mov eax, 1      ; 1 is the exit syscall
        sub esp, 4      ; instead of 16 bytes stack alignment, osx (and bsd) ABI just requires a 4 byte gap
        int 0x80