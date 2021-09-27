.intel_syntax noprefix

    .align 16
    .globl spinlock_enter
spinlock_enter:
    xor r10, r10
    inc r10
    
spinlock_retry:
    xor eax, eax
    pause
    lock cmpxchg [rdi], r10
    jnz spinlock_retry

    ret
    
    .align 16
    .globl spinlock_leave
spinlock_leave:
    mov DWORD PTR [rdi], 0
    ret
    
    .align 16
    .globl spinlock_try_enter
spinlock_try_enter:
    mov eax, 1
    xchg [rdi], eax
    cmp eax, 0
    jne spinlock_pause
    pause
spinlock_pause:
    ret
