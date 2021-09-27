
#include <libuthread/defines.h>
#include <libuthread/linux/kthread.h>
#include <libuthread/linux/atomic.h>

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

struct thread_info {
    struct kthread thread;
    int is_running;
};

void *thread_proc (void *arg)
{
    struct thread_info *info = arg;
    int did_run = 0;
    
    while (FETCH_ONCE_S32(&info->is_running) == 1 || did_run == 0) {
        char buffer[256];
        ssize_t size = sprintf (buffer, "hello world %u\n", info->thread.index);
        ssize_t bytes_wr = write (STDOUT_FILENO, buffer, size);
        assert (bytes_wr == size);
        did_run = 1;
    }
    
    return (void *)((unsigned long long) info->thread.index);
}

#define foreach_array_index(var, lower, upper) \
    for (var = lower; var < upper; var++)

#include <time.h>
        
int main (int argc, char **argv)
{    
    struct thread_info threads[4];

    unsigned int i, j;
    foreach_array_index (i, 0, countof (threads)) {
        threads[i].is_running = 1;

    }
    
    foreach_array_index (i, 0, countof (threads)) {
        kthread_create (&threads[i].thread, 512 * 1024, 0, i, &thread_proc, &threads[i]);
    }
    
    struct timespec wait_time = cons (struct timespec, 0, 100000000);
    nanosleep (&wait_time, NULL);

    foreach_array_index (i, 0, countof (threads)) {
        WRITE_ONCE_S32 (&threads[i].is_running, 0);
    }
    
    foreach_array_index (i, 0, countof (threads)) {
        unsigned long long res;
        pthread_join (threads[i].thread.handle, (void **)&res);
        printf ("%llx\n", res);
    }
    
    return 0;
}
