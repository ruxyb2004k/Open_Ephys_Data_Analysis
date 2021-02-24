function shiftedAngles = circularShift(v,shift,limits,dim)
% function shiftedAngles = circularShift(M,CircleLimits,shift,dimension)
% circularly shifts all the input values by the specified value on the circle delineated by the limits, 
% the second input must be the circular limits, if no second input is provided or it is
% empty the limits will be assumed as 0 and 360 (degrees on a circle)
% dimension defaults to first non singleton dimension when ommited
if nargin < 3 || isempty(limits)
   limits = [0 360];
end
if nargin < 4 || isempty(dim)
    dim = 1;
end
    
    [v,vShapeParams] = shape2d(v,dim);
    

    limspan = diff(limits);
    pos0 = mean(limits);
    
    m = v+ones(size(v))*diag(shift(:))-pos0; %set mean of distribution to 0°
    m = m/limspan; %scale span to 1
    
    m = exp(2*pi*m*1i);
    
    mAngle = angle(m); %returns angles as -pi to +pi
    mAngle = mAngle/(2*pi); %ensure all are between -0.5 and 0.5 (span of 1);
    shiftedAngles = (mAngle*limspan)+pos0;
    
    shiftedAngles = unshape(shiftedAngles,vShapeParams);
end

function [v,p] = shape2d(v,dim)
    p = [];
    p.origsize = size(v);
    p.permutekey = 1:numel(p.origsize);
    p.permutekey(dim) = 1;
    p.permutekey(1) = dim;
    
    v = permute(v,p.permutekey);
    
    s = size(v);
    p.permutedsize = s;
    p.newsize = [p.permutedsize(1),prod(p.permutedsize(2:end))];  
    
    v = reshape(v,p.newsize);
    
end

function v = unshape(v,p)
    v = reshape(v,p.permutedsize);
    v = permute(v,p.permutekey);
end