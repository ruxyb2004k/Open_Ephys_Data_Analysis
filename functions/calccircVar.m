function [circVar,theta] = calccircVar(data,radians)
% This function calculates the circular Variance (1 - r) and the polar X
% position of the maximum (theta) that is being calculated as a byproduct
% Heavily inspired by the circular statistsics toolbox. 
% See page of toolbox for information on citing.


r = sum(data'.*exp(1i*2*radians));

theta = rad2deg(angle(r)/2); 
% convert from -180 : 180 datarange to 0:180
theta = mod(theta, 180);

r = abs(r)./sum(data);
circVar = 1-r;

end

