function a = setproperty(a,name,p)
%SETPROPERTY Set a dataset array property.

%   Copyright 2006-2017 The MathWorks, Inc.


% We may be given a name (when called from set), or a subscript expression
% that starts with a '.name' subscript (when called from subsasgn).  Get the
% name and validate it in any case.
if nargin > 1
    name = convertStringsToChars(name);
end

if nargin > 2
    p = convertStringsToChars(p);
    
end

if isstruct(name)
    s = name;
    if s(1).type == '.'
        name = s(1).subs;
    else
        error(message('stats:dataset:setproperty:InvalidSubscript'));
    end
    haveSubscript = true;
else
    haveSubscript = false;
end
% Allow partial match for property names if this is via the set method;
% require exact match if it is direct assignment via subsasgn
name = matchpropertyname(a,name,haveSubscript);

if haveSubscript && ~isscalar(s)
    % If there's cascaded subscripting into the property, get the existing
    % property value and let the property's subsasgn handle the assignment.
    % This may change its shape or size or otherwise make it invalid; that
    % gets checked by the individual setproperty methods called below.  The
    % property may currently be empty, ask for a non-empty default version to
    % allow assignment into only some elements.
    oldp = getproperty(a,name,true);
    p = subsasgn(oldp,s(2:end),p);
end

% Convert chars to cell strings for the following properties.
% convertStringsToChars may have converted strings to chars instead of
% cellstrs
if ischar(p) && ismember(name,{'ObsNames','VarNames','DimNames',...
        'VarDescription','Units'})
    p = cellstr(p);
end

% Assign the new property value into the dataset.
switch name
case 'ObsNames'
    a = setobsnames(a,p);
case 'VarNames'
    % Allow modification (with warning) of names to make them valid if this
    % is via the set method; do not if it is direct assignment via subsasgn
    a = setvarnames(a,p,[],~haveSubscript);
case 'DimNames'
    a = setdimnames(a,p);
case 'VarDescription'
    a = setvardescription(a,p);
case 'Units'
    a = setunits(a,p);
case 'Description'
    a = setdescription(a,p);
case 'UserData'
    a = setuserdata(a,p);
end
