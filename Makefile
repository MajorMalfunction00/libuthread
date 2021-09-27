INSTALL_DIR=/usr/local

B:=build/bin
O:=build/obj
D:=build/dep
T:=build/tst
L:=build/lib

CFLAGS:=-DUTHREAD_USE_VALGRIND=1
CPPFLAGS:=

ALL_CPPFLAGS:=-std=c99 -Iinclude $(CPPFLAGS)
ALL_CFLAGS:=-Wall -Wextra -O2 -g $(CFLAGS)
ALL_LDFLAGS:=-L$(L) $(LDFLAGS)

all: tests $(L)/libuthread.a

tests: $(T)/kthread \
		$(T)/uthread-create \
		$(T)/uthread-reenter \
		$(T)/uthread-empty \
		$(T)/uthread-vgpr \
		$(T)/smp-spinlock
	./$(T)/kthread
	./$(T)/uthread-create
	./$(T)/uthread-reenter
	./$(T)/uthread-empty
	./$(T)/uthread-vgpr
	./$(T)/smp-spinlock
	
install: | $(L)/libuthread.a
	cp $(L)/libuthread.a $(INSTALL_DIR)/lib/libuthread.a
	cp -r include/libuthread $(INSTALL_DIR)/include/libuthread


# NOTE: library
$(L)/libuthread.a: $(O)/linux-mm-page.o \
		   $(O)/linux-kthread.o \
		$(O)/linux-uthread-ops.o $(O)/uthread.o \
		$(O)/linux-smp-spinlock-asm.o | $(L)
	$(AR) rcs $@ $^

$(O)/linux-kthread.o: src/linux/kthread.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/linux-kthread.d"

$(O)/linux-mm-page.o: src/linux/mm-page.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/linux-mm-page.d"
	
$(O)/linux-uthread-ops.o: src/linux/uthread-ops.S | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/linux-uthread-ops.d"
	
$(O)/uthread.o: src/uthread.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/uthread.d"
	
$(O)/linux-smp-spinlock-asm.o: src/linux/smp-spinlock-asm.S | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/linux-smp-spinlock-asm.d"

# NOTE: tests

$(T)/kthread: $(O)/tests-kthread.o | $(T) $(L)/libuthread.a
	$(CC) $(ALL_LDFLAGS) -o $@ $^ $(L)/libuthread.a -lpthread

$(O)/tests-kthread.o: tests/kthread.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/tests-kthread.d"

$(T)/uthread-create: $(O)/tests-uthread-create.o | $(T) $(L)/libuthread.a
	$(CC) $(ALL_LDFLAGS) -o $@ $^ $(L)/libuthread.a -lpthread
	
$(O)/tests-uthread-create.o: tests/uthread-create.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/tests-uthread-create.d"
	
$(T)/uthread-reenter: $(O)/tests-uthread-reenter.o | $(T) $(L)/libuthread.a
	$(CC) $(ALL_LDFLAGS) -o $@ $^ $(L)/libuthread.a -lpthread
	
$(O)/tests-uthread-reenter.o: tests/uthread-reenter.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/tests-uthread-reenter.d"
	
$(T)/uthread-empty: $(O)/tests-uthread-empty.o | $(T) $(L)/libuthread.a
	$(CC) $(ALL_LDFLAGS) -o $@ $^ $(L)/libuthread.a -lpthread

$(O)/tests-uthread-empty.o: tests/uthread-empty.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/tests-uthread-empty.d"

$(T)/uthread-vgpr: $(O)/tests-uthread-vgpr.o | $(T) $(L)/libuthread.a
	$(CC) $(ALL_LDFLAGS) -o $@ $^ $(L)/libuthread.a -lpthread

$(O)/tests-uthread-vgpr.o: tests/uthread-vgpr.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/tests-uthread-vgpr.d"

$(T)/smp-spinlock: $(O)/tests-smp-spinlock.o | $(T) $(L)/libuthread.a
	$(CC) $(ALL_LDFLAGS) -o $@ $^ $(L)/libuthread.a -lpthread

$(O)/tests-smp-spinlock.o: tests/smp-spinlock.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/tests-smp-spinlock.d"

clean:
	rm -rf $(B)/*
	rm -rf $(O)/*
	rm -rf $(D)/*
	rm -rf $(L)/*
	rm -rf $(T)/*

-include build.d/init.mk
-include $(wildcard $(D)/*.d)
