#ifndef LIBUTHREAD_DEFINES_H
#define LIBUTHREAD_DEFINES_H

#define ignore(expr) (void)(expr)
#define countof(array) (sizeof array / sizeof array[0])
#define cons(type, ...) (type) { __VA_ARGS__ }
#define foreach_array_index(idx, lower, upper) \
    for (idx = lower; idx < upper; idx++)

#endif /* EOF */
