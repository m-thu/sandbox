set term post eps enhanced color solid linewidth 2.0 font "Helvetica,18"
set output "leapfrog.eps"

set samples 1000
set encoding iso_8859_1

set xlabel "#threads / block"
set ylabel "time / ms"


set pointsize 3
plot "leapfrog_1024.txt" u 1:2 w points title "N = 1024", "leapfrog_10240.txt" u 1:2 w points title "N = 10240", "leapfrog_51200.txt" u 1:2 w points title "N = 51200", "leapfrog_102400.txt" u 1:2 w points title "N = 102400" 

set output
