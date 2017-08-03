% Lorenz attractor (Matlab/Octave)

% \dot x = \sigma (y - x)
% \dot y = x (\rho - z) - y
% \dot z = xy - \beta z

clear
close all
format

% Parameters
sigma = 10;
beta  = 8/3;
rho   = 28;

% Initial conditions
x0 = [1, 1, 1];

f = @(t, x) [sigma * (x(2) - x(1))     ; ...
             x(1) * (rho - x(3)) - x(2); ...
             x(1) * x(2) - beta * x(3)];

t_span = [0:0.01:200];

[t, x] = ode45(f, t_span, x0);

plot3(x(:, 1), x(:, 2), x(:, 3));
axis off
