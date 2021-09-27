
#include <libuthread/uthread.h>
#include <libuthread/linux/mm-page.h>
#include <stdlib.h>

void coroutine (void *self, void *sched, void *arg)
{
    exit (0);
}

int main (int argc, char **argv)
{
    struct linux_uthread main_thr;
    struct linux_uthread child_thr;
    
    char buffer[2048];
    uthread_convert (&main_thr, buffer);
    
    struct uthread_stack stack;
    void *pages = mmap_pages (NULL, 16384, PROT_READ | PROT_WRITE, 0);
    uthread_stack_init (pages, 16384, &stack);

    uthread_create (&child_thr, &stack, &coroutine);
    uthread_invoke (&child_thr, &main_thr, NULL);
    
    free_pages (pages, 16384);
    
    return 42;
}
