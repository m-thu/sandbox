% Numerical solution of Poisson equation
% Matthias Thumann, 2021

clc
clear
close all
format

% ^
% | y
% |
%
%       100 (V)
% --------------------         ^
% |                  |         |
% |                  |         |
% |                  |         L
% |                  | 0 (V)   |
% |                  |         |
% |                  |         |
% --------------------         v
%        0 (V)
% <------- L -------->     ---> x

L = 30;

% Initial values for potential
U = zeros(L,L);

% Boundary conditions
U(:,L) = ones(1,L) * 100;

rho = zeros(L, L);
rho(10, 15) = -10;

figure
surf([1:L], [1:L], U)
title('Initial potential with boundary conditions')

for k=1:100
    % Iterate over all points except for the boundaries
    for i=2:L-1
        for j=2:L-1
            U(i,j) = 1/4 * (U(i+1, j) + U(i-1, j) + U(i, j+1) + U(i, j-1))...
                + pi * rho(i,j);
        end
    end
end

figure
surf([1:L], [1:L], U)
title('Potential after 100 iterations')