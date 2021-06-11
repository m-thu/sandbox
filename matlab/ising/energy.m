function [E] = energy(S, B)
    % Spin-spin interaction
    E = - sum(S(1:end-1) .* S(2:end));
    
    % External magnetic field
    E = E - B * sum(S);
end