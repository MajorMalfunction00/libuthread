#ifndef LIBUTHREAD_STK_H
#define LIBUTHREAD_STK_H

#include <libuthread/config.h>
#include <libuthread/defines.h>

struct uthread_stack {
    void *top;
    unsigned long long token;
    void *base;
    unsigned long long size;
};

static void uthread_stack_init (void *base, unsigned long long size, struct uthread_stack *stack)
{
    stack->base = base;
    stack->size = size;
    stack->top = (unsigned char *) base + size;
    stack->token = ~0ULL;
}

#if LIBUTHREAD_USE_VALGRIND == 1

#include <valgrind/valgrind.h>
static void __uthread_stack_rem_token (struct uthread_stack *stack)
{
    VALGRIND_STACK_DEREGISTER (stack->token);
}

static void __uthread_stack_set_token (struct uthread_stack *stack)
{
    void *base = stack->top - stack->size;
    stack->token = VALGRIND_STACK_REGISTER (base, stack->top);
}

#else

static void __uthread_stack_set_token (struct uthread_stack *stack)
{
    ignore (stack);
}

static void __uthread_stack_rem_token (struct uthread_stack *stack)
{
    ignore (stack);
}

#endif /* #if USE_VALGRIND */


#endif /* EOF */
