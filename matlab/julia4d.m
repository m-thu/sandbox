% 4D Julia set (Matlab/Octave)

clear all
close all
format

% Plot area
x_min = -1.5;
x_max = 1.5;
y_min = -1.5;
y_max = 1.5;
z_min = -1.5;
z_max = 1.5;

% Resolution
res = 0.05;

% Maximum absolute value for q
s = 2;

% Maximum number of iterations
max_iter = 23;

c = Quaternion([-1, 0.2, 0, 0]);

X = [];
Y = [];
Z = [];

tic();

for x = x_min:res:x_max
	for y = y_min:res:y_max
		for z = z_min:res:z_max
			q = Quaternion([x, y, z, 0]);
			for i = 1:max_iter
				q = q*q + c;
				if (q.Norm > s)
					break
				end
			end
			if i == max_iter
				X = [X, x];
				Y = [Y, y];
				Z = [Z, z];
			end
		end
	end
end

disp(['Time elapsed: ', num2str(toc()), ' s'])

figure(1)
scatter3(X, Y, Z, 6)
