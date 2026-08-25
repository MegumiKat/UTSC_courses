CC = gcc
CFLAGS = -Wall # -Wextra -Werror -std=c99
LDFLAGS =
GG = gdb

# Source files
SRCS = graph.c graph_algos.c minheap.c graph_tester.c

# Object files
OBJS = $(SRCS:.c=.o)

# Output binary
TARGET = graph_tester

# Input file
INPUT_FILE = sample_input.txt

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -g -o $@ $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

run: $(TARGET)
	./$(TARGET) $(INPUT_FILE)

debug: $(TARGET)
	./$(TARGET) $(INPUT_FILE)

clean:
	rm -f $(OBJS) $(TARGET)
