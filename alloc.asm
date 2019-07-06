%include "xnu.asm"

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
    dq 0

; This points to one location past the memory we are managing
current_break:
    dq 0

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
    AVAILABLE equ 1         ; This is the number we will use to mark
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
    push rbp                        ; standard function stuff
    mov rbp, rsp

    ; If the brk system call is called with 0, it
    ; returns the last valid usable address
    ; We're using the C std lib sbrk with 0 increment to determine the last valid usable address
    sub	rsp, 8                      ; reverse engineered from GCC, although GCC was 16
    xor edi, edi                    ; pass 0 to sbrk to retrieve the current break
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

	add	rsp, 8                      ; reverse engineered from GCC
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
    mov edx, [rax + HDR_SIZE_OFFSET]

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

    push rcx
    push rbx
                                    ; We need to adapt to MacOS
    mov rdi, rcx                    ; rdi will hold the increment
    add rdi, HEADER_SIZE            ; add space for the headers
    call _sbrk                      ; now its time to ask MacOS
                                    ; for more memory

                                    ; under normal conditions, this should
                                    ; return the new break in %rax, which
                                    ; will be either 0 if it fails, or
                                    ; it will be equal to or larger than
                                    ; we asked for. We don’t care
                                    ; in this program where it actually
                                    ; sets the break, so as long as %eax
                                    ; isn’t 0, we don’t care what it is

    cmp rax, 0                      ; check for error conditions
    je error

    pop rbx                         ; restore saved registers
    pop rcx

    ; set this memory as unavailable, since we're about to
    ; give it away
    mov dword [rax + HDR_AVAIL_OFFSET], UNAVAILABLE
    ; set the size of the memory
    mov dword [rax + HDR_SIZE_OFFSET], edx

    ; move rax to the actual start of usable memory.
    ; rax now holds the return value
    add rax, HEADER_SIZE

    mov [rel current_break], rbx

    mov rsp, rbp                    ; return the function
    pop rbp
    ret

error:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
; END OF FUNCTION

;; deallocate ;;
; PURPOSE:
;   The purpose of this function is to give back
;   a region of memory to the pool after we’re done
;   using it.
;
; PARAMETERS:
;   The only parameter is the address of the memory
;   we want to return to the memory pool.
;
; RETURN VALUE:
;   There is no return value.
;
; PROCESSING:
;   If you remember, we actually hand the program the
;   start of the memory that they can use, which is
;   8 storage locations after the actual start of the
;   memory region. All we have to do is go back
;   8 locations and mark that memory as available,
;   so that the allocate function knows it can use it.

    global deallocate
    ; Stack position of the memory region to free
    ST_MEMORY_SEG equ 8

deallocate:
    ; since the function is so simple, we
    ; don’t need any of the fancy function stuff

    ; get the address of the memory to free
    ; (normally this is [rbp + 16], but since
    ; we didn’t push rbp or move rsp to
    ; rbp we can just do [rsp + 8])
    mov rax, [rsp + ST_MEMORY_SEG]

    ; get the pointer to the real beginning of the memory
    sub rax, HEADER_SIZE

    ; mark it as available
    mov dword [rax + HDR_AVAIL_OFFSET], AVAILABLE

    ; return
    ret
; END OF FUNCTION
