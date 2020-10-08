classdef ToolboxFittableParametricDistribution < prob.ToolboxParametricDistribution & ...
                                                 prob.FittableParametricDistribution
%ParametricDistribution Base class for fittable parametric probability distributions.
    
%   Copyright 2012-2018 The MathWorks, Inc.

    properties(Hidden,Dependent=true,GetAccess='public',SetAccess='protected')
        % For compatibility with earlier versions of probability objects
        NumParams
        ParamNames
        Params
        ParamIsFixed
        ParamDescription
        ParamCov
        NLogL
        DistName
    end

    properties(Hidden,Dependent,GetAccess='public',SetAccess='protected')
        % For backward compatibility
        Support
    end

    methods(Access='protected')
        function pd = ToolboxFittableParametricDistribution
        end
        function pnums = pNamesToNums(this,pnums)
            if ischar(pnums) || iscellstr(pnums)
                [tf,pnums] = ismember(pnums,this.ParameterNames);
                if any(~tf)
                    error(message('stats:probdists:BadParameterArgument'));
                end
            elseif ~isvector(pnums) || ~all(ismember(pnums,1:this.NumParameters))
                error(message('stats:probdists:BadParameterArgument'));
            end
        end
    end
    methods
        function ci = paramci(this,varargin)
%PARAMCI Confidence intervals for parameters
%    CI = PARAMCI(P) takes a probability distribution object P and returns
%    the array CI containing 95% confidence intervals for the parameters in
%    P. P must be created by fitting to data. CI is 2-by-N, where N is the
%    number of parameters in P. Column J of CI contains the lower and upper
%    bounds of a confidence interval for the Jth parameter.
%
%    CI = PARAMCI(P, 'NAME1',VALUE1,'NAME2',VALUE2,...) specifies optional
%    argument name/value pairs chosen from the following list. Argument
%    names are case insensitive and partial matches are allowed.
%
%      Name           Value
%      'Alpha'        A number between 0 and 1 specifying 100(1-ALPHA)
%                     percent confidence intervals. Default is 0.05 for 95%
%                     confidence.
%      'Parameter'    A vector of parameter numbers for which intervals
%                     should be computed, or a cell array of strings of
%                     parameter names. Default is all parameters.
%      'Type'         Either 'Wald' to compute intervals using the Wald
%                     method, 'exact' to use an exact method, or 'lr' to
%                     use likelihood ratio confidence intervals. The
%                     'exact' type is available only for certain
%                     distributions. Default is 'exact' when available, or
%                     'Wald' otherwise.
%      'LogFlag'      A boolean vector with one element for each parameter
%                     specifying which Wald intervals should be computed on
%                     the log scale. Default depends on the distribution.
%
%    The 'exact' type is available for the following distributions:
%       binomial    - computed using the Clopper-Pearson method based on
%                     exact probability calculations (does not provide
%                     exact coverage probabilities).
%       exponential - method based on a chi-square distribution provides
%                     exact coverage for for complete and Type 2 censored
%                     samples. 
%       normal      - method based on t and chi-square distributions for
%                     uncensored samples provides exact coverage; the Wald
%                     method is used for censored samples.
%       lognormal   - method based on t and chi-square distributions for
%                     uncensored samples provides exact coverage; the Wald
%                     method is used for censored samples.
%       Poisson     - method based on a chi-square distribution provides
%                     exact coverage, though for large degrees of freedom
%                     the chi-square is approximated by a normal
%                     distribution for numerical efficiency.
%       Rayleigh    - method based on a chi-square distributio provides
%                     exact coverage probabilities.
%
%    Example: Demonstrate that for the exponential distribution, the Wald
%             method gives results closer to the exact results if it is
%             computed on the log scale.
%        rng('default')
%        x = 5*-log(rand(30,1));
%        p = fitdist(x,'exponential');
%        ci1 = paramci(p,'type','exact')
%        ci2 = paramci(p,'type','wald','LogFlag',false)
%        ci3 = paramci(p,'type','wald','LogFlag',true)
%
%    See also fitdist, proflik.

            [varargin{:}] = convertStringsToChars(varargin{:});
            requireScalar(this)
            if isscalar(varargin) && isnumeric(varargin{1}) && isnumeric(varargin{1})
                % Support syntax of older ProbDistUnivParam/paramci method
                varargin = {'alpha' varargin{1}};
            end
            logci = this.getInfo.logci;
            okargs =   {'alpha' 'parameter'          'type' 'logflag'};
            defaults = {0.05,   1:this.NumParameters 'wald' logci};
            [alpha,pnums,citype,logci] = statslib.internal.parseArgs(okargs,defaults,varargin{:});
            if ~isempty(citype)
                citype = statslib.internal.getParamVal(citype,{'wald' 'exact' 'lr'},'''type''');
            end
            if isequal(citype,'exact')
                % Derived class is responsible for handling the 'exact'
                % method, so if we see it here we know it's not valid for
                % this distribution
                error(message('stats:probdists:NoExact',this.DistributionName));
            end
            if ~(isscalar(alpha) && isnumeric(alpha) && alpha>0 && alpha<1)
                error(message('stats:ecdf:BadAlpha'))
            end
            if ischar(pnums) && size(pnums,1) == 1
                pnums = cellstr(pnums);
            end
            pnums = pNamesToNums(this,pnums);
            info = this.getInfo;
            plim = info.plim(:,pnums);
            
            if all(this.ParameterIsFixed)
                ci = repmat(this.ParameterValues(pnums),2,1);
            elseif isequal(citype,'wald')
                if any(~this.ParameterIsFixed & logci & this.ParameterValues<=0)
                    error(message('stats:probdists:LogNotPositive'))
                end
                % Compute Wald intervals
                ci = dfswitchyard('statparamci',this.ParameterValues(pnums),...
                                 this.ParameterCovariance(pnums,pnums),...
                                 alpha,logci(pnums));
            else  % ctype is 'lr'
                % Start by computing exact or Wald intervals.
                ci = paramci(this,'Parameter',pnums,'Alpha',alpha);
                
                % Compute likelihood ratio confidence intervals by finding
                % the place at which the profile log likelihood for each
                % parameter drops by the appropriate chi-square value
                target = this.NegativeLogLikelihood + chi2inv(1-alpha,1)/2;
                opt = optimset('fzero');
                pv = this.ParameterValues;
                for j = 1:length(pnums)
                    if this.ParameterIsFixed(j)
                        ci(:,j) = pv(j);
                    else
                        F = @(p) -proflik(this,pnums(j),p,'Start',this.ParameterValues) - target;
                        width = diff(ci(:,j));
                        tol = width * 1e-4 / max(1,max(abs(ci(:,j))));
                        opt = optimset(opt,'TolX',tol);
                        estimate = pv(pnums(j));

                        for k=1:2
                            limits = plim(:,j);
                            if estimate==limits(k)
                                cikj = estimate;
                            else
                                limits(3-k) = estimate;
                                startval = locateStartValue(F,ci(k,j),pv(pnums(j)),limits);
                                if any(startval==limits(k))
                                    cikj = limits(k);
                                else
                                    cikj = fzero(F,startval,opt);
                                end
                            end
                            if isnan(cikj)
                                cikj = limits(k);
                            end
                            ci(k,j) = cikj;
                        end
                    end
                end
            end
            ci = [max(plim(1,:),ci(1,:)); min(plim(2,:),ci(2,:))];
        end
        function [ll,param,others] = proflik(this,pnum,varargin)
%PROFLIK Profile likelihood
%   [LL,PARAM] = PROFLIK(PD,PNUM) computes the profile log likelihood for
%   parameter PNUM, and returns a vector LL of log likelihood values and a
%   vector PARAM of corresponding parameter values. The log likelihood is
%   the value of the likelihood with paramter PNUM set to the values PARAM,
%   maximized over the remaining parameters.
%
%   [LL,PARAM] = PROFLIK(PD,PNUM,PARAM) specifies the values of the
%   parameter. The default PARAM is chosen based on the default confidence
%   interval method for PD. If the parameter can take only restricted
%   values, and if the confidence interval violates that restriction, then
%   you can use this input to specify valid values.
%
%   [LL,PARAM,OTHER] = PROFLIK(...) also returns a matrix OTHER containing
%   the values of the other parameters that maximize the likelihood. Each
%   row of OTHER contains the values for all parameters except PNUM.
%
%   [...] = PROFLIK(PC,PNUM,PARAM,'Display','on') displays a plot of the
%   profile log likelihood overlaid on an approximation of the log
%   likelihood. The approximation is based on a Taylor series expansion
%   around the estimated parameter value, as a function of the PNUM
%   parameter or its logarithm. The intersection of the curves with the
%   horizontal dotted line marks the endpoints of 95% confidence intervals.
%   PROFLIK(PC,PNUM,PARAM,'Display','off') is the default and omits the
%   display.
%
%   Example: For a Weibull fit to MPG, the Taylors series is a good
%            approximation to the profile likelihood. The interval based on
%            the exact profile likelihood extends further out on the left,
%            and not as far out on the right.
%       load carsmall
%       p = fitdist(MPG,'Weibull');
%       proflik(p,2,'display','on');
%
%   See also fitdist, paramci.

            if nargin > 1
                pnum = convertStringsToChars(pnum);
            end
            [varargin{:}] = convertStringsToChars(varargin{:});
            
            requireScalar(this)
            if all(this.ParameterIsFixed)
                error(message('stats:probdists:RequiresFit','proflik'));
            end
            if nargin<2
                pnum = find(~this.ParameterIsFixed,1,'first');
            elseif ischar(pnum)
                pnum = find(strcmp(pnum,this.ParameterNames));
            end
            if ~statslib.internal.isScalarInt(pnum,1,this.NumParameters)
                error(message('stats:probdists:ParamNameNumber'));
            elseif this.ParameterIsFixed(pnum)
                error(message('stats:probdists:ParamEstimated'));
            end
            singleparam = sum(~this.ParameterIsFixed)==1;
            param = [];
            if ~isempty(varargin) && ~ischar(varargin{1})
                param = varargin{1};
                varargin(1) = [];
            end
            okargs =   {'Display' 'Start'};
            defaults = {'off'     []};
            [dodisp,pStart,setFlag] = statslib.internal.parseArgs(okargs,defaults,varargin{:});
            if isequal(dodisp,'on') || isequal(dodisp,'off') || (isscalar(dodisp) && islogical(dodisp))
                if ~islogical(dodisp)
                    dodisp = isequal(dodisp,'on');
                end
            else
                error(message('stats:probdists:BadDisplay'))
            end

            dosort = true;
            if isempty(param)
                % Default PARAM values span an exact or Wald-style
                % confidence interval
                ci = paramci(this,'alpha',0.02);
                if singleparam
                    npts = 101; % can afford to do more, no optimization
                else
                    npts = 21;
                end
                param = linspace(ci(1,pnum),ci(2,pnum),npts);
                dosort = false;
            elseif ~(isnumeric(param) && isreal(param) && isvector(param))
                error(message('stats:probdists:ParamRealVector'));
            end
            ll = zeros(size(param),class(param)); % to hold log like values
            info = this.getInfo;
            pdffunc = info.pdffunc;               % pdf function
            cdffunc = info.cdffunc;               % cdf function

            if nargout>=3
                % to hold other parameter values
                others = zeros([length(param),length(this.ParameterValues)-1],class(param));
            end
            if singleparam
                % single parameter, no maximization needed
                pvec = this.ParameterValues;
                for j=1:numel(param)
                    pvec(pnum) = param(j);
                    ll(j) = loglik(this.InputData,pdffunc,cdffunc,pvec);
                end
            else
                % multiple parameters, first sort them
                if dosort
                    [param,sortidx] = sort(param);
                end
                
                % use estimated values of other parameters as starting values
                fixed = this.ParameterIsFixed;
                fixed(pnum) = true;
                
                pFull = this.ParameterValues;
                if ~setFlag.Start
                    pStart = pFull(~fixed);
                else
                    pStart = pStart(~fixed);
                end
                pStart0 = pStart;
                
                j0 = max(1,sum(param<pFull(pnum)));
                opt = optimset(optimset('fminsearch'),'Display','off');
                for j=j0:numel(param)
                    % loop upward away from estimate, maximize over other parameters
                    pFull(pnum) = param(j);
                    F = @(p)-loglik(this.InputData,pdffunc,cdffunc,merge(pFull,p,~fixed));
                    [pStart,llopt] = fminsearch(F,pStart,opt);
                    ll(j) = -llopt;
                    if nargout>=3
                        others(j,:) = pStart;
                    end
                end
                
                pStart = pStart0;
                for j=j0-1:-1:1
                    % now loop downward, starting again from same p0 values
                    pFull(pnum) = param(j);
                    F = @(p)-loglik(this.InputData,pdffunc,cdffunc,merge(pFull,p,~fixed));
                    [pStart,llopt] = fminsearch(F,pStart,opt);
                    ll(j) = -llopt;
                    if nargout>=3
                        others(j,:) = pStart;
                    end
                end
                
                % undo sorting
                if dosort
                    param(sortidx) = param;
                    ll(sortidx) = ll;
                    if nargout>=3
                        others(sortidx,:) = others;
                    end
                end
            end
            
            % plot if requested
            if dodisp
                p0 = this.ParameterValues(pnum);
                xx = linspace(min(param),max(param));
                info = this.getInfo;
                dolog = info.logci(pnum);
                v = this.ParameterCovariance(pnum,pnum);
                if dolog
                    v = v/p0^2;
                    pnew = log(p0);
                    xnew = log(max(0,xx));
                else
                    pnew = p0;
                    xnew = xx;
                end
                yy = -this.NegativeLogLikelihood - .5*(xnew-pnew).^2/v;
                plot(p0,-this.NegativeLogLikelihood,'ko',...
                    param,ll,'b-', ...
                    xx,yy,'r-',...
                    xx,(-this.NegativeLogLikelihood-chi2inv(.95,1)/2)*ones(size(xx)),'k:')
                xlabel(this.ParameterNames{pnum});
                ylabel(getString(message('stats:probdists:LabelLogLik')))
                legend(getString(message('stats:probdists:LegendEstimate')),...
                       getString(message('stats:probdists:LegendExact')),...
                       getString(message('stats:probdists:LegendWald')),...
                       getString(message('stats:probdists:LegendConf')),...
                       'location','best')
            end
        end
    end
    methods % get/set methods
        function s = get.Support(this)
            info = this.getInfo;
            range = icdf(this,[0 1]);
            closedbound = info.closedbound;
            iscontinuous = info.iscontinuous;
            s = struct('range',range,...
                       'closedbound',closedbound,...
                       'iscontinuous',iscontinuous);
            s = fixSupport(this,s);
        end
        function a = get.NumParams(this)
            a = this.NumParameters;
        end
        function a = get.ParamNames(this)
            a = this.ParameterNames;
        end
        function a = get.Params(this)
            a = this.ParameterValues;
        end
        function a = get.ParamIsFixed(this)
            a = this.ParameterIsFixed;
        end
        function a = get.ParamDescription(this)
            a = this.ParameterDescription;
        end
        function a = get.DistName(this)
            info = this.getInfo;
            a = info.code;  % code, not name, for backward compatibility
        end
        function a = get.ParamCov(this)
            a = this.ParameterCovariance;
        end
        function a = get.NLogL(this)
            a = negloglik(this);
        end
    end
    methods(Hidden)
        function this = invalidateFit(this)
            if ~isempty(this.InputData)
                this.InputData = [];
                this.NegativeLogLikelihood = [];
                this.ParameterIsFixed = true(1,this.NumParameters);
                this.ParameterCovariance = zeros(this.NumParameters);
            end
        end
    end
    methods(Hidden,Access=protected)
        function s = fixSupport(~,s)
            % derived class may override this method to compute the support
            % based on the parameters of the distribution
        end
    end
    methods(Static,Access=protected)
        function [x,cens,freq,opt,setflag] = processFitArgs(x,varargin)
%processFitArgs Processing censoring, frequency, and options arguments

            % Arguments other than these will generate an error
            okargs =   {'censoring' 'frequency' 'options'};
            defaults = {[]          []          []};
            [cens,freq,opt,setflag] = statslib.internal.parseArgs(okargs,defaults,varargin{:});
            [badin,~,x,cens,freq] = statslib.internal.removenan(x,cens,freq);
            if badin>0
                error(message('stats:ecdf:InputSizeMismatch'));
            end
            if ~isempty(freq) && ...
                       (~isvector(freq) || ~numel(freq)==numel(x) || ...
                        ~all(isnan(freq) | (freq>=0 & freq==round(freq))))
                error(message('stats:ProbDistUnivParam:fit:BadFrequency'));
            end
        end
        function x = removeCensoring(x,cens,freq,distname)
%removeCensoring Reject censoring and expand X as specified by FREQ.

            % For distributions that do not accept censoring
            if any(cens)
                 error(message('stats:ProbDistUnivParam:fit:CensoringNotAllowed', distname));
            end
            if ~isempty(freq) && ~all(freq==1)
                % These distributions require data be expanded so that all
                % frequencies are 1
                i = cumsum(freq);
                j = zeros(1, i(end));
                j(i(1:end-1)+1) = 1;
                j(1) = 1;
                x = x(cumsum(j));
            end
        end
    end
end % classdef

function ll = loglik(input,pdf,cdf,params)
% Compute negative log likelihood
x = input.data;
if isempty(input.cens)
    c = false(size(x));
else
    c = input.cens;
end
if isempty(input.freq)
    f = ones(size(x));
else
    f = input.freq;
end
pcell = num2cell(params);
ll = sum(f(~c).*log(pdf(x(~c),pcell{:})));
if any(c)
    ll = ll + sum(f(c).*log(1-cdf(x(c),pcell{:})));
end
if isnan(ll) % likely invalid parameter, treat as 0 likelihood
    ll = -Inf;
end
end

function p = merge(p,newp,locations)
% Merge NEWP into P at the specified locations - used to vary a subset of
% parameters in an optimization process
p(locations) = newp;
end

% ------
function startval = locateStartValue(F,startval,estimate,limit)
% Locate a starting value for fzero. Try to find a value that yields a
% valid finite objective function, and if possible has sign opposite the
% value at the estimate.

% First make sure the starting value yields a valid function result
tries = 0;
while(true)
    try
        Fval = F(startval);
        ok = isfinite(Fval);
    catch me
        if ~strcmp(me.identifier, 'MATLAB:fzero:ValueAtInitGuessComplexOrNotFinite')
            rethrow(me)
        end
        ok = false;
        Fval = -1; % any negative value will do
    end
    if ok || tries>=10
        break
    else
        % back off if moving this far causes a problem
        startval = (startval+estimate)/2;
        tries = tries+1;
    end
end

% Next try to find a positive value (value at the estimate is negative)
tries = 0;
factor = 2;
while(Fval<0 && ~any(startval==limit))
    newstart = estimate + factor*(startval-estimate);
    newstart = max(limit(1),min(limit(2),newstart));
    try
        Fval = F(newstart);
        if ~isfinite(Fval)
            Fval = -Inf;
            ok = false;
        elseif Fval>0
            startval = newstart;
            break
        else
            startval = newstart;
            ok = true;
        end
    catch me
        ok = false;
    end
    if ~ok
        factor = (1+factor)/2;
    end
    tries = tries+1;
    if tries>=10
        break
    end
end
if Fval<0
    % Never got a positive value, try the limit
    try
        % If successful, use that
        Flim = F(limit);
        startval = limit;
        Fval = Flim;
    catch
        % If not, give up on finding a bracket interval
    end
end
if Fval>0
    % Got a positive value, can bracket target
    startval = [estimate startval];
    return
end
end
