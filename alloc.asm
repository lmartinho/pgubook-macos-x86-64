%include "xnu.asm"

extern _printf
extern _sbrk

; PURPOSE: Program to manage memory usage - allocates
;          and deallocates memory as requested
;
; NOTES:   The programs using these routines will ask
;          for a certain size of memory. We actually
;          use more than that size, but we put it
;          at the beginning, before the pointer
;          we hand back. We add a size field and 
;          an AVAILABLE/UNAVAILABLE marker. So, the
;          memory looks like this
;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ;; Available Marker ;; Size of memory ;; Actual memory locations ;;
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                          ^--Returned pointer
;                                             points here
;          The pointer we return only points to the actual
;          locations requested to make it easier for the
;          calling program. It also allows us to change our
;          structure without the calling program having to
;          change at all.

    section .data
; GLOBAL VARIABLES
; This points to the beginning of the memory we are managing
heap_begin:
    dd 0

; This points to one location past the memory we are managing
current_break:
    dd 0
    %rep 31; padding to 40 bytes
    db 0
    %endrep

first_string: ; debug
    db `address: %#x\n`, 0

; STRUCTURE INFORMATION
    ; Size of space for memory region header
    HEADER_SIZE equ 8
    ; Location of the "available" flag in the header
    HDR_AVAIL_OFFSET equ 0
    ; Location of the size field in the header
    HDR_SIZE_OFFSET equ 4

; CONSTANTS
    UNAVAILABLE equ 0       ; This is the number we will use to mark
                            ; space that has been given out
    AVAILABLE equ 0         ; This is the number we will use to mark
                            ; space that has been returned, and is 
                            ; available for giving
    SYS_BRK equ 0x2000017   ; (currently unused) System call number for 
                            ; the break function
    SYS_SBRK equ 0x2000069  ; (currently unused)

    section .text

; FUNCTIONS

;; allocate_init ;;
; PURPOSE: Call this function to initialize the 
;          functions (specifically, this sets the heap_begin and
;          current_break). This has no parameters and no
;          return value.
    global allocate_init
allocate_init:
    ; FIXME: Getting a seg fault when I do the standard push rbp
    ;push rbp                        ; standard function stuff
    mov rbp, rsp

    ; If the brk system call is called with 0, it
    ; returns the last valid usable address
    ; We're using the C std lib sbrk with 0 increment to determine the last valid usable address
    mov rdi, 0
    call _sbrk

    inc rax                         ; rax now has the last valid
                                    ; address, and we want the
                                    ; memory location after that

    mov [rel current_break], rax    ; store the current break

    mov [rel heap_begin], rax       ; store the current break as our
                                    ; first address. this will cause
                                    ; the allocate function to get
                                    ; more memory from Linux the
                                    ; first time it is run

; The C standard library available in on my system uses System V AMD64 ABI
; and not the x86 cdecl, so we use registers like on the other system calls
lea rdi, [rel first_string]
mov rsi, [rel heap_begin]
call _printf

    mov rsp, rbp
    pop rbp

    ret

    global start
    global _main
_main:
start:
    call allocate_init

    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
; END DEBUGGING CODE