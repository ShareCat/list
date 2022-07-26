
AR ?= ar
CC ?= gcc
PREFIX ?= /usr/local
DESTDIR ?=

CFLAGS = -O3 -std=c99 -Wall -Wextra -Ideps

SRCS = src/list.c \
		   src/list_node.c \
		   src/list_iterator.c

OBJS = $(SRCS:.c=.o)

MAJOR_VERSION = 0
MINOR_VERSION = 2
PATCH_VERSION = 0

all: build/liblist.a build/liblist.so.$(MAJOR_VERSION).$(MINOR_VERSION).$(PATCH_VERSION)

install: all
	test -d $(DESTDIR)$(PREFIX)/lib || mkdir -p $(DESTDIR)$(PREFIX)/lib
	cp -f build/liblist.a $(DESTDIR)$(PREFIX)/lib/liblist.a
	cp -f build/liblist.so.$(MAJOR_VERSION).$(MINOR_VERSION).$(PATCH_VERSION) $(DESTDIR)$(PREFIX)/lib/liblist.so.$(MAJOR_VERSION).$(MINOR_VERSION).$(PATCH_VERSION)
	ln -sf liblist.so.$(MAJOR_VERSION).$(MINOR_VERSION).$(PATCH_VERSION) $(DESTDIR)$(PREFIX)/lib/liblist.so.$(MAJOR_VERSION).$(MINOR_VERSION)
	ln -sf liblist.so.$(MAJOR_VERSION).$(MINOR_VERSION) $(DESTDIR)$(PREFIX)/lib/liblist.so.$(MAJOR_VERSION)
	ln -sf liblist.so.$(MAJOR_VERSION) $(DESTDIR)$(PREFIX)/lib/liblist.so
	test -d $(DESTDIR)$(PREFIX)/include || mkdir -p $(DESTDIR)$(PREFIX)/include/
	cp -f src/list.h $(DESTDIR)$(PREFIX)/include/list.h

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/lib/liblist.a
	rm -f $(DESTDIR)$(PREFIX)/include/list.h

build/liblist.a: $(OBJS)
	@mkdir -p build
	$(AR) rcs $@ $^

build/liblist.so.$(MAJOR_VERSION).$(MINOR_VERSION).$(PATCH_VERSION): $(OBJS)
	@mkdir -p build
	ld -z now -shared -lc -soname `basename $@` src/*.o -o $@
	strip --strip-unneeded --remove-section=.comment --remove-section=.note $@

bin/test: test.o $(OBJS)
	@mkdir -p bin
	$(CC) $^ -o $@

bin/benchmark: benchmark.o $(OBJS)
	@mkdir -p bin
	$(CC) $^ -o $@

%.o: %.c
	$(CC) $< $(CFLAGS) -c -o $@

clean:
	rm -fr bin build *.o src/*.o

test: bin/test
	@./$<

benchmark: bin/benchmark
	@./$<

.PHONY: test benchmark clean install uninstall
