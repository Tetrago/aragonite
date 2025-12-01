MAKEFLAGS += --silent

include library.defs

SRCS_ROOT  ?= ./
BUILD_TYPE ?= Debug
ROOT_DIR   ?= $(shell git rev-parse --show-toplevel)
BUILD_DIR  ?= $(ROOT_DIR)/build/$(BUILD_TYPE)/$(NAME)

AR  ?= ar
CC  ?= gcc
CXX ?= g++
LD  ?= ld

COMMON_FLAGS = -Wall -Wextra -Wundef -Wpedantic $(foreach warn,$(SUPPRESS_WARNINGS), -Wno-$(warn)) -fvisibility=hidden
CFLAGS      := $(COMMON_FLAGS) $(CFLAGS)
CXXFLAGS    := $(COMMON_FLAGS) -fvisibility-inlines-hidden $(CXXFLAGS)
LDFLAGS     += --gc-sections $(shell pkg-config --libs $(LIBS) 2>/dev/null)$(foreach dep,$(EXTERNAL_DEPS), -L$(BUILD_DIR)/../$(dep) -l$(dep))

ifeq ($(BUILD_TYPE), Debug)
CFLAGS   += -Og -g
CXXFLAGS += -Og -g
else ifeq ($(BUILD_TYPE), Release)
CFLAGS   += -O3 -DNDEBUG -flto
CXXFLAGS += -O3 -DNDEBUG -flto
else
$(error invalid build type: $(BUILD_TYPE))
endif

OBJECTS := $(SRCS:%.c=$(BUILD_DIR)/%.o)
OBJECTS := $(OBJECTS:%.cpp=$(BUILD_DIR)/%.o)

.PHONY: all
all: $(BUILD_DIR)/lib$(NAME).a $(BUILD_DIR)/lib$(NAME).so

$(BUILD_DIR)/%.o: $(SRCS_ROOT)%.c
	mkdir -p $(dir $@)
	echo "CC  $(patsubst $(SRCS_ROOT)%,%,$<)"
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o: $(SRCS_ROOT)%.cpp
	mkdir -p $(dir $@)
	echo "CCX $(patsubst $(SRCS_ROOT)%,%,$<)"
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(EXTERNAL_DEPS):
	for dep in $(EXTERNAL_DEPS); do $(MAKE) -C ../../external/$$dep; done

$(BUILD_DIR)/lib$(NAME).so: $(EXTERNAL_DEPS) $(OBJECTS)
	echo "LD  lib$(NAME).so"
	$(LD) $(LDFLAGS) -shared -o $@ $(OBJECTS)

$(BUILD_DIR)/lib$(NAME).a: $(EXTERNAL_DEPS) $(OBJECTS)
	echo "AR  lib$(NAME).a"
	$(AR) rcs $@ $(OBJECTS)

.PHONY: clean
clean:
	echo "RM $(BUILD_DIR:$(ROOT_DIR)/%=%)"
	rm -rf $(BUILD_DIR)

.PHONY: info
info:
	echo "=== $(NAME) ==="
	echo "BUILD_TYPE    = $(BUILD_TYPE)"
	echo "AR            = $(AR)"
	echo "CC            = $(CC)"
	echo "CXX           = $(CXX)"
	echo "LD            = $(LD)"
	echo "CFLAGS        = $(CFLAGS)"
	echo "CXXFLAGS      = $(CXXFLAGS)"
	echo "LDFLAGS       = $(LDFLAGS)"
	echo "EXTERNAL_DEPS = $(EXTERNAL_DEPS)"
