#ifndef LIBUTHREAD_VEC_H
#define LIBUTHREAD_VEC_H

void __vec_capture_sse128 (void *);
void __vec_restore_sse128 (void *);

void __vec_capture_avx256 (void *);
void __vec_restore_avx256 (void *);

void __vec_capture_avx512 (void *);
void __vec_restore_avx512 (void *);

#endif /* EOF */
