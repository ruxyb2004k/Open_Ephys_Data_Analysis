classdef FittableParametricDistribution < prob.FittableDistribution
%FittableDistribution Base class for fittable probability distributions.
    
%   Copyright 2012 The MathWorks, Inc.

    properties(GetAccess='public',SetAccess='protected')
%ParameterCovariance Covariance matrix of parameter estimates.
%    ParameterCovariance is an N-by-N matrix, where N is the number of
%    parameters in the distribution. The (I,J) element is the estimated
%    covariance between the estimates of the Ith parameter and the Jth
%    parameter. The (I,I) element is the estimated variance of the Ith
%    parameter estimate.
%
%    If parameter I is fixed rather than estimated by fitting to data, then
%    the Ith row and column of the matrix are zero.
%
%    See also ParameterValues, ParameterNames, ParameterIsFixed.
        ParameterCovariance = [];

%ParameterIsFixed Fixed parameters.
%    ParameterIsFixed is a boolean vector of length N, where N is the
%    number of parameters in the distribution. The Ith element is true if
%    the Ith parameter is fixed, or false if it is estimated by fitting to
%    data.
%
%    See also ParameterValues, ParameterNames, ParameterCovariance.
        ParameterIsFixed = false(0,1);
    end 
    
    methods
        ci = paramci(this,varargin)
        [ll,param,others] = proflik(this,pnum,param,pStart)
    end
    
end % classdef
