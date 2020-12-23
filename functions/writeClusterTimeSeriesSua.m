%%% Code created on 29.10.2020 by RB

% Stats 1

clusterTimeSeries.spikeInTrials = spikeInTrials;
if numel(goodCodes) %exist('spikeByTrial', 'var')
    clusterTimeSeries.spikeByTrial = spikeByTrial;
    clusterTimeSeries.amplByTrial = amplByTrial;
    clusterTimeSeries.traceByTrial = traceByTrial;
    clusterTimeSeries.maxTraceByTrial = maxTraceByTrial;
    clusterTimeSeries.baselineByTrial = baselineByTrial;
else    
    clusterTimeSeries.spikeByTrial = [];
    clusterTimeSeries.amplByTrial = [];
    clusterTimeSeries.traceByTrial = [];
    clusterTimeSeries.maxTraceByTrial = [];
    clusterTimeSeries.baselineByTrial = [];
end

clusterTimeSeries.bin = bin;

clusterTimeSeries.traceFreqGood = traceFreqGood;
clusterTimeSeries.traceFreqGoodSel = traceFreqGoodSel;

clusterTimeSeries.statsSua.keepTrials = keepTrials;
clusterTimeSeries.statsSua.keepTrialsBase = keepTrialsBase;

clusterTimeSeries.statsSua.statsCodesInd = statsCodesInd;
clusterTimeSeries.statsSua.hSua = hSua;
clusterTimeSeries.statsSua.pSua = pSua;
clusterTimeSeries.statsSua.hSuaW = hSuaW;
clusterTimeSeries.statsSua.pSuaW = pSuaW;

clusterTimeSeries.statsSua.hSuaBase = hSuaBase;
clusterTimeSeries.statsSua.pSuaBase = pSuaBase;
clusterTimeSeries.statsSua.hSuaBaseW = hSuaBaseW;
clusterTimeSeries.statsSua.pSuaBaseW = pSuaBaseW;

clusterTimeSeries.statsSua.hSuaBaseSameCond = hSuaBaseSameCond;
clusterTimeSeries.statsSua.pSuaBaseSameCond = pSuaBaseSameCond;
clusterTimeSeries.statsSua.hSuaBaseSameCondW = hSuaBaseSameCondW;
clusterTimeSeries.statsSua.pSuaBaseSameCondW = pSuaBaseSameCondW;

clusterTimeSeries.statsSua.hSuaBaseComb = hSuaBaseComb;
clusterTimeSeries.statsSua.pSuaBaseComb = pSuaBaseComb;
clusterTimeSeries.statsSua.hSuaBaseCombW = hSuaBaseCombW;
clusterTimeSeries.statsSua.pSuaBaseCombW = pSuaBaseCombW;

