#ifndef LIBUTHREAD_OPS_H
#define LIBUTHREAD_OPS_H

#include <pthread.h>
#include <stddef.h>
#include <libuthread/linux/uthread-stk.h>

typedef unsigned long long reg_t;
typedef void (*uthread_fn) (void *self, void *sched, void *arg);

struct linux_continuation {
    reg_t rax;
    reg_t rdi;
    reg_t rsi;
    reg_t rdx;
    reg_t rcx;
    reg_t r8;
    reg_t r9;
    reg_t rbx;
    reg_t r12;
    reg_t r13;
    reg_t r14;
    reg_t r15;
    reg_t rbp;
    reg_t rsp;
    reg_t rip;
    reg_t msr;
    reg_t vec;
};

struct linux_uthread {
    struct uthread_stack stack;
    struct linux_continuation cont;
};

void __uthread_convert (struct linux_continuation *cont, struct uthread_stack *stack, void *vgpr);
void __uthread_create (struct linux_continuation *cont, struct uthread_stack *stack, uthread_fn);

void __uthread_capture (struct linux_continuation *cont);

__attribute__((returns_twice))
void __uthread_restore (struct linux_continuation *cont);

__attribute__ ((returns_twice))
void __uthread_invoke (struct linux_continuation *new_cont, struct linux_continuation *old_cont, 
                       struct linux_uthread *old_ctx, struct linux_uthread *new_ctx, void *arg);

#endif
