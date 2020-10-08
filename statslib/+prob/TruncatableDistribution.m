classdef TruncatableDistribution < prob.UnivariateDistribution
%TruncatableDistribution Interface for truncatable distributions.
    
%   Copyright 2012-2018 The MathWorks, Inc.

    properties(GetAccess='public',SetAccess='protected')
%Truncation - Two-element vector defining the truncation interval.
%    Truncation is a two-element vector of the form [LOWER,UPPER]
%    indicating that the distribution is truncated to the interval with
%    lower limit LOWER and upper limit UPPER. For an untruncated
%    distribution, the vector is [-Inf,Inf]. The TRUNCATE method sets the
%    Truncation property.
%
%    See also truncate, IsTruncated.
        Truncation = [];
    end
    properties(Dependent=true,GetAccess='public',SetAccess='protected')
%IsTruncated - Boolean indicating if the distribution is truncated.
%    IsTruncated is true if the distribution is truncated to a subset of
%    the real line, or false if it is not.
%
%    See also truncate, Truncation.
        IsTruncated;
    end

    methods(Access=protected,Abstract = true)
        % The TruncatableDistribution class implements the methods below
        % and provides support for truncation. These implementations use a
        % template pattern that expects a derived class to implement a hook
        % or callback to perform the basic (untruncated) calculation:
        %    Method        Hook
        %    pdf           pdffun
        %    cdf           cdffun
        %    icdf          icdffun
        %    random        randomfun
        y = icdffun(this,x)
        y = cdffun(this,x)
        y = pdffun(this,x)
        y = randomfun(this,x,varargin)
    end    
    
    methods
        % New methods for this class
        function td = truncate(this,lower,upper)
%TRUNCATE Truncate probability distribution to an interval.
%    T = TRUNCATE(P,LOWER,UPPER) takes a probability distribution P and
%    returns another probability distribution T that represents P
%    truncated to the interval with lower limit LOWER and upper limit
%    UPPER. The pdf of T is zero outside the interval. Inside the
%    interval it is equal to the pdf of P, but divided by the probability
%    assigned to that interval by P.
%
%    Example: Create normal distribution truncated to the interval [-2,2].
%        p = makedist('normal')
%        q = truncate(p,-2,2)
%
%    See also Truncation, IsTruncated.
            requireScalar(this);
            checkTruncationArgs(this,lower,upper);
            td = this;
            if isa(td,'prob.ToolboxFittableParametricDistribution')
                td = invalidateFit(td);
            end
            td.Truncation = [lower upper];
        end
        function tf = get.IsTruncated(this)
            tr = this.Truncation;
            tf = ~(isempty(tr) || (numel(tr)==2 && tr(1)==-Inf && tr(2)==Inf));
        end
        
        % Implementations of methods from parent class
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
            if ~this.IsTruncated
                y = randomfun(this,varargin{:});
            else
                y = icdf(this,rand(varargin{:}));
            end
        end
        
        function y = pdf(this,x)
%PDF Probability density function.
%    Y = PDF(P,X) computes the probability density function of the
%    probability distribution P at the values in X, and returns the result
%    in the array Y.
%
%    Example: Plot the pdf for a normal distribution with mean 100 and
%             standard deviation 10.
%        p = makedist('normal', 'mu',100, 'sigma',10)
%        x = linspace(70,130);
%        plot(x,pdf(p,x))
%
%    See also FITDIST, MAKEDIST.

            requireScalar(this);
            if ~this.IsTruncated
                y = pdffun(this,x);
                y(isnan(x)) = NaN;
            else
                [plower,pupper,Lower,Upper] = tailprobs(this);
                y = zeros(size(x),class(x));
                t = (x>=Lower & x<=Upper);
                y(t) = pdffun(this,x(t)) / (pupper-plower);
                y(isnan(x)) = NaN;
            end
        end
        
        function [varargout] = cdf(this,x,varargin)
%CDF Cumulative distribution function.
%    Y = CDF(P,X) computes the cumulative distribution function of the
%    probability distribution P at the values in X, and returns the result
%    in the array Y.
%
%    Y = CDF(P,X,'upper') computes the upper tail probability of the  
%    probability distribution P at the values in X, and returns the result
%    in the array Y.
%
%    Example: Plot the cdf and the upper tail probability for a normal 
%             distribution with mean 100 and standard deviation 10.
%        p = makedist('normal', 'mu',100, 'sigma',10)
%        x = linspace(70,130);
%        subplot(2,1,1);
%        plot(x,cdf(p,x))
%        title('cdf')
%        subplot(2,1,2);
%        plot(x,cdf(p,x,'upper'))
%        title('upper tail probability')
%
%    See also FITDIST, MAKEDIST.
            [varargin{:}] = convertStringsToChars(varargin{:});
            
            requireScalar(this);
            wasnan = isnan(x);
            if nargout>1
                checkConfSupport(this);
            end
            if ~this.IsTruncated
                if nargout<=1
                    y = cdffun(this,x,varargin{:});
                else
                    [y,ylo,yup] = cdffun(this,x,varargin{:});
                end
            else
                [plower,pupper,Lower,Upper] = tailprobs(this);
                y = zeros(size(x),class(x));
                x = min(x,Upper);
                t = (x>=Lower & x<=Upper);
                t1 = (x<Lower);
                if ~isempty(varargin)
                    if strcmpi(varargin{end},'upper')
                        uflag = true;
                        varargin(end)=[];
                    else
                        error(message('stats:cdf:UpperTailProblem'));
                    end
                else
                    uflag = false;
                end
                if nargout<=1
                    if uflag==true
                        y(t) = (pupper-cdffun(this,x(t))) / (pupper-plower);
                        y(t1) = 1;
                    else
                        y(t) = (cdffun(this,x(t))-plower) / (pupper-plower);
                    end
                else
                    ylo = zeros(size(x),class(x));
                    yup = zeros(size(x),class(x));
                    [y(t),ylo(t),yup(t)] = cdffun(this,x(t),varargin{:});
                    if uflag==true
                        y(t) = (pupper-y(t)) / (pupper-plower);
                        ylo(t) = (pupper-ylo(t)) / (pupper-plower);
                        yup(t) = (pupper-yup(t)) / (pupper-plower);
                        y(t1) = 1;
                        ylo(t1) = 1;
                        yup(t1) = 1;
                    else
                        y(t) = (y(t)-plower) / (pupper-plower);
                        ylo(t) = (ylo(t)-plower) / (pupper-plower);
                        yup(t) = (yup(t)-plower) / (pupper-plower);
                    end
                end
            end
            y(wasnan) = NaN;
            varargout = {y};
            if nargout>=2
                ylo(wasnan) = NaN;
                yup(wasnan) = NaN;
                varargout = {y ylo yup};
            end
        end
        
        function [varargout] = icdf(this,pin,varargin)
%ICDF Inverse cumulative distribution function.
%    Y = ICDF(P,PROB) computes the inverse cumulative distribution function
%    of the probability distribution P at the values in PROB, and returns
%    the result in the array Y.
%
%    Example: Compute the quartiles of a normal distribution with mean 100
%             and standard deviation 10.
%        p = makedist('normal', 'mu',100, 'sigma',10)
%        icdf(p,[.25 .5 .75])
%
%    See also FITDIST, MAKEDIST.
            [varargin{:}] = convertStringsToChars(varargin{:});
            
            requireScalar(this);
            if nargout>1
                checkConfSupport(this);
            end
            if this.IsTruncated
                % Make p relative to the truncation limit cdf values
                [plower,pupper,Lower,Upper] = tailprobs(this);
                p = plower + pin*(pupper-plower);
            else
                p = pin;
            end
            
            if nargout<=1
                y = icdffun(this,p);
                
                % All discrete distributions are in this category. Make
                % sure roundoff issues don't yield values outside
                % truncation and/or support limits.
                % The logic below works under the assumption that all
                % distributions are either (1) continuous, or (2a) discrete
                % with support on contiguous integers, and (2b) the
                % universe of discrete distributions is discrete
                % distributions that inherit from prob.ToolboxDistribution,
                % plus prob.MultinomialDistribution.  Currently, there
                % is no support for customer-defined discrete
                % distributions.
                
                if this.IsTruncated
                    SL = max(Lower,icdffun(this,0));
                    SU = min(Upper,icdffun(this,1));
                    if any(y<SL)
                        if (isa(this,'prob.ToolboxDistribution') && ...
                                ~this.getInfo.iscontinuous) || ...
                                isa(this,'prob.MultinomialDistribution')
                            % Currently, all distributions falling here have 
                            % support on contiguous integers. 
                            SL = ceil(SL);
                            SU = floor(SU);
                            for i = SL:SU
                                if ~isequal(pdf(this,i),0)
                                    break
                                end
                            end
                            y(y<SL) = i;
                        else
                            % Assume the distribution is continuous.
                            y(y<SL) = SL;
                        end
                    end
                    if any(y>SU)
                        if (isa(this,'prob.ToolboxDistribution') && ...
                                ~this.getInfo.iscontinuous) || ...
                                isa(this,'prob.MultinomialDistribution')
                            % Currently, all distributions falling here have
                            % support on contiguous integers.
                            SL = ceil(SL);
                            SU = floor(SU);
                            for i = SU:-1:SL
                                if ~isequal(pdf(this,i),0)
                                    break
                                end
                            end
                            y(y>SU) = i;
                        else
                            % Assume the distribution is continuous.
                            y(y>SU) = SU;
                        end
                    end
                end
            else
                [y,ylo,yup] = icdffun(this,p,varargin{:});
            end
            t = (pin<0 | pin>1);
            if any(t)
                y(t) = NaN;
                if nargout>=2
                    ylo(t) = NaN;
                    yup(t) = NaN;
                end
            end
            if nargout<=1
                varargout = {y};
            else
                varargout = {y ylo yup};
            end
        end
    end
    
    methods(Access=protected)
        function displayBody(this)
            % Overrride to include a truncation note in the display
            displayCallback(this)
            if ~isempty(this) && ~isempty(this.Truncation)
                fprintf('  %s\n',getString(message('stats:probdists:DisplayTrunc',...
                    sprintf('%g',this.Truncation(1)), ...
                    sprintf('%g',this.Truncation(2)))));
            end
        end
        function checkConfSupport(this)
            % Error if this object doesn't support confidence bounds for
            % the cdf
            if isa(this,'prob.ToolboxDistribution')
                info = this.getInfo;
                if ~info.hasconfbounds
                    m = message('stats:probdists:NoConfBounds',this.DistributionName);
                    throwAsCaller(MException(m.Identifier,'%s',getString(m)));
                end
            end
        end
        function [plower,pupper,Lower,Upper] = tailprobs(this)
            % Get tail probabilities and truncation bounds. Take pains to
            % compute the cdf just below the lower truncation limit, in
            % case this distribution gives positive probability exactly at
            % that point.
            if isempty(this.Truncation)
                Lower = -Inf;
                Upper = Inf;
                lo = -Inf;
            else
                Lower = this.Truncation(1);
                Upper = this.Truncation(2);
                lo = protectiveLowBound(Lower);
            end
            plower = cdffun(this,lo);
            pupper = cdffun(this,Upper);
        end
    end
    
    methods(Access=protected,Hidden=true)
        
        function TM = truncatedMoment(this,degree)
%TRUNCATEDMOMENT Calculates the truncated central moment of degree DEGREE.
%
% This function should be called for continuous functions distributions only.
%
% TM           Mean or variance of the truncated distributiion, depending
%              on DEGREE.
%
% degree       The degree of the moment. Must be 1 (mean) or 2 (variance).
%
% See also integral.

            % Degree parameter must be either 1 or 2
            if ~isscalar(degree) || ~(isequal(degree,1) || isequal(degree,2))
                % error out ...
            end

            % Create waypoints for the numerical integration.
            % Use equi-spaced quantiles.
            waypoints = icdffun(this,(0.01:0.01:0.99)');
            varargin = {'Waypoints',waypoints};
            
            % The following quantities are:
            % TL     Lower truncation limit
            % TU     Upper truncation limit
            % SL     Lower extreme of support, untruncated distribution
            % SU     Upper extreme of support, untruncated distribution
            % L      Endpoint for semi-infinite integrals
            % U      Endpoint for semi-infinite integrals

            [~,~,TL,TU] = tailprobs(this);
            SL = icdffun(this,0);
            SU = icdffun(this,1);
            L = max(TL,SL);
            U = min(TU,SU);

            % There are three warning message ids issued by integral().
            % Inhibit these and restore their incoming state when we
            % go out of scope.
            warnidNonFinite = 'MATLAB:integral:NonFiniteValue';
            warnidMaxInterval = 'MATLAB:integral:MaxIntervalCountReached';
            warnidMinStep = 'MATLAB:integral:MinStepSize';

            warnStateNonFinite = warning('off',warnidNonFinite);
            warnStateMaxInterval = warning('off',warnidMaxInterval);
            warnStateMinStep = warning('off',warnidMinStep);
            cleanupObj1 = onCleanup(@() warning(warnStateNonFinite));
            cleanupObj2 = onCleanup(@() warning(warnStateMaxInterval));
            cleanupObj3 = onCleanup(@() warning(warnStateMinStep));

            if isequal(degree,1)
                f = @(x) x .* pdf(this,x);
            else
                theMean = truncatedMoment(this,1);
                f = @(x) (x-theMean).^2 .* pdf(this,x);
            end

            if isequal(SU,Inf)
                % Infinite right support (untruncated). Upper truncation
                % point is unbounded, and (L,U) may be very large,though
                % finite.  The integral() function may fail on such
                % intervals, so give it a semi-infinite integral.
                [TM,wmsg1,warnid1] = doIntegral(f,L,Inf,varargin{:});
            elseif isequal(SL,-Inf)
                % Likewise for infinite left tail.
                [TM,wmsg1,warnid1] = doIntegral(f,-Inf,U,varargin{:});
            else
                % Untruncated support is finite
                [TM,wmsg1,warnid1] = doIntegral(f,L,U,varargin{:});
            end
            warning(wmsg1,warnid1);
        end %- truncatedMoment
        
        function tm = truncatedMeanDiscrete(this,um)
%TRUNCATEDMEANDISCRETE Calculates the truncated mean for discrete distributions.
%
% This function should be called only for integer-valued probability
% distributions, with either finite support or support that is infinite
% on the right but finite on the left.
% 
% TM   The truncated mean
% UM   The untruncated mean
        
            % Determine the range of integers that the truncation
            % points contain.
            [plower, pupper, lower, upper] = tailprobs(this);
            lower = ceil(lower);
            upper = floor(upper);
            upper = min(upper,icdffun(this,1));
            if isequal(upper,Inf)
                % Can't sum infinite series.  Instead, subtract off
                % the left tail from the adjusted untruncated mean.
                w = 1 / (pupper - plower);
                x = 1:(lower-1);
                tm = w * (um - sum(x .* pdffun(this,x)));
            else
                x = lower:upper;
                p = pdf(this,x);
                tm = sum(p .* x);
            end
        end

        function tv = truncatedVarDiscrete(this,um,uv)
%TRUNCATEDVARDISCRETE Calculates the truncated variance for discrete distributions.
%
% This function should be called only for integer-valued probability
% distributions, with either finite support or support that is infinite
% on the right but finite on the left.
%
% TM   The truncated mean
% UM   The untruncated mean
% UV   The untruncated variance

            m = mean(this);
            % Determine the range of integers that the truncation
            % points contain.
            [plower, pupper, lower, upper] = tailprobs(this);
            lower = ceil(lower);
            upper = floor(upper);
            upper = min(upper,icdffun(this,1));
            if isequal(upper,Inf)
                % Can't sum infinite series.  Instead, subtract off
                % the left tail from the adjusted untruncated variance.
                w = 1 / (pupper - plower);
                x = 0:(lower-1);
                tv = w * (uv + (um-m)^2 - sum( (x-m).^2 .* pdffun(this,x) ));
            else
                x = lower:upper;
                p = pdf(this,x);
                tv = sum(p .* (x-m).^2);
            end
        end

        function checkTruncationArgs(this,lower,upper)
            if ~(isscalar(lower) && isnumeric(lower) && isreal(lower) && ~isnan(lower))
                error(message('stats:probdists:BadTruncationParameter','LOWER'))
            end
            if ~(isscalar(upper) && isnumeric(upper) && isreal(upper) && ~isnan(upper))
                error(message('stats:probdists:BadTruncationParameter','UPPER'))
            end
            if ~(lower<upper)
                error(message('stats:probdists:LowerLTUpper','LOWER','UPPER'))
            end
            lo = protectiveLowBound(lower);
            plower = cdffun(this,lo);
            pupper = cdffun(this,upper);
            if isequal(plower,pupper)
                error(message('stats:probdists:ZeroMassTruncation'));
            end
        end
    end %- protected and hidden

end % classdef

function lo = protectiveLowBound(low)
if isfinite(low)
    lo = low - eps(low);
    if lo+eps(lo) < low
        lo = lo + eps(lo);
    end
else
    lo = low;
end
end

function [q,wmsg,wid] = doIntegral(f,L,U,varargin)
lastwarn('');
q = integral(f,L,U,varargin{:});
[wmsg,wid] = lastwarn;
end


