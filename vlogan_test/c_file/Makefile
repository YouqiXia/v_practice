BUILD_DIR=./build
SRC=$(wildcard *.c)
OBJ=$(SRC:%.c=$(BUILD_DIR)/%.o)
LIB=$(OBJ:%.o=%.so)


CC=gcc
CFLAGS=-Wall -g -c
LDFLAGS=-lpthread

default: run

PHONY: run clean build

run:build $(LIB)

build:
	-mkdir $(BUILD_DIR)

debug:
	$(info $(SRC) $(BIN) $(OBJ))

$(LIB):%.so:%.o
	$(CC) -shared $(LDFLAGS) $^ -o $@

$(OBJ):$(BUILD_DIR)/%.o:%.c
	$(CC) $(CFLAGS) $^ -o $@

clean:
	-rm $(BUILD_DIR) -r