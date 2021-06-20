% Numerical solution of wave equation
% Matthias Thumann, 2021

clc
clear
close all
format

% Parameters
L = 1;
c = 1;
N_x = 100;
N_t = 250;

Delta_x = L / N_x;
Delta_t = 2 / N_t;

% Solution y(x,t)
% Boundary condition y(t, x=0) = x(t, x=L) = 0
y = zeros(N_x, N_t);

% Initial condition for x
for i=0:N_x-1
    x = i * Delta_x;
    if x <= 4/5*L
        y(i+1, 1) = 5/4 * x / L;
    else
        y(i+1, 1) = 5 - 5 * x / L;
    end
end
y(N_x,1) = 0;

for j=1:N_t-1
    for i=2:N_x-1
        if j == 1
            y(i,j+1) = 2*y(i,j) - y(i,1) ...
               + c^2 / ((Delta_x / Delta_t)^2) ...
               * (y(i-1,j) + y(i+1,j) - 2*y(i,j));
        else
           y(i,j+1) = 2*y(i,j) - y(i,j-1) ...
               + c^2 / ((Delta_x / Delta_t)^2) ...
               * (y(i-1,j) + y(i+1,j) - 2*y(i,j));
        end
    end
end

figure(1)

for i=0:9
    subplot(5,2,i+1)
    plot(y(:,i*25+1))
    ylim([-1 1])
    xlabel('x')
    ylabel('y(x,t)')
    title(strcat('Time step: ', num2str(i*25)))
end

% figure
% vid = VideoWriter('wave', 'MPEG-4');
% set(vid, 'FrameRate', 10);
% vid.Quality = 100;
% open(vid)
% for i=1:N_t
%     plot(y(:,i));
%     ylim([-1 1])
%     frame = getframe;
%     writeVideo(vid, frame);
% end
% close(vid)

figure(2)
for i=1:N_t
    plot(y(:,i));
    xlabel('x')
    ylabel(strcat('y(x, t = ', num2str((i-1)*Delta_t, '%1.2f'), ')'))
    ylim([-1 1])
    pause(0.1)
end