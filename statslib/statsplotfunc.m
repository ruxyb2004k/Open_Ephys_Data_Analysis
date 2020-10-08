function varargout = statsplotfunc(action,fname,inputnames,inputvals)
%STATPLOTFUNC  Support function for Plot Picker component.

% Copyright 2009-2018 The MathWorks, Inc.

% Default display functions for stats plots
if strcmp(action,'defaultshow')
    n = length(inputvals);
    toshow = false;
    % A single empty should always return false
    if isempty(inputvals) ||  isempty(inputvals{1})
        varargout{1} = false;
        return
    end
    
    % A temporary check to ensure that no statistics plots are enabled when
    % an unsupported object (datetime, duration, calendarDuration) is selected
    if ~unsupportedObjectSelection(lower(fname),inputvals, n)
        switch lower(fname)
            case 'boxplot' % Numeric vector or matrix and optional grouping variable
                if n==1
                    x = inputvals{1};
                    toshow = isnumeric(x) && ~isscalar(x)&& ismatrix(x);
                elseif n==2
                    x = inputvals{1};
                    group = inputvals{2};
                    toshow = isnumeric(x) && ~isscalar(x) && ismatrix(x) && ...
                        localCheckValidGroup(x,group,2);
                end
            case 'ecdf' % 1 numeric vector
                if n==1
                    x = inputvals{1};
                    toshow =  isnumeric(x) && ~isscalar(x) && isvector(x);
                end
            case 'histfit'
                if n==1
                    x = inputvals{1};
                    toshow = isvector(x) && isnumeric(x) && ~isscalar(x);
                elseif n==2
                    x = inputvals{1};
                    n = inputvals{2};
                    toshow = isvector(x) && isnumeric(x) && ~isscalar(x) && ...
                        isscalar(n) && n>0 && round(n)==n;
                elseif n==3
                    x = inputvals{1};
                    n = inputvals{2};
                    dist = inputvals{3};
                    toshow = isvector(x) && isnumeric(x) && ~isscalar(x) && ...
                        isscalar(n) && n>0 && round(n)==n;
                    toshow = toshow && ischar(dist);
                end
            case 'ksdensity'
                if n==1
                    x = inputvals{1};
                    toshow = isvector(x) && isnumeric(x) && ~isscalar(x);
                elseif n==2
                    x = inputvals{1};
                    xi = inputvals{2};
                    toshow = isvector(x) && isnumeric(x) && ~isscalar(x);
                    toshow = toshow && isvector(xi) && isnumeric(xi) && ~isscalar(xi);
                end
            case 'probplot'
                if n==1
                    Y = inputvals{1};
                    toshow = isnumeric(Y) && ~isscalar(Y) && ismatrix(Y);
                elseif n==3
                    Y = inputvals{1};
                    cens = inputvals{2};
                    freq = inputvals{3};
                    toshow = isnumeric(Y) && ~isscalar(Y) && ismatrix(Y) && ...
                        isequal(size(Y),size(cens)) && isequal(size(freq),size(Y));
                    toshow = toshow && ~any(isnan(cens(:))) && all((logical(cens(:))-cens(:))==0) && all(freq(:)>=0 && ...
                        (round(freq(:))-freq(:))==0);
                end
            case {'weibull probability plot' 'normal probability plot'}
                if n==1
                    Y = inputvals{1};
                    toshow = isnumeric(Y) && ~isscalar(Y) && ismatrix(Y);
                elseif n==3
                    Y = inputvals{1};
                    cens = inputvals{2};
                    freq = inputvals{3};
                    toshow = isnumeric(Y) && ~isscalar(Y) && ismatrix(Y) && ...
                        isequal(size(Y),size(cens)) && isequal(size(freq),size(Y));
                    toshow = toshow && ~any(isnan(cens(:))) && all((logical(cens(:))-cens(:))==0) && all(freq(:)>=0 && ...
                        (round(freq(:))-freq(:))==0);
                end
                if toshow && strcmpi(fname,'weibull probability plot')
                    toshow = min(min(Y))>=0;
                end
            case 'qqplot'
                if n==1
                    X = inputvals{1};
                    toshow = isnumeric(X) && ~isscalar(X) && ismatrix(X);
                elseif n==2
                    X = inputvals{1};
                    Y = inputvals{2};
                    toshow = isnumeric(X) && ~isscalar(X) && ismatrix(X) && ...
                        ((ismatrix(Y) && ~isscalar(Y) && isnumeric(Y) && ...
                        (isvector(X) || isvector(Y) || size(X,2)==size(Y,2))) || ...
                        isa(Y,'prob.UnivariateDistribution') || isa(Y,'prob.UniformDistribution') ||...
                        isa(Y,'prob.TriangularDistribution') || isa(Y,'prob.PiecewiseLinearDistribution') || ...
                        isa(Y,'prob.MultinomialDistribution'));
                elseif n==3
                    X = inputvals{1};
                    Y = inputvals{2};
                    pvec = inputvals{3};
                    toshow = isnumeric(X) && ~isscalar(X) && ismatrix(X) && ...
                        (ismatrix(Y) && ~isscalar(Y) && isnumeric(Y) && ...
                        (isvector(X) || isvector(Y) || size(X,2)==size(Y,2)));
                    toshow = toshow && isnumeric(pvec) && ~isscalar(pvec) && ...
                        isvector(pvec);
                    toshow = toshow && all(pvec(:)>=0 & pvec(:)<=100);
                end
            case 'gscatter'
                if n==3
                    x = inputvals{1};
                    y = inputvals{2};
                    group = inputvals{3};
                    toshow = isLikeNumeric(x) && isLikeNumeric(y) ...
                        &&   isvector(x) && isvector(y) ...
                        &&   ~isscalar(x) && length(x)==length(y) ...
                        &&   localCheckValidGroup(x,group,1);
                end
            case 'hist3'
                if n==1
                    x = inputvals{1};
                    toshow = isnumeric(x) && ismatrix(x) && size(x,1)>1 && size(x,2)==2;
                elseif n==2
                    x = inputvals{1};
                    bins = inputvals{2};
                    toshow = isnumeric(x) && ismatrix(x) && size(x,1)>1 && size(x,2)==2;
                    if ~toshow
                        varargout{1} = toshow;
                        return;
                    end
                    toshow = isnumeric(bins) && isvector(bins) && length(bins)==2 && ...
                        all(round(bins(:))-bins(:)==0) && all(bins(:)>0);
                    if toshow
                        varargout{1} = toshow;
                        return;
                    end
                    toshow = iscell(bins) && isvector(bins) && length(bins)==2 && isnumeric(bins{1}) && ...
                        isnumeric(bins{2}) && isvector(bins{1}) && isvector(bins{2}) && ...
                        all(diff(bins{1})>=0) && all(diff(bins{2})>=0);
                end
            case 'scatterhist'
                if n==2
                    x = inputvals{1};
                    y = inputvals{2};
                    toshow = isnumeric(x) && ~isscalar(x) && isvector(x) && isvector(y) && ...
                        isnumeric(y) && length(x)==length(y);
                elseif n==3
                    x = inputvals{1};
                    y = inputvals{2};
                    z = inputvals{3};
                    toshow_xy = isnumeric(x) && ~isscalar(x) && isvector(x) && isvector(y) && ...
                        length(x)==length(y);
                    toshow = toshow_xy && (ischar(z) && size(z,1)==length(x) || ...
                        (isvector(z) && length(z)==length(x) && (isnumeric(z) || iscellstr(z) || isstring(z) || isa(z,'categorical'))));
                end
            case 'gplotmatrix'
                if n==3
                    x = inputvals{1};
                    y = inputvals{2};
                    group = inputvals{3};
                    toshow = isLikeNumeric(x) && ismatrix(x) ...
                        &&   isLikeNumeric(y) && ismatrix(y) ...
                        && (~isvector(x) || ~isvector(y)) ...
                        && size(x,1)==size(y,1);
                    toshow = toshow && localCheckValidGroup(x,group,1);
                end
            case 'parallelcoords'
                if n==1
                    X = inputvals{1};
                    toshow = isLikeNumeric(X) && ~isvector(X) && ismatrix(X);
                end
            case 'andrewsplot'
                if n==1
                    x = inputvals{1};
                    toshow = isLikeNumeric(x) && ~isscalar(x) && ismatrix(x) && ~isinteger(x);
                end
            case 'glyphplot'
                if n==1
                    X = inputvals{1};
                    toshow = isLikeNumeric(X) && ~isscalar(X) && ismatrix(X) && ~isinteger(X);
                end
            case 'faces glyph plot'
                if n==1
                    X = inputvals{1};
                    toshow = isLikeNumeric(X) && ~isscalar(X) && ismatrix(X) && ~isinteger(X) && size(X,2)<=17;
                end
            case 'controlchart'
                if n==1
                    X = inputvals{1};
                    toshow =  (isfloat(X) && ~isvector(X) && ismatrix(X)) || ...
                        (isa(X,'timeseries') && size(X.Data,2)>1);
                elseif n==2
                    x = inputvals{1};
                    group = inputvals{2};
                    toshow =  isfloat(x) && ~isscalar(x) && ismatrix(x) && ...
                        localCheckValidGroup(x,group,1);
                end
            case 'dendrogram'
                if n==1
                    x = inputvals{1};
                    toshow = isnumeric(x) && ismatrix(x) && size(x,1)>1 && size(x,2)==3;
                elseif n==2
                    x = inputvals{1};
                    p = inputvals{2};
                    toshow = isnumeric(x) && ismatrix(x) && size(x,1)>1 && size(x,2)==3 && ...
                        isscalar(p) && p>=0 && round(p)==p;
                end
                
            case {'residprob' 'residhist' 'residfitted'}
                if n==1
                    x = inputvals{1};
                    toshow = isa(x,'LinearModel') || isa(x,'NonLinearModel') || isa(x,'GeneralizedLinearModel');
                end
            case {'effects'}
                if n==1
                    x = inputvals{1};
                    toshow = isa(x,'LinearModel');
                end
            case {'slice'}
                if n==1
                    x = inputvals{1};
                    toshow = isa(x,'LinearModel') || isa(x,'NonLinearModel');
                end
        end
    end
    varargout{1} = toshow;
elseif strcmp(action,'defaultdisplay') 
    dispStr = '';
    switch lower(fname)
        case 'normal probability plot'
            dispStr =  ['probplot(''normal'',' inputnames{1} ');figure(gcf)'];
        case 'weibull probability plot'
            dispStr =  ['probplot(''weibull'',' inputnames{1} ');figure(gcf)'];
        case 'faces glyph plot'
            dispStr =  ['glyphplot(' inputnames{1} ',''glyph'',''face'');figure(gcf)'];
        case 'residuals fitted'
            dispStr =  ['plotResiduals(' inputnames{1} ',''fitted'');figure(gcf)'];
        case 'residuals probplot'
            dispStr =  ['plotResiduals(' inputnames{1} ',''prob'');figure(gcf)'];
        case 'slice'
            dispStr =  ['plotSlice(' inputnames{1} ');']; % no gcf, plots into hidden handle
        case 'scatterhist'
            if length(inputnames) == 3
                dispStr = ['scatterhist(' inputnames{1} ',' inputnames{2} ',''group'',' inputnames{3} ');figure(gcf)'];
            else
                dispStr = ['scatterhist(' inputnames{1} ',' inputnames{2} ');figure(gcf)'];
            end
    end
    varargout{1} = dispStr;
end



function validGroup = localCheckValidGroup(x,group,matrixdim)
% matrixdim specifies the dimension along which group applies to x

if iscell(group)
    % If this is a valid single group then test it
    if (isvector(x) && isvector(group) && length(group)==size(x,1)) || ...
       (~isvector(x) && isvector(group) && length(group)==size(x,matrixdim))
        validGroup = true;
        return;
    % Otherwise, maybe group is a cell array of groups. If any are invalid 
    % then return false.
    else
        for k=1:numel(group)
            if ~localCheckValidGroup(x,group{k},matrixdim)
               validGroup = false;
               return;
            end
        end
        validGroup = true;
        return
    end
end

% Check validity of numeric and char array groups
if ischar(group)
    validGroup = (~isvector(x) && size(group,1)==size(x,matrixdim)) || ...
        (isvector(x) && size(group,1)==size(x,1));
else
    validGroup = (isvector(x) && isvector(group) && length(group)==size(x,1)) || ...
           (~isvector(x) && isvector(group) && length(group)==size(x,matrixdim));
end

% function returns true if an unsupported type like datetime, duration or
% calendarDuration is selected in the Workspace Browser
function unsupportedObject = unsupportedObjectSelection(fname,inputvals, n)
unsupportedObject = false;
if ismember(fname,{'gscatter' 'gplotmatrix' 'glyphplot' 'parallelcoords' 'andrewsplot' 'faces glyph plot'})
    return
end
for k = 1:n
    if isdatetime(inputvals{k}) || isduration(inputvals{k}) || iscalendarduration(inputvals{k})
        unsupportedObject = true;
        return
    end
end

% helper for things that treat datetime and duration like numeric
function tf = isLikeNumeric(x)
tf = isnumeric(x) || isdatetime(x) || isduration(x);
