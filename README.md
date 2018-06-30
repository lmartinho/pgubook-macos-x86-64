# Programming from the Ground Up for macOS (x86-64)

Porting the [Programming from the Ground Up 1.0](https://savannah.nongnu.org/projects/pgubook/) book to *macOS* High Sierra, using x86-64 Assembly.

Translating the pgubook to the XNU kernel that powers macOS (formerly OS X).
Targets 64-bit architecture and uses NASM assembler, with Intel syntax.

Tested with: 

- System Version: macOS 10.13.5 (17F77)
- Kernel Version: Darwin 17.6.0 (xnu-4570.61.1)

References:

- [XNU System Calls](https://opensource.apple.com/source/xnu/xnu-4570.41.2/bsd/kern/syscalls.master.auto.html)

- [System V x86-64 psABI](https://github.com/hjl-tools/x86-psABI/wiki/X86-psABI)