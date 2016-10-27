#!/bin/bash

rm -f nbody_cpu5.txt
for ((i = 10000; i <= 45000; i+=5000))
do
	./nbody_cpu_opt $i >>nbody_cpu5.txt
done
