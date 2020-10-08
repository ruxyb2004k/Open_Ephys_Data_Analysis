classdef MultinomialDistribution < prob.ParametricDistribution & ...
                                   prob.TruncatableDistribution
%MultinomialDistribution Multinomial probability distribution.
%    An object of the MultinomialDistribution class represents a multinomial
%    probability distribution with a single random trial.  The distribution
%    is specified by a vector of probabilities which sum to one.  The vector
%    of probabilities are stored in the class property Probabilities.
%    The outcome of one trial of MultinomialDistribution is an integer
%    in the range 1 to K, where K = length(Probabilities).  That is, the 
%    distribution is assumed to have K possible outcome values, on 
%    support 1:K, and each random trial produces one of these outcome
%    values, weighted according the the parameter Probabilities.  This
%    distribution object can be created directly using the MAKEDIST function.
%    This distribution cannot be fit to data.
%
%    MultinomialDistribution methods:
%       cdf                   - Cumulative distribution function
%       icdf                  - Inverse cumulative distribution function
%       iqr                   - Interquartile range
%       mean                  - Mean
%       median                - Median
%       pdf                   - Probability density function
%       random                - Random number generation
%       std                   - Standard deviation
%       truncate              - Truncation distribution to an interval
%       var                   - Variance
%
%    MultinomialDistribution properties:    
%       Probabilities         - Value of the probability of all multinomial categories
%       DistributionName      - Name of the distribution
%       NumParameters         - Number of parameters
%       ParameterNames        - Names of parameters
%       ParameterDescription  - Descriptions of parameters
%       ParameterValues       - Vector of values of parameters
%       Truncation            - Two-element vector indicating truncation limits
%       IsTruncated           - Boolean flag indicating if distribution is truncated
%
%    See also fitdist, makedist.

%   Copyright 2012-2014 The MathWorks, Inc.

    properties(Dependent=true)
%Probabilities Outcome probabilities
%    The Probabilities property represents the parameter that is the vector of 
%    class probabilities for a multinomial distribution.  Probabilities is a
%    vector and Probabilities(I) is the probability that a multinomial trial
%    has outcome I.  The values of Probabilities must sum to 1.
        Probabilities
    end
    properties(GetAccess='public',Constant=true)
%DistributionName Distribution name.
%    The DistributionName property indicates the name of the probability
%    distribution.
%
%    See also ParameterNames, ParameterValues.
        DistributionName = getString(message('stats:probdists:DistNameMultinomial'));

%NumParameter Number of parameters.
%    NumParameters is the number of parameters in the distribution.
%
%    See also ParameterValues.
        NumParameters = 1;

%ParameterNames Parameter names.
%    ParameterNames is a cell array of strings containing the names of the
%    parameters of the probability distribution.
%
%    See also ParameterValues, ParameterDescription.
        ParameterNames = {'Probabilities'};

%ParameterDescription Parameter description.
%    ParameterNames is a cell array of strings containing short
%    descriptions of the parameters of the probability distribution.
%
%    See also ParameterNames, ParameterValues.
        ParameterDescription = {getString(message('stats:probdists:ParameterDescriptionMultinomialProbabilities'))};
    end
    
    properties(GetAccess='public',SetAccess='protected')
%ParameterValues Parameter values.
%    ParameterVales is a vector containing the values of the parameters of
%    the probability distribution.
%
%    See also Probabilities
        ParameterValues
    end
    
    methods(Hidden)
        function pd = MultinomialDistribution(p)
            % p must be a vector of non-negative real values that sum to 1.
            if nargin==0
                p = [0.5 0.5];
            end
            pd.ParameterValues = {checkargs(p)};
        end
    end
    methods
        function m = mean(this)
            requireScalar(this)
            if this.IsTruncated
                x = 1:length(this.Probabilities);
                inbound = ((x >= this.Truncation(1)) & (x <= this.Truncation(2)));
                x = x(inbound);
                p = pdf(this,x);
                m = sum(p .* x);
                return
            end
            m = sum(this.Probabilities .* (1:length(this.Probabilities)));
        end
        function v = var(this)
            requireScalar(this)
            if this.IsTruncated
                x = 1:length(this.Probabilities);
                inbound = ((x >= this.Truncation(1)) & (x <= this.Truncation(2)));
                x = x(inbound);
                p = pdf(this,x);
                m = sum(p .* x);
                v = sum(p .* (x-m).^2);
                return
            end
            v = sum(this.Probabilities .* (1:length(this.Probabilities)).^2) - mean(this)^2;
        end
        function this = set.Probabilities(this,p)
            this.ParameterValues = {checkargs(p)};
        end
        function p = get.Probabilities(this)
            p = this.ParameterValues{1};
        end
    end
    methods(Access=protected)
        function p = cdffun(this,xin,uflag)
            if ~isreal(xin)
                error(message('stats:probdists:BadCDFValue'));
            end                
            requireScalar(this);
            missing = isnan(xin);
            s = size(xin);
            x = floor(xin);
            k = length(this.Probabilities);
            c = cumsum(this.Probabilities);
            % Protect against round-off in the cumsum
            c(end) = cast(1.0,class(c));
            x(x > k) = k;
            x(x < 1) = 1;
            % This gives spurious values for p but they will be overwritten ...
            x(missing) = 1;
            p = c(x);
            p(xin < 1) = 0;
            % ... here
            p(missing) = NaN;
            p = reshape(p,s);
            if nargin==3
                if ~strcmpi(uflag,'upper')
                    error(message('stats:cdf:UpperTailProblem'));
                else
                    p = 1 - p;
                end
            end
        end
        function y = pdffun(this,x)
            requireScalar(this);
            s = size(x);
            missing = isnan(x);
            outofrange = (x<1 | x>length(this.Probabilities) | (x-floor(x))>0) | missing;
            ix = x;
            ix(outofrange) = 1;
            y = this.Probabilities(ix);
            y(outofrange) = 0;
            y(missing) = NaN;
            y = reshape(y,s);
        end
        function q = icdffun(this,p)
            if ~isreal(p)
                error(message('stats:probdists:BadCDFValue'));
            end                
            requireScalar(this);
            s = size(p);
            p = p(:);
            q = zeros(numel(p),1);
            c = cumsum(this.Probabilities);
            c = [0 c(1:(end-1))];
            missing = isnan(p);
            p(missing) = 0;
            for i=1:length(c)
                q(p>c(i)) = i;
            end
            q(p>1) = NaN;
            q(p<0) = NaN;
            q(p==0) = 1;
            q(missing) = NaN;
            q = reshape(q,s);
        end
        function y = randomfun(this,varargin)
            requireScalar(this);
            r = zeros(varargin{:});
            n = numel(r);
            s = size(r);
            clear r;
            edges = min([0 cumsum(this.Probabilities)],1); % protect against accumulated round-off
            edges(end) = 1; % get the upper edge exact
            [~, y] = histc(rand(n,1),edges);
            y = reshape(y,s);
        end
        function displayCallback(this)
            fprintf('  Probabilities:\n');
            disp(this.Probabilities)
        end
    end
end % classdef

function p = checkargs(p)
if ~(isvector(p) && isnumeric(p) && isreal(p) && all(p>=0)) 
    error(message('stats:probdists:BadMultinomialProbabilities'))
end
% Test for sum to one, allowing for round-off in the sum.
if abs(sum(p)-1) > eps(class(p))*length(p)
    error(message('stats:probdists:BadMultinomialProbabilities'))
elseif sum(p) ~= 1
    p(end) = 1 - sum(p(1:end-1));
end
p = p(:)';
end
