#include <libuthread/linux/mm-page.h>

void *mmap_pages (void *addr, unsigned long long size, int prot, int flags)
{
    return mmap (addr, size, prot, MAP_PRIVATE | MAP_ANONYMOUS | flags, -1, 0);
}

void  free_pages (void *addr, unsigned long long size)
{
    munmap (addr, size);
}
