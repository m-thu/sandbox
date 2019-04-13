% Euler-forward algorithm
% =======================
%
% Circuit diagram:
%
%        R             L
%      _____
% ----|_____|-------UUUUUU----
% |                          |
% |  ^                       |
% |  |                       |
% |  | i(t)                  |
% |                          |
% o  --------------------->  o
%          ^
%   u(t) = u * sin(omega * t)
%
%  State variable: i(t)
%  Output        : i(t)
%
%  State space representation:
%     di/dt = 1/L * (u - R*i)

clear
close all
format

% Parameters
R       =    1; % Ohm
L       =    1; % Henry
i0      =    0; % Initial current (A)
h       = 0.01; % Time step (s)
t_start =    0; % Start time (s)
t_end   =    5; % Stop time (s)
f       =    5; % Frequency of the input voltage u(t) (Hz)
u_amp   =   10; % Amplitude of the input voltage u(t) (V)

% Initialize time and current
i = i0;
t = t_start;

% Resulting i(t)
it = [];

% Numerical integration using Euler forward
while t <= t_end
	% Input voltage
	u = u_amp * sin(2*pi*f * t);
	% Time derivative of the current
	ip = 1/L * (u - R*i);
	% Integrate
	i = i + ip*h;
	% Save result
	it = [it i];
	% Add time step
	t = t + h;
end

% Plot result
figure(1);
t = [0:length(it)-1] * h;
plot(t, it);
xlabel('t / s');
ylabel('i(t) / A');
