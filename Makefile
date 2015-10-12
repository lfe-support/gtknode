## -*- mode: Makefile; fill-column: 80; comment-column: 67; -*-

CC    ?= gcc
ERL   ?= $(shell readlink -e $(shell which erl))
REBAR ?= $(shell which rebar 2> /dev/null || which ./rebar)

.PHONY: all ecompile generate link examples

SRCS     = $(shell echo c_src/*.c)
OBJS     = $(patsubst c_src/%.c, c_src/%.o, $(SRCS))
ESRCS    = $(shell echo src/*.erl)
BEAMS    = $(patsubst src/%.erl, ebin/%.beam, $(ESRCS))
ERL_ROOT = $(shell dirname $(shell dirname $(ERL)))

all: ebin ecompile generate link

examples:
	make -C priv/examples

ebin:
	mkdir $@

ecompile: $(BEAMS)

ebin/%.beam: src/%.erl
	erlc +debug_info +warnings_as_errors -o ebin $<

generate:
	./priv/generator/generate.sh

link: priv/generator/build/gtknode

priv/generator/build/gtknode: $(OBJS)
	$(CC) \
	$(shell pkg-config --libs libglade-2.0) \
	$(shell pkg-config --libs gmodule-2.0) \
	$(OBJS) \
	-L$(ERL_ROOT)/usr/lib -lei \
	-o $@

c_src/%.o: c_src/%.c
	$(CC) \
	$(shell pkg-config --cflags libglade-2.0) \
	-I $(ERL_ROOT)/usr/include \
	-o $@ -c $<
