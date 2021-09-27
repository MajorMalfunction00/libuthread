
#define _GNU_SOURCE
#include <pthread.h>
#include <libuthread/uthread.h>

void uthread_convert (struct linux_uthread *fib, void *vgpr_buffer)
{
	pthread_attr_t attr;
	size_t stack_size;
	void *stack_addr;
	
	pthread_getattr_np(pthread_self(), &attr);
	pthread_attr_getstack(&attr, &stack_addr, &stack_size);
	pthread_attr_destroy(&attr);
	
	fib->stack.top = (char *)stack_addr + stack_size;
    fib->stack.base = NULL;
    fib->stack.size = stack_size;
    fib->stack.token = 0;
    
    __uthread_stack_set_token(&fib->stack);
    __uthread_convert (&fib->cont, &fib->stack, vgpr_buffer);
}

void uthread_create (struct linux_uthread *newctx, struct uthread_stack *stack, uthread_fn fn)
{ 
    
    void *code_ptr;
    *(void **)(&code_ptr) = fn;
    
    newctx->stack = *stack;
    __uthread_create (&newctx->cont, &newctx->stack, code_ptr);
}

__attribute__((returns_twice))
void uthread_invoke (struct linux_uthread *oldctx, struct linux_uthread *newctx, void *arg)
{
    
    __uthread_stack_rem_token(&oldctx->stack);
    __uthread_stack_set_token(&newctx->stack);

    __uthread_capture (&newctx->cont);
    __uthread_invoke (&oldctx->cont, &newctx->cont, oldctx, newctx, arg);
}

__attribute__((returns_twice))
void uthread_switch (struct linux_uthread *oldctx, struct linux_uthread *newctx)
{
    __uthread_stack_rem_token(&oldctx->stack);
    __uthread_stack_set_token(&newctx->stack);

    __uthread_capture (&oldctx->cont);
    __uthread_restore (&newctx->cont);
}
