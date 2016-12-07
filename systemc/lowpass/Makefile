SYSTEMC_HOME ?= /usr/local/systemc-2.3.1

CC := g++
CXXFLAGS := -std=c++98 -pedantic -Wall -Wextra -Wno-long-long \
	-I. -I$(SYSTEMC_HOME)/include -Os -pipe
LDFLAGS := -L. -L$(SYSTEMC_HOME)/lib-linux64 \
	-Wl,-rpath=$(SYSTEMC_HOME)/lib-linux64
LDLIBS := -lsystemc -lm

main : main.o toplevel.o lowpass_tb.o lowpass.o

main.o : toplevel.hpp
toplevel.o : toplevel.hpp
lowpass_tb.o : lowpass_tb.hpp
lowpass.o : lowpass.hpp

clean :
	rm -f main
	rm -f *.o
	rm -f *.vcd

.PHONY : view clean
