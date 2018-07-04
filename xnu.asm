; Common XNU Definitions
; @see https://opensource.apple.com/source/xnu/xnu-4570.41.2/bsd/kern/syscalls.master.auto.html

; System Call Numbers
SYS_OPEN equ 0x2000005
SYS_WRITE equ 0x2000004
SYS_READ equ 0x2000003
SYS_CLOSE equ 0x2000006
SYS_EXIT equ 0x2000001

; Standard file descriptors
STDIN  equ 0
STDOUT equ 1
STDERR equ 2

; Common Status Codes
END_OF_FILE equ 0