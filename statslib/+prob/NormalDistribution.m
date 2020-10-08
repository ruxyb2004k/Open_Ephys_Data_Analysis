classdef NormalDistribution < prob.ToolboxFittableParametricDistribution
%NormalDistribution Normal probability distribution.
%    An object of the NormalDistribution class represents a normal
%    probability distribution with a specific mean MU and standard
%    deviation SIGMA. This distribution object can be created directly
%    using the MAKEDIST function or fit to data using the FITDIST function.
%
%    NormalDistribution methods:
%       cdf                   - Cumulative distribution function
%       icdf                  - Inverse cumulative distribution function
%       iqr                   - Interquartile range
%       mean                  - Mean
%       median                - Median
%       negloglik             - Negative log likelihood function
%       paramci               - Confidence intervals for parameters
%       pdf                   - Probability density function
%       proflik               - Profile likelihood function
%       random                - Random number generation
%       std                   - Standard deviation
%       truncate              - Truncation distribution to an interval
%       var                   - Variance
%
%    NormalDistribution properties:    
%       DistributionName      - Name of the distribution
%       mu                    - Value of the mu parameter (mean)
%       sigma                 - Value of the sigma parameter (standard deviation)
%       NumParameters         - Number of parameters
%       ParameterNames        - Names of parameters
%       ParameterDescription  - Descriptions of parameters
%       ParameterValues       - Vector of values of parameters
%       Truncation            - Two-element vector indicating truncation limits
%       IsTruncated           - Boolean flag indicating if distribution is truncated
%       ParameterCovariance   - Covariance matrix of estimated parameters
%       ParameterIsFixed      - Two-element boolean vector indicating fixed parameters
%       InputData             - Structure containing data used to fit the distribution
%
%    See also fitdist, makedist.

%    Copyright 2012-2019 The MathWorks, Inc.

    properties(Dependent=true)
%MU Mean of normal distribution
%    The MU property represents the parameter that is the mean of the
%    normal distribution.
%
%    See also SIGMA.
        mu
        
%SIGMA Standard deviation of normal distribution
%    The SIGMA property represents the parameter that is the standard
%    deviation of the normal distribution.
%
%    See also MU.
        sigma
    end
    properties(GetAccess='public',Constant=true)
%DistributionName Distribution name.
%    The DistributionName property indicates the name of the probability
%    distribution.
%
%    See also ParameterNames, ParameterValues.
        DistributionName = getString(message('stats:dfittool:NameNormal'));

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
        ParameterNames = {'mu' 'sigma'};

%ParameterDescription Parameter description.
%    ParameterNames is a cell array of strings containing short
%    descriptions of the parameters of the probability distribution.
%
%    See also ParameterNames, ParameterValues.
        ParameterDescription = {getString(message('stats:probdists:ParameterDescriptionLocation')) ...
                                getString(message('stats:probdists:ParameterDescriptionScale'))};
    end
    properties(GetAccess='public',SetAccess='protected')
%ParameterValues Parameter values.
%    ParameterVales is a vector containing the values of the parameters of
%    the probability distribution.
%
%    See also MU, SIGMA.
        ParameterValues
    end
    methods(Hidden)
        function pd = NormalDistribution(mu,sigma)
            if nargin==0
                mu = 0;
                sigma = 1;
            end
            checkargs(mu,sigma)

            pd.ParameterValues = [mu sigma];
            pd.ParameterIsFixed = [true true];
            pd.ParameterCovariance = zeros(pd.NumParameters);
        end
    end
    methods
        function m = mean(this)
            requireScalar(this)
            if this.IsTruncated
                m = truncatedMoment(this,1);
                return
            end
            m = this.mu;
        end
        function s = std(this)
            requireScalar(this)
            if this.IsTruncated
                v = truncatedMoment(this,2);
                s = sqrt(v);
                return
            end
            s = this.sigma;
        end
        function v = var(this)
            requireScalar(this)
            if this.IsTruncated
                v = truncatedMoment(this,2);
                return
            end
            v = this.sigma^2;
        end
        function ci = paramci(this,varargin)
            [varargin{:}] = convertStringsToChars(varargin{:});
            
            requireScalar(this)

            if isscalar(varargin) && isnumeric(varargin{1})
                % Support syntax of older ProbDistUnivParam/paramci method
                varargin = {'alpha' varargin{1}};
            end
            pnums = 1:this.NumParameters;
            if all(this.ParameterIsFixed)
                % Avoid calling Statistics and Machine Learning Toolbox functions
                for j=1:2:length(varargin)-1
                    vj = varargin{j};
                    if strncmpi(vj,'parameter',length(vj))
                        pnums = varargin{j+1};
                    end
                end
                pnums = pNamesToNums(this,pnums);
                ci = repmat(this.ParameterValues(pnums),2,1);
                return
            end
            okargs =   {'alpha' 'parameter' 'type' 'logflag'};
            defaults = {0.05,   pnums       'exact' []};
            [alpha,pnums,citype] = statslib.internal.parseArgs(okargs,defaults,varargin{:});
            if ~(isscalar(alpha) && isnumeric(alpha) && alpha>0 && alpha<1)
                error(message('stats:ecdf:BadAlpha'))
            end
            if isequal(citype,'exact')  && ~all(this.ParameterIsFixed)
                pnums = pNamesToNums(this,pnums);
                ci = dfswitchyard('statnormci',[this.mu this.sigma],this.ParameterCovariance,alpha,...
                            this.InputData.data,this.InputData.cens,this.InputData.freq);
                ci = ci(:,pnums);
            else
                ci = paramci@prob.ToolboxFittableParametricDistribution(this,varargin{:});
            end
        end
    end
    methods
        function this = set.mu(this,mu)
            checkargs(mu,this.sigma);
            this.ParameterValues(1) = mu;
            this = invalidateFit(this);
        end
        function this = set.sigma(this,sigma)
            checkargs(this.mu,sigma);
            this.ParameterValues(2) = sigma;
            this = invalidateFit(this);
        end
        function mu = get.mu(this)
            mu = this.ParameterValues(1);
        end
        function sigma = get.sigma(this)
            sigma = this.ParameterValues(2);
        end

    end
    methods(Static,Hidden)
        function pd = fit(varargin)
%FIT Fit distribution to data.
%    FIT is a static method that fits the normal distribution to data.
%    Fitting requires the Statistics and Machine Learning Toolbox. You
%    should call the FITDIST function instead of calling this method
%    directly.
%
%    See also FITDIST.

            if ~license('test','Statistics_Toolbox')
                error(message('stats:fitdist:NoLicense'))
            end
            
            [x,cens,freq,opt] = prob.ToolboxFittableParametricDistribution.processFitArgs(varargin{:});
            [m,s] = normfit(x,0.05,cens,freq,opt);
            p = [m s];
            [nll,cov] = normlike(p,x,cens,freq);
            pd = prob.NormalDistribution.makeFitted(p,nll,cov,x,cens,freq);
        end
        function varargout = likefunc(varargin)
            [varargout{1:nargout}] = normlike(varargin{:});
        end
        function [varargout] = cdffunc(x,varargin)
            if nargin>1 && strcmpi(varargin{end},'upper')
                uflag=true;
                varargin(end) = [];
            elseif nargin>1 && ischar(varargin{end})&& ~strcmpi(varargin{end},'upper')
                error(message('stats:cdf:UpperTailProblem'));
            else
                uflag=false;
            end
            [varargout{1:max(1,nargout)}] = localnormcdf(uflag,x,varargin{:});
            
            function [p,plo,pup] = localnormcdf(uflag,x,mu,sigma,pcov,alpha)
                if nargin < 3, mu = 0; end
                if nargin < 4, sigma = 1; end
                if nargout>1
                    if nargin<5
                        error(message('stats:normcdf:TooFewInputsCovariance'));
                    end
                    if ~isequal(size(pcov),[2 2])
                        error(message('stats:normcdf:BadCovarianceSize'));
                    end
                    if nargin<6
                        alpha = 0.05;
                    elseif ~isnumeric(alpha) || numel(alpha)~=1 || alpha<=0 || alpha>=1
                        error(message('stats:normcdf:BadAlpha'));
                    end
                end
                try
                    z = (x-mu) ./ sigma;
                    if uflag==true
                        z = -z;
                    end
                catch
                    error(message('stats:normcdf:InputSizeMismatch'));
                end
                % Prepare output
                p = NaN(size(z),class(z));
                if nargout>=2
                    plo = NaN(size(z),class(z));
                    pup = NaN(size(z),class(z));
                end
                % Set edge case sigma=0                
                if uflag==true
                    p(sigma==0 & x<mu) = 1;
                    p(sigma==0 & x>=mu) = 0;
                    if nargout>=2
                        plo(sigma==0 & x<mu) = 1;
                        plo(sigma==0 & x>=mu) = 0;
                        pup(sigma==0 & x<mu) = 1;
                        pup(sigma==0 & x>=mu) = 0;
                    end
                else
                    p(sigma==0 & x<mu) = 0;
                    p(sigma==0 & x>=mu) = 1;
                    if nargout>=2
                        plo(sigma==0 & x<mu) = 0;
                        plo(sigma==0 & x>=mu) = 1;
                        pup(sigma==0 & x<mu) = 0;
                        pup(sigma==0 & x>=mu) = 1;
                    end
                end
                % Normal cases
                if isscalar(sigma)
                    if sigma>0
                        todo = true(size(z));
                    else
                        return;
                    end
                else
                    todo = sigma>0;
                end
                z = z(todo);
                % Use the complementary error function, rather than .5*(1+erf(z/sqrt(2))),
                % to produce accurate near-zero results for large negative x.
                p(todo) = 0.5 * erfc(-z ./ sqrt(2));
                % Compute confidence bounds if requested.
                if nargout>=2
                    zvar = (pcov(1,1) + 2*pcov(1,2)*z + pcov(2,2)*z.^2) ./ (sigma.^2);
                    if any(zvar<0)
                        error(message('stats:normcdf:BadCovarianceSymPos'));
                    end
                    normz = sqrt(2).*erfcinv(alpha);
                    halfwidth = normz * sqrt(zvar);
                    zlo = z - halfwidth;
                    zup = z + halfwidth;
                    plo(todo) = 0.5 * erfc(-zlo./sqrt(2));
                    pup(todo) = 0.5 * erfc(-zup./sqrt(2));
                end
            end
        end      
        function y = pdffunc(x,mu,sigma)
            if nargin<2, mu = 0; end
            if nargin<3, sigma = 1; end
            % Return NaN for out of range parameters.
            sigma(sigma <= 0) = NaN;
            try
                y = exp(-0.5 * ((x - mu)./sigma).^2) ./ (sqrt(2*pi) .* sigma);
            catch
                error(message('stats:normpdf:InputSizeMismatch'));
            end
        end
        function [x,varargout] = invfunc(p,mu,sigma,varargin)
            if nargin>3
                [x,varargout{1:nargout-1}] = norminv(p,mu,sigma,varargin{:});
                return
            end
            if nargin<2, mu = 0; end
            if nargin<3, sigma = 1; end
            sigma(sigma <= 0) = NaN;
            p(p < 0 | 1 < p) = NaN;
            x0 = -sqrt(2).*erfcinv(2*p);
            try
                x = mu + sigma.*x0;
            catch
                error(message('stats:norminv:InputSizeMismatch'));
            end
        end
        function x = randfunc(mu,sigma,varargin)
            if nargin<3, varargin = {1}; end
            t = mu + sigma.*zeros(varargin{:});
            x = mu + sigma.*randn(size(t));
        end
        function pd = makeFitted(p,nll,cov,x,cens,freq)
            pd = prob.NormalDistribution(p(1),p(2));
            pd.NegativeLogLikelihood = nll;
            pd.ParameterCovariance = cov;
            pd.ParameterIsFixed = [false false];
            pd.InputData = struct('data',x,'cens',cens,'freq',freq);
        end
        function info = getInfo
            info = getInfo@prob.ToolboxDistribution('prob.NormalDistribution');
            info.name = getString(message('stats:dfittool:NameNormal'));
            info.code = 'normal';
            info.hasconfbounds = true;
            info.censoring = true;
            info.islocscale = true;
            info.logci = [false true];
        end
        function name = matlabCodegenRedirect(~) % we need the output to be assigned so that we can reach a more helpful error message below
                         name = 'prob.coder.NormalDistribution';
        end
    end
end % classdef

function checkargs(mu,sigma)
if ~(isscalar(mu) && isnumeric(mu) && isreal(mu) && isfinite(mu))
    error(message('stats:probdists:ScalarParameter','MU'))
end
if ~(isscalar(sigma) && isnumeric(sigma) && isreal(sigma) && sigma>=0 && isfinite(sigma))
    error(message('stats:probdists:NonnegativeParameter','SIGMA'))
end
end
