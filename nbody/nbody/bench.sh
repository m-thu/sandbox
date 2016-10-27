#!/bin/bash

for N in 1024 4096 10240 20480
do
	rm -f nbody_$N.txt
	for P in 32 64 128 256
	do
		echo -ne "$P\t" >>nbody_$N.txt
		./nbody -N$N -T16 -S1000 -P$P >>nbody_$N.txt
	done
done
