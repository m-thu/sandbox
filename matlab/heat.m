% Numerical solution of 1-dimensional heat equation
% Matthias Thumann, 2021

clc
clear
close all
format

% Parameters
k = 1;
c = 1;
rho = 1;

L = 20; % Length
T0 = 100; % Initial temperature
t_max = 200;
delta_x = 5;
delta_t = 10;

eta = k * delta_t / (c * rho * delta_x^2);

% Boundary condition: T(x=0) = 0, T(x=L) = 0
T = zeros(L, t_max+1);

% Initial temperature: T0 for 2 <= x <= L - 1
T(2:L-1,1) = ones(L-2,1) * T0;

for j=1:t_max
    for i=2:L-1
        T(i,j+1) = T(i,j) + ...
            eta * (T(i+1,j) + T(i-1, j) - 2*T(i, j));
    end
end

figure(1)
surf([1:t_max+1], [1:L], T)
xlabel('Time')
ylabel('Position')
zlabel('Temperature')

figure(2)
imagesc(T)
xlabel('Time')
ylabel('Position')