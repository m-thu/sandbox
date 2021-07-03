! Logistic map
! Matthias Thumann, 2021

program logistic_map
      real*8, parameter :: mu_min = 0., mu_max = 4.
      real*8, parameter :: mu_steps = 100000.
      integer, parameter :: N_max = 100 ! Max. iterations before plotting
      real*8 :: mu, x

      ! Initialize PGPLOT library
      call pgbegin(0, '/xwin', 1, 1)
      call pgenv(sngl(mu_min), sngl(mu_max), 0., 1., 0, 1)
      call pglab('mu', 'x_1000', 'Logistic map')

      mu = mu_min
      delta = (mu_max - mu_min) / mu_steps
      do
        if (mu > mu_max) exit

        x = rand(0)
        do i = 1, N_max
                x = mu * x * (1 - x)
        enddo

        call pgsci(2) ! Color
        call pgpt(1, sngl(mu), sngl(x), -1)

        mu = mu + delta
      enddo

      call pgend
end