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
%     case 'cellMetrics' 

end        