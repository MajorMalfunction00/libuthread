#ifndef LIBUTHREAD_DEFINES_H
#define LIBUTHREAD_DEFINES_H

#define ignore(expr) (void)(expr)
#define countof(array) (sizeof array / sizeof array[0])
#define cons(type, ...) (type) { __VA_ARGS__ }

#endif /* EOF */
