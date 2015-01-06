function [ data_rCen, data_exact ] = generateRightCensoredData(n, mu_star, sigma_star, rThresh)
%generateLowResData 


    data_exact = mu_star + sigma_star*randn(1,n); % Sample estiamted normal distribution.
    data_rCen = min(data_exact, rThresh);         % Right censor.

end

