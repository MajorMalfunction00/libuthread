#include <libuthread/linux/kthread.h>

int kthread_create (struct kthread *thr, 
                    unsigned int stack_size,
                    unsigned int group, unsigned int index, 
                    kthread_fn fn, void *arg)
{
    thr->group = group;
    thr->index = index;
    
    pthread_attr_t attr;
    pthread_attr_init (&attr);
    
    pthread_attr_setstacksize (&attr, stack_size);
    return pthread_create (&thr->handle, &attr, fn, arg);
}
