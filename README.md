# bootstrap

I wrote this demo -- based off a question an engineering friend ask me -- for a class I TAed at Stanford. At that time I had acess to Matlab and its optimization module. I no longer have access to matlab (the fmincon function, in particular) and cannot test the demo nor produce the plots.

http://en.wikipedia.org/wiki/Process_capability_index

Process capability indicies compare allowable process output error, or diviation from some target value, to the estimated variation of that output. That is perhaps a crude charaterizaion, but for the purposes of the demo it's sufficient to understand the PCI as some statistic of interest which is determined by the estimated mean and variance of the process output (which is assumed to be normally distributed.

The goal of the exercise is to take some process output data and produce (1) an estimate the (lower bound) process capability index (C_pl =  mu_hat - LSL / 3 sigma_hat ) and (2) a confidence interval for this estimate. Just for fun, we throw in a further complication: the process output data is right cencserd. This detail was actually part of the question my engineering friend origianlly asked me. The device she used to measure the process output had a max reading which was at least equaled by a number output samples. The difficulty of the exercise is twofold: firstly, how to compute the estimated mean and variance for the underlying process output when you only have access to the right censored reading; and secondly, how to compute a confidence interval for the C_pl statistic.

MLE of the mean and variance of the underling proce