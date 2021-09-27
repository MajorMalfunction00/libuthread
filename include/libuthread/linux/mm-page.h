#ifndef QSW_ENGINE_MM_PAGE_H
#define QSW_ENGINE_MM_PAGE_H

#define _GNU_SOURCE
#include <sys/mman.h>

void *mmap_pages (void *addr, unsigned long long size, int prot, int flags);
void  free_pages (void *addr, unsigned long long size);

#endif /* EOF */
