
#include <libuthread/uthread.h>
#include <libuthread/linux/mm-page.h>

#include <stdio.h>
#include <assert.h>

struct linux_uthread main_thr;
struct uthread_stack stack;
    
struct linux_uthread child_thr;
struct linux_uthread gchld_thr;
struct uthread_stack gchld_stk;

void coroutine2 (void *self, void *sched, void *arg)
{
    printf ("%s: self = %.16p\n", __func__, self);
    printf ("%s: sched = %.16p\n", __func__, sched);
    printf ("Hello, again\n");

    uthread_switch (self, sched);

}

void coroutine (void *self, void *sched, void *arg)
{
    printf ("%s: self = %.16p\n", __func__, self);
    printf ("%s: sched = %.16p\n", __func__, sched);
    printf ("Hello, world\n");

    void *pages = mmap_pages (NULL, 16384, PROT_READ | PROT_WRITE, 0);
    uthread_stack_init (pages, 16384, &gchld_stk);

    uthread_create (&gchld_thr, &gchld_stk, &coroutine2);
    uthread_invoke (&gchld_thr, self, NULL);
    //uthread_switch (self, sched);
    uthread_switch (self, sched);
    exit (0);
}

int main (int argc, char **argv)
{
    char buffer[2048];
    
    printf ("main_thr = %.16p\n", &main_thr);
    printf ("child_thr = %.16p\n", &child_thr);
    printf ("gchld_thr = %.16p\n", &gchld_thr);
    
    uthread_convert (&main_thr, buffer);
    
    void *pages = mmap_pages (NULL, 16384, PROT_READ | PROT_WRITE, 0);
    uthread_stack_init (pages, 16384, &stack);

    uthread_create (&child_thr, &stack, &coroutine);
    uthread_invoke (&child_thr, &main_thr, NULL);
    
    //free_pages (pages, 16384);
    
    printf ("EXITING...\n");
    
    return 0;
}
