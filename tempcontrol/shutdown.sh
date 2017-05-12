#!/bin/sh

# GPIO 26: Shutdown switch (input, active low)
GPIO_SHUTDOWN=/sys/class/gpio/gpio26/value

while [ true ]; do
	[ `cat ${GPIO_SHUTDOWN}` -eq 1 ] || /sbin/poweroff
	sleep 1
done