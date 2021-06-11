% Logistic map (bifurcations)

clc
clear
close all
format

% Set default interpreter for xlabel, ylabel, title, ...
set(0, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');

N = 1000;
M = 100000;
x = zeros(1, N);
x_result = zeros(1, M);

k = 1;
for mu=linspace(0, 4, M)
    x(1) = rand;

    for i=2:N
        x(i) = mu * x(i-1) * (1 - x(i-1));
    end

    x_result(k) = x(N);
    k = k + 1;
end

figure
scatter(linspace(0, 4, M), x_result, 0.5)
xlabel('$$\mu$$', 'FontSize', 15)
ylabel(strcat(['$$x_{', int2str(N), '}$$']), 'FontSize', 15)
set(gca, 'FontSize', 15)