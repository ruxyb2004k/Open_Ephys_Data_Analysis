function pd = makedist(distname,varargin)
%MAKEDIST Make probability distribution
%    PD = MAKEDIST(DISTNAME) creates an object
%    representing the probability distribution DISTNAME and having
%    a default set of parameter values.
%
%    PD = MAKEDIST(DISTNAME,PNAME1,PVAL1,PNAME2,PVAL2,...) creates an object
%    representing the probability distribution DISTNAME and a specified set
%    of parameter values.
%
%    LIST = MAKEDIST returns a cell array LIST containing a list of the
%    probability distributions that MAKEDIST can create.
%
%    MAKEDIST -RESET resets the list of distributions by searching the path
%    for files contained in a package named "prob" and implementing classes
%    derived from ProbabilityDistribution.
%
%    In addition to making a distribution directly using MAKEDIST, if you
%    have the Statistics and Machine Learning Toolbox you can make a
%    distribution by fitting to data using FITDIST.
%
%    Example:
%       % create a normal distribution with mu=100 and sigma=10
%       pd = makedist('normal','mu',100,'sigma',10)
%
%       % make the same distribution by assigning to parameters
%       pd = makedist('normal')
%       pd.mu = 100
%       pd.sigma = 10
%
%       % generate a random sample and plot its histogram
%       hist(random(pd,100,1))
%
%    See also FITDIST.

%    Copyright 2012-2017 The MathWorks, Inc.

% Registry will hold all the registered distribution names as keys,
% and the names of the defining classes (hence also the names of
% their constructors) as values.

if nargin > 0
    distname = convertStringsToChars(distname);
end

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if nargin==0
    % Special case, list all distributions available to makedist.
    % (This is all parametric toolbox distributions.)
    pd = prob.ProbabilityDistributionRegistry.list('parametric')';
    return
elseif nargin==1 && strcmpi(distname,'-reset')
    % Special case, reset the list of distributions
    hroot = 0;
    setappdata(hroot,'alldistributions',[]);  % same as call to dfgetset
    prob.ProbabilityDistributionRegistry.refresh;
    return
end

% Typical case, make a distribution with the given name
if ~(ischar(distname) && isrow(distname))
    error(message('stats:fitdist:BadDist'))
end
try
    switch(distname)
        case 'ev', distname = 'extreme value';
        case 'gev', distname = 'generalized extreme value';
        case 'gp', distname = 'generalized pareto';
        case 'hn', distname = 'half normal';
        case 'nbin', distname = 'negative binomial';
        case 'wbl', distname = 'weibull';
    end
    spec = prob.ProbabilityDistributionRegistry.get(distname);
catch ME
    error(message('stats:ProbDistUnivParam:checkdistname:UnrecognizedName',distname));
end
if ~spec.parametric
    error(message('stats:fitdist:NotMakeable',distname));
end
theDefiningClassName = spec.classname;

% Two cases:
if nargin==1 || ~ischar(varargin{1})
    % makedist('distname',p1,p2)
    pd = feval(theDefiningClassName, varargin{:});
else
    % makedist('distname', 'p1',p1, 'p2',p2)
    
    % Create the class with default parameters
    pdtemp = feval(theDefiningClassName);
    if ~isa(pdtemp,'prob.ParametricDistribution')
        error(message('stats:probdists:NotParametric',lower(spec.basename)));
    end
    
    % Process arguments as parameter names and values
    pnames = pdtemp.ParameterNames;
    inputvals = cell(1,length(pnames));
    [inputvals{1:end},setFlag] = parseArgs(pnames,inputvals,varargin{:});

    % Replace parameters all at once so error checking can be done for them
    % as a group
    oldpvals = pdtemp.ParameterValues;
    if iscell(oldpvals)
        newpvals = oldpvals;
    else
        newpvals = num2cell(pdtemp.ParameterValues);
        for j=1:pdtemp.NumParameters
            newpvals{j} = pdtemp.ParameterValues(j);
        end
    end
    for j=1:length(pnames)
        if setFlag.(pnames{j})
            newpvals{j} = inputvals{j};
        end
    end
    pd = feval(theDefiningClassName, newpvals{:});
end

end

% The following is a subset of internal.stats.parseArgs, made available for
% use outside the Statistics and Machine Learning Toolbox
function [varargout]=parseArgs(pnames,dflts,varargin)
nparams = length(pnames);
varargout = dflts;
setflag = false(1,nparams);
nargs = length(varargin);

dosetflag = nargout>nparams;

% Must have name/value pairs
if mod(nargs,2)~=0
    m = message('stats:internal:parseArgs:WrongNumberArgs');
    throwAsCaller(MException(m.Identifier, '%s', getString(m)));
end

% Process name/value pairs
for j=1:2:nargs
    pname = varargin{j};
    if ~ischar(pname)
        m = message('stats:internal:parseArgs:IllegalParamName');
        throwAsCaller(MException(m.Identifier, '%s', getString(m)));
    end
    
    mask = strncmpi(pname,pnames,length(pname)); % look for partial match
    if ~any(mask)
        m = message('stats:internal:parseArgs:BadParamName',pname);
        throwAsCaller(MException(m.Identifier, '%s', getString(m)));
    elseif sum(mask)>1
        mask = strcmpi(pname,pnames); % use exact match to resolve ambiguity
        if sum(mask)~=1
            m = message('stats:internal:parseArgs:AmbiguousParamName',pname);
            throwAsCaller(MException(m.Identifier, '%s', getString(m)));
        end
    end
    varargout{mask} = varargin{j+1};
    setflag(mask) = true;
end

% Indicate which return values were set explicitly
if dosetflag
    setflag = cell2struct(num2cell(setflag),pnames,2);
    varargout{nparams+1} = setflag;
end

end