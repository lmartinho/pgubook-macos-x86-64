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

;; allocate ;;
; PURPOSE:    This function is used to grab a section of
;             memory. It checks to see if there are any
;             free blocks, and, if not, it asks MacOS
;             for a new one.
;
; PARAMETERS: This function has one parameter - the size
;             of the memory block we want to allocate
;
; RETURN VALUE: 
;             This function returns the address of the
;             allocate memory in rax. If there is no
;             memory available, it will return 0 in rax.
;
; PROCESSING:
; Variables used:
;
;   rcx - hold the size of the requested memory
;         (first/only parameter)
;   rax - current memory region being examined
;   rbx - current break position
;   rdx - size of the current memory region
;
; We scan through each memory region starting with
; heap_begin. We look at the size of each one, and if
; it has been allocated. If it's big enough for the
; requested size, and its available, it grabs that one.
; If it does not find a region large enough, it asks
; MacOS for more memory. In that case, it moves
; current_break up.
    global allocate
    ST_MEM_SIZE equ 16  ; stack position of the memory size
                        ; to allocate
allocate:
    push rbp            ; standard function stuff
    mov rbp, rsp

    mov rcx, [rbp + ST_MEM_SIZE]    ; rcx will hold the size
                        ; we are looking for (which is the first
                        ; and only parameter)
    
    mov rax, [rel heap_begin]       ; rax will hold the current 
                                    ; search location

    mov rbx, [rel current_break]    ; rbx will hold the current
                                    ; break

alloc_loop_begin:                   ; here we iterate through each
                                    ; memory region

    cmp rax, rbx                    ; need more memory if these are equal
    je move_break

    ; grab the size of this memory
    mov rdx, [rax + HDR_SIZE_OFFSET]
    ; if the space is unavailable, 
    ; go to the next one
    cmp dword [rax + HDR_AVAIL_OFFSET], UNAVAILABLE
    je next_location

    cmp rdx, rcx                    ; If the space is available, compare
    jle allocate_here               ; the size to the needed size. If its
                                    ; big enough, go to allocate_here

next_location:
    add rax, HEADER_SIZE            ; The total size of the memory 
    add rax, rdx                    ; region is the sum of the size
                                    ; requested (currently stored
                                    ; in rdx), plus another 8 bytes
                                    ; for the header (4 for the 
                                    ; AVAILABLE/UNAVAILABLE flag,
                                    ; and 4 for the size of the 
                                    ; region). So, adding rdx and 8
                                    ; to rax will get the address 
                                    ; of the next memory region
    
    jmp alloc_loop_begin            ; go look for the next location

allocate_here:                      ; if we've made it here,
                                    ; that means that the
                                    ; region header of the region
                                    ; to allocate is in rax

    ; mark space as unavailable
    mov dword [rax + HDR_AVAIL_OFFSET], UNAVAILABLE
    add rax, HEADER_SIZE            ; move rax past the header to
                                    ; the usable memory (since
                                    ; that's what we return)
    
    mov rsp, rbp
    pop rbp
    ret

move_break:                         ; if we've made it here, that
                                    ; means that we've exhausted 
                                    ; all addressable memory, and
                                    ; we need to ask for more.

                                ; rbx holds the current
                                ; endpoint of the data,
                                ; and rcx holds its size

                                ; We need to adapt to MacOS
    mov rdi, rcx                ; rdi will hold the increment
    add rdi, HEADER_SIZE        ; add space for the headers
    call _sbrk                ; now its time to ask MacOS
                                ; for more memory

                                ; under normal conditions, this should
                                ; return the new break in %eax, which
                                ; will be either 0 if it fails, or
                                ; it will be equal to or larger than
                                ; we asked for. We don’t care
                                ; in this program where it actually
                                ; sets the break, so as long as %eax
                                ; isn’t 0, we don’t care what it is

    mov rdi, rcx
    call _sbrk

    global start
    global _main
_main:
start:
    call allocate_init

    mov rax, SYS_EXIT
    mov rdi, 0
    syscall
; END DEBUGGING CODE