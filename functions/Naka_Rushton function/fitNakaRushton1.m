% fitNakaRushton.m
%
%        $Id:$ 
%      usage: fit = fitNakaRushton(c,r)
%         by: justin gardner
%       date: 12/24/13
%    purpose: fit a naka-rushton to data (taken from selectionModel)
%

function fit = fitNakaRushton(c,r,varargin)

% check arguments
if nargin < 2
  help fitNakaRushton
  return
end

% parse arguments
% getArgs(varargin,{'dispFit=0','evalFit=[]'});
dispFit=0;
evalFit=c;
% find contrast that evokes closest to half-maximal response
rMid = ((max(r)-min(r))/2) + min(r);
[dummy,rMidIndex] = min(abs(r-rMid));
initC50 = c(rMidIndex(1));

% parmaeters
             %Rmax          c50         n     offsets x 5
initParams = [max(r)        initC50     2       min(r)];
minParams =  [0             .1           1      -inf];
% maxParams =  [inf           1           5       inf];
maxParams =  [1             .9           5       inf];

% set model type
m.fixedN = 0;
m.dispFit = dispFit;
% optimization parameters
maxiter = inf;
optimParams = optimset('MaxIter',maxiter,'Display','off');

% now go fit
[params resnorm residual exitflag output lambda jacobian] = lsqnonlin(@nakaRushtonResidual,initParams,minParams,maxParams,optimParams,c,r,m);

% parse params and return
fit = parseParams(params,m);

% if evalFit is set then eval at every contrast specified in that variable
if ~isempty(evalFit)
  fit.cFit = evalFit;
  fit.rFit = nakaRushton(evalFit,fit);
end
%% R2
Rfit=fit.rFit;
SSreg=(Rfit-r).^2;
SStot=(Rfit-mean(r)).^2;
fit.Rsqr=1-(sum(SSreg)./sum(SStot));