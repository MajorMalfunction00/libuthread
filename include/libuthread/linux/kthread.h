#ifndef QSW_STDLIB_LINUX_KTHREAD_H
#define QSW_STDLIB_LINUX_KTHREAD_H

#include <libuthread/config.h>
#include <pthread.h>

struct kthread {
    unsigned int group;
    unsigned int index;
    pthread_t handle;
};

typedef void *(*kthread_fn) (void *);

int kthread_create (struct kthread *thr, unsigned int stack_size,
                    unsigned int group, unsigned int index, 
                    kthread_fn fn, void *arg);

#endif /* EOF */
