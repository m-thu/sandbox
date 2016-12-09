SYSTEMC_HOME ?= /usr/local/systemc-2.3.1

CC := g++
CXXFLAGS := -std=c++98 -pedantic -Wall -Wextra -Wno-long-long \
	-I. -I$(SYSTEMC_HOME)/include -Os -pipe
LDFLAGS := -L. -L$(SYSTEMC_HOME)/lib-linux64 \
	-Wl,-rpath=$(SYSTEMC_HOME)/lib-linux64
LDLIBS := -lsystemc -lm

main : main.o

main.o : sender.hpp receiver.hpp

clean :
	rm -f main
	rm -f *.o
	rm -f *.vcd

.PHONY : clean
