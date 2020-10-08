classdef (InferiorClasses = {?matlab.graphics.axis.Axes, ?matlab.ui.control.UIAxes}) ordinal < categorical
%ORDINAL Arrays for ordinal data.
%   NOTE: The ORDINAL class is provided for backwards compatibility.  For new
%   code, create CATEGORICAL arrays with the Orderable property set to true.
%
%   Ordinal arrays are used to store discrete values that have an ordering but
%   are not numeric.  An ordinal array provides efficient storage and
%   convenient manipulation of such data, while also maintaining meaningful
%   labels for the values.
%
%   Use the ORDINAL constructor to create an ordinal array from a numeric,
%   logical, or character array, or from a cell array of strings.  Ordinal
%   arrays can be subscripted, concatenated, reshaped, sorted, etc. much like
%   ordinary numeric arrays.  You can make comparisons between elements of two
%   ordinal arrays, or between an ordinal array and a single string
%   representing a ordinal value.  Type "methods ordinal" for more operations
%   available for ordinal arrays.  Ordinal arrays are often used as grouping
%   variables.
%
%   Each ordinal array carries along a list of possible values that it can
%   store, known as its levels.  The list is created when you create an
%   ordinal array, and you can access it using the GETLEVELS method, or modify
%   it using the ADDLEVELS, MERGELEVELS, or DROPLEVELS methods.  Assignment to
%   the array will also add new levels automatically if the values assigned
%   are not already levels of the array.  The ordering on values stored in an
%   ordinal array is defined by the order of the list of levels.  You can
%   change that order using the REORDERLEVELS method.
%
%   Examples:
%      % Create an ordinal array from integer data
%      quality = ordinal([1 2 3; 3 2 1; 2 1 3],{'low' 'medium' 'high'})
%
%      % Find elements meeting a criterion
%      quality >= 'medium'
%      ismember(quality,{'low' 'high'})
%
%      % Compare two ordinal arrays
%      quality2 = fliplr(quality)
%      quality == quality2
%
%   See also CATEGORICAL, ORDINAL, ORDINAL.

%   Copyright 2006-2019 The MathWorks, Inc.


    methods
        function b = ordinal(a,labels,levels,edges)
%ORDINAL Create an ordinal array.
%   NOTE: The ORDINAL class is provided for backwards compatibility.  For new
%   code, create CATEGORICAL arrays with the Orderable property set to true.
%
%   B = ORDINAL(A) creates an ordinal array from A.  A is a numeric, logical,
%   character, or categorical array, or a cell array of strings. ORDINAL
%   creates levels of B from the sorted unique values in A, and creates
%   default labels for them.
%
%   B = ORDINAL(A,LABELS) creates an ordinal array from A, labeling the levels
%   in B using LABELS.  LABELS is a character array or cell array of strings.
%   ORDINAL assigns the labels to levels in B in order according to the sorted
%   unique values in A.
%
%   B = ORDINAL(A,LABELS,LEVELS) creates an ordinal array from A, with
%   possible levels and their order defined by LEVELS.  LEVELS is a vector
%   whose values can be compared to those in A using the equality operator.
%   ORDINAL assigns labels to each level from the corresponding elements of
%   LABELS.  If A contains any values not present in LEVELS, the levels of the
%   corresponding elements of B are undefined.  Pass in [] for LABELS to allow
%   ORDINAL to create default labels.
%
%   B = ORDINAL(A,LABELS,[],EDGES) creates an ordinal array by binning the
%   numeric array A, with bin edges given by the numeric vector EDGES.  The
%   uppermost bin includes values equal to the rightmost edge.  ORDINAL
%   assigns labels to each level in B from the corresponding elements of
%   LABELS.  EDGES must have one more element than LABELS.
%
%   By default, an element of B is undefined if the corresponding element of A
%   is NaN (when A is numeric), an empty string (when A is character), or
%   undefined (when A is categorical).  ORDINAL treats such elements as
%   "undefined" or "missing" and does not include entries for them among the
%   possible levels for B.  To create an explicit level for those elements
%   instead of treating them as undefined, you must use the LEVELS input, and
%   include NaN, the empty string, or an undefined element.
%
%   You may include duplicate labels in LABELS in order to merge multiple
%   values in A into a single level in B.
%
%   Examples:
%      quality1 = ordinal([1 2 3; 3 2 1; 2 1 3],{'low' 'medium' 'high'})
%      quality2 = ordinal([1 2 3; 3 2 1; 2 1 3],{'high' 'medium' 'low'},[3 2 1])
%      size = ordinal(rand(5,2),{'small' 'medium' 'large'},[],[0 1/3 2/3 1])
%
%   See also CATEGORICAL, ORDINAL, ORDINAL.
%   See also CATEGORICAL, NOMINAL, ORDINAL.

            if nargin>0
                a = convertStringsToChars(a);
            end
            if nargin>1
                labels = convertStringsToChars(labels);
            end
            if nargin>2
                levels = convertStringsToChars(levels);
            end
            
            if nargin == 0
                a = [];
                args = {};
            else
                if ischar(a)
                    if ~ismatrix(a)
                        error(message('MATLAB:categorical:NDCharArrayData'));
                    end
                    a = strtrim(cellstr(a));
                end

                if nargin == 1 % ordinal(a)
                    args = {};
                elseif nargin == 2 % ordinal(a,labels)
                    if ischar(labels), labels = strtrim(cellstr(labels)); end
                    args = {getUniqueValues(a) labels};
                elseif (nargin == 3) || isempty(edges) % ordinal(a,labels,levels) or ordinal(a,labels,levels,[])
                    if ischar(levels), levels = strtrim(cellstr(levels)); end
                    if isempty(labels)
                        args = {levels};
                    else
                        if ischar(labels), labels = strtrim(cellstr(labels)); end
                        args = {levels,labels};
                    end
                elseif isempty(levels) % ordinal(a,labels,[],edges)
                    if isempty(labels)
                        [a,labels] = statslib.internal.categoryNumbersAndLabels(a,edges);
                    else
                        if ischar(labels), labels = strtrim(cellstr(labels)); end
                        a = statslib.internal.categoryNumbersAndLabels(a,edges);
                        if numel(labels) ~= length(edges)-1
                            error(message('MATLAB:categorical:discretize:WrongNumCategoryNames',length(edges),length(edges)-1));
                        end
                    end
                    args = {1:length(labels),labels};
                else % ordinal(a,labels,levels,edges)
                    error(message('MATLAB:categorical:discretize:ValuesetAndEdges'));
                end
            end
            
            % Preserve old nominal/ordinal behavior
            if isa(a,'categorical'), a = removecats(a); end
            
            b = b@categorical(a,args{:},'Ordinal',true);
        end % ordinal constructor
        
        % Backwards compatibility
        function l = getlabels(a)
            %GETLABELS Get level labels of an ordinal array.
            %   S = GETLABELS(A) returns the labels for the levels of the ordinal
            %   array A.  S is a cell array of strings.  S contains the labels ordered
            %   according to the ordering of the levels of A.
            %
            %   See also ORDINAL/GETLEVELS, ORDINAL/ADDLEVELS, ORDINAL/DROPLEVELS, ORDINAL/ISLEVEL,
            %            ORDINAL/MERGELEVELS, ORDINAL/REORDERLEVELS, ORDINAL/SETLABELS.
            l = categories(a)';
        end
        function b = getlevels(a)
            %GETLEVELS Get a ordinal array's levels.
            %   L = GETLEVELS(A) returns the levels for the ordinal array A.  L is a
            %   ordinal vector.
            %
            %   See also ORDINAL/GETLEVELS, ORDINAL/GETLABELS, ORDINAL/ADDLEVELS, ORDINAL/DROPLEVELS, ORDINAL/ISLEVEL,
            %            ORDINAL/MERGELEVELS, ORDINAL/REORDERLEVELS, ORDINAL/SETLABELS.
            b = a;
            b.codes = cast(1:length(a.categoryNames), 'like', a.codes);
        end
        function a = addlevels(a,newlevels)
            %ADDLEVELS Add levels to a ordinal array.
            %   B = ADDLEVELS(A,NEWLEVELS) adds levels to the ordinal array A.  NEWLEVELS
            %   is a cell array of strings or a 2-dimensional character matrix that
            %   specifies the levels to be added.  ADDLEVELS adds the new levels at the
            %   end of A's list of categorical levels.
            %
            %   ADDLEVELS adds new levels, but does not modify the value of any elements.
            %   B will not contain any elements that actually have those new levels as
            %   their value until you assign those levels to some of its elements.
            %
            %   See also ORDINAL/GETLEVELS, ORDINAL/GETLABELS, ORDINAL/DROPLEVELS, ORDINAL/ISLEVEL,
            %            ORDINAL/MERGELEVELS, ORDINAL/REORDERLEVELS, ORDINAL/SETLABELS.
            newlevels = convertStringsToChars(newlevels);
            if ischar(newlevels), newlevels = strtrim(cellstr(newlevels)); end
            a = addcats(a,newlevels,'After',a.categoryNames{end});
        end
        function a = droplevels(a,oldlevels)
            %DROPLEVELS Remove levels from a ordinal array.
            %   B = DROPLEVELS(A) removes unused levels from the ordinal array A.  B
            %   is a ordinal array with the same size and values as A, but whose list
            %   of potential levels includes only those levels of A that are actually
            %   present in some element of A.
            %
            %   B = DROPLEVELS(A,OLDLEVELS) removes levels from the ordinal array A.
            %   OLDLEVELS is a cell array of strings or a 2-dimensional character matrix
            %   that specifies the levels to be removed.
            %
            %   DROPLEVELS removes levels, but does not remove elements.  Elements of B that
            %   correspond to elements of A having levels in OLDLEVELS all become undefined.
            %
            %   See also ORDINAL/GETLEVELS, ORDINAL/GETLABELS, ORDINAL/ADDLEVELS, ORDINAL/ISLEVEL,
            %            ORDINAL/MERGELEVELS, ORDINAL/REORDERLEVELS, ORDINAL/SETLABELS.
            if nargin < 2
                a = removecats(a);
            else
                oldlevels = convertStringsToChars(oldlevels);
                if ischar(oldlevels), oldlevels = strtrim(cellstr(oldlevels)); end
                a = removecats(a,oldlevels);
            end
        end
        function tf = islevel(levels,a)
            %ISLEVEL Test for ordinal array levels.
            %   TF = ISLEVEL(LEVELS,A) returns a logical array the same size as the cell
            %   array of strings LEVELS, containing true (1) where the corresponding
            %   element of LEVELS is a level of the ordinal array A, and false (0)
            %   otherwise.  A need not contain any elements that have values from LEVELS
            %   for ISLEVEL to return true.
            %
            %   LEVELS can also be a single string or a 2-dimensional character matrix.
            %
            %   See also ORDINAL/GETLEVELS, ORDINAL/GETLABELS, ORDINAL/ADDLEVELS, ORDINAL/DROPLEVELS,
            %            ORDINAL/MERGELEVELS, ORDINAL/REORDERLEVELS, ORDINAL/SETLABELS.
            levels = convertStringsToChars(levels);
            if ischar(levels) && ~isrow(levels), levels = strtrim(cellstr(levels)); end
            tf = iscategory(a,levels);
        end
        function a = mergelevels(a,oldlevels,newlevel)
            %MERGELEVELS Merge levels of a ordinal array.
            %   B = MERGELEVELS(A,OLDLEVELS,NEWLEVEL) merges two or more levels of the
            %   ordinal array A into a single new level.  OLDLEVELS is a cell array of
            %   strings or a 2-dimensional character matrix that specifies the levels to be
            %   merged.  Any elements of A that have levels in OLDLEVELS are assigned the
            %   new level in the corresponding elements of B.  NEWLEVEL is a character
            %   string that specifies the new level.
            %
            %   B = MERGELEVELS(A,OLDLEVELS) merges two or more levels of A and uses the
            %   first level in OLDLEVELS as the new level.
            %
            %   See also ORDINAL/GETLEVELS, ORDINAL/GETLABELS, ORDINAL/ADDLEVELS, ORDINAL/DROPLEVELS,
            %            ORDINAL/ISLEVEL, ORDINAL/REORDERLEVELS, ORDINAL/SETLABELS.
            oldlevels = convertStringsToChars(oldlevels);
            if ischar(oldlevels), oldlevels = strtrim(cellstr(oldlevels)); end
            if nargin < 3
                a = mergecats(a,oldlevels);
            else
                newlevel = convertStringsToChars(newlevel);
                a = mergecats(a,oldlevels,newlevel);
            end
        end
        function a = reorderlevels(a,newlevels)
            %REORDERLEVELS Reorder levels in a ordinal array.
            %   B = REORDERLEVELS(A,NEWLEVELS) reorders the levels of the ordinal array A.
            %   NEWLEVELS is a cell array of strings or a 2-dimensional character matrix
            %   that specifies the new order.  NEWLEVELS must be a reordering of LEVELS(A).
            %
            %   The order of the levels of a ordinal array has no mathematical significance,
            %   and is used only for display purposes, and when you convert the categorical
            %   array to numeric values using methods such as DOUBLE or SUBSINDEX, or
            %   compare two arrays using ISEQUAL.
            %
            %   See also ORDINAL/GETLEVELS, ORDINAL/GETLABELS, ORDINAL/ADDLEVELS, ORDINAL/DROPLEVELS,
            %            ORDINAL/ISLEVEL, ORDINAL/MERGELEVELS, ORDINAL/SETLABELS.
            newlevels = convertStringsToChars(newlevels);
            if ischar(newlevels), newlevels = strtrim(cellstr(newlevels)); end
            a = reordercats(a,newlevels);
        end
        function a = setlabels(a,newlevels,levels)
            %SETLABELS Rename levels of a ordinal array.
            %   B = SETLABELS(A,NEWNAMES) renames the levels of the ordinal array A.
            %   NEWNAMES is a cell array of strings or a 2-dimensional character matrix.
            %   NAMES are assigned to levels in the order supplied in NEWNAMES.
            %
            %   B = SETLABELS(A,NEWNAMES,OLDNAMES) renames only the levels specified in
            %   OLDNAMES.  OLDNAMES is a cell array of strings or a 2-dimensional character
            %   matrix.
            %
            %   See also ORDINAL/GETLEVELS, ORDINAL/GETLABELS, ORDINAL/ADDLEVELS, ORDINAL/DROPLEVELS,
            %            ORDINAL/ISLEVEL, ORDINAL/MERGELEVELS, ORDINAL/REORDERLEVELS.
            newlevels = convertStringsToChars(newlevels);
            if ischar(newlevels), newlevels = strtrim(cellstr(newlevels)); end
            if nargin < 3
                a = renamecats(a,newlevels);
            else
                levels = convertStringsToChars(levels);
                if ischar(levels), levels = strtrim(cellstr(levels)); end
                a = renamecats(a,levels,newlevels);
            end
        end
        function c = levelcounts(a,dim)
            %LEVELCOUNTS Count occurrences of each category in a ordinal array.
            %   C = LEVELCOUNTS(A), for a ordinal vector A, counts the number of
            %   elements in A equal to each of A's levels.  The vector C contains
            %   those counts, and has as many elements as A has levels.
            %
            %   For matrices, LEVELCOUNTS(A) is a matrix of column counts.  For N-D
            %   arrays, LEVELCOUNTS(A) operates along the first non-singleton dimension.
            %
            %   C = LEVELCOUNTS(A,DIM) operates along the dimension DIM.
            %
            %   See also ORDINAL/ISLEVEL, ORDINAL/ISMEMBER, ORDINAL/SUMMARY.
            if nargin < 2
                c = countcats(a);
            else
                c = countcats(a,dim);
            end
        end
        function [no,xo] = hist(varargin)
            %HIST  Histogram.
            %   HIST(Y) with no output arguments produces a histogram bar plot of the
            %   counts for each level of the categorical vector Y.  If Y is an M-by-N
            %   categorical matrix, HIST computes counts for each column of Y, and plots
            %   a group of N bars for each categorical level.
            %
            %   HIST(Y,X) plots bars only for the levels specified by X.  X is a
            %   categorical vector, a string array or a cell array of character vectors.
            %
            %   HIST(AX,...) plots into AX instead of GCA.
            %
            %   N = HIST(...) returns the counts for each categorical level.  If Y is a
            %   matrix, HIST works down the columns of Y and returns a matrix of counts
            %   with one column for each coluimn of Y and one row for each cetegorical
            %   level.
            %
            %   [N,X] = HIST(...) also returns the categorical levels to corresponding
            %   each count in N, or corresponding to each column of N if Y is a matrix.
            %
            %   See also NOMINAL/LEVELCOUNTS, NOMINAL/GETLEVELS.
            
            % Convert string and char to cellstr. convertStringsToChars 
            % converts scalar strings to chars which is not allowed
            ind = cellfun(@(x) isstring(x)||ischar(x),varargin(:));
            if any(ind)
                varargin{ind} = cellstr(varargin{ind});
            end
            
            if nargout == 0
                for i = 1:nargin
                    arg_i = varargin{i};
                    if isa(arg_i,'categorical')
                        varargin{i} = categorical(arg_i,'Ordinal',isordinal(arg_i));
                    end
                end
                hist(varargin{:});
            elseif nargout == 1
                [~,ycodes,ctrs] = categoricalHist(varargin{:});
                no = hist(ycodes,ctrs);
            else
                [~,ycodes,ctrs,xnames] = categoricalHist(varargin{:});
                [no, xo] = hist(ycodes,ctrs);
                xo = reshape(xnames,size(xo));
                haveAxes = ishandle(varargin{1});
                y = varargin{1+haveAxes};
                if nargin < 2 + haveAxes % x was not passed in
                    xo = strings2categorical(xo,y);
                else % x was passed in
                    x = varargin{2+haveAxes};
                    if isa(x,'categorical')
                        xo = x;
                    else
                        xo = strings2categorical(xo,y);
                    end
                end
            end
        end
        function [tf,loc] = ismember(a,b,varargin)
            %ISMEMBER True for elements of a categorical array in a set.
            %   LIA = ISMEMBER(A,B) for categorical arrays A and B, returns a logical array
            %   of the same size as A containing true where the elements of A are in B and
            %   false otherwise.  A or B may also be a category name or a cell array of
            %   strings containing category names.
            %
            %   If A and B are both ordinal, they must have the same sets of categories,
            %   including their order.  If neither A nor B are ordinal, they need not have
            %   the same sets of categories, and the comparison is performed using the
            %   category names.
            %
            %   LIA = ISMEMBER(A,B,'rows') for categorical matrices A and B with the same
            %   number of columns, returns a logical vector containing true where the rows
            %   of A are also rows of B and false otherwise.  A or B may also be a cell array
            %   of strings containing category names.
            %
            %   [LIA,LOCB] = ISMEMBER(A,B) also returns an index array LOCB containing the
            %   highest absolute index in B for each element in A which is a member of B
            %   and 0 if there is no such index.
            %
            %   [LIA,LOCB] = ISMEMBER(A,B,'rows') also returns an index vector LOCB
            %   containing the highest absolute index in B for each row in A which is a
            %   member of B and 0 if there is no such index.
            %
            %   In a future release, the behavior of ISMEMBER will change including:
            %     -	occurrence of indices in LOCB will switch from highest to lowest
            %     -	tighter restrictions on combinations of classes
            %
            %   In order to see what impact those changes will have on your code, use:
            %
            %      [LIA,LOCB] = ISMEMBER(A,B,'R2012a')
            %      [LIA,LOCB] = ISMEMBER(A,B,'rows','R2012a')
            %
            %   If the changes in behavior adversely affect your code, you may preserve
            %   the current behavior with:
            %
            %      [LIA,LOCB] = ISMEMBER(A,B,'legacy')
            %      [LIA,LOCB] = ISMEMBER(A,B,'rows','legacy')
            %
            %   See also ISCATEGORY, UNIQUE, UNION, INTERSECT, SETDIFF, SETXOR.
            [varargin{:}] = convertStringsToChars(varargin{:});
            if ischar(a) && ~isrow(a), a = strtrim(cellstr(a)); end
            if ischar(b) && ~isrow(b), b = strtrim(cellstr(b)); end
            if nargout < 2
                tf = ismember@categorical(a,b,varargin{:});
            else
                [tf,loc] = ismember@categorical(a,b,varargin{:});
            end
        end
    end

    methods(Hidden, Static = true)
        function a = empty(varargin)
            if nargin == 0
                codes = [];
            else
                codes = zeros(varargin{:});
                if ~isempty(codes)
                        error(message('MATLAB:class:emptyMustBeZero'));
                end
            end
            a = ordinal(codes);
        end
        
        function b = loadobj(a)
            % If loading an old-style Stats ordinal array, fill in missing properties.
            if isfield(a,'labels')
                acodes = a.codes;
                labels = a.labels(:);
                b = ordinal(acodes, labels, cast(1:length(labels),'like',acodes));                
            else
                b = a;
            end
        end
    end
end

function levels = getUniqueValues(data)
    % Numeric, logical, cellstr, categorical, or anything else
    % that has a unique method.  Cellstr will already have had
    % leading/trailing spaces removed.  Save the index vector
    % for later.
    try
        levels = unique(data(:));
    catch ME
        m = message('MATLAB:categorical:UniqueMethodFailedData');
        throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
    end
    
    % '' or NaN or <undefined> all become <undefined> by default, remove
    % those from the list of levels.
    if iscellstr(levels)
        levels = levels(~cellfun('isempty',levels));
    elseif isfloat(levels)
        levels = levels(~isnan(levels));
    elseif isa(levels,'categorical')
        % can't use categorical subscripting on levels, go directly to the codes
        levels.codes = levels.codes(~isundefined(levels));
    end
end
