function [ L ] = logLikelihood( data, rThresh, param )


    mu = param(1);
    sigma = param(2);
    if sigma > 0
        
        density = normpdf(data, mu, sigma);
        rCensoredSet = data >= rThresh;
      
        L = dot(log(density), ~rCensoredSet) + ...
            sum(rCensoredSet)*log( 1 - normcdf(rThresh, mu, sigma ));
        
    else %Sometimes the sigma > 0 constraint in fmincon is not strictly held, which can cause errors w/o this case
        L = -Inf;
    end

end

