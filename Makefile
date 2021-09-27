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

tests: $(T)/kthread 
	./$(T)/kthread
	
install: | $(L)/libuthread.a
	cp $(L)/libuthread.a $(INSTALL_DIR)/lib/libuthread.a
	cp -r include/libuthread $(INSTALL_DIR)/include/libuthread


# NOTE: library
$(L)/libuthread.a: $(O)/linux-mm-page.o \
		   $(O)/linux-kthread.o \
			| $(L)
	$(AR) rcs $@ $^

$(O)/linux-mm-page.o: src/linux/mm-page.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/linux-mm-page.d"
	
$(O)/linux-kthread.o: src/linux/kthread.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/linux-kthread.d"

# NOTE: tests

$(T)/kthread: $(O)/tests-kthread.o | $(T) $(L)/libuthread.a
	$(CC) $(ALL_LDFLAGS) -o $@ $^ $(L)/libuthread.a -lpthread

$(O)/tests-kthread.o: tests/kthread.c | $(O) $(D)
	$(CC) $(ALL_CFLAGS) $(ALL_CPPFLAGS) -c $< -o $@ -MMD -MF "$(D)/tests-kthread.d"
clean:
	rm -rf $(B)/*
	rm -rf $(O)/*
	rm -rf $(D)/*
	rm -rf $(L)/*
	rm -rf $(T)/*

-include build.d/init.mk
-include $(wildcard $(D)/*.d)