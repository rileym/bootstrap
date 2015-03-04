# bootstrap

I wrote this demo, inspired by a question an engineering friend asked me, for a probabilistic modeling class I was TAing at Stanford. 

**Unfortunately, I no longer have access to Matlab (the `fmincon` function, in particular, which Octave does not yet have) and cannot test the demo nor produce new plots anymore.**

### Demo Background and Set-Up

  [Process capability indices](http://en.wikipedia.org/wiki/Process_capability_index) measure the “safety” or margin-for-error of engineering processes. They compare allowable process output error — i.e. deviation from some target value — to the estimated variation of that output. That is likely a crude characterization, but for the purposes of the demo it is enough to understand the process capability index as a statistic determined by the estimated mean and variance of the (assumed to be normally distributed) process output.

The goal of the exercise is to take process output data and produce:

* An estimate of the (lower bound) process capability index (below denoted `C_pl`, where `C_pl =  ( mu_hat - LSL ) / ( 3 sigma_hat )` ) 
* A confidence interval for this estimate

As an additional complication of the exercise, our process output data is right censored. (This complication was actually an element of my engineering friend’s question; the device she used to measure the process output had a maximum reading that was equaled (or surpassed) by a portion of the output values.) 

The difficulty of the exercise is thus twofold:

1. How to compute the estimated mean and variance for the *underlying* process output (as opposed to the reported output, which is censored) with access only to the right censored readings?
2. How to compute a confidence interval for the resultant process capability index point estimate?

### 1. Estimating the Process Capability Index — MLE
  
To estimate the mean and variance of the underlying normal distribution, we compute the MLE. Of course, to do so we must first write out the likelihood of the right censored data as a function of the underlying mean, `mu`, and variance, `sigma^2`. With a little thought it becomes clear how to form the likelihood (and so too the log-likelihood) function: 
* For each data point `x_i` *less than* the right censoring threshold, there is a corresponding `f_mu_theta(x_i)` term in the likelihood product, where `f_mu_theta` is the density function for a normal random variable with mean `mu` and variance `sigma^2`
* For each data point `x_i` *equal to* the right censoring threshold (indicating that the true process output value was at least that large) there is a `1-F_mu_theta(x_i)` term in the likelihood product, where `F_mu_theta` is the CDF of a normal random variable with mean `mu` and variance `sigma^2`.


Given this likelihood expression, we need only to maximize it (or, rather, its logarithm) over `mu` and `sigma^2` in order to produce point estimates for `mu`, `sigma^2`, and `C_pl`. Since the Normal CDF cannot be expressed in closed form, we must maximize the (log) likelihood numerically. For this task I’ve used Matlab's `fmincon` (where the *con*straint is `sigma >= 0`).

### 2. Computing a Confidence Interval — Bootstrap

With the above MLE procedure in hand we are able to produce point estimates of `mu`, `sigma`, and `C_pl` from our right-censored process output data. How then do we to produce confidence intervals for our point estimates? The answer: with the parametric bootstrap. 

Using the MLE estimates of `mu` and `sigma^2` produced in the previous step, we take a normal distribution with those parameters as a stand-in for the “true” (and unknown) underlying process output distribution. From this distribution we may now draw and right-censor `N` (some large number) *bootstrapped* sample sets of right censored data. For each of these generated sample sets, we can again estimate a `mu`, a `sigma`, and a `C_pl` using our MLE procedure. Then, by examining the spread of those `N` *bootstrapped* estimates with, say, a histogram, we get a qualitative sense of our estimating procedure’s sensitivity to the particular idiosyncrasies of the sample sets to which it is applied. In other words, we get a qualitative idea of the precision of out original point estimates.

![atl text](https://github.com/rileym/bootstrap/blob/master/bootstrappedCPlestimates.jpg)

To produce a concrete confidence interval of say, 95%, (computed for `mu`, `sigma`, or `C_pl`, but here let’s focus on `C_pl`) is the interval centered at the original MLE estimate (before bootstrapping) for `C_pl` with upper and lower bounds at a distance `l_95` from the center, where `l_95` is the 95th percentile absolute deviation of the bootstrapped estimates of `C_pl` to the original estimate of `C_pl`.

