classdef FittableDistribution
%FittableDistribution Base class for fittable probability distributions.
    
%   Copyright 2012 The MathWorks, Inc.

    properties(GetAccess='public',SetAccess='protected')
%InputData Input data used in fitting distribution.
%    InputData is a struct specifying the data used to fit the
%    distribution. The struct has the following fields:
%
%      'data'  Data vector
%      'cens'  Censoring vector, or empty if none
%      'freq'  Frequency vector, or empty if none
%
%    See also fitdist.
        InputData = [];

    end
    methods
        function v = negloglik(pd)
%NEGLOGLIK Negative log likelihood.
%    NEGLOGLIK returns the value of the negative log likelihood
%    function for the data used to fit the distribution.
%
%    Example: Demonstrate that the Weibull distribution, which is more
%             flexible than the exponential distribution, produces a fit
%             with a lower negative log likelihood (higher likelihood).
%        load carsmall
%        p = fitdist(MPG,'Weibull');
%        wnll = negloglik(p)
%        q = fitdist(MPG,'exponential');
%        enll = negloglik(q)
%
%    See also fitdist.
            if ~isempty(pd.NegativeLogLikelihood)
                v = pd.NegativeLogLikelihood;
                return
            elseif isempty(pd.InputData) || isempty(pd.InputData.data)
                v = [];
                return
            end
            x = pd.InputData.data;
            c = pd.InputData.cens;
            f = pd.InputData.freq;
            if isempty(f)
                f = ones(size(x));
            end
            if isempty(c)
                c = false(size(x));
            else
                c = logical(c);
            end
            
            v = 0;
            if any(c) % compute log survivor function for censoring points
                v = v - sum(f(c) .* log(1-cdf(pd, x(c))));
            end
            if any(~c) % compute log pdf for observed data
                v = v - sum(f(~c) .* log(pdf(pd,x(~c))));
            end
        end
    end
    methods(Static,Hidden,Abstract)
        pd = fit(x,varargin);
    end
    properties(Access=protected)
        NegativeLogLikelihood = []
    end
end % classdef
