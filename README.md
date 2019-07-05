# Programming from the Ground Up for macOS (x86-64)

Porting the [Programming from the Ground Up 1.0](https://savannah.nongnu.org/projects/pgubook/) book, by Jonathan Bartlett, to *macOS* Mojave, using x86-64 Assembly.

Translating the pgubook to the XNU kernel that powers macOS (formerly OS X).
Targets 64-bit architecture and uses NASM assembler, with Intel syntax.

Toolchain:
- NASM version 2.14.02 (installed via Homebrew)
- ld64 version 450.3 (clang-1001.0.46.4)

Tested with: 
- System Version: macOS 10.14.5 (18F132)
- Kernel Version: Darwin 18.6.0 (xnu-4903.261.4~2/RELEASE_X86_64)

References:

- [XNU System Calls](https://opensource.apple.com/source/xnu/xnu-4570.41.2/bsd/kern/syscalls.master.auto.html)

- [System V x86-64 psABI](https://github.com/hjl-tools/x86-psABI/wiki/X86-psABI)