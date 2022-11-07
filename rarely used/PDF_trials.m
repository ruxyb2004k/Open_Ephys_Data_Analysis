%% example creating a distribution

mu = 0;
sigma = 1;
pd = makedist('Normal','mu',mu,'sigma',sigma);

%Define the input vector x to contain the values at which to calculate the pdf.

% x = [-2 -1 0 1 2];
x = -3:.1:3;

%Compute the probability density function values for the standard normal distribution at the values in x.
y = pdf(pd,x);

%Compute the cumulative density function values for the standard normal distribution at the values in x.
z = cdf(pd,x);

figure;
plot(x,y); hold on
plot(x,z)

%% example create a normal population
mu = 0;
sigma = 1;
r1 = normrnd(mu,sigma,50,1);
r2 = normrnd(mu,sigma,50,1);
mean(r1);
std(r1);
[h,p] = kstest2(r1,r2) % compare two normal populations; h = 1 if the two distributions are different
%% real data

z1=sortOIndexAllStimBase(2, :, 2);
z2=sortOIndexAllStimBase(2, :, 4);

x = -1:.1:1; % OI values

mu = nanmean(z1);
sigma = nanstd(z1);
pd1 = makedist('Normal','mu',mu,'sigma',sigma);
y1 = pdf(pd1,x);

mu = nanmean(z2);
sigma = nanstd(z2);
pd2 = makedist('Normal','mu',mu,'sigma',sigma);
y2 = pdf(pd2,x);

figure;
plot(x,y1); hold on
plot(x,y2)

[h,p] = kstest(z1) % h = 1 if mean of distribution is different than 0 (distribution can still be normal)
[h,p] = kstest(z2)
[h,p] = kstest2(z1,z2) % h=1 if the two distributions are different
