function [index] = index_1(x,y)
%INDEX_1 (x-y)/(x+y)
%   Compare the size of two different variables.
%   The larger x in comparison to y, the closer index will be to 1
%   The smaller x in comparison to y, the closer index will be to -1

index = (x-y)/(x+y);

end

