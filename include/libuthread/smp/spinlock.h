#ifndef UTHREAD_SMP_SPINLOCK_H
#define UTHREAD_SMP_SPINLOCK_H

#include <libuthread/linux/atomic.h>

struct spinlock {
    atomic32_t handle;
};

static void spinlock_init (struct spinlock *lock)
{
    atomic_put (&lock->handle, 0);
}

extern int spinlock_enter (struct spinlock *lock);
extern int spinlock_try_enter (struct spinlock *lock);

extern void spinlock_leave (struct spinlock *lock);

#endif /* EOF */
