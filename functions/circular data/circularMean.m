function [meanAngle,meanMagnitude,m,preMeanComplex] = circularMean(m,lims,dim)
% function [meanAngle,meanMagnitude,complexMean,complexInput] = circularMean(M,CircleLimits,dimension)
% calculates the circular mean of the input variables, the second input
% must be the circular limits, if no second input is provided or it is
% empty the limits will be assumed as 0 and 360 (degrees on a circle)
% dimension defaults to first non singleton dimension when ommited
%
% instead of a dimension a function handle can be provided that will take
% the place of the mean function

% 2019-04-25 Robert Staadt - changed the transformation to alingn 0° on the
%   transitional circle with the mean between the limits instead of the first limit

if nargin < 2 || isempty(lims)
   lims = [0 360];
end
if nargin <3 || isempty(dim)
    meanfunc = @(x) mean(x);
elseif isa(dim,'function_handle')
    meanfunc = dim;
else
    meanfunc = @(x) mean(x,dim);
end
limspan = diff(lims);
limcenter = mean(lims);
%%
m = m-limcenter; %set center of limits to 0°
m = m/limspan; %scale span to 1

m = exp(2*pi*m*1i);

% figure;
% plot(m,'k.')
% axis equal
% hold on
if nargout >=4
    preMeanComplex = m;
end

m = meanfunc(m);

meanAngle = angle(m); %returns angle as -pi to +pi
meanAngle = meanAngle/(2*pi); % make span 1 again
meanAngle = meanAngle*limspan+limcenter;

meanMagnitude = abs(m);
end

