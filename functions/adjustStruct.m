function structExp = adjustStruct(structExp)   

s = inputname(1);

switch s 
%     case 'sessionInfo'
%        
%     case 'timeSeries'    
%        
%     case 'spikeClusterData'
       
    case 'clusterTimeSeries'
        structExp.iSelectedCodesInd = false(1,size(structExp.spikeInTrials,2));
        structExp.iSelectedCodesInd(structExp.selectedCodesInd) = true;
        structExp.iSelectedCodesIndSpont = nan(1,size(structExp.spikeInTrials,2));
        structExp.iSelectedCodesIndSpont(structExp.selectedCodesInd) = structExp.selectedCodesIndSpont;
        
        sz = size(structExp.traceByTrial);
        if sum(sz)
            sz_nan = sz;
            sz_nan(3) = 25 - sz_nan(3); % complete with nans until trial 25
            structExp.traceByTrial = cat(3, structExp.traceByTrial, nan(sz_nan));
        end
%     case 'cellMetrics' 

end        