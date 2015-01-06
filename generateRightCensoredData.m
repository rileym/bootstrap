function [ data_rCen, data_exact ] = generateRightCensoredData(n, mu_star, sigma_star, rThresh)
%generateLowResData 


    data_exact = mu_star + sigma_star*randn(1,n);
    data_rCen = min(data_exact, rThresh);

end

