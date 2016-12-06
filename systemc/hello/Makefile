SYSTEMC_HOME ?= /usr/local/systemc-2.3.1

CC := g++
CXXFLAGS := -std=c++98 -pedantic -Wall -Wextra -Wno-long-long \
	-I. -I$(SYSTEMC_HOME)/include
LDFLAGS := -L. -L$(SYSTEMC_HOME)/lib-linux64 \
	-Wl,-rpath=$(SYSTEMC_HOME)/lib-linux64
LDLIBS := -lsystemc -lm

hello : hello.o

clean :
	rm -f hello
	rm -f *.o

.PHONY : clean
