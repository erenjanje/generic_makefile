# Helper functions
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# Programs
COMPILER := g++
RM := rm -f
MKDIR := mkdir -p
EMPTY_ECHO := echo
RUNNER :=

# Extensions
SRC_EXTENSION := cpp
OBJ_EXTENSION := o
STATIC_LIB_EXTENSION := a
DYNAMIC_LIB_EXTENSION := so

# Directories
SRCDIR := source/
INCDIR := $(SRCDIR)
LIBDIR := lib/
BUILDDIR := build/
OBJDIR := $(BUILDDIR)objects/
BINDIR := $(BUILDDIR)bin/
DEPENDDIR := depends/

# Files
SRCS := $(call rwildcard,$(SRCDIR),*.$(SRC_EXTENSION))
OBJS := $(SRCS:$(SRCDIR)%.$(SRC_EXTENSION)=$(OBJDIR)%.$(OBJ_EXTENSION))
DEPENDS := $(SRCS:$(SRCDIR)%.$(SRC_EXTENSION)=$(DEPENDDIR)%.d)
STATIC_LIBS := $(call rwildcard,$(LIBDIR),*.$(STATIC_LIB_EXTENSION))
DYNAMIC_LIBS := $(call rwildcard,$(LIBDIR),*.$(DYNAMIC_LIB_EXTENSION))

# Compiler options
DEBUG :=
OPTIMIZATION_LEVEL := $(if $(DEBUG),g,3)
ERRORS := no-unused-parameter no-unknown-pragmas all extra
DEFINES := $(if $(DEBUG),DEBUG,RELEASE) GLFW_INCLUDE_NONE
FLAGS := openmp modules-ts PIC $(if $(DEBUG),sanitize=leak,)
STANDARD := c++20

# Linker options
LIBS := m glfw

# Make the options suitable for passing to compiler/flagize them
_DEBUG := $(if $(DEBUG),-g,)
_ERRORS := $(ERRORS:%=-W%)
_DEFINES := $(DEFINES:%=-D%)
_FLAGS := $(FLAGS:%=-f%)
_STANDARD := $(STANDARD:%=-std=%)

# Make the linker options suitable flags
FOUND_LIBS := $(STATIC_LIBS:$(LIBDIR)lib%.$(STATIC_LIB_EXTENSION)=%) $(DYNAMIC_LIBS:$(LIBDIR)lib%.$(DYNAMIC_LIB_EXTENSION)=%)
_ALL_LIBS := $(FOUND_LIBS) $(LIBS)
_LIBS := $(_ALL_LIBS:%=-l%)

CXXFLAGS := -I"./$(INCDIR)" -O$(OPTIMIZATION_LEVEL) $(_DEFINES) $(_STANDARD) $(_FLAGS) $(_ERRORS)
LDFLAGS := $(CXXFLAGS) -L"$(LIBDIR)" $(_LIBS)

EXECNAME := main
ARGS := 

run: build
	@echo RUNNING $(EXECNAME)
	@echo ===================
	@$(EMPTY_ECHO)
	@$(BINDIR)$(EXECNAME) $(ARGS)
.PHONY: run

debug:
	@echo $(LDFLAGS)
.PHONY: debug

build: $(OBJS)
	@echo LINKING $(EXECNAME)
	@$(COMPILER) $(filter-out %.h,$(filter-out %.hpp,$(filter-out %.hpp.gch,$^))) -o $(BINDIR)$(EXECNAME) $(LDFLAGS)
.PHONY: build

clean:
	@echo RM $(OBJS)
	@$(RM) $(OBJS)
.PHONY: clean

-include $(DEPENDS)

$(OBJDIR)%.$(OBJ_EXTENSION) $(DEPENDDIR)%.d: $(SRCDIR)%.$(SRC_EXTENSION)
	@echo COMPILE $<
	@$(MKDIR) $(patsubst $(SRCDIR)%,$(OBJDIR)%,$(^D))
	@$(MKDIR) $(patsubst $(SRCDIR)%,$(DEPENDDIR)%,$(^D))
	@-$(COMPILER) $(CXXFLAGS) -MMD -MP -MF $(patsubst $(SRCDIR)%.$(SRC_EXTENSION),$(DEPENDDIR)%.d,$<) -c $< -o $@

init:
	@echo "Initializing Folders"
	@$(MKDIR) $(SRCDIR)
	@$(MKDIR) $(INCDIR)
	@$(MKDIR) $(OBJDIR)
	@$(MKDIR) $(LIBDIR)
	@$(MKDIR) $(BUILDDIR)
	@$(MKDIR) $(BINDIR)
	@$(MKDIR) $(DEPENDDIR)
	@echo "Initialization Completed"
.PHONY: init
