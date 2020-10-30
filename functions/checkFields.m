%%% checkFields created by RB on 13.10.2020 %%% 
function out = checkFields(struct)
out = 0;
s = inputname(1);

switch s
    case 'sessionInfo'
        fields = {'session', 'nChannels', 'recordingDepth', 'conditionNames', 'trialDuration',...
            'preTrialTime', 'afterTrialTime', 'visStim', 'optStimInterval', 'probe', 'animal',...
            'recRegion', 'rates', 'condData', 'chOffset', 'nShanks'};
        
    case 'timeSeries'    
        fields = {'recStartDataPoint', 'events', 'dataPoints', 'timestamps', 'info', 'medCh', 'stdCh',...
            'range1', 'range2', 'subTrialsForAnalysis', 'timestampsRange', 'trialsForAnalysis', 'gain'};
        
    case 'spikeClusterData'        
        fields = {'clusterSoftware', 'trialsForAnalysisSelected', 'times', 'channelPosition',...
            'codes', 'uniqueCodes', 'uniqueCodesLabel', 'uniqueCodesChannel', 'uniqueCodesDepth',...
            'uniqueCodesRealDepth', 'rangeTimes', [struct.clusterSoftware, 'Time'], 'unclCodes', 'goodCodes', 'muaCodes'...
            'noiseCodes', 'spikeTimes', 'ACC25', 'refrPeriodRatio', 'presence', 'falsePos', 'adjGraph', 'channelShank'};
        if strcmp(struct.clusterSoftware, 'kilosort')
            fields{end+1} = 'uniqueCodesContamPct'; 
        end    
        
    case 'clusterTimeSeries'
        fields = {'selectedCodes', 'selectedCodesDepth', 'selectedCodesInd', 'selectedCodesIndSpont',...
            'spikeInTrials', 'spikeByTrial', 'bin', 'traceByTrial', 'maxTraceByTrial', 'baselineByTrial',...
            'traceFreqGood', 'traceFreqGoodSel', 'statsSua', 'statsSuaSel', 'selectedCodesMua',...
            'selectedCodesDepthMua', 'selectedCodesIndMua', 'spikeInTrialsMua', 'spikeByTrialMua',...
            'traceByTrialMua', 'maxTraceByTrial', 'baselineByTrialMua', 'traceFreqMua', 'traceFreqMuaSel',...
            'statsMua', 'statsMuaSel', 'stimTime', 'baseTime', 'amplByTrial'};
    
    case 'cellMetrics'
        fields = {'indivTrough', 'waveformDataFilt', 'waveformCodes', 'waveformFiltAvgNorm', 'waveformFiltAvg',...
            'peakTroughRatio', 'troughPeakTime', 'peakAsymmetry', 'minCh', 'normMinCh', 'iMinCh', 'visitedCh',...
            'waveformCodeChannelNew', 'polarity', 'derivative_TroughtoPeak', 'peakA', 'peakB', 'trough'}; % last two not yet implemented for Klusta
         
end    

for f = 1:numel(fields)
    if  ~isfield(struct, fields(f))
        warning([s, ' does not contain field ', char(fields(f))])
        out = out+1;
    end
end   

disp(['Total fields: ',num2str(numel(fieldnames(struct))), ', should be: ', num2str(numel(fields))])
disp(['Fields missing: ',num2str(out)])

