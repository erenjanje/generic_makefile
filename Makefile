CC=g++
RM=rm
EXTENSION=cc

INCDIR=include
SRCDIR=src
OBJDIR=obj
BUILDDIR=build
BINDIR=bin
SRCS = $(wildcard $(SRCDIR)/*.$(EXTENSION))
OBJS = $(patsubst $(SRCDIR)/%.$(EXTENSION), $(OBJDIR)/%.o, $(SRCS))

CFLAGS=-I"./$(INCDIR)"
LDFLAGS=-fPIC -lm

EXECNAME=main

run: build
	@echo "RUNNING\n================\n"
	@$(BINDIR)/$(EXECNAME)
.PHONY: run

build: $(OBJS)
	@$(CC) $^ -o $(BINDIR)/$(EXECNAME) $(LDFLAGS)
	@echo "CC $<"
.PHONY: build

clean:
	@$(RM) -f $(OBJS)
	@echo RM $(OBJS)
.PHONY: clean

$(OBJDIR)/%.o: $(SRCDIR)/%.$(EXTENSION)
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "CC $<"

init:
	@echo "Initializing Folders"
	@mkdir $(INCDIR)
	@mkdir $(SRCDIR)
	@mkdir $(OBJDIR)
	@mkdir $(BUILDDIR)
	@mkdir $(BINDIR)
	@echo "Initialization Completed"
.PHONY: init

remove: check_remove
	@$(RM) -rf $(INCDIR)
	@$(RM) -rf $(SRCDIR)
	@$(RM) -rf $(OBJDIR)
	@$(RM) -rf $(BUILDDIR)	
	@$(RM) -rf $(BINDIR)
.PHONY: remove


check_remove:
	@echo "Removing folders"
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]

.PHONY: remove check_remove
