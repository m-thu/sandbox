CFLAGS = -Wall -Wextra -pedantic -std=c99 -Os -pipe

all : sender receiver

vcan :
	@(lsmod | grep vcan >/dev/null) || sudo modprobe vcan
	@(ip addr | grep vcan >/dev/null) \
	 || (sudo ip link add dev vcan0 type vcan; \
	    sudo ip link set up vcan0)

clean :
	rm -f *.o
	rm -f sender receiver

.PHONY : all clean vcan
