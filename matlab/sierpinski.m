% Sierpinski

clc
clear
close all
format

% Set default interpreter for xlabel, ylabel, title, ...
set(0, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');

% Vertices of triangle
v = [-1 0; 1 0; 0 1];

figure
hold on

% Triangle
plot([v(1,1), v(2,1)], [v(1,2), v(2,2)])
plot([v(2,1), v(3,1)], [v(2,2), v(3,2)])
plot([v(3,1), v(1,1)], [v(3,2), v(1,2)])

% Number of points
N = 10e3;

p = [.2 .2];
points = zeros(N, 2);
points(1,:) = p;
plot(p(1), p(2), '.')

for i=2:N
    p = (p + v(randi([1,3]),:)) ./ 2;
    plot(p(1), p(2), '.')
    points(i,:) = p;
end

hold off

% Box counting
M = 10;
densities = zeros(1, M);

for k=1:M
    N_boxes = 2^k;
    boxes = zeros(N_boxes, N_boxes);
    
    for i=1:N
        boxes(ceil((points(i,1) - v(1,1)) / (v(2,1) - v(1,1)) * N_boxes), ...
            ceil((points(i,2) - v(1,2)) / (v(3,2) - v(1,2)) * N_boxes)) = 1;
    end
    
    densities(k) = sum(boxes(:) == 1) / N_boxes^2;
end

figure
semilogy(densities)
xlabel('Log(Number of boxes)')
ylabel('Density')

P = polyfit([1:6], log(densities(1:6))/log(2), 1);
hold on
plot([1:10], 2.^(P(2) + P(1)*[1:10]))
hold off

legend('Measured density', 'Linear fit for first six values')

display(['Boxcounting dimension: ', num2str(P(1)+2)])