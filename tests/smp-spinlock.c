#include <libuthread/smp/spinlock.h>
#include <libuthread/linux/kthread.h>

#include <pthread.h>
#include <unistd.h>
#include <assert.h>

#include <stdio.h>

struct thread_info {
    struct kthread thread;
};

struct thread_info info;
__attribute__ ((aligned (64))) struct spinlock lock1;
 struct spinlock lock2;

void *thread_proc (void *arg)
{
    int status = -1;
    
retry:
    {
        status = spinlock_try_enter(&lock1);
        if (status == 1) {
            goto retry;
        }
        status = spinlock_try_enter (&lock2);
        if (status == 1) {
            spinlock_leave (&lock1);
            goto retry;
        }
    }
    
    write (STDOUT_FILENO, "world!\n", 7);
    
    assert (lock1.handle.counter == 1);
    assert (lock2.handle.counter == 1);
    
    
    spinlock_leave (&lock2);
    spinlock_leave (&lock1);
    return NULL;
}

int main (int argc, char **argv)
{
    pthread_attr_t attr;
    pthread_attr_init (&attr);
    
    pthread_attr_setstacksize (&attr, 512 * 1024);
    
    spinlock_init (&lock1);
    spinlock_init (&lock2);
    
    int status = -1;
retry:
    {
        status = spinlock_try_enter(&lock1);
        if (status == 1) {
            goto retry;
        }
        
        status = spinlock_try_enter (&lock2);
        if (status == 1) {
            spinlock_leave (&lock1);
            goto retry;
        }
    }
    
    write (STDOUT_FILENO, "Hello, ", 8);
    pthread_create (&info.thread.handle, &attr, &thread_proc, NULL);
    
    sleep (1);
    
    spinlock_leave (&lock2);
    spinlock_leave (&lock1);
    
    write (STDOUT_FILENO, "Goodbye\n", 8);
    
    return 0;
}
