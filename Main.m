%% MLE and Bootstrapped CI of Normal dist. parameters (mu, theta) and process capability index
%% with censored data.

%% See: http://en.wikipedia.org/wiki/Bootstrapping_%28statistics%29#Parametric_bootstrap
%% and http://en.wikipedia.org/wiki/Process_capability_index

%%
%% NOTE: I wrote this demo -- based off a question an engineering friend ask me -- for a class I TAed at
%% Stanford. At that time I had acess to Matlab and its optimization module. I no longer have access to 
%% matlab (nor fmincon, in particular) and haven't tested the demo in a while. Also the visualization part
%% is only half done. 
%%

% Riley Matthews :-)

clc;
clear;


%% Read In Data 

hovData = csvread('./censoredData.csv');
n = length(hovData);
hovData = reshape(hovData, n, 1); %make into a column vector


rightThresh = 80;   % Right censoring threshold
LSL = 72;           % See http://en.wikipedia.org/wiki/Process_capability_index

%% MLEstimate

f = @(param)(-logLikelihood(hovData, rightThresh, param)); %logLikelyhood computes the
                % log likelihood of seeing the right censored data


x0 = [mean(hovData); std(hovData)];     % x0 = [mu0; sigma0], the initial guess.

A = [0,0;0,-1];
b = zeros(2,1); %% Sigma is a non-negative real value. A*x<=b will enforce
                %% that constraint in the MLE computation/optimization.

param_est = fmincon(f,x0,A,b); %Computes MLE. fmincon attempts to find a value
                            % x which minimizes the function f (-log Liklihoood) s.t. A*x<=b (sigma>=0).
                            % Type "help fmincon" into the cmd-window for more. 
                            
%% Parametric Bootstrap

mu_est = param_est(1);  %Parameter estimates from the above MLE.
sigma_est = param_est(2);
Cpl_est = CpLower(LSL, mu_est, sigma_est); % Point estimate of the Cplower for which we want to find
                                           % a confidence interval. (See the process capability index 
                                           % link if you haven't done so already.)

N = 5*10^3;               %Number of iterations (10000 is typical I think)
bsParams = zeros(2,N);  %Vector to record our bootsrap estimates of mu and sigma
CPLs = zeros(1,N);      %Vector to record the corrsponding Cplwr estimates

tic %tic (here) and toc (below) just output the time to execute everything between the two
    %statments.  
%Compute N parameter estimates by sampleing the estimated dist:
for i = 1:N 
    
    % Resample and censor from estimated distribution
    [data_rCen, ~] = generateRightCensoredData(n, mu_est, sigma_est, rightThresh);
    % Compute & record new estimated parameters
    f = @(param)(-logLikelihood(data_rCen, rightThresh, param)); 
    bsParams(:,i) = fmincon(f,x0,A,b); 
    CPLs(i) = CpLower(LSL, bsParams(1,i), bsParams(2,i));
  
end
toc


%% CI from Bootsrap

confidenceLevel = .95;
delta = 1 - confidenceLevel;

% Sort the absolute deviation between the Bootstrap estimates and the original
% estimate, find the 1-delta percentile (call it z), and then your 1-delta CI is:
% [original_parameter_estimate -z, original_parameter_estimate+z]

% CI for mu

sortedMuAbsDev = sort( abs( bsParams(1,:) - mu_est )); %Vector of the sorted 
            %values of |mu_tilde_hat_i-mu_est|, i.e., the absolute
            %difference between the bootsrapped estimate and the original
            %estimate.
z_Mu = sortedMuAbsDev(round(N*(1-delta))); %Thus z_Mu is the value such that
                            % a 100*(1-delta)% of the bootstraped estimates
                            %  will be within z_Mu of the mu_est.
muCI = [mu_est-z_Mu, mu_est+z_Mu]

% CI for sigma

sortedSigAbsDev = sort( abs( bsParams(2,:)-sigma_est )); %As above, except with sigma.
z_Sigma = sortedSigAbsDev(round(N*(1-delta)));
sigmaCI = [sigma_est-z_Sigma, sigma_est+z_Sigma]

%CI for Cpl

sortedCplAbsDev = sort( abs( CPLs(:)-Cpl_est ));
z_Cpl = sortedCplAbsDev(round(N*(1-delta)));
Cpl_CI = [Cpl_est-z_Cpl, Cpl_est+z_Cpl]


%% Visualize 

% Mu and sigma confidence box.

figure;
scatter(bsParams(1,:), bsParams(2,:)); %Draw B.S. estimates
xlabel('mu estimates'); ylabel('sigma estimates');
hold all;
s = 100;
lH = 2;
scatter(mu_est, sigma_est,.7*s,'o','filled'); %Draw Original esimate
% scatter(mu_star, sigma_star,s,'^','filled'); %Draw *True Parameters*
axis manual; %Freeze axis 

%Draw mu CI
line([muCI(1),muCI(1)], [sigma_est-lH ,sigma_est+lH ],...
    'Color','m','LineStyle','--');
line([muCI(2),muCI(2)], [sigma_est-lH ,sigma_est+lH ],...
    'Color','m','LineStyle','--');
%Draw sigma CI
line([mu_est-lH, mu_est+lH], [ sigmaCI(1), sigmaCI(1) ],...
    'Color','m','LineStyle','--');
line([mu_est-lH, mu_est+lH], [ sigmaCI(2), sigmaCI(2) ],...
    'Color','m','LineStyle','--');

hold off;

figure;
hist(CPLs ,75);

% TODO: Add Cpl_CI to the CPLs histogram.
% TODO: Read about joint or simultainus bootstrap CIs (e.g., the simultainus CI for (mu, sigma) is not a box? or is it?)