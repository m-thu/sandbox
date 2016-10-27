set term post eps enhanced color solid linewidth 2.0 font "Helvetica,18"
set output "nbody_cpu.eps"

set samples 1000
set encoding iso_8859_1

set xlabel "N"
set ylabel "#interactions / s"

#set logscale y

f(x) = a

fit f(x) "nbody_cpu5.txt" u 1:2 via a

set pointsize 3
plot [5000:50000] [1.067e8:1.07e8] "nbody_cpu5.txt" u 1:2 notitle w points, f(x) notitle

set output
