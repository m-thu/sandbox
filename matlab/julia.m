% Julia set (Matlab/Octave)

% z_{n+1} = z_n^2 + c

clear
close all
format

% Maximum absolute value of z_{n+1}
s = 2;

% Maximum number of iterations
max_iter = 23;

% Plot area (Mandelbrot set)
m_x_min = -2.1;
m_x_max = 0.9;
m_y_min = -1.2;
m_y_max = 1.2;

% Plot area (Julia set)
x_min = -2;
x_max = 2;
y_min = -2;
y_max = 2;

% Resolution (Mandelbrot set)
m_res = 0.01;

% Resolution (Julia set)
res = 0.005;

% Plot Mandelbrot set
m_x        = m_x_min:m_res:m_x_max;
m_y        = m_y_min:m_res:m_y_max;
[c_x, c_y] = meshgrid(m_x, m_y);
m_c        = complex(c_x, c_y);
m_z        = zeros(size(m_c));
M          = zeros(size(m_c));

for i = 1:max_iter
	m_z = m_z.^2 + m_c;
	M = M + (abs(m_z) <= s);
end

figure(1)
imagesc(M)
colormap jet
axis off

pos = get(gcf, 'Position');
msgbox('Select any point from the Mandelbrot set by clicking!');
[mouse_x, mouse_y] = ginput(1);
c = m_x_min + (mouse_x/pos(1))*(m_x_max-m_x_min) ...
    + 1j*m_y_min + 1j*(mouse_y/pos(2))*(m_y_max-m_y_min);

% Plot Julia set
x          = x_min:res:x_max;
y          = y_min:res:y_max;
[z_x, z_y] = meshgrid(x, y);
z          = complex(z_x, z_y);
J          = zeros(size(z));

tic()

for i = 1:max_iter
	z = z.^2 + c;
	J = J + (abs(z) <= s);
end

disp(['Time elapsed: ', num2str(toc()), ' s'])

figure(2)
imagesc(J)
%colormap jet
colormap([jet(); flipud(jet()); 0 0 0])
axis off
title(['Julia set for c = ', num2str(c)])
