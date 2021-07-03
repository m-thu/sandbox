! Mandelbrot set
! Matthias Thumann, 2021

program mandelbrot
      implicit none

      ! Maximum number of iterations
      integer, parameter :: max_iter = 23
      ! Maximum absolute value of z
      real*8, parameter :: max_z = 2
      ! Plot area
      real*8, parameter :: x_min = -2.1, x_max = 0.9, &
              y_min = -1.2, y_max = 1.2
      ! Resolution
      real*8, parameter :: resolution = 0.004

      real*8 :: x, y
      complex*8 :: z, c
      integer :: i

      ! Initialize PGPLOT library
      call pgbegin(0, '/xwin', 1, 1)
      call pgenv(sngl(x_min), sngl(x_max), &
              sngl(y_min), sngl(y_max), 0, 1)
      call pglab('Re(c)', 'Im(c)', 'Mandelbrot set')

      x = x_min
      do
        if (x > x_max) exit

        y = y_min
        do
        if (y > y_max) exit

        z = 0
        c = complex(x, y)
        do i = 1, max_iter
                if (abs(z) > max_z) exit
                z = z**2 + c
        enddo

        if (i < max_iter) then
                call pgsci(mod(i, 15)) ! Color
                call pgpt(1, sngl(x), sngl(y), -1)
        endif

        y = y + resolution
        enddo

        x = x + resolution
      enddo

      call pgend
end