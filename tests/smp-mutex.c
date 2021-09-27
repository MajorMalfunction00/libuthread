
#include <libuthread/uthread.h>
#include <libuthread/smp/spinlock.h>
#include <libuthread/linux/kthread.h>
#include <libuthread/linux/atomic.h>
#include <libuthread/linux/mm-page.h>
#include <libuthread/list.h>

#include <unistd.h>
#include <assert.h>

struct mutex {
    struct spinlock user_lock;
    struct spinlock wait_lock;
    //struct wait_struct
    struct list_link wait_list;
    void *waiter;
};

struct list_link g_wait_list;
struct spinlock g_wait_lock;

void mutex_init (struct mutex *mutex)
{
    spinlock_init (&mutex->user_lock);
    spinlock_init (&mutex->wait_lock);
    list_init (&mutex->wait_list);
    mutex->waiter = NULL;
}

int __mutex_acquire (void *_self, void *_caller, void *_sched, struct mutex *mutex)
{
    struct linux_uthread *self = _self;
    struct linux_uthread *caller = _caller;
    struct linux_uthread *sched = _sched;
    
    if (spinlock_try_enter (&mutex->user_lock) == 0) {
        return 0;
    }
    
    spinlock_try_enter (&mutex->wait_lock);
    spinlock_try_enter (&g_wait_lock);
    
    list_add_tail (&mutex->wait_list, &g_wait_list);
    
    spinlock_leave (&g_wait_lock);
    spinlock_leave (&mutex->wait_lock);
    
    //uthread_switch (self, sched);
    
    return 1;
}

int mutex_acquire (void *self, void *sched, struct mutex *mutex)
{
    if (spinlock_try_enter (&mutex->user_lock) == 1) {
        write (STDOUT_FILENO, "BLK\n", 4);
        return 1;
    } else {
        write (STDOUT_FILENO, "LCK\n", 4);
        return 0;
    }
}

void mutex_release (void *self, void *sched, struct mutex *mutex)
{
    spinlock_try_enter (&g_wait_lock);
    
    spinlock_leave (&g_wait_lock);
    spinlock_leave (&mutex->user_lock);
    
    write (STDOUT_FILENO, "RELEASED\n", 10);
}

struct mutex mut;

struct thread_info {
    struct kthread thread;
    struct linux_uthread context;
    int is_running;
};

void blocked_task (void *self, void *sched, void *arg)
{
    write (STDOUT_FILENO, "BLOCKED TASK\n", 13);
}

void thread_sched (void *self, void *sched, void *arg)
{
    struct thread_info *info = arg;
    printf ("%u: ENTER SCHED\n", info->thread.index);
    
    uthread_switch (self, sched);
    
    do {
        while (spinlock_try_enter (&mut.user_lock) == 1) {
            //write (STDOUT_FILENO, "BLOCKED\n", 8);
        }
        
        uthread_switch (self, sched);
    } while (FETCH_ONCE_S32 (&info->is_running) == 1);
    
    uthread_switch (self, sched);
}

void *thread_entry (void *arg)
{
    struct thread_info *info = arg;
    struct linux_uthread sched_thr;
    
    char self_vgpr[2048];
    uthread_convert (&info->context, self_vgpr);
    
    void *pages = mmap_pages (NULL, 16384, PROT_READ | PROT_WRITE, 0);
    uthread_stack_init (pages, 16384, &sched_thr.stack);
    uthread_create (&sched_thr, &sched_thr.stack, &thread_sched);
    
    uthread_invoke (&sched_thr, &info->context, info);
    
    while (mutex_acquire (&sched_thr, &info->context, &mut)) {
        write (STDOUT_FILENO, "TRY ACQ\n", 8);
        uthread_switch (&sched_thr, &info->context);
    }
    
    assert (atomic_get (&mut.user_lock.handle) == 1);
    write (STDOUT_FILENO, "ACQ\n", 4);
    
    blocked_task (NULL, NULL, NULL);
    mutex_release (&info->context, &sched_thr, &mut);

    return NULL;
}

int main (int argc, char **argv)
{
    list_init (&g_wait_list);
    spinlock_init (&g_wait_lock);
    
    mutex_init (&mut);
    
    pthread_attr_t attr;
    pthread_attr_init (&attr);
    pthread_attr_setstacksize (&attr, 512 * 1024);
    
    struct thread_info infos[4];
    struct thread_info *info = &infos[0];
    
    char root_vgpr[2048];
    infos[0].thread.handle = pthread_self ();
    infos[0].thread.index = 0;
    infos[0].thread.group = 0;
    uthread_convert (&infos[0].context, root_vgpr);

    struct linux_uthread sched_thr;
    
    void *pages = mmap_pages (NULL, 16384, PROT_READ | PROT_WRITE, 0);
    uthread_stack_init (pages, 16384, &sched_thr.stack);
    uthread_create (&sched_thr, &sched_thr.stack, &thread_sched);
    
    uthread_invoke (&sched_thr, &info->context, info);
    
    assert (__mutex_acquire (&info->context, &info->context, &sched_thr, &mut) == 0);
    
    unsigned int i;
    foreach_array_index (i, 1, countof (infos)) {
        infos[i].thread.index = i;
        infos[i].thread.group = 0;
        
        pthread_create (&infos[i].thread.handle, &attr, &thread_entry, &infos[i]);
    }
    
    mutex_release (&info->context, &info->context, &mut);
    
    foreach_array_index (i, 1, countof (infos)) {
        pthread_join (infos[i].thread.handle, NULL);
    }
    
    assert (mutex_acquire (&info->context, &info->context, &mut) == 0);
    mutex_release (&info->context, &info->context, &mut);
    
    return 0;
}
