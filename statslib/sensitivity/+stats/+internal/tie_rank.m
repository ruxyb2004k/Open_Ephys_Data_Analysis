function r = tie_rank(x)
% tie_rank  Sort the input in ranked order
%
%    R = tie_rank(X) returns rank values of X.  X may be a column vector,
%    matrix, or table.  The columns of X are ranked.

%  Copyright 2013-2017 The MathWorks, Inc.

% If input is a table, store variable names and extract table data
inTable = istable(x);
if inTable
    varnames = x.Properties.VariableNames;
    x = table2array(x);
end

% Rank data
r = zeros(size(x));   % preallocate
for ii = 1:size(x,2)
	col = x(:,ii);
	[~, rowidx] = sort(col);
	ranks =  1:numel(col);
	ranks = reshape(ranks, size(col));
	r(rowidx, ii) = ranks;
end

% If input was a table, format output as a table with same variable names
if inTable
    r = array2table(r, 'VariableNames', varnames);
end