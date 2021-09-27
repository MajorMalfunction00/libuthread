#ifndef QSW_STDLIB_ATOMIC_H
#define QSW_STDLIB_ATOMIC_H

#include <stdint.h>

typedef struct atomic32 {
    int32_t counter;
} atomic32_t;

#define __FETCH_ONCE(type, var) \
    *(volatile type *)(var)

#define __WRITE_ONCE(type, var, val) \
    *(volatile type *)(var) = val
    
#define FETCH_ONCE_S32(var) \
    __FETCH_ONCE(int32_t, var)
    
#define WRITE_ONCE_S32(var, val) \
    __WRITE_ONCE(int32_t, var, val)

#define atomic_put(var, val) \
    *(volatile int32_t *)(&(var)->counter) = val
    
#define atomic_get(var) \
    *(volatile int32_t *)(&(var)->counter)

#endif /* EOF */
