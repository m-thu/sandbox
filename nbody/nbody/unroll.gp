set term post eps enhanced color solid linewidth 2.0 font "Helvetica,18"
set output "unroll.eps"

set samples 1000
set encoding iso_8859_1

set xlabel "unroll count"
set ylabel "#interactions / s"

set key right center

set pointsize 3
plot "unroll.txt" u 1:2 w points title "N = 20480, p = 64"

set output
