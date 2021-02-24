function [stdAngle,new0,preMeanComplex] = circularStd(m,lims,dim)
% function [stdAngle,meanAngle,complexInput] = circularStd(M,CircleLimits,dimension)
% calculates the circular std of the input variables, the second input
% must be the circular limits, if no second input is provided or it is
% empty the limits will be assumed as 0 and 360 (degrees on a circle)
% dimension defaults to first non singleton dimension when ommited
%
% instead of a dimension a function handle can be provided that will take
% the place of the std function

% created 2019-04-25 Robert Staadt
if nargin < 2 || isempty(lims)
   lims = [0 360];
end
if nargin <3 || isempty(dim)
    varfunc = @(x) std(x);
    dim = [];
elseif isa(dim,'function_handle')
    varfunc = dim;
    dim = [];
else
    varfunc = @(x) std(x,[],dim);
end

new0 = circularMean(m,lims,dim);

limspan = diff(lims);
%%
m = m-new0; %set mean of distribution to 0°
m = m/limspan; %scale span to 1

m = exp(2*pi*m*1i);

% figure;
% plot(m,'k.')
% axis equal
% hold on
if nargout >=2
    preMeanComplex = m;
end


mAngle = angle(m); %returns angles as -pi to +pi
mAngle = mAngle/(2*pi); %ensure all are between -0.5 and 0.5 (span of 1);
stdAngle = varfunc(mAngle)*limspan;%take std and scale back to the original limit span 

end

