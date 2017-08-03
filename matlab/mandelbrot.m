% Mandelbrot set (Matlab/Octave)

% z_{n+1} = z_n^2 + c, z_0 = 0, z,c \in \mathbb{C}
% c \in \mathcal{M} \iff \limsup\limits_{n\to\infty} |z_{n+1}| \leq 2

clear
close all
format

% Maximum absolute value of z_{n+1}
s = 2;

% Maximum number of iterations
max_iter = 23;

% Plot area
x_min = -2.1;
x_max = 0.9;
y_min = -1.2;
y_max = 1.2;

% Resolution
res = 0.001;

x          = x_min:res:x_max;
y          = y_min:res:y_max;
[c_x, c_y] = meshgrid(x, y);
c          = complex(c_x, c_y);
z          = zeros(size(c));
M          = zeros(size(c));

tic()

for i = 1:max_iter
	z = z.^2 + c;
	M = M + (abs(z) <= s);
end

disp(['Time elapsed: ', num2str(toc()), ' s'])

figure(1)
imagesc(M)
colormap([jet(); flipud(jet()); 0 0 0]);
%colormap jet
axis off
