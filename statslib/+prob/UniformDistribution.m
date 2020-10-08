classdef UniformDistribution < prob.ToolboxParametricDistribution
%UniformDistribution Uniform probability distribution.
%    An object of the UniformDistribution class represents a uniform
%    probability distribution with a lower limit Lower and upper
%    limit Upper. This distribution object can be created directly
%    using the MAKEDIST function.
%
%    UniformDistribution methods:
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
%    UniformDistribution properties:    
%       DistributionName      - Name of the distribution
%       Lower                 - Value of the Lower parameter (lower limit)
%       Upper                 - Value of the Upper parameter (upper limit)
%       NumParameters         - Number of parameters
%       ParameterNames        - Names of parameters
%       ParameterDescription  - Descriptions of parameters
%       ParameterValues       - Vector of values of parameters
%       Truncation            - Two-element vector indicating truncation limits
%       IsTruncated           - Boolean flag indicating if distribution is truncated
%
%    See also makedist.
    
%    Copyright 2012-2013 The MathWorks, Inc.

    properties(Dependent=true)
%Lower Lower limit of uniform distribution
%    The Lower property represents the parameter that is the lower limit
%    of the uniform distribution.
%
%    See also Upper.
        Lower = 0;

%Upper Upper limit of uniform distribution
%    The Upper property represents the parameter that is the upper limit
%    of the uniform distribution.
%
%    See also Lower.
        Upper = 1
    end
    properties(GetAccess='public',Constant=true)
%DistributionName Distribution name.
%    The DistributionName property indicates the name of the probability
%    distribution.
%
%    See also ParameterNames, ParameterValues.
        DistributionName = getString(message('stats:dfittool:NameUniform'));

%NumParameter Number of parameters.
%    NumParameters is the number of parameters in the distribution.
%
%    See also ParameterValues. 
        NumParameters = 2;

%ParameterNames Parameter names.
%    ParameterNames is a cell array of strings containing the names of the
%    parameters of the probability distribution.
%
%    See also ParameterValues, ParameterDescription.
        ParameterNames = {'Lower' 'Upper'};

%ParameterDescription Parameter description.
%    ParameterNames is a cell array of strings containing short
%    descriptions of the parameters of the probability distribution.
%
%    See also ParameterNames, ParameterValues.
        ParameterDescription = {getString(message('stats:probdists:ParameterDescriptionLower')) ...
                                getString(message('stats:probdists:ParameterDescriptionUpper'))};
    end
    properties(GetAccess='public',SetAccess='protected')
%ParameterValues Parameter values.
%    ParameterVales is a vector containing the values of the parameters of
%    the probability distribution.
%
%    See also Lower, Upper.
        ParameterValues
    end
    methods(Hidden)
        function pd = UniformDistribution(lower,upper)
            if nargin==0
                lower = 0;
                upper = 1;
            end
            checkargs(lower,upper)
            
            pd.ParameterValues = [lower upper];
        end
    end
    methods
        function m = mean(this)
            requireScalar(this)
            if this.IsTruncated
                m = truncatedMoment(this,1);
                return
            end
            if sign(this.Upper) == sign(this.Lower)
                m = this.Lower + (this.Upper-this.Lower)/2;
            else
                m = this.Upper/2 + this.Lower/2;
            end
        end
        function v = var(this)
            requireScalar(this)
            if this.IsTruncated
                v = truncatedMoment(this,2);
                return
            end
            v = (this.Upper/sqrt(12)-this.Lower/sqrt(12))^2;
        end
        function this = set.Lower(this,Lower)
            checkargs(Lower,this.Upper)
            this.ParameterValues(1) = Lower;
        end
        function this = set.Upper(this,Upper)
            checkargs(this.Lower,Upper)
            this.ParameterValues(2) = Upper;
        end
        function Lower = get.Lower(this)
            Lower = this.ParameterValues(1);
        end
        function Upper = get.Upper(this)
            Upper = this.ParameterValues(2);
        end
    end
    methods(Static,Hidden)
        function p = cdffunc(x,varargin)
            if nargin>1 && strcmpi(varargin{end},'upper')
                %Compute upper tail and remove 'upper' flag
                uflag=true;
                varargin(end) = [];
            elseif nargin>1 && ischar(varargin{end})&& ~strcmpi(varargin{end},'upper')
                error(message('stats:cdf:UpperTailProblem'));
            else
                uflag=false;
            end
            p = localunifcdf(x,uflag,varargin{:});
            
            function p = localunifcdf(x,uflag,a,b)
                if nargin <3
                    a = 0;
                    b = 1;
                end
                % check inputs
                vin={x,a,b};
                vout = vin;
                isscalar = (cellfun('prodofsize',vin) == 1);
                if all(isscalar)
                    [x,a,b]=vout{:};
                else
                    for j=1:3
                        sz{j} = size(vin{j});
                    end
                    t = sz(~isscalar);
                    size1 = t{1};
                    % Scalars receive this size.  Other arrays must have the proper size.
                    for j=1:3
                        sizej = sz{j};
                        if (isscalar(j))
                            vj = vin{j};
                            if isnumeric(vj)
                                t = zeros(size1,class(vj));
                            else
                                t = zeros(size1);
                            end
                            t(:) = vin{j};
                            vout{j} = t;
                        elseif (~isequal(sizej,size1))
                            error(message('stats:unifcdf:InputSizeMismatch'));
                        end
                    end
                    [x,a,b]=vout{:};
                end              
                % Initialize P to zero.
                if isa(x,'single') || isa(a,'single') || isa(b,'single')
                    p = zeros(size(x),'single');
                else
                    p = zeros(size(x));
                end
                k = find(x > a & x < b & a < b);
                if  uflag == true
                    %Compute upper tail
                    p(x <= a & a < b) = 1;
                    p(x >= b & a < b) = 0;
                    if any(k)
                        p(k) = (b(k)- x(k)) ./ (b(k) - a(k));
                    end
                else
                    % (1) x <= a and a < b.
                    p(x <= a & a < b) = 0;
                    % (2) x >= b and a < b.
                    p(x >= b & a < b) = 1;
                    % (3) a < x < b.
                    if any(k)
                        p(k) = (x(k) - a(k)) ./ (b(k) - a(k));
                    end
                end
                % (4) a >= b then set p to NaN.
                p(a >= b) = NaN;
                % (5) If x or a or b is NaN, set p to NaN.
                p(isnan(x) | isnan(a) | isnan(b)) = NaN;
            end
        end
        function y = pdffunc(x,a,b)
            if nargin == 1 % default parameter values
                a = 0;
                b = 1;
            end
            try
                temp = (1 ./ (b-a)) + (0*x);
            catch
                error(message('stats:unifrnd:InputSizeMismatch'));
            end
            if isa(x,'single') || isa(a,'single') || isa(b,'single')
                y = zeros(size(temp),'single');
            else
                y = zeros(size(temp));
            end
            
            if ~isscalar(a) || ~isscalar(b)
                y(a >= b) = NaN;
            elseif a > b
                y(:) = NaN;
            end
            k = find(x >= a & x <= b & a < b);
            if any(k)
                y(k) = temp(k);
            end
            
            % Pass NaN inputs through to outputs
            y(isnan(x)|isnan(a)|isnan(b)) = NaN;
        end
        function x = invfunc(p,a,b)
            if nargin == 1 % default parameter values
                a = 0;
                b = 1;
            end
            try
                temp = a + p.*(b-a);
            catch
                error(message('stats:unifrnd:InputSizeMismatch'));
            end
            if isa(p,'single') || isa(p,'single') || isa(p,'single')
                x = zeros(size(temp),'single');
            else
                x = zeros(size(temp));
            end
            
            x(a >= b | p < 0 | p > 1) = NaN;

            k = find(~(a >= b | p < 0 | p > 1));
            if any(k)
                % entire temp array is computed in a way that works for
                % scalar or vector parameters, now extract the useful part
                x(k) = temp(k);
            end
            
            % Pass NaN inputs through to outputs
            x(isnan(p)|isnan(a)|isnan(b)) = NaN;
        end
        function r = randfunc(a,b,varargin)
            if nargin == 1 % default parameter values
                a = 0;
                b = 1;
            end
            % Avoid    a+(b-a)*rand   in case   a-b > realmax
            a2 = a/2;
            b2 = b/2;
            mu = a2+b2;
            sig = b2-a2;
            
            szab = size(mu);
            if nargin<3
                varargin = {szab}; % take size from sizes of a and b inputs
            end
            r = rand(varargin{:});
            if ~isscalar(mu)
                % make sure sizes are compatible
                if ~isequal(size(r),szab)
                    error(message('stats:unifrnd:InputSizeMismatch'));
                end
            end
            r = mu + sig .* (2*r-1);
            
            % Fill in elements corresponding to illegal parameter values
            if ~isscalar(a) || ~isscalar(b)
                r(a > b) = NaN;
            elseif a > b
                r(:) = NaN;
            end
        end
        function info = getInfo
            info = getInfo@prob.ToolboxDistribution('prob.UniformDistribution');
            info.name = prob.UniformDistribution.DistributionName;
            info.code = 'uniform';
            info.closedbound = [true true];
        end
    end
end % classdef

function checkargs(lower,upper)
if ~(isscalar(lower) && isnumeric(lower) && isreal(lower) && isfinite(lower))
    error(message('stats:probdists:ScalarParameter','Lower'))
end
if ~(isscalar(upper) && isnumeric(upper) && isreal(upper) && isfinite(upper))
    error(message('stats:probdists:ScalarParameter','Upper'))
end
if ~(lower<upper)
    error(message('stats:probdists:LowerLTUpper','Lower','Upper'))
end
end
