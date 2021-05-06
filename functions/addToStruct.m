function [structAll] = addToStruct(structExp, structAll)

s = inputname(1);

switch s % <; is 1>, <, is 2>
%     case 'sessionInfo'
%        
%     case 'timeSeries'    
%        
    case 'spikeClusterData'
        dimCatFields.goodCodes = 1;
       
    case 'clusterTimeSeries'
%         dimCatFields.selectedCodesIndSpont = 2; % keep commented

        dimCatFields.iSelectedCodesInd = 2;
        dimCatFields.iSelectedCodesIndSpont = 2;
        % comment out the next 10 lines when only looking at fig 15
%         dimCatFields.traceFreqGood = 2;
%         dimCatFields.traceFreqGoodSel = 2;
%         dimCatFields.statsSua.pSua = 2;
%         dimCatFields.statsSua.pSuaW = 2;
%         dimCatFields.statsSua.pSuaBase = 2;
%         dimCatFields.statsSua.pSuaBaseW = 2;
%         dimCatFields.statsSua.pSuaBaseSameCond = 2;
%         dimCatFields.statsSua.pSuaBaseSameCondW = 2;
%         dimCatFields.statsSua.pSuaBaseComb = 1;
%         dimCatFields.statsSua.pSuaBaseCombW = 1;
        
    case 'cellMetrics'        
%         dimCatFields.waveformDataFilt = 2;
        dimCatFields.indivTrough = 2;
        dimCatFields.waveformCodes = 1;
        dimCatFields.waveformFiltAvgNorm = 1;
        dimCatFields.waveformFiltAvg = 1;
        dimCatFields.peakTroughRatio = 2;
        dimCatFields.troughPeakTime = 2;
        dimCatFields.peakAsymmetry = 2;
%         dimCatFields.minCh = 2;
%         dimCatFields.normMinCh = 2;
%         dimCatFields.iMinCh = 2;
%         dimCatFields.visitedCh = 2;   
        dimCatFields.putativeCellType = 1; % from here on it needs double checking
        dimCatFields.putativeConnections.excitatory = 1;
        dimCatFields.putativeConnections.inhibitory = 1;  
        dimCatFields.fft_metrics.P1 = 2;
        dimCatFields.fft_metrics.M = 1;
        dimCatFields.fft_metrics.maxI = 1;
        dimCatFields.fft_metrics.maxF = 1;
        dimCatFields.fft_metrics.snrM = 1;
        
        fields = fieldnames(structExp.acg_metrics);
        for fieldInd = 1:numel(fields)
            field = char(fields(fieldInd));
            dimCatFields.acg_metrics.(field) = 2;
        end  
        
end

        
        
fields = fieldnames(dimCatFields);

for fieldInd = 1:numel(fields)
    field = char(fields(fieldInd));    
    if isa(dimCatFields.(field), 'struct')
        fields2ndLevel = fieldnames(dimCatFields.(field));
        for field2ndLevelInd = 1:numel(fields2ndLevel)
            field2ndLevel = char(fields2ndLevel(field2ndLevelInd));
            structAll.(field).(field2ndLevel) = cat(dimCatFields.(field).(field2ndLevel), structAll.(field).(field2ndLevel),structExp.(field).(field2ndLevel));
        end    
    else
        structAll.(field) = cat(dimCatFields.(field), structAll.(field),structExp.(field));
    end    
end

        

