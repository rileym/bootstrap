# bootstrap

  I wrote this demo — based off a question an engineering friend asked me — for a class I TAed at Stanford. At that time I had access to Matlab and its optimization module. NB: I no longer have access to Matlab (the `fmincon` function, in particular, which Octave does not yet have) and cannot test the demo nor produce the plots.

### Demo Background and Set-Up

  [Process capability indices](http://en.wikipedia.org/wiki/Process_capability_index) compare allowable process output error — i.e. deviation from some target value — to the estimated variation of that output. That may be a crude characterization, but for the purposes of the demo it is enough to understand the process capability index as some statistic of interest determined by the estimated mean and variance of the process output (which is assumed to be normally distributed).

  The goal of the exercise is to take process output data and produce:

1. an estimate the (lower bound) process capability index (below denoted `C_pl`, where `C_pl =  ( mu_hat - LSL ) / 3 sigma_hat` ) 
2. a confidence interval for this estimate

As an additional complication of the exercise, we take the process output data to be right censored. (This complication was actually an aspect of my engineering friend’s question: the device she used to *measure* the process output had a maximum reading that was equaled or surpassed by a number of the output data.) The difficulty of the exercise is thus twofold: firstly, how to compute the estimated mean and variance for the *underlying* process output when you only have access to the right censored reading; and secondly, how to compute a confidence interval for the one-sided process capability index.

### Estimating the Capability Index — MLE
  
  To estimate the mean and variance of the underlying normal distribution, we can compute the MLE. Of course to do so we must first write out the likelihood function of the right censored data as a function of the underlying mean, `mu`, and variance, `sigma^2`. With a little thought it should become clear how to form the likelihood (and so too the log-likelihood) function: for each data point/reading `x_i` less than the right censoring threshold, we multiply in a corresponding `f_mu_theta(x_i)` term into the likelihood product, where `f_mu_theta` is the density function for a normal random variable with mean mu and variance `sigma^2`; and for each data point `x_i` equal to the right censoring threshold (indicating that the corresponding true process output was at least that large) we multiply in a `1-F_mu_theta(x_i)` term into the likelihood product, where `F_mu_theta` is the CDF of a normal random variable with mean `mu` and variance `sigma^2`.

  As the CDF cannot be expressed in closed form, we must maximize the (log) likelihood numerically. For this task we use Matlab's `fmincon` (where the *con*straint is `sigma >= 0`).

### Computing a Confidence Interval — Bootstrap

  With a MLE procedure in hand we can produce point estimates of mu, sigma, and `C_pl`. How then to produce confidence intervals? — with the parametric bootstrap. Using the MLE estimates of `mu` and `sigma^2` to estimate the underlying process output distribution, we generate N bootstrapped samples of right censored data, and for each sample, we again estimate `mu`, `sigma`, and `C_pl` using the above procedure. With those bootstrapped estimates, we get a sense of our estimating procedure’s sensitivity to the idiosyncrasies of the particular sample to which it is applied. A precise confidence interval of say, 95%, (for mu, sigma, or `C_pl` — let's focus on `C_pl`) is the interval centered at the original MLE estimate (before bootstrapping) for `C_pl` with upper and lower bounds at a distance `l_95` from the center, where `l_95` is the 95th percentile absolute deviation of the bootstrapped estimates of `C_pl` to the original estimate of `C_pl`.
