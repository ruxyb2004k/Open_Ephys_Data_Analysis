function d = cell2dataset(c,varargin)
%CELL2DATASET Convert cell array to dataset array.
%   D = CELL2DATASET(C) converts the M-by-N cell array C to an (M-1)-by-N
%   dataset array D.  Each column of C becomes a variable in D.  The first
%   row of C contains names for the variables.
%
%   D = CELL2DATASET(C, 'PARAM1', VAL1, 'PARAM2', VAL2, ...) specifies optional
%   parameter name/value pairs that determine how the data in C are converted.
%
%      'ReadVarNames'  A logical value indicating whether or not the first row
%                      of C contains variable names.  Default is true, unless
%                      variables names are specified using the VarNames parameter.
%                      When false, CELL2DATASET creates default variable names.
%      'VarNames'      A cell array of strings containing variable names for
%                      D.  The names must be valid MATLAB identifiers, and must
%                      be unique.
%      'ReadObsNames'  A logical value indicating whether or not the first
%                      column of C contains observation names.  Default is
%                      false.  When true, CELL2DATASET creates observation
%                      names in D using the first column of C, and sets
%                      D.Properties.DimNames to {C{1,1}, 'Variables'}.
%      'ObsNames'      A cell array of strings containing observation names for
%                      D.  The names need not be valid MATLAB identifiers, but
%                      must be unique.
%      'NumCols'       A vector of non-negative integers that determines the
%                      number of columns for each variable in D, by combining
%                      multiple columns in C into a single variable in D.
%                      'NumCols' must sum to SIZE(C,2), or SIZE(C,2)-1 if
%                      'ReadObsNames' is true.
%
%   See also DATASET2CELL, STRUCT2DATASET, DATASET.

%   Copyright 2012-2017 The MathWorks, Inc.

if nargin > 0
    if isstring(c)
        c = cellstr(c);
    end
end

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if ~iscell(c) || ~ismatrix(c)
    error(message('stats:cell2dataset:NDCell'));
end
[nrows,ncols] = size(c);

pnames = {'VarNames' 'ObsNames' 'ReadVarNames' 'ReadObsNames' 'NumCols'};
dflts =  {       []         []      (nrows>0)          false        [] };
[varnames,obsnames,readVarnames,readObsnames,numCols,supplied] ...
    = statslib.internal.parseArgs(pnames, dflts, varargin{:});

haveVarnames = false;
if supplied.VarNames
    if supplied.ReadVarNames
        if readVarnames
            error(message('stats:cell2dataset:VarNamesParamConflict'));
        end
    else
        readVarnames = false;
    end
    haveVarnames = true;
end

haveObsnames = false;
if supplied.ObsNames
    if readObsnames
        error(message('stats:cell2dataset:ObsNamesParamConflict'));
    end
    haveObsnames = true;
elseif readObsnames
    if readVarnames
        dimname = c{1,1};
        obsnames = c(2:end,1);
    else
        obsnames = c(:,1);
    end
    c(:,1) = [];
    ncols = ncols - 1;
    haveObsnames = true;
end

if supplied.NumCols
    if isnumeric(numCols) && isvector(numCols) && ...
            all(round(numCols)==numCols) && all(numCols>=0)
        if sum(numCols)~=ncols
            error(message('stats:cell2dataset:NumColsWrongSum'));
        end
        % The i-th variable in D will have numCols(i) columns.  Create a
        % mapping from vars to those (zero or more) cell columns.  Negative
        % values for numCols are not accepted.
        nvars = length(numCols);
        cumCols = cumsum(numCols);
        var2cols = cell(1,nvars);
        var2cols{1} = 1:cumCols(1);
        for j = 2:nvars
            var2cols{j} = (cumCols(j-1)+1):cumCols(j);
        end
    else
        error(message('stats:cell2dataset:InvalidNumCols'));
    end
else
    % Each column of C becomes a variable in D
    nvars = ncols;
    var2cols = num2cell(1:nvars);
end

if readVarnames
    if supplied.NumCols
        % Create var names by concatenating column names from each group of
        % columns.  However, leave the default names alone for vars that contain a
        % column that had no name, or for vars that contain no columns.
        colnames = c(1,:);
        empties = cellfun('isempty',colnames);
        varnames = dfltDatasetVarNames(nvars);
        for j = find(numCols(:)'>0)
            if all(~empties(var2cols{j}))
                names = colnames(var2cols{j}); names(2,:) = {'_'};
                varnames{j} = [names{1:end-1}];
            end
        end
    else
        varnames = c(1,:);
        empties = cellfun('isempty',varnames);
        if any(empties)
            % Use dataset's default names for columns with empty headers
            dfltnames = dfltDatasetVarNames(nvars);
            varnames(empties) = dfltnames(empties);
        end
    end
    % Modify the names if needed to make them valid, fill in empty strings, and
    % make sure that any names we modified or filled in are not duplicates of
    % valid non-empty names
    if ~isStrings(varnames,true)
        error(message('stats:dataset:setvarnames:InvalidVarnames'));
    end
    [varnames, mods] = matlab.lang.makeValidName(varnames);
    if any(mods) % will warn if mods are made
        warning(message('stats:dataset:ModifiedVarnames'));
    end
    varnames = matlab.lang.makeUniqueStrings(varnames,{},namelengthmax);
    c(1,:) = [];
    haveVarnames = true;
    nrows = nrows - 1;
elseif supplied.VarNames
    % Be consistent with how the constructor handles its VarNames parameter: Do
    % not accept empty names, but make sure the names are valid, and that any
    % names we modified are not duplicates of valid names
    if isString(varnames), varnames = {varnames}; end
    if ~isStrings(varnames,false)
        error(message('stats:dataset:setvarnames:InvalidVarnames'));
    end
    [varnames, mods] = matlab.lang.makeValidName(varnames);
    if any(mods) % will warn if mods are made
        warning(message('stats:dataset:ModifiedVarnames'));
    end    
    varnames = matlab.lang.makeUniqueStrings(varnames,mods,namelengthmax);
    haveVarnames = true;
else % varnames neither supplied nor read from col headers
    baseName = inputname(1);
    if ~isempty(baseName) && (nvars > 0)
        varnames = strcat(baseName,cellstr(num2str((1:nvars)','%-d'))');
        haveVarnames = true;
    end
end

vars = cell(1,nvars);
for j = 1:nvars
    cj = c(:,var2cols{j});
    if isempty(cj) % prevent iscellstr from catching these
        % give these the right number of rows, but no columns
        vars{j} = zeros(size(cj,1),0);
    elseif iscellstr(cj)
        % Prevent a cellstr that happens to have all the same length strings,
        % e.g., datestrs, from being converted into a char matrix.
        vars{j} = cj;
    elseif any(cellfun(@(x)size(x,1),cj(:)) ~= 1)
        % If the cells don't all have one row, we won't be able to
        % concatenate them and preserve observations, leave it as is.
        vars{j} = cj;
    else
        % Concatenate cell contents into a homogeneous array (if all cells
        % of cj contain "atomic" values), a cell array (if all cells of cj
        % contain cells), or an object array (if all the cells of cj
        % contain objects).  The result may have multiple columns or pages
        % if the cell contents did, but each row will correspond to a
        % "row" (i.e., element) of S.  If that fails, leave it as a cell.
        try
            vars_j = cell(1,size(cj,2));
            % Concatenate rows first
            for i = 1:size(cj,2), vars_j{i} = cat(1,cj{:,i}); end
            % Now concatenate multiple columns into a matrix
            vars{j} = cat(2,vars_j{:});
        catch ME %#ok<NASGU>
            vars{j} = cj;
        end
    end
end

if isempty(vars) % creating a dataset with no variables
    % Give the output dataset the same number of rows as the input cell ...
    if haveObsnames % ... using either the supplied observation names
        d = dataset('ObsNames',obsnames);
    else            % ... or by tricking the constructor
        dummyNames = cellstr(num2str((1:nrows)'));
        d = dataset('ObsNames',dummyNames(1:nrows));
        d.Properties.ObsNames = {};
    end
else
    % Create from a scalar struct to prevent the constructor from
    % misinterpreting cells of the form {data string string ...}.
    d = dataset(cell2struct(vars,dfltDatasetVarNames(nvars),2));
    if haveVarnames, d.Properties.VarNames = varnames; end
    if haveObsnames, d.Properties.ObsNames = obsnames; end
end

if readObsnames && readVarnames
    d.Properties.DimNames{1} = dimname;
end


%-----------------------------------------------------------------------
function names = dfltDatasetVarNames(nvars)
dummyVars = cell(1,nvars);
dummy = dataset(dummyVars{:});
names = dummy.Properties.VarNames;


%-----------------------------------------------------------------------
function tf = isString(s)
% Require a (possibly empty) row of chars or ''.
tf = ischar(s) && (isrow(s) || isequal(s,''));


%-----------------------------------------------------------------------
function tf = isStrings(s,allowEmpty)
% ISSTRINGS Require a char row vector, or '', or a cell array of same
if allowEmpty
    stringTest = @(s) ischar(s) && ( isrow(s) || isequal(s,'') );
else
    stringTest = @(s) ischar(s) && isrow(s) && any(s ~= ' ');
end
if iscell(s)
    tf = all(cellfun(stringTest,s,'UniformOutput',true));
else
    tf = false;
end
