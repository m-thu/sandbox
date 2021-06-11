% One dimesional Ising model

clc
clear
close all
format

rng('shuffle', 'Twister')

% Number of spins
N = 50;
% Number of time steps
n = 200;
% Temperature
kT = 0.1;
% External magnetic field
B = 0.;

% Generate random configuration
S = randi([0,1], 1, N);
S(S == 0) = -1.;

% Matrix with results
Result = zeros(N, n);
E_result = zeros(1, n);

for i=1:n
    % Generate trial configuration by flipping one spin
    S_trial = S;
    k = randi([1,N]);
    S_trial(k) = -S_trial(k);
    
    % Energy of new and old configuration
    E = energy(S, B);
    E_result(i) = E;
    E_trial = energy(S_trial, B);
    Delta_E = E_trial - E;
    
    % Probability of accepting new configuration
    p = exp(-Delta_E / kT);
    
    if rand <= p
        Result(:,i) = S_trial.';
        S = S_trial;
    else
        Result(:,i) = S.';
    end
end

imagesc(Result)
xlabel('Time step')
ylabel('Spin orientation')

figure
plot(E_result)
xlabel('Time step')
ylabel('Energy')

% Calculate histogram of resulting energies

tries = 1000;
E_hist = zeros(1, tries);

for j = 1:tries
    % Generate random configuration
    S = randi([0,1], 1, N);
    S(S == 0) = -1.;
    
    for i=1:n
        % Generate trial configuration by flipping one spin
        S_trial = S;
        k = randi([1,N]);
        S_trial(k) = -S_trial(k);
    
        % Energy of new and old configuration
        E = energy(S, B);
        E_trial = energy(S_trial, B);
        Delta_E = E_trial - E;
    
        % Probability of accepting new configuration
        p = exp(-Delta_E / kT);
    
        if rand <= p
            S = S_trial;
        end
    end
    
    E_hist(j) = energy(S, B);
end

figure
histogram(E_hist)
xlabel('Energy')
ylabel('# Occurrences')