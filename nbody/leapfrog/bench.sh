#!/bin/bash

for N in 1024 10240 51200 102400
do
	rm -f leapfrog_$N.txt
	for TPB in 8 16 32 64 128 256 512
	do
		echo -ne "$TPB\t" >>leapfrog_$N.txt
		./leapfrog -N$N -T$TPB -S10000 >>leapfrog_$N.txt
	done
done
