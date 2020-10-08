classdef UnivariateDistribution < prob.ProbabilityDistribution
%UnivariateDistribution Univariate probability distribution.

%   Copyright 2012 The MathWorks, Inc.

    methods(Abstract = true)
        % Method added for univariate class
        [varargout] = icdf(varargin)
    end

    methods
        % Simple implementation often overridden in derived class
        function y = random(this,varargin)
%RANDOM Random number generation.
%    R = RANDOM(P) generates a random number R from the probability
%    distribution P.
%
%    R = RANDOM(P,M,N,...) or R = RANDOM(P,[M,N,...]) creates an
%    M-by-N-by-... array R of independent random numbers from P.
%
%    Example: Generate normal random variables with mean 100 and standard
%             deviation 10.
%        p = makedist('normal', 'mu',100, 'sigma',10)
%        x = random(p,1000,1);
%        hist(x,40)
%
%    See also FITDIST, MAKEDIST.
            requireScalar(this);
            y = icdf(this,rand(varargin{:}));
        end

        % Methods suitable for univariate classes
        function y = median(this)
%MEDIAN Median.
%    M = MEDIAN(P) computes the median M for the probability distribution
%    P. M is the value such that half of the probabilty is below M and half
%    is above.
%
%    Example: Create a Weibull distribution and demonstrate that its mean
%             is larger than its median.
%        p = makedist('weibull', 'A',200, 'B',1.1)
%        wmean = mean(p)
%        wmedian = median(p)
%
%    See also IQR, ICDF.
            y = icdf(this,.5);
        end
        function y = iqr(this)
%IQR Interquartile range.
%    R = IQR(P) computes the interquartile range R for the probability
%    distribution P. R is the difference between the 75th and 25th
%    percentage points of P.
%
%    Example: Compute the interquartile range for the normal and t
%             distributions with the same location and scale parameters.
%        p = makedist('normal', 'mu',100, 'sigma',10)
%        niqr = iqr(p)
%        q = makedist('tlocationscale', 'mu',100, 'sigma',10, 'nu',5)
%        tiqr = iqr(q)
%
%    See also MEDIAN, ICDF.
            y = icdf(this,.75) - icdf(this,.25);
        end
    end
end % classdef
