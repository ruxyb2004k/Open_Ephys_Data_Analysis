


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handler to intialize the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initHandler(figtype)

% common variables
global gVar;
global gFignum;
SCREENXMAX = 4800;
SCREENXMIN = -1600;
SCREENYMAX = 1600;
SCREENYMIN = 0;

% get next figure number
if (isempty(gFignum)) gFignum = 1;, else gFignum = gFignum + 1;, end

% open the figure
gVar(gFignum).fig = figure;

% set figtype
gVar(gFignum).figtype = figtype;

% set the close handler functions for the figure
set(gVar(gFignum).fig,'CloseRequestFcn',sprintf('smartfig(''close'',%i)',gFignum));

% see if the init file has an initial position
initpos = readInit(figtype,'initpos');

% if it does then reset the position of the figure
if (~isempty(initpos))
  % check position to make sure it is not off screen
  if (initpos(1) > SCREENXMAX)
    initpos(1) = initpos(1)-SCREENXMAX;
  end
  if ((initpos(1)+initpos(3)) < SCREENXMIN)
    initpos(1) = initpos(1)+SCREENXMAX;
  end
  if (initpos(2) > SCREENYMAX)
    initpos(2) = initpos(2)-SCREENYMAX;
  end
  if ((initpos(2)+initpos(4)) < SCREENYMIN)
    initpos(2) = initpos(2)+SCREENYMAX;
  end
  % see if we are running on unix, and displaying on yoyodyne
  % since there is some annoying drift of the size
%  if (isunix)
%    [s w] = system('setenv | grep DISPLAY');
%    if (findstr('yoyodyne',w))
%      barheight = 22;
%      initpos(2) = initpos(2)+barheight;
%      initpos(4) = initpos(4)-barheight;
%    end
%  end
  % set the positio
  set(gVar(gFignum).fig,'Position',initpos);
end
% turn off menus
%set(gVar(gFignum).fig,'MenuBar','none');

% set up buttons
gVar(gFignum).buttons.close = ...
uicontrol('Style','pushbutton',...
          'String','Close',...
          'Callback',...
	  sprintf('smartfig(''close'',%i)',gFignum),...
	  'Position',buttonpos(1,1));

set(gVar(gFignum).fig,'Name',figtype);

