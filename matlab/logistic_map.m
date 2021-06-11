% Logistic map (time plot)

clc
clear
close all
format

% Set default interpreter for xlabel, ylabel, title, ...
set(0, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');

% mu = 0.5; % x_i -> 0
mu = 2.8; % x_i -> fixed point
% mu = 3;   % x_i oscillates

N = 40;
x = zeros(1, N);
x(1) = 0.5;

for i=2:N
    x(i) = mu * x(i-1) * (1 - x(i-1));
end

figure
plot(x)
xlabel('Time step', 'FontSize', 15)
ylabel('$$x_i$$', 'FontSize', 15)
set(gca, 'FontSize', 15)

% Fixed point
x_f = (mu - 1) / mu;
hold on; plot(ones(1, N) * x_f); hold off