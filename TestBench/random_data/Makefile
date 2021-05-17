INCDIR= $(shell pwd)
SRCDIR= $(shell pwd)
OBJDIR= $(shell pwd)
BINDIR= $(shell pwd)

VPATH = $(SRCDIR)

# FLAGS
CC := g++
CFLAGS=-c -g -Wall `root-config --cflags` -I${INCDIR}
LDFLAGS=`root-config --glibs` -lHistPainter

# File names
EXEC = $(BINDIR)/test_model
FILES= $(wildcard $(SRCDIR)/*.cpp)
SOURCES=$(FILES)

OBJECTS = $(FILES:$(SRCDIR)/%.cpp=${OBJDIR}/%.o)
print-%  : ; @echo $* = $($*)

$(OBJDIR)/%.o: %.cpp
	$(CC) $(CFLAGS) $< -o $@
$(EXEC): $(OBJECTS)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS)
	rm $(OBJDIR)/*.o

# To remove generated files
clean:
	rm $(BINDIR)/* $(OBJDIR)/*.o
