% Pendulum

clc
clear
close all
format

% Set default interpreter for xlabel, ylabel, title, ...
set(0, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');

% Parameters
w0    = 1;
w     = 0.6;
alpha = 0.0;
F     = 0.;

% Initial conditions
x0 = [0.1, 0];

t_span = [0:0.1:6*pi];

% x1 = theta
% x2 = d/dt theta
%
% d/dt x1 = x2
% d/dt x2 = -w0^2 * sin(x1) - alpha * x2 + F*cos(w*t)

f = @(t, x) [x(2); ...
    -w0^2 * sin(x(1)) - alpha * x(2) + F * cos(w*t)];

[t, x] = ode45(f, t_span, x0);

figure
plot(t, x(:,1))
xlabel('$$t / \mathrm{s}$$', 'FontSize', 15);
ylabel('$$\theta / \mathrm{rad}$$', 'FontSize', 15);
set(gca, 'FontSize', 15)
title('Time-Angle plot')

N = 200;
P = zeros(N, length(t_span), 2);

for i=1:N
    % Random initial conditions
    x0 = [10*rand - 5, 10*rand - 5];
    
    [t, x] = ode45(f, t_span, x0);
    
    P(i, :, 1) = x(:, 1);
    P(i, :, 2) = x(:, 2);
end

figure
hold on
for i=1:N
    plot(P(i, :, 1), P(i, :, 2))
end
hold off
xlabel('$$\theta / \mathrm{rad}$$', 'FontSize', 15)
ylabel('$$\dot{\theta} / \mathrm{rad}\cdot\mathrm{s}^{-1}$$', 'FontSize', 15)
set(gca, 'FontSize', 15)
title('Phase space plot')
xlim([-10 10])
ylim([-5 5])