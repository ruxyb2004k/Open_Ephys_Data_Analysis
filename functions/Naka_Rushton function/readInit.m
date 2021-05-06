%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to read a value to the init file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [value] = readInit(figtype,name)

% initfile path and name
global initpath;
initname = 'smartfig';

% just call it .smartfig.mat
fullinitname = sprintf('.smartfig.mat');

%disp(sprintf('smartfig %s',fullinitname));
% see if we have a file
try
  finit = fopen([initpath fullinitname],'r');
catch
  disp(sprintf('ERROR %s',lasterr));
  disp(sprintf('UHOH: ERROR OPENING %s',fullinitname));
  value = [];
  return;
end

% check if the init var exists
if (finit ~= -1)
  % close the file
  fclose(finit);
  % get init variable since it already exisits
  load([initpath fullinitname])
  % convert the name to initvar
  eval(sprintf('initvar = %s;',initname));
else
  % no init variable so the field does not exist
  value = [];
  return;
end

% get the name,value pair
if (isfield(initvar,figtype) & ...
    (isfield(eval(sprintf('initvar.%s',figtype)),name)))
  eval(sprintf('value = initvar.%s.%s;',figtype,name));
else
  value = [];
end
