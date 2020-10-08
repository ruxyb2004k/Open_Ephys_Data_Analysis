classdef ParametricDistribution 
%PARAMETRICDISTRIBUTION Base class for parametric probability distributions.
    
%   Copyright 2012 The MathWorks, Inc.

    properties(GetAccess='public',Constant=true,Abstract=true)
%NumParameters Number of parameters in the distribution.
%   NumParameters is a positive integer indicating the number of parameters
%   in the distribution. This number includes all fixed and estimated
%   parameters.
%
%   See also ParameterValues, ParameterNames, ParameterDescription.
        NumParameters

%ParametersNames Names of the parameters in the distribution.
%   ParametersNames is a cell array or strings containing the names of the
%   parameters in the distribution.
%
%   See also ParameterValues, NumParameters, ParameterDescription.
        ParameterNames

%ParametersDescription Description of the parameters in the distribution.
%   ParametersDescription is a cell array or strings containing the short
%   descriptions of the parameters in the distribution.
%
%   See also ParameterValues, ParameterNames, NumParameters.
        ParameterDescription
    end
    
    properties(GetAccess='public',SetAccess='protected',Abstract=true)
%ParameterValues Values of the parameters in the distribution.
%   ParametersValues is a vector containing values of the parameters in
%   the distribution. The values may represent specified values if the
%   distribution was created directly, or estimated values if the
%   distribution was created by fitting to data.
%
%   See also ParameterNames, NumParameters, ParameterDescription.
        ParameterValues
    end
    
%     methods
%         function m = mean(this)
% %MEAN Mean of the distribution.
% %   M = MEAN(PD) returns the mean M of the probability distribution PD.
% %
% %   Example: Create a Weibull distribution and demonstrate that its mean
% %            is larger than its median.
% %        p = makedist('weibull', 'A',200, 'B',1.1)
% %        wmean = mean(p)
% %        wmedian = median(p)
% %
% %   See also VAR, STD, ParameterValues.
%             error(message('stats:probdists:NoMethod','mean'));
%         end
%         function v = var(this)
%  %VAR Variance of the distribution.
% %   V = VAR(PD) returns the variance V of the probability distribution PD.
% %
% %   Example: Create a Weibull distribution and compute its variance.
% %        p = makedist('weibull', 'A',20, 'B',1.1)
% %        var(p)
% %
% %   See also MEAN, STD, ParameterValues.
%             error(message('stats:probdists:NoMethod','var'));
%         end
%         function s = std(this)
% %STD Standard deviation of the distribution.
% %   S = STD(PD) returns the standard deviation S of the probability
% %   distribution PD.
% %
% %   Example: Create a Weibull distribution and compute its standard
% %            deviation.
% %        p = makedist('weibull', 'A',20, 'B',1.1)
% %        std(p)
% %
% %   See also VAR, MEAN, ParameterValues.
%             s = sqrt(var(this));
%         end
%     end

end
