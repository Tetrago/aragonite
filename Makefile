MAKEFLAGS += --silent

EXTERNAL_TARGETS ?= glfw
LIB_TARGETS ?= window

.PHONY: all
all:
	for target in $(EXTERNAL_TARGETS); do $(MAKE) -C external/$$target $@; done
	for target in $(LIB_TARGETS); do $(MAKE) -C libs/$$target $@; done

.PHONY: clean
clean:
	for target in $(EXTERNAL_TARGETS); do $(MAKE) -C external/$$target $@; done
	for target in $(LIB_TARGETS); do $(MAKE) -C libs/$$target $@; done
