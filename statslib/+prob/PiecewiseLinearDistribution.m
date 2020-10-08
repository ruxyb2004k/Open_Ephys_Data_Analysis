classdef PiecewiseLinearDistribution < prob.ParametricDistribution & ...
                                       prob.TruncatableDistribution
%PiecewiseLinearDistribution Piecewise linear probability distribution.
%    An object of the PiecewiseLinearDistribution class represents a
%    distribution with a cumulative distribution function composed of
%    piecewise linear segments, or equivalently, a probability density that
%    is a step function. This distribution object can be created using the
%    MAKEDIST function.
%
%    PiecewiseLinearDistribution methods:
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
%    PiecewiseLinearDistribution properties:    
%       x                     - Vector of values at which the cdf changes slope
%       Fx                    - Vector of cdf values at each x value
%       DistributionName      - Name of the distribution
%       NumParameters         - Number of parameters
%       ParameterNames        - Names of parameters
%       ParameterDescription  - Descriptions of parameters
%       ParameterValues       - Vector of values of parameters
%       Truncation            - Two-element vector indicating truncation limits
%       IsTruncated           - Boolean flag indicating if distribution is truncated
%
%    See also makedist.

%   Copyright 2012-2016 The MathWorks, Inc.

    properties(Dependent)
%x Values at which the cdf changes slope.
%   x is a vector of the values at which the cdf changes slope. The
%   piecewise linear distribution is defined by two properties x and Fx.
%   The cdf between x(J) and x(J+1) increases linearly from Fx(J) to
%   Fx(J+1), for all J. 
%
%   See also Fx.
    x = []
        
%Fx Values of the cdf values at each x value.
%   Fx is a vector of the values of the cdf at each value of x. The
%   piecewise linear distribution is defined by two properties x and Fx.
%   The cdf between x(J) and x(J+1) increases linearly from Fx(J) to
%   Fx(J+1), for all J. 
%
%   See also x.
        Fx = []
    end
    properties(GetAccess=public, Constant)
        DistributionName = getString(message('stats:probdists:DistNamePiecewiseLinear'));
    end
    properties(GetAccess='public',Constant=true)
%NumParameters Number of parameters in the distribution.
%   NumParameters is a positive integer indicating the number of parameters
%   in the distribution. This number includes all fixed and estimated
%   parameters.
%
%   See also ParameterValues, ParameterNames, ParameterDescription.
        NumParameters = 2;

%ParametersNames Names of the parameters in the distribution.
%   ParametersNames is a cell array or strings containing the names of the
%   parameters in the distribution.
%
%   See also ParameterValues, NumParameters, ParameterDescription.
        ParameterNames = {'x' 'Fx'};

%ParametersDescription Description of the parameters in the distribution.
%   ParametersDescription is a cell array or strings containing the short
%   descriptions of the parameters in the distribution.
%
%   See also ParameterValues, ParameterNames, NumParameters.
        ParameterDescription = {'x' 'cdf = F(x)'};
    end
    
    properties(GetAccess='public',SetAccess='protected')
%ParameterValues Values of the parameters in the distribution.
%   ParametersValues is a two-element cell array containing x values in the
%   first cell and cdf values F(x) in the second cell.
%
%   See also ParameterNames, NumParameters, ParameterDescription.
        ParameterValues = zeros(2,0)
    end
    
    methods(Hidden)
        function pd = PiecewiseLinearDistribution(x,Fx)
            if nargin==0
                x = [0 1];
                Fx = [0 1];
            end
            checkParams(x,Fx);
            pd.ParameterValues = {x(:)', Fx(:)'};
        end
    end
    methods
        function m = mean(this)
            requireScalar(this)
            if this.IsTruncated
                m = truncatedMoment(this,1);
                return
            end
            means = (this.x(1:end-1)+this.x(2:end))/2;
            probs = diff(this.Fx);
            
            % Compute the mean as a linear combination of the means of each
            % part
            m = dot(probs,means);
        end
        function v = var(this)
            requireScalar(this);
            if this.IsTruncated
                v = truncatedMoment(this,2);
                return
            end
            means = (this.x(1:end-1)+this.x(2:end))/2;
            probs = diff(this.Fx);
            vars = diff(this.x).^2/12;
            m = dot(probs,means);
            
            % Compute the variance by combining variance and bias for the
            % two parts
            v = dot(probs,vars+(means-m).^2);
        end
        function x = get.x(this)
            x = this.ParameterValues{1};
        end
        function this = set.x(this,x)
            checkParams(x,this.Fx);
            this.ParameterValues{1} = x(:)';
        end
        function Fx = get.Fx(this)
            Fx = this.ParameterValues{2};
        end
        function this = set.Fx(this,Fx)
            checkParams(this.x,Fx);
            this.ParameterValues{2} = Fx(:)';
        end

    end
    methods(Access=protected)
        function y = randomfun(obj,varargin)
            requireScalar(obj);
            p = rand(varargin{:});
            y = zeros(size(p),class(p));
            [~,bin] = histc(p(:)',obj.Fx);
            y0 = obj.x(bin);
            dx = diff(obj.x);
            dF = diff(obj.Fx);
            dy = (p(:)' - obj.Fx(bin)) .* dx(bin) ./ dF(bin);
            y(:) = y0 + dy;
        end
        function y = pdffun(obj,xin)
            requireScalar(obj);
            [~,bin] = histc(xin,[-Inf,obj.x,Inf]);
            % histc will create an extra bucket for any finite values 
            % xin that are greater than or equal to max(obj.x).  It 
            % will create an additional bucket for Inf values, if 
            % any are present.  In either of these cases, the value
            % of the pdf should be zero.
            lx = length(obj.x);
            bin(bin>lx) = lx+1;
            y = zeros(size(xin),class(xin));
            binp = [0,diff(obj.Fx)./diff(obj.x),0];
            y(bin>0) = binp(bin(bin>0));
            y(isnan(xin)) = NaN;
        end
        function y = cdffun(obj,xin,uflag)
            requireScalar(obj);
            y = zeros(size(xin),class(xin));
            t = (xin>=obj.x(1) & xin<=obj.x(end));
            y(t) = interp1(obj.x,obj.Fx,xin(t),'linear');
            y(xin>obj.x(end)) = 1;
            y(isnan(xin)) = NaN;
            if nargin==3
                if ~strcmpi(uflag,'upper')
                    error(message('stats:cdf:UpperTailProblem'));
                else
                    y = 1 - y;
                end
            end
        end
        function y = icdffun(obj,p)
            requireScalar(obj);
            pint = obj.Fx;
            xint = obj.x;
            diffp = diff(pint);
            if any(diffp==0)
                % remove consecutive bins with near-zero probability
                epsp = 2*eps(pint);
                same = diffp <= epsp(1:end-1);
                t = same(1:end-1) & same(2:end);
                while(any(t))
                    idx = find(t);
                    same(idx) = [];
                    pint(idx+1) = [];
                    xint(idx+1) = [];
                    diffp = diff(pint);
                    t = same(1:end-1) & same(2:end);
                end
                idx = find(diffp==0);
                pint(idx+1) = pint(idx) + eps(pint(idx));
            end
            p(p < 0 | 1 < p) = NaN;
            y = interp1(pint,xint,p,'linear');
        end
        function displayCallback(obj)
            for j=1:length(obj.x)
                fprintf('F(%g) = %g\n',obj.x(j),obj.Fx(j));
            end
        end
    end
end % classdef

function checkParams(x,Fx)
if numel(x)~=numel(Fx)
    error(message('stats:probdists:BadPiecewiseLength'));
end
if ~(isvector(x) && isnumeric(x) && isreal(x) && all(isfinite(x)) && all(diff(x)>0))
    error(message('stats:probdists:BadPiecewiseX'));
end
if ~(isequal(size(x),size(Fx)) && isnumeric(Fx) && isreal(Fx) && all(isfinite(Fx)) && all(diff(Fx)>=0) && Fx(1)==0 && Fx(end)==1)
    error(message('stats:probdists:BadPiecewiseF'));
end
end

