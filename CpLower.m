function [ cpl ] = CpLower( LSL, mu_est, sigma_est )
% Computes Cp,lwr as defined here:
% http://en.wikipedia.org/wiki/Process_capability_index

    cpl = (mu_est - LSL)/(3*sigma_est);

end

