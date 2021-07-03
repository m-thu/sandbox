all : hello logistic-map mandelbrot

hello : hello.o

logistic-map : logistic-map.o -lpgplot

mandelbrot : mandelbrot.o -lpgplot

FC = gfortran
FFLAGS = -Os
CC = gfortran

%.o : %.f95
	$(FC) $(FFLAGS) -c $< -o $@

clean:
	rm -f *.o
	rm -f hello

.PHONY : clean all