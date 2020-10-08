function [catNumbers,catLabels] = categoryNumbersAndLabels(inputData,edges)
%CATEGORYNUMBERSANDLABELS Bin continuous numeric data.
%   This function is specifically to maintain backwards compatibility for the
%   four-input (data,labels,[],edges) syntaxes of nominal and ordinal.
%
%   CATNUMBERS = CATEGORYNUMBERSANDLABELS(A,EDGES) returns the indices of the
%   bins that the elements of X fall into. EDGES is a numeric vector that contains
%   bin edges in monotonically increasing order. An element X(i) falls into the
%   j-th bin if EDGES(j) <= X(i) < EDGES(j+1), for 1 <= j < N where N is the
%   number of bins and length(EDGES) = N+1. The last bin includes the right edge
%   such that it contains EDGES(N) <= X(i) <= EDGES(N+1). For out-of-range
%   values where X(i) < EDGES(1) or X(i) > EDGES(N+1) or isnan(X(i)), BINS(i)
%   returns NaN.
%
%   [CATNUMBERS,CATNAMES] = CATEGORYNUMBERSANDLABELS(A,EDGES) returns category
%   names in the form "[A,B)", where A and B are consecutive values from EDGES.

%   Copyright 2016-2018 The MathWorks, Inc.

try
    if ~isnumeric(inputData) || ~isreal(inputData)
        error(message('MATLAB:categorical:discretize:NonnumericData'));
    elseif ~isnumeric(edges) || ~isreal(edges) || ~isvector(edges) || length(edges) < 2
        error(message('MATLAB:categorical:discretize:InvalidEdges'));
    elseif length(edges)-1 > categorical.maxNumCategories
        error(message('MATLAB:categorical:MaxNumCategoriesExceeded',categorical.maxNumCategories));
    end
    
    if (nargout > 1)
        % Create names from the edges
        catLabels = matlab.internal.datatypes.numericBinEdgesToCategoryNames(edges,false);
    end
    catNumbers = discretize(inputData,edges);
catch ME
    if strcmp(ME.identifier,'MATLAB:discretize:InvalidSecondInput')
        msg = message('MATLAB:histc:InvalidInput');
        ME = MException(msg.Identifier,msg.getString());
    elseif strcmp(ME.identifier,'MATLAB:discretize:DefaultCategoryNamesNotUnique')
        msg = message('MATLAB:categorical:discretize:CantCreateCategoryNames');
        ME = MException(msg.Identifier,msg.getString());
    end
    throwAsCaller(ME);
end
