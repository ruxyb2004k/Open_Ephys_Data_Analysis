function [structAll] = addToStruct(structExp, structAll)

s = inputname(1);

switch s % <; is 1>, <, is 2>
%     case 'sessionInfo'
%        
%     case 'timeSeries'    
%        
%     case 'spikeClusterData'
       
    case 'clusterTimeSeries'
%         dimCatFields.selectedCodesIndSpont = 2;
        structExp.iSelectedCodesInd = false(1,size(structExp.spikeInTrials,2));
        structExp.iSelectedCodesInd(structExp.selectedCodesInd) = true; 
        structExp.iSelectedCodesIndSpont = nan(1,size(structExp.spikeInTrials,2));
        structExp.iSelectedCodesIndSpont(structExp.selectedCodesInd) = structExp.selectedCodesIndSpont; 
        dimCatFields.iSelectedCodesInd = 2;
        dimCatFields.iSelectedCodesIndSpont = 2;
        
    case 'cellMetrics'        
        dimCatFields.waveformDataFilt = 2;
        dimCatFields.indivTrough = 2;
        dimCatFields.waveformCodes = 1;
        dimCatFields.waveformFiltAvgNorm = 1;
        dimCatFields.waveformFiltAvg = 1;
        dimCatFields.peakTroughRatio = 2;
        dimCatFields.troughPeakTime = 2;
        dimCatFields.peakAsymmetry = 2;
        dimCatFields.minCh = 2;
        dimCatFields.normMinCh = 2;
        dimCatFields.iMinCh = 2;
        dimCatFields.visitedCh = 2;        
        
end

        
        
fields = fieldnames(dimCatFields);

for fieldInd = 1:numel(fields)
    field = char(fields(fieldInd));
    structAll.(field) = cat(dimCatFields.(field), structAll.(field),structExp.(field));
end

        

