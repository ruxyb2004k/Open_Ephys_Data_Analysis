%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates the position of button on the page
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pos] = buttonpos(row,col)

bwidth = 50;
bheight = 20;
marginsize = 5;
buttontop=10;

% left position
pos(1) = marginsize + (bwidth+marginsize)*(col-1);
pos(2) = buttontop + (bheight+marginsize)*(row-1);
pos(3) = bwidth;
pos(4) = bheight;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handler to close the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closeHandler(fignum)

% common variables
global gVar;

% if gVar does not have fig number, then it means
% that we must have cleared all variables, so there
% is no info remaining about the figure. just close it
% without saving then.
if length(gVar) < fignum
  closereq
  return
end

% make sure the fig number is valid
if gVar(fignum).fig == 0
  closereq
  return
end

% make sure we are switched to the figure
figure(gVar(fignum).fig);

huh = get(gVar(fignum).fig);
if ~isfield(huh,'Position')
  disp(sprintf('HUH: Figure %i does not have position',gVar(fignum).fig));
  return
end

% get position and save in init file
writeInit(gVar(fignum).figtype,'initpos',get(gVar(fignum).fig,'Position'));

% reset figure number
gVar(fignum).fig = 0;
gVar(fignum).closetime = datestr(now);
gVar(fignum).closepos = huh.Position;
% close the figure
closereq;
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to write a value to the init file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function writeInit(figtype,name,value)

% initfile path and name
global initpath;
initname = 'smartfig';

% just call it .smartfig.mat
fullinitname = sprintf('.smartfig.mat');

%disp(sprintf('Saving to: %s',[initpath fullinitname]));

% see if we have a file
finit = fopen([initpath fullinitname],'r');
if (finit ~= -1)
  % close the file
  fclose(finit);
  % get init variable since it already exisits
  load([initpath fullinitname])
end

% set the name,value pair
eval(sprintf('%s.%s.%s = value;',initname,figtype,name));

% write it to the file
if (str2num(first(version)) < 7)
  eval(sprintf('save %s %s;',[initpath fullinitname],initname));
else
  eval(sprintf('save %s %s -V6;',[initpath fullinitname],initname));
end
