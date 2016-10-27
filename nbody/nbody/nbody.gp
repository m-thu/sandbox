set term post eps enhanced color solid linewidth 2.0 font "Helvetica,18"
set output "nbody.eps"

set samples 1000
set encoding iso_8859_1

set xlabel "#threads / block"
set ylabel "#interactions / s"

set key at 300, 1e10

set pointsize 3
plot "nbody_1024.txt" u 1:2 w points title "N = 1024", "nbody_4096.txt" u 1:2 w points title "N = 4096", "nbody_10240.txt" u 1:2 w points title "N = 10240", "nbody_20480.txt" u 1:2 w points title "N = 20480" 

set output
