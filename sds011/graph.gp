set term png size 640,480 font "Helvetica,15"
set output

set samples 1000
set encoding iso_8859_1

set timefmt "%H-%M-%S"
set xdata time
set xrange [ "00:00:00":"23:59:59" ]
set format x "%H"
unset mxtics

set xlabel "Hour"
set ylabel "ug / m^3"

plot filename u 1:2 title "PM 2.5" w points,\
     filename u 1:3 title "PM 10" w points
