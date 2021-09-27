.intel_syntax noprefix
.section .text

#define UTHREAD_CONT_OFF_RAX 0
#define UTHREAD_CONT_OFF_RDI 8
#define UTHREAD_CONT_OFF_RSI 16
#define UTHREAD_CONT_OFF_RDX 24
#define UTHREAD_CONT_OFF_RCX 32
#define UTHREAD_CONT_OFF_R8  40
#define UTHREAD_CONT_OFF_R9  48
#define UTHREAD_CONT_OFF_RBX 56
#define UTHREAD_CONT_OFF_R12 64
#define UTHREAD_CONT_OFF_R13 72
#define UTHREAD_CONT_OFF_R14 80
#define UTHREAD_CONT_OFF_R15 88
#define UTHREAD_CONT_OFF_RBP 96
#define UTHREAD_CONT_OFF_RSP 104
#define UTHREAD_CONT_OFF_RIP 112
#define UTHREAD_CONT_OFF_MSR 120
#define UTHREAD_CONT_OFF_VEC 128

#define UTHREAD_STK_TOP  0
#define UTHREAD_STK_TOKEN 8
#define UTHREAD_STK_SIZE 16
#define UTHREAD_STK_BASE 24

    .align 16
__uthread_exit:
    mov eax, 60
    mov edi, 0
    syscall
    hlt
    
    .align 16
    .globl __uthread_convert
__uthread_convert:

    mov [rdi + UTHREAD_CONT_OFF_RBX], rbx
    mov [rdi + UTHREAD_CONT_OFF_R12], r12
    mov [rdi + UTHREAD_CONT_OFF_R13], r13
    mov [rdi + UTHREAD_CONT_OFF_R14], r14
    mov [rdi + UTHREAD_CONT_OFF_R15], r15
    
    mov [rdi + UTHREAD_CONT_OFF_RSP], rsp
    mov [rdi + UTHREAD_CONT_OFF_RBP], rbp
    
    mov [rdi + UTHREAD_CONT_OFF_VEC], rdx
    
    lea r10, [rip]
    mov [rdi + UTHREAD_CONT_OFF_RIP], r10

    ret
    
    .align 16
    .globl __uthread_create
__uthread_create:

    mov r10, [rsi + UTHREAD_STK_TOP]
    sub r10, 2048
    and r10, 0xffffffffffffffc0
    
    
    mov [rdi + UTHREAD_CONT_OFF_VEC], r10
    
    mov [rdi + UTHREAD_CONT_OFF_RSP], r10
    mov [rdi + UTHREAD_CONT_OFF_RBP], r10
    
	pushfq
	pop r10
    mov [rdi + UTHREAD_CONT_OFF_MSR], r10
    
    xor eax, eax
    mov [rdi + UTHREAD_CONT_OFF_RAX], rax # clear all registers
    mov [rdi + UTHREAD_CONT_OFF_RDI], rax
    mov [rdi + UTHREAD_CONT_OFF_RSI], rax
    mov [rdi + UTHREAD_CONT_OFF_RDX], rax
    mov [rdi + UTHREAD_CONT_OFF_RCX], rax
    mov [rdi + UTHREAD_CONT_OFF_R8], rax
    mov [rdi + UTHREAD_CONT_OFF_R9], rax
    mov [rdi + UTHREAD_CONT_OFF_RBX], rax
    mov [rdi + UTHREAD_CONT_OFF_R12], rax
    mov [rdi + UTHREAD_CONT_OFF_R13], rax
    mov [rdi + UTHREAD_CONT_OFF_R14], rax
    mov [rdi + UTHREAD_CONT_OFF_R15], rax
    
    mov [rdi + UTHREAD_CONT_OFF_RIP], rdx

    ret
    
    .align 16
    .globl __uthread_invoke
__uthread_invoke:
    mov rbx, [rdi + UTHREAD_CONT_OFF_RBX]
    mov r12, [rdi + UTHREAD_CONT_OFF_R12]
    mov r13, [rdi + UTHREAD_CONT_OFF_R13]
    mov r14, [rdi + UTHREAD_CONT_OFF_R14]
    mov r15, [rdi + UTHREAD_CONT_OFF_R15]
    
    mov rbp, [rdi + UTHREAD_CONT_OFF_RBP]
    mov rsp, [rdi + UTHREAD_CONT_OFF_RSP]
    mov r11, [rdi + UTHREAD_CONT_OFF_RIP]
    
    mov rdi, rdx
    mov rsi, rcx
    mov rdx, r8 
    
    call r11
    
    call __uthread_exit
    ret
    
    .align 16
    .globl __uthread_capture
__uthread_capture:
    pushfq
	pop r10
	mov [rdi + UTHREAD_CONT_OFF_MSR], r10
	
	push rdi
	mov rdi, [rdi + UTHREAD_CONT_OFF_VEC]
    call __vec_capture_sse128
    pop rdi
    
    mov [rdi + UTHREAD_CONT_OFF_RBX], rbx
    mov [rdi + UTHREAD_CONT_OFF_R12], r12
    mov [rdi + UTHREAD_CONT_OFF_R13], r13
    mov [rdi + UTHREAD_CONT_OFF_R14], r14
    mov [rdi + UTHREAD_CONT_OFF_R15], r15

    mov [rdi + UTHREAD_CONT_OFF_RSP], rsp
    mov [rdi + UTHREAD_CONT_OFF_RBP], rbp
    
	lea r11, [rip]
    mov [rdi + UTHREAD_CONT_OFF_RIP], r11
    
    ret
    
    .align 16
    .globl __uthread_restore
__uthread_restore:
    mov r10, [rdi + UTHREAD_CONT_OFF_MSR]
	push r10
	popfq
    
	push rdi
	mov rdi, [rdi + UTHREAD_CONT_OFF_VEC]
    call __vec_restore_sse128
    pop rdi
    
    mov rbx, [rdi + UTHREAD_CONT_OFF_RBX]
    mov r12, [rdi + UTHREAD_CONT_OFF_R12]
    mov r13, [rdi + UTHREAD_CONT_OFF_R13]
    mov r14, [rdi + UTHREAD_CONT_OFF_R14]
    mov r15, [rdi + UTHREAD_CONT_OFF_R15]
    
    mov rbp, [rdi + UTHREAD_CONT_OFF_RBP]
    mov rsp, [rdi + UTHREAD_CONT_OFF_RSP]
    mov r11, [rdi + UTHREAD_CONT_OFF_RIP]
   
    call r11
    ret
    
    .align 16
    .globl __vec_capture_sse128
__vec_capture_sse128:
    movups XMMWORD PTR [rdi + 16 * 0 ], xmm0
    movups XMMWORD PTR [rdi + 16 * 1 ], xmm1
    movups XMMWORD PTR [rdi + 16 * 2 ], xmm2
    movups XMMWORD PTR [rdi + 16 * 3 ], xmm3
    movups XMMWORD PTR [rdi + 16 * 4 ], xmm4
    movups XMMWORD PTR [rdi + 16 * 5 ], xmm5
    movups XMMWORD PTR [rdi + 16 * 6 ], xmm6
    movups XMMWORD PTR [rdi + 16 * 7 ], xmm7
    movups XMMWORD PTR [rdi + 16 * 8 ], xmm8
    movups XMMWORD PTR [rdi + 16 * 9 ], xmm9
    movups XMMWORD PTR [rdi + 16 * 10], xmm10
    movups XMMWORD PTR [rdi + 16 * 11], xmm11
    movups XMMWORD PTR [rdi + 16 * 12], xmm12
    movups XMMWORD PTR [rdi + 16 * 13], xmm13
    movups XMMWORD PTR [rdi + 16 * 14], xmm14
    movups XMMWORD PTR [rdi + 16 * 15], xmm15
    
    ret
    
    .align 16
    .globl __vec_restore_sse128
__vec_restore_sse128:
    movups xmm0, XMMWORD PTR [rdi + 16 * 0 ]
    movups xmm1, XMMWORD PTR [rdi + 16 * 1 ]
    movups xmm2, XMMWORD PTR [rdi + 16 * 2 ]
    movups xmm3, XMMWORD PTR [rdi + 16 * 3 ]
    movups xmm4, XMMWORD PTR [rdi + 16 * 4 ]
    movups xmm5, XMMWORD PTR [rdi + 16 * 5 ]
    movups xmm6, XMMWORD PTR [rdi + 16 * 6 ]
    movups xmm7, XMMWORD PTR [rdi + 16 * 7 ]
    movups xmm8, XMMWORD PTR [rdi + 16 * 8 ]
    movups xmm9, XMMWORD PTR [rdi + 16 * 9 ]
    movups xmm10, XMMWORD PTR [rdi + 16 * 10]
    movups xmm11, XMMWORD PTR [rdi + 16 * 11]
    movups xmm12, XMMWORD PTR [rdi + 16 * 12]
    movups xmm13, XMMWORD PTR [rdi + 16 * 13]
    movups xmm14, XMMWORD PTR [rdi + 16 * 14]
    movups xmm15, XMMWORD PTR [rdi + 16 * 15]
    
    ret
    ret
    
    .align 16
    .globl __vec_capture_avx256
__vec_capture_avx256:
    vmovups YMMWORD PTR [rdi + 32 * 0 ], ymm0
    vmovups YMMWORD PTR [rdi + 32 * 1 ], ymm1
    vmovups YMMWORD PTR [rdi + 32 * 2 ], ymm2
    vmovups YMMWORD PTR [rdi + 32 * 3 ], ymm3
    vmovups YMMWORD PTR [rdi + 32 * 4 ], ymm4
    vmovups YMMWORD PTR [rdi + 32 * 5 ], ymm5
    vmovups YMMWORD PTR [rdi + 32 * 6 ], ymm6
    vmovups YMMWORD PTR [rdi + 32 * 7 ], ymm7
    vmovups YMMWORD PTR [rdi + 32 * 8 ], ymm8
    vmovups YMMWORD PTR [rdi + 32 * 9 ], ymm9
    vmovups YMMWORD PTR [rdi + 32 * 10], ymm10
    vmovups YMMWORD PTR [rdi + 32 * 11], ymm11
    vmovups YMMWORD PTR [rdi + 32 * 12], ymm12
    vmovups YMMWORD PTR [rdi + 32 * 13], ymm13
    vmovups YMMWORD PTR [rdi + 32 * 14], ymm14
    vmovups YMMWORD PTR [rdi + 32 * 15], ymm15
    
    ret
    
    .align 32
    .globl __vec_restore_avx256
__vec_restore_avx256:
    vmovups ymm0, YMMWORD PTR [rdi + 32 * 0 ]
    vmovups ymm1, YMMWORD PTR [rdi + 32 * 1 ]
    vmovups ymm2, YMMWORD PTR [rdi + 32 * 2 ]
    vmovups ymm3, YMMWORD PTR [rdi + 32 * 3 ]
    vmovups ymm4, YMMWORD PTR [rdi + 32 * 4 ]
    vmovups ymm5, YMMWORD PTR [rdi + 32 * 5 ]
    vmovups ymm6, YMMWORD PTR [rdi + 32 * 6 ]
    vmovups ymm7, YMMWORD PTR [rdi + 32 * 7 ]
    vmovups ymm8, YMMWORD PTR [rdi + 32 * 8 ]
    vmovups ymm9, YMMWORD PTR [rdi + 32 * 9 ]
    vmovups ymm10, YMMWORD PTR [rdi + 32 * 10]
    vmovups ymm11, YMMWORD PTR [rdi + 32 * 11]
    vmovups ymm12, YMMWORD PTR [rdi + 32 * 12]
    vmovups ymm13, YMMWORD PTR [rdi + 32 * 13]
    vmovups ymm14, YMMWORD PTR [rdi + 32 * 14]
    vmovups ymm15, YMMWORD PTR [rdi + 32 * 15]


    
    .align 16
    .globl __vec_capture_avx512
__vec_capture_avx512:
    vmovups ZMMWORD PTR [rdi + 64 * 0 ], zmm0
    vmovups ZMMWORD PTR [rdi + 64 * 1 ], zmm1
    vmovups ZMMWORD PTR [rdi + 64 * 2 ], zmm2
    vmovups ZMMWORD PTR [rdi + 64 * 3 ], zmm3
    vmovups ZMMWORD PTR [rdi + 64 * 4 ], zmm4
    vmovups ZMMWORD PTR [rdi + 64 * 5 ], zmm5
    vmovups ZMMWORD PTR [rdi + 64 * 6 ], zmm6
    vmovups ZMMWORD PTR [rdi + 64 * 7 ], zmm7

    vmovups ZMMWORD PTR [rdi + 64 * 8 ], zmm8
    vmovups ZMMWORD PTR [rdi + 64 * 9 ], zmm9
    vmovups ZMMWORD PTR [rdi + 64 * 10], zmm10
    vmovups ZMMWORD PTR [rdi + 64 * 11], zmm11
    vmovups ZMMWORD PTR [rdi + 64 * 12], zmm12
    vmovups ZMMWORD PTR [rdi + 64 * 13], zmm13
    vmovups ZMMWORD PTR [rdi + 64 * 14], zmm14
    vmovups ZMMWORD PTR [rdi + 64 * 15], zmm15
    
    vmovups ZMMWORD PTR [rdi + 64 * 16], zmm16
    vmovups ZMMWORD PTR [rdi + 64 * 17], zmm17
    vmovups ZMMWORD PTR [rdi + 64 * 18], zmm18
    vmovups ZMMWORD PTR [rdi + 64 * 19], zmm19
    vmovups ZMMWORD PTR [rdi + 64 * 20], zmm20
    vmovups ZMMWORD PTR [rdi + 64 * 21], zmm21
    vmovups ZMMWORD PTR [rdi + 64 * 22], zmm22
    vmovups ZMMWORD PTR [rdi + 64 * 23], zmm23
    
    vmovups ZMMWORD PTR [rdi + 64 * 24], zmm24
    vmovups ZMMWORD PTR [rdi + 64 * 25], zmm25
    vmovups ZMMWORD PTR [rdi + 64 * 26], zmm26
    vmovups ZMMWORD PTR [rdi + 64 * 27], zmm27
    vmovups ZMMWORD PTR [rdi + 64 * 28], zmm28
    vmovups ZMMWORD PTR [rdi + 64 * 29], zmm29
    vmovups ZMMWORD PTR [rdi + 64 * 30], zmm30
    vmovups ZMMWORD PTR [rdi + 64 * 31], zmm31
    
    ret
    
    .align 16
    .globl __vec_restore_avx512
__vec_restore_avx512:
    vmovups zmm0, ZMMWORD PTR [rdi + 64 * 0 ]
    vmovups zmm1, ZMMWORD PTR [rdi + 64 * 1 ]
    vmovups zmm2, ZMMWORD PTR [rdi + 64 * 2 ]
    vmovups zmm3, ZMMWORD PTR [rdi + 64 * 3 ]
    vmovups zmm4, ZMMWORD PTR [rdi + 64 * 4 ]
    vmovups zmm5, ZMMWORD PTR [rdi + 64 * 5 ]
    vmovups zmm6, ZMMWORD PTR [rdi + 64 * 6 ]
    vmovups zmm7, ZMMWORD PTR [rdi + 64 * 7 ]
    vmovups zmm8, ZMMWORD PTR [rdi + 64 * 8 ]
    vmovups zmm9, ZMMWORD PTR [rdi + 64 * 9 ]
    vmovups zmm10, ZMMWORD PTR [rdi + 64 * 10]
    vmovups zmm11, ZMMWORD PTR [rdi + 64 * 11]
    vmovups zmm12, ZMMWORD PTR [rdi + 64 * 12]
    vmovups zmm13, ZMMWORD PTR [rdi + 64 * 13]
    vmovups zmm14, ZMMWORD PTR [rdi + 64 * 14]
    vmovups zmm15, ZMMWORD PTR [rdi + 64 * 15]
    
    vmovups zmm16, ZMMWORD PTR [rdi + 64 * 16]
    vmovups zmm17, ZMMWORD PTR [rdi + 64 * 17]
    vmovups zmm18, ZMMWORD PTR [rdi + 64 * 18]
    vmovups zmm19, ZMMWORD PTR [rdi + 64 * 19]
    vmovups zmm20, ZMMWORD PTR [rdi + 64 * 20]
    vmovups zmm21, ZMMWORD PTR [rdi + 64 * 21]
    vmovups zmm22, ZMMWORD PTR [rdi + 64 * 22]
    vmovups zmm23, ZMMWORD PTR [rdi + 64 * 23]
    vmovups zmm24, ZMMWORD PTR [rdi + 64 * 24]
    vmovups zmm25, ZMMWORD PTR [rdi + 64 * 25]
    vmovups zmm26, ZMMWORD PTR [rdi + 64 * 26]
    vmovups zmm27, ZMMWORD PTR [rdi + 64 * 27]
    vmovups zmm28, ZMMWORD PTR [rdi + 64 * 28]
    vmovups zmm29, ZMMWORD PTR [rdi + 64 * 29]
    vmovups zmm30, ZMMWORD PTR [rdi + 64 * 30]
    vmovups zmm31, ZMMWORD PTR [rdi + 64 * 31]
    
    ret
    
