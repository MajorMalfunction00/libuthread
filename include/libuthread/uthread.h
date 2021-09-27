#ifndef LIBUTHREAD_H
#define LIBUTHREAD_H

#include <libuthread/defines.h>
#include <libuthread/linux/uthread-ops.h>
#include <libuthread/linux/uthread-stk.h>
#include <libuthread/linux/uthread-vec.h>

void uthread_convert (struct linux_uthread *fib, void *vgpr_buffer);
void uthread_create (struct linux_uthread *newctx, struct uthread_stack *stack, uthread_fn fn);

__attribute__((returns_twice))
void uthread_invoke (struct linux_uthread *oldctx, struct linux_uthread *newctx, void *arg);

__attribute__((returns_twice))
void uthread_switch (struct linux_uthread *oldctx, struct linux_uthread *newctx);

#endif /* EOF */
