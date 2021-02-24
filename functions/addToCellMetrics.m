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
        dimCatFields.putativeCellType = 1; %!!! untested
        dimCatFields.putativeConnections.excitatory = 1;
        dimCatFields.putativeConnections.inhibitory = 1;  
%         dimCatFields.acg_metrics = 2;

                        
end

        
structAll = addToStructNested(structExp, structAll, dimCatFields);

% !!!everything needs to be tested!!!
function [structAll] = addToStructNested(structExp, structAll, dimCatFields)
fields = fieldnames(dimCatFields);

for fieldInd = 1:numel(fields)
    field = char(fields(fieldInd));
    if isstruct(dimCatFields.(field))% !!! untested
        structAll = addToStructNested(structExp.(field),structAll.(field), dimCatFields.(field));
    else
        structAll.(field) = cat(dimCatFields.(field), structAll.(field),structExp.(field));
    end
end

        

