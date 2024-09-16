%%% created by RB on 09.11.2021
%%% analysis for allExpDataVisualization_A2.m
%%% modifications in comparison to the predvious version regarding
%%% adjustBase
disp('Running  analysis...')
if sessionInfoAll.trialDuration == 18
    C = [[0 0 0]; [0 0 1];  [0.7 0.7 0.7]; [0 0.4470 0.7410]; [0 0 0]; [0.5 0.5 0.5]]; % black, navy-blue, grey, light blue, black, dark grey - traces
elseif sessionInfoAll.trialDuration == 6 || sessionInfoAll.trialDuration == 9 
    C = [repmat([0 0 0; 0 0 1],4,1); [0.7 0.7 0.7]; [0 0.4470 0.7410]; repmat([0 0 0; 0.5 0.5 0.5], 4,1)]; % (black, navy-blue)*4, grey, light blue, (black, dark grey)*4 - traces

    for i= 1:(totalConds/2-1)
        contrasts(i)= floor(100/2^(i-1));
    end
    contrasts0 = [contrasts, 0];
end


mixed = sum(classUnitsAll(iUnitsFilt) == 1) & sum(classUnitsAll(iUnitsFilt) == 2); % 0 if only one cell type and 1 if both cell types are included in analysis
%% Analysis for Fig. 1 (2x): average of timecourses 
% !!! recalculated after analysis for Fig 2 using baseSelect !!!

% Smooth trace frequency timecourses (TCs)
smooth_param = 1;

smoothTraceFreqAll = nan(totalConds, totalUnits, totalDatapoints);
for cond = 1 : totalConds
    for unit = find(iUnitsFilt)% & baseSelect)%
        smoothTraceFreqAll(cond,unit,:) = smooth(squeeze(clusterTimeSeriesAll.traceFreqGood(cond, unit, :)),smooth_param, smooth_method);
    end
end

% Calculate mean of smoothed trace frequency TCs
meanTraceFreqAll = squeeze(nanmean(smoothTraceFreqAll,2));
% subtract Vph - V
smoothTraceFreqAllSubtr = squeeze((smoothTraceFreqAll(2,:,:)-smoothTraceFreqAll(1,:,:)));
meanTraceFreqAllSubtr = nanmean(smoothTraceFreqAllSubtr,1);

% Calculate STEM of frequency TCs over cells
STEMtraceFreqAll = nan(totalConds, totalDatapoints);
for cond = 1 : totalConds
    for datapoint = 1:totalDatapoints
        STEMtraceFreqAll(cond, datapoint) = nanstd(smoothTraceFreqAll(cond, :, datapoint))/sqrt(sum(~isnan(smoothTraceFreqAll(cond, :, datapoint))));
    end 
end

STEMtraceFreqAllSubtr = nan(1, totalDatapoints);
for datapoint = 1:totalDatapoints
    STEMtraceFreqAllSubtr(1, datapoint) = nanstd(smoothTraceFreqAllSubtr(:, datapoint))/sqrt(sum(~isnan(smoothTraceFreqAllSubtr(:, datapoint))));
end 
    

%% Analysis for Fig. 2 (2x): average of normalized time courses
% Baseline calculations  % dim: cond, unit, stim 
baseStim = clusterTimeSeriesAll.baseTime; % [12 27 42 57 72 87] or [6, 12, 26];
% baseDuration = 1/bin-1; % additional data points for baseline quantification (1 sec)

% anaylze data as if having a longBase, in order to select for units with baseline above threshold
[baseStim, baseDuration] = adjustBase(baseStim, bin, 1);  
allStimBase = nan(totalConds, totalUnits, numel(baseStim));
for cond = 1:totalConds
    for unit = find(iUnitsFilt)
        for stim = 1:numel(baseStim)
            allStimBase(cond, unit, stim) = nanmean(clusterTimeSeriesAll.traceFreqGood(cond, unit, baseStim(stim):baseStim(stim)+baseDuration),3);
        end
    end
end
baseSelect = allStimBase(totalConds-1,:,1) >= thresholdFreq ; % select units with baseline higher than the selection threshold for 0%;

if longBase == 0 % if analysis not intented for long baseline
    [baseStim, baseDuration] = adjustBase(baseStim, bin, longBase);  % readjust baseStim and baseDuration for longBase = 0
    allStimBase = nan(totalConds, totalUnits, numel(baseStim));
    for cond = 1:totalConds
        for unit = find(iUnitsFilt)
            for stim = 1:numel(baseStim)
                allStimBase(cond, unit, stim) = nanmean(clusterTimeSeriesAll.traceFreqGood(cond, unit, baseStim(stim):baseStim(stim)+baseDuration),3);
            end
        end
    end
end    


traceFreqAllMinusBase = nan(totalConds, totalUnits, totalDatapoints);
for cond = 1 : totalConds
    for unit = find(iUnitsFilt)
        traceFreqAllMinusBase(cond, unit, :)= clusterTimeSeriesAll.traceFreqGood(cond, unit, :)- allStimBase(cond,unit,1);
    end
end

% calculare max in each timecourse of each cell, for conds with evoked activity
if sessionInfoAll.trialDuration == 18
    searchMax = [17:19]; % in data points
elseif sessionInfoAll.trialDuration == 6
    searchMax = [31:33];
elseif sessionInfoAll.trialDuration == 9
    searchMax = [46:48];
end


maxTraceFreqAll = nan(totalConds, totalUnits);
maxIndTraceFreqAll = nan(totalConds, totalUnits);
smoothMaxTraceFreqAll = nan(totalConds, totalUnits);

for cond = 1: totalConds-2 
    for unit = find(iUnitsFilt)%find(baseSelect)%
        [maxTraceFreqAll(cond, unit), maxIndTraceFreqAll(cond, unit)] = max(traceFreqAllMinusBase(cond, unit, searchMax));
        maxIndTraceFreqAll(cond, unit) = maxIndTraceFreqAll(cond, unit) + searchMax(1)-1;
%         maxIndTraceFreqAll(cond, unit) = searchMax(2); % select the values in the middle of the searchMax interval as max index
        %             smoothMaxTraceFreqAll(cond, unit) = mean(mean(traceFreqAllMinusBase(cond, unit, maxIndTraceFreqAll(cond, unit)-1:maxIndTraceFreqAll(cond,unit)+1))); % smooth over 3 points
%         smoothMaxTraceFreqAll(cond, unit) = mean(traceFreqAllMinusBase(cond, unit, maxIndTraceFreqAll(cond, unit))); % just max  or %:maxIndTraceFreqAll(cond, unit)+2
        smoothMaxTraceFreqAll(cond, unit) = mean(traceFreqAllMinusBase(cond, unit, searchMax)); % just max  or %:maxIndTraceFreqAll(cond, unit)+2

    end
end

% amplSelect = smoothMaxTraceFreqAll(1, :) > 0 & smoothMaxTraceFreqAll(1, :) > 0; % select only units with amplitude >0


% normalize >0% vis. stim. to max (without photostim) (or smoothMax) and then smooth
smooth_param = 1; 
normTraceFreqAll = nan(totalConds,totalUnits, totalDatapoints); % normalizationof two consecutive conds to the first (control) cond out of the two
normTraceFreqAll100 = nan(totalConds,totalUnits, totalDatapoints); % normalization to 100% control condition
normTraceFreqAllsame = nan(totalConds,totalUnits, totalDatapoints); % normalization to the same cond
for cond = 1:totalConds %%%%
    condNorm = floor((cond+1)/2)*2-1; % normalized by the non-photostim condition
    for unit = find(baseSelect)%find(iUnitsFilt)%find(amplSelect)%f
%     for unit = find(baseSelect)%find(amplSelect)%
%         normTraceFreqAll(cond, unit, :) = smooth(traceFreqAllMinusBase(cond, unit, :)/maxTraceFreqAll(condNorm, unit),smooth_param, smooth_method);
        normTraceFreqAll(cond, unit, :) = smooth(traceFreqAllMinusBase(cond, unit, :)/smoothMaxTraceFreqAll(condNorm, unit),smooth_param, smooth_method);
        normTraceFreqAll100(cond, unit, :) = smooth(traceFreqAllMinusBase(cond, unit, :)/smoothMaxTraceFreqAll(1, unit),smooth_param, smooth_method);
        normTraceFreqAllsame(cond, unit, :) = smooth(traceFreqAllMinusBase(cond, unit, :)/smoothMaxTraceFreqAll(cond, unit),smooth_param, smooth_method);
    end
end

% normalize 0% vis stim to baseline (without photostim) and then smooth
if longBase == 1
    smooth_param = 3;% !! modify here !!
end
% thresholdFreq = 0.1 % selection threshold in Hz
% totalBaseSelectUnits = numel(find(baseSelect))
for cond = totalConds-1:totalConds
    for unit = find(baseSelect)
        normTraceFreqAll(cond, unit, :) = smooth(clusterTimeSeriesAll.traceFreqGood(cond, unit, :)/allStimBase(totalConds-1, unit,1),smooth_param, smooth_method);
        normTraceFreqAll100(cond, unit, :) = smooth(traceFreqAllMinusBase(cond, unit, :)/smoothMaxTraceFreqAll(1, unit),smooth_param, smooth_method);
        normTraceFreqAllsame(cond, unit, :) = smooth(clusterTimeSeriesAll.traceFreqGood(cond, unit, :)/allStimBase(cond, unit,1),smooth_param, smooth_method);
    end
end

% Calculate mean of smoothed and norm TCs
meanNormTraceFreqAll = squeeze(nanmean(normTraceFreqAll,2));
meanNormTraceFreqAll100 = squeeze(nanmean(normTraceFreqAll100,2));
meanNormTraceFreqAllsame = squeeze(nanmean(normTraceFreqAllsame,2));
  
% Correction for the peak not being at 1
% normTraceFreqAllAdj = nan(size(normTraceFreqAll));
% meanNormTraceFreqAllAdj = nan(size(meanNormTraceFreqAll));
normTraceFreqAllAdj = normTraceFreqAll; % copying to already contain the spont conds, which will not be adjusted
meanNormTraceFreqAllAdj = meanNormTraceFreqAll;% copying to already contain the spont conds, which will not be adjusted
for cond = 1:totalConds-2 
    condNorm = floor((cond+1)/2)*2-1; % normalized by the non-photostim condition
    corrF = max(meanNormTraceFreqAll(condNorm,searchMax));
    for unit = find(iUnitsFilt)%find(amplSelect)%
        normTraceFreqAllAdj(cond, unit, :) = normTraceFreqAll(cond, unit, :) / corrF;
    end
    meanNormTraceFreqAllAdj(cond, :) = squeeze(nanmean(normTraceFreqAllAdj(cond,:,:),2));
end    

%subtract Vph-V and Sph-S
normTraceFreqAllAdjSubtr = nan(totalConds/2, totalUnits, totalDatapoints);
for cond =1:2:totalConds
    normTraceFreqAllAdjSubtr((cond+1)/2,:,:) = squeeze(normTraceFreqAllAdj(cond+1, :, :) - normTraceFreqAllAdj(cond, :, :)); 
end
meanNormTraceFreqAllAdjSubtr = squeeze(nanmean(normTraceFreqAllAdjSubtr,2));

normTraceFreqAll100Adj = nan(size(normTraceFreqAll100));
corrF = max(meanNormTraceFreqAll100(1,searchMax));
for cond = 1:totalConds %%%%
    for unit = find(iUnitsFilt)%find(amplSelect)%
        normTraceFreqAll100Adj(cond, unit, :) = normTraceFreqAll100(cond, unit, :) / corrF; % corrected here, 100 was missing
    end
    meanNormTraceFreqAll100Adj(cond, :) = squeeze(nanmean(normTraceFreqAll100Adj(cond,:,:),2));% corrected here, 100 was missing
end

% Calculate STEM of TCs over cells
STEMnormTraceFreqAll = nan(totalConds, totalDatapoints);
STEMnormTraceFreqAllAdj = nan(totalConds, totalDatapoints);
STEMnormTraceFreqAllsame = nan(totalConds, totalDatapoints);
for cond = 1:totalConds
    for datapoint = 1:totalDatapoints
        STEMnormTraceFreqAll(cond, datapoint) = nanstd(normTraceFreqAll(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAll(cond, :,datapoint))));
        STEMnormTraceFreqAll100(cond, datapoint) = nanstd(normTraceFreqAll100(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAll100(cond, :,datapoint))));
        STEMnormTraceFreqAllAdj(cond, datapoint) = nanstd(normTraceFreqAllAdj(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAllAdj(cond, :,datapoint))));
        STEMnormTraceFreqAll100Adj(cond, datapoint) = nanstd(normTraceFreqAll100Adj(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAll100Adj(cond, :,datapoint))));
        STEMnormTraceFreqAllsame(cond, datapoint) = nanstd(normTraceFreqAllsame(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAllsame(cond, :,datapoint))));
    end    
end

STEMnormTraceFreqAllAdjSubtr = nan(1, totalDatapoints);
for cond =1:totalConds/2
    for datapoint = 1:totalDatapoints
        STEMnormTraceFreqAllAdjSubtr(cond, datapoint) = nanstd(normTraceFreqAllAdjSubtr(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAllAdjSubtr(cond,:,datapoint))));
    end
end

%% Reanalysis for Fig. 1 (2x): average of timecourses 
% !!! using baseSelect !!!


% Smooth trace frequency timecourses (TCs)
smooth_param = 1;

smoothTraceFreqAll = nan(totalConds, totalUnits, totalDatapoints);
for cond = 1 : totalConds
    for unit = find(iUnitsFilt & baseSelect)%
        smoothTraceFreqAll(cond,unit,:) = smooth(squeeze(clusterTimeSeriesAll.traceFreqGood(cond, unit, :)),smooth_param, smooth_method);
    end
end

% Calculate mean of smoothed trace frequency TCs
meanTraceFreqAll = squeeze(nanmean(smoothTraceFreqAll,2));
% subtract Vph - V
smoothTraceFreqAllSubtr = squeeze((smoothTraceFreqAll(2,:,:)-smoothTraceFreqAll(1,:,:)));
meanTraceFreqAllSubtr = nanmean(smoothTraceFreqAllSubtr,1);

% Calculate STEM of frequency TCs over cells
STEMtraceFreqAll = nan(totalConds, totalDatapoints);
for cond = 1 : totalConds
    for datapoint = 1:totalDatapoints
        STEMtraceFreqAll(cond, datapoint) = nanstd(smoothTraceFreqAll(cond, :, datapoint))/sqrt(sum(~isnan(smoothTraceFreqAll(cond, :, datapoint))));
    end 
end

STEMtraceFreqAllSubtr = nan(1, totalDatapoints);
for datapoint = 1:totalDatapoints
    STEMtraceFreqAllSubtr(1, datapoint) = nanstd(smoothTraceFreqAllSubtr(:, datapoint))/sqrt(sum(~isnan(smoothTraceFreqAllSubtr(:, datapoint))));
end 
    

%% Analysis Fig. 3 (2x): Baseline quantification

% Calculate mean and STEM of baseline and stat tests

meanAllStimBase = squeeze(nanmean(allStimBase(:,baseSelect,:),2));

for cond = 1:totalConds
    for stim = 1:numel(baseStim)
        STEMallStimBase(cond, stim) = nanstd(allStimBase(cond,baseSelect,stim))/sqrt(sum(~isnan(allStimBase(cond, baseSelect,stim))));
    end
end

for cond = 1:2:totalConds
    for stim = 1:numel(baseStim)
        [hAllStimBase((cond+1)/2,stim,1), pAllStimBase((cond+1)/2,stim,1)] = ttest(squeeze(allStimBase(cond+1,:,1)),squeeze(allStimBase(cond+1,:,stim))); % param: all stims vs first stim in photostim conditions
        [hAllStimBase((cond+1)/2,stim,2), pAllStimBase((cond+1)/2,stim,2)] = ttest(squeeze(allStimBase(cond,:,stim)),squeeze(allStimBase(cond+1,:,stim))); % param: stim in photostim cond vs stim in non-photostim cond
        [pAllStimBaseW((cond+1)/2,stim,1), hAllStimBaseW((cond+1)/2,stim,1)] = signrank(squeeze(allStimBase(cond+1,:,1)),squeeze(allStimBase(cond+1,:,stim))); % nonparam: all stims vs first stim in photostim conditions
        [pAllStimBaseW((cond+1)/2,stim,2), hAllStimBaseW((cond+1)/2,stim,2)] = signrank(squeeze(allStimBase(cond,:,stim)),squeeze(allStimBase(cond+1,:,stim))); % nonparam: stim in photostim cond vs stim in non-photostim cond
    end    
end



%% Analysis Fig. 4 (2x) - Normalized baseline to the first stim value

% normalize baseline to first stim (before photostim) in each condition 
normAllStimBase = nan(totalConds, totalUnits, totalStim);
allStimBaseNormTrace = nan(totalConds, totalUnits, numel(baseStim));

% thresholdFreq = 0.5 % selection threshold in Hz
% baseSelect = allStimBase(totalConds-1,:,1) >= thresholdFreq ; % select units with baseline higher than the selection threshold for 0%;
totalBaseSelectUnits = numel(find(baseSelect));
for cond = 1:totalConds
    for unit = find(baseSelect)
        for stim = 1:numel(baseStim)            
            if allStimBase(cond, unit, 1) ~=0
                normAllStimBase(cond, unit, stim) = allStimBase(cond, unit, stim)/allStimBase(cond, unit, 1);  
            else     
                normAllStimBase(cond, unit, stim) = NaN;
            end
            % baseline in the normalized traces
            allStimBaseNormTrace(cond, unit, stim) = nanmean(traceFreqAllMinusBase(cond, unit, baseStim(stim):baseStim(stim)+baseDuration),3);   
            allStimBaseNormTrace100(cond, unit, stim) = nanmean(normTraceFreqAll100(cond, unit, baseStim(stim):baseStim(stim)+baseDuration),3);
        end
    end
end

% Calculate mean and STEM of normalized baseline
meanNormAllStimBase = squeeze(nanmean(normAllStimBase,2));

STEMnormAllStimBase = nan(totalConds, numel(baseStim));
for cond = 1:totalConds
    for stim = 1:numel(baseStim)
        STEMnormAllStimBase(cond,stim) = nanstd(normAllStimBase(cond,:,stim))/sqrt(sum(~isnan(normAllStimBase(cond,:,stim))));
    end
end

for cond = 1:2:totalConds
    for stim = 1:numel(baseStim)
        [hNormAllStimBase((cond+1)/2,stim,1), pNormAllStimBase((cond+1)/2,stim,1)] = ttest(squeeze(normAllStimBase(cond+1,:,1)),squeeze(normAllStimBase(cond+1,:,stim))); % param: all stims vs first stim in photostim conditions
        [hNormAllStimBase((cond+1)/2,stim,2), pNormAllStimBase((cond+1)/2,stim,2)] = ttest(squeeze(normAllStimBase(cond,:,stim)),squeeze(normAllStimBase(cond+1,:,stim))); % param: stim in photostim cond vs stim in non-photostim cond
        [pNormAllStimBaseW((cond+1)/2,stim,1), hNormAllStimBaseW((cond+1)/2,stim,1)] = signrank(squeeze(normAllStimBase(cond+1,:,1)),squeeze(normAllStimBase(cond+1,:,stim))); % nonparam: all stims vs first stim in photostim conditions
        [pNormAllStimBaseW((cond+1)/2,stim,2), hNormAllStimBaseW((cond+1)/2,stim,2)] = signrank(squeeze(normAllStimBase(cond,:,stim)),squeeze(normAllStimBase(cond+1,:,stim))); % nonparam: stim in photostim cond vs stim in non-photostim cond
    end    
end


%% Analysis Fig. 5 (2x): Amplitude quantification

% calculare max in each timecourse of each cell, for conds with evoked activity
if sessionInfoAll.trialDuration == 18
    amplInt = [18:18]; % in data points
elseif sessionInfoAll.trialDuration == 6
    amplInt = [31:33];
elseif sessionInfoAll.trialDuration == 9
    amplInt = [46:48];
end

allStimAmpl = nan(totalConds, totalUnits, totalStim);
allStimAmplNormTrace = nan(totalConds, totalUnits, totalStim);
allStimAmplNormTrace100 = nan(totalConds, totalUnits);
for cond = 1:totalConds
    for unit = find(iUnitsFilt)
        for stim = 1:totalStim % 2 calculations: hz values and normalized values
            allStimAmpl(cond, unit, stim) = nanmean(clusterTimeSeriesAll.traceFreqGood(cond, unit, (stim-1)*(3/bin)+amplInt),3);
            allStimAmplNormTrace(cond, unit, stim) = nanmean(normTraceFreqAll(cond, unit, (stim-1)*(3/bin)+amplInt),3);
            allStimAmplNormTrace100(cond, unit) = nanmean(normTraceFreqAll100(cond, unit, (stim-1)*(3/bin)+amplInt),3);
        end
    end
end

% Calculate mean and STEM of amplitudes
meanAllStimAmpl = nan(totalConds, totalStim);
meanAllStimAmplNormTrace = nan(totalConds, totalStim);
for cond = 1:totalConds
    for stim = 1:totalStim
        meanAllStimAmpl(cond, stim) = squeeze(nanmean(allStimAmpl(cond, :, stim),2));
        meanAllStimAmplNormTrace(cond, stim) = squeeze(nanmean(allStimAmplNormTrace(cond, :, stim),2));
        meanAllStimAmplNormTrace100(cond) = nanmean(allStimAmplNormTrace100(cond, :),2);
    end
end

STEMallStimAmpl = nan(totalConds, totalStim);
STEMallStimAmplNormTrace = nan(totalConds, totalStim);
for cond = 1:totalConds
    for stim = 1:totalStim
        STEMallStimAmpl(cond, stim) = nanstd(allStimAmpl(cond,:, stim))/sqrt(sum(~isnan(allStimAmpl(cond,:, stim))));  
        STEMallStimAmplNormTrace(cond, stim) = nanstd(allStimAmplNormTrace(cond,:, stim))/sqrt(sum(~isnan(allStimAmplNormTrace(cond,:, stim))));  
        STEMallStimAmplNormTrace100(cond) = nanstd(allStimAmplNormTrace100(cond,:))/sqrt(sum(~isnan(allStimAmplNormTrace100(cond,:))));

    end
end

for cond = (1:2:totalConds)
    for stim = 1:totalStim
        [hAllStimAmpl((cond+1)/2, stim), pAllStimAmpl((cond+1)/2, stim)] =ttest(allStimAmpl(cond,:, stim),allStimAmpl(cond+1,:, stim)); % opt vs vis
        [pAllStimAmplW((cond+1)/2, stim), hAllStimAmplW((cond+1)/2, stim)] =signrank(allStimAmpl(cond,:, stim),allStimAmpl(cond+1,:, stim)); %  opt vs vis
        [hAllStimAmplNormTrace((cond+1)/2, stim), pAllStimAmplNormTrace((cond+1)/2, stim)] =ttest(allStimAmplNormTrace(cond,:, stim),allStimAmplNormTrace(cond+1,:, stim)); % opt vs vis
        [pAllStimAmplNormTraceW((cond+1)/2, stim), hAllStimAmplNormTraceW((cond+1)/2, stim)] =signrank(allStimAmplNormTrace(cond,:, stim),allStimAmplNormTrace(cond+1,:, stim)); %  opt vs vis
        [hAllStimAmplNormTrace100((cond+1)/2), pAllStimAmplNormTrace100((cond+1)/2)] =ttest(allStimAmplNormTrace100(cond,:),allStimAmplNormTrace100(cond+1,:)); % opt vs vis
        [pAllStimAmplNormTrace100W((cond+1)/2), hAllStimAmplNormTrace100W((cond+1)/2)] =signrank(allStimAmplNormTrace100(cond,:),allStimAmplNormTrace100(cond+1,:)); %  opt vs vis
    end   
end


%% Analysis Fig. 6a (5x)  - normalized amplitude to the first stim amplitude in no photostim cond or SEE NEXT!

% Normalized amplitude calculations : select first line or the next ones 
 normAllStimAmpl = allStimAmplNormTrace;

% for cond = 1:totalConds
%     condNorm = floor((cond+1)/2)*2-1; % normalized by the non-photostim condition
%     for unit = 1:totalUnits
%         normAllStimAmpl(cond, unit) = allStimAmpl(cond, unit)/allStimAmpl(condNorm, unit);
%     end
% end

% Calculate mean and STEM of normalized amplitude

meanNormAllStimAmpl = nanmean(normAllStimAmpl,2);
    
for cond = 1:totalConds  
    STEMnormAllStimAmpl(cond) = nanstd(normAllStimAmpl(cond,:))/sqrt(sum(~isnan(normAllStimAmpl(cond,:))));  
end

for cond = (1:2:totalConds)
    [hNormAllStimAmpl((cond+1)/2), pNormAllStimAmpl((cond+1)/2)] =ttest(normAllStimAmpl(cond,:),normAllStimAmpl(cond+1,:)); % opt vs vis
    [pNormAllStimAmplW((cond+1)/2), hNormAllStimAmplW((cond+1)/2)] =signrank(normAllStimAmpl(cond,:),normAllStimAmpl(cond+1,:)); %  opt vs vis
end

%% Analysis Fig. 6b (1x)  - normalized amplitude to the first stim amplitude in the same non photostim cond 
%%%%% !!!! needs double checking !!!! %%%%%%
% Normalized amplitude calculations : select first line or the next ones 
if totalStim ==6
    normAllStimAmpl100 = allStimAmplNormTrace.*(isfinite(allStimAmplNormTrace)); % normalize to first stim in the same non-photostim cond
elseif totalStim == 1
    normAllStimAmpl100 = allStimAmplNormTrace100;
    normAllStimAmpl100Diff = nan(totalConds/2, totalUnits);
    for cond = 1:2:totalConds
        normAllStimAmpl100Diff((cond+1)/2,:) = normAllStimAmpl100(cond+1,:) - normAllStimAmpl100(cond,:);
    end    
end    
% normAllStimAmpl100 = nan(totalConds, totalUnits, totalStim)
% for cond = 1:totalConds-2
%     for unit = find(iUnitsFilt)
%         for stim = 1:totalStim
%             normAllStimAmpl100(cond, unit, stim) = allStimAmpl(cond, unit, stim)/allStimAmpl(1, unit,1); % normalize to first stim in first condition
%            
%         end
%     end
% end

% Calculate mean and STEM of normalized amplitude

meanNormAllStimAmpl100 = squeeze(nanmean(normAllStimAmpl100,2));
% if totalStim == 1 % Correction for normalization: maybe it can also be applied to P7 ? 
meanNormAllStimAmpl100 = meanNormAllStimAmpl100 /meanNormAllStimAmpl100(1);
normAllStimAmpl100 = normAllStimAmpl100 /meanNormAllStimAmpl100(1);
% end
    
    
for cond = 1:totalConds 
    for stim = 1:totalStim
        STEMnormAllStimAmpl100(cond, stim) = nanstd(normAllStimAmpl100(cond,:, stim))/sqrt(sum(~isnan(normAllStimAmpl100(cond,:, stim))));  
    end
end

for cond = (1:2:totalConds)
    for stim = 1:totalStim
        [hNormAllStimAmpl100((cond+1)/2, stim), pNormAllStimAmpl100((cond+1)/2, stim)] =ttest(normAllStimAmpl100(cond,:, stim),normAllStimAmpl100(cond+1,:, stim)); % opt vs vis
        [pNormAllStimAmpl100W((cond+1)/2, stim), hNormAllStimAmpl100W((cond+1)/2, stim)] =signrank(normAllStimAmpl100(cond,:, stim),normAllStimAmpl100(cond+1,:, stim)); %  opt vs vis
    end
end

if totalStim == 1
    meanNormAllStimAmpl100Diff = nanmean(normAllStimAmpl100Diff,2);
    for cond = (1:2:totalConds)
        STEMnormAllStimAmpl100Diff((cond+1)/2, :) = nanstd(normAllStimAmpl100Diff((cond+1)/2,:))/sqrt(sum(~isnan(normAllStimAmpl100Diff((cond+1)/2,:))));  
    end
end    

%% Analysis Fig. 7, 8 - Opto-index and ratio of baselines in photostim vs non-photostim. conditions

ratioAllStimBase = nan(totalConds/2, totalUnits, numel(baseStim));
OIndexAllStimBase = nan(totalConds/2, totalUnits, numel(baseStim));
OIvalues = -1:.1:1; % OI values

for cond = 1:2:totalConds
    for unit = find(baseSelect)%find(iUnitsFilt)%
        for stim = 1:numel(baseStim)
            if allStimBase(cond, unit, stim) ~= 0
                ratioAllStimBase((cond+1)/2, unit, stim) = allStimBase(cond+1, unit, stim)/allStimBase(cond, unit, stim); 
            end
            if (allStimBase(cond+1, unit, stim)+allStimBase(cond, unit, stim)) ~= 0
                if cond < totalConds-2
                    OIndexAllStimBase((cond+1)/2, unit, stim) = (allStimBase(cond+1, unit, stim)-allStimBase(cond, unit, stim))/(allStimBase(cond+1, unit, stim)+allStimBase(cond, unit, stim));
                else
                    OIndexAllStimBase((cond+1)/2, unit, stim) = (allStimBase(cond+1, unit, stim)-allStimBase(cond+1, unit, 1))/(allStimBase(cond+1, unit, stim)+allStimBase(cond+1, unit, 1));   
                end    
            end    
        end        
    end
end

% OI calculated based on the same trace
OIndexAllStimBaseSame = nan(totalConds, totalUnits, numel(baseStim));
for cond = 1:totalConds
    for unit = find(baseSelect)%find(iUnitsFilt)%
        for stim = 1:numel(baseStim)
            if (allStimBase(cond, unit, stim)+allStimBase(cond, unit, 1)) ~= 0
                OIndexAllStimBaseSame(cond, unit, stim) = (allStimBase(cond, unit, stim)-allStimBase(cond, unit, 1))/(allStimBase(cond, unit, stim)+allStimBase(cond, unit, 1)); 
            end
        end
    end
end


% ??? only for multi-stim protocol ???
if numel(baseStim) > 1
    ratioNormAllStimBase = ratioAllStimBase./ratioAllStimBase(:,:,1);
end

% sort ratioNormAllStimAmpl

sortRatioNormAllStimBase = nan(totalConds/2, totalUnits, numel(baseStim));
sortOIndexAllStimBase = nan(totalConds/2, totalUnits, numel(baseStim));
indexRatioNormAllStimBase = nan(totalConds/2, totalUnits, numel(baseStim));
indexOIndexAllStimBase = nan(totalConds/2, totalUnits, numel(baseStim));

meanOIndexAllStimBase = squeeze(nanmean(OIndexAllStimBase,2));
meanOIndexAllStimBaseExc = squeeze(nanmean(OIndexAllStimBase(:,classUnitsAll == 1,:),2));
meanOIndexAllStimBaseInh = squeeze(nanmean(OIndexAllStimBase(:,classUnitsAll == 2,:),2));

sigmaOIndexAllStimBase = nan(totalConds/2,numel(baseStim));
sigmaOIndexAllStimBaseExc = nan(totalConds/2,numel(baseStim));
sigmaOIndexAllStimBaseInh = nan(totalConds/2,numel(baseStim));

distOIndexAllStimBase = nan(totalConds/2,numel(baseStim), numel(OIvalues));
distOIndexAllStimBaseExc = nan(totalConds/2,numel(baseStim), numel(OIvalues));
distOIndexAllStimBaseInh = nan(totalConds/2,numel(baseStim), numel(OIvalues));


for cond = 1:2:totalConds
    for stim = 2:numel(baseStim)
        [sortRatioNormAllStimBase((cond+1)/2,:, stim), indexRatioNormAllStimBase((cond+1)/2,:, stim)] = sort(ratioNormAllStimBase((cond+1)/2,:, stim));
        [sortOIndexAllStimBase((cond+1)/2,:, stim), indexOIndexAllStimBase((cond+1)/2,:, stim)] = sort(OIndexAllStimBase((cond+1)/2,:, stim));
        if mixed
            sigmaOIndexAllStimBase((cond+1)/2, stim) = nanstd(OIndexAllStimBase((cond+1)/2,:, stim));
            sigmaOIndexAllStimBaseExc((cond+1)/2, stim) = nanstd(OIndexAllStimBase((cond+1)/2,classUnitsAll == 1,stim));
            sigmaOIndexAllStimBaseInh((cond+1)/2, stim) = nanstd(OIndexAllStimBase((cond+1)/2,classUnitsAll == 2, stim));
            
            pdOIndexAllStimBase((cond+1)/2, stim) = makedist('Normal','mu',meanOIndexAllStimBase((cond+1)/2, stim),'sigma',sigmaOIndexAllStimBase((cond+1)/2, stim));
            pdOIndexAllStimBaseExc((cond+1)/2, stim) = makedist('Normal','mu',meanOIndexAllStimBaseExc((cond+1)/2, stim),'sigma',sigmaOIndexAllStimBaseExc((cond+1)/2, stim));
            pdOIndexAllStimBaseInh((cond+1)/2, stim) = makedist('Normal','mu',meanOIndexAllStimBaseInh((cond+1)/2, stim),'sigma',sigmaOIndexAllStimBaseInh((cond+1)/2, stim));
            
            distOIndexAllStimBase((cond+1)/2, stim,:) = pdf(pdOIndexAllStimBase((cond+1)/2, stim),OIvalues);
            distOIndexAllStimBaseExc((cond+1)/2, stim,:) = pdf(pdOIndexAllStimBaseExc((cond+1)/2, stim),OIvalues);
            distOIndexAllStimBaseInh((cond+1)/2, stim,:) = pdf(pdOIndexAllStimBaseInh((cond+1)/2, stim),OIvalues);
            [hOIndexAllStimBaseExcInh((cond+1)/2, stim), pOIndexAllStimBaseExcInh((cond+1)/2, stim)] = kstest2(squeeze(OIndexAllStimBase((cond+1)/2,classUnitsAll == 1, stim)),squeeze(OIndexAllStimBase((cond+1)/2,classUnitsAll == 2, stim)));
        end
    end
end

% calculate p val for comparison within the same condition
meanOIndexAllStimBaseSame = squeeze(nanmean(OIndexAllStimBaseSame,2));
meanOIndexAllStimBaseSameExc = squeeze(nanmean(OIndexAllStimBaseSame(:,classUnitsAll == 1,:),2));
meanOIndexAllStimBaseSameInh = squeeze(nanmean(OIndexAllStimBaseSame(:,classUnitsAll == 2,:),2));

sigmaOIndexAllStimBaseSame = nan(totalConds,numel(baseStim));
sigmaOIndexAllStimBaseSameExc = nan(totalConds,numel(baseStim));
sigmaOIndexAllStimBaseSameInh = nan(totalConds,numel(baseStim));

distOIndexAllStimBaseSame = nan(totalConds,numel(baseStim), numel(OIvalues));
distOIndexAllStimBaseSameExc = nan(totalConds,numel(baseStim), numel(OIvalues));
distOIndexAllStimBaseSameInh = nan(totalConds,numel(baseStim), numel(OIvalues));

for cond = 1:totalConds
    for stim = 2:numel(baseStim)
        if mixed
            sigmaOIndexAllStimBaseSame(cond, stim) = nanstd(OIndexAllStimBaseSame(cond,:, stim));
            sigmaOIndexAllStimBaseSameExc(cond, stim) = nanstd(OIndexAllStimBaseSame(cond,classUnitsAll == 1,stim));
            sigmaOIndexAllStimBaseSameInh(cond, stim) = nanstd(OIndexAllStimBaseSame(cond,classUnitsAll == 2, stim));
            
            pdOIndexAllStimBaseSame(cond, stim) = makedist('Normal','mu', meanOIndexAllStimBaseSame(cond, stim),'sigma',sigmaOIndexAllStimBaseSame(cond, stim));
            pdOIndexAllStimBaseSameExc(cond, stim) = makedist('Normal','mu',meanOIndexAllStimBaseSameExc(cond, stim),'sigma',sigmaOIndexAllStimBaseSameExc(cond, stim));
            pdOIndexAllStimBaseSameInh(cond, stim) = makedist('Normal','mu',meanOIndexAllStimBaseSameInh(cond, stim),'sigma',sigmaOIndexAllStimBaseSameInh(cond, stim));
            
            distOIndexAllStimBaseSame(cond, stim,:) = pdf(pdOIndexAllStimBaseSame(cond, stim),OIvalues);
            distOIndexAllStimBaseSameExc(cond, stim,:) = pdf(pdOIndexAllStimBaseSameExc(cond, stim),OIvalues);
            distOIndexAllStimBaseSameInh(cond, stim,:) = pdf(pdOIndexAllStimBaseSameInh(cond, stim),OIvalues);
            [hOIndexAllStimBaseSameExcInh(cond, stim), pOIndexAllStimBaseSameExcInh(cond, stim)] = kstest2(squeeze(OIndexAllStimBaseSame(cond,classUnitsAll == 1, stim)),squeeze(OIndexAllStimBaseSame(cond,classUnitsAll == 2, stim)));
        end
    end
end

STEMOIndexAllStimBase = nan(totalConds/2, numel(baseStim));
STEMOIndexAllStimBaseExc = nan(totalConds/2, numel(baseStim));
STEMOIndexAllStimBaseInh = nan(totalConds/2, numel(baseStim));

for cond = 1:totalConds/2  
    for stim = 2:numel(baseStim)
        STEMOIndexAllStimBase(cond, stim) = nanstd(OIndexAllStimBase(cond,:,stim))/sqrt(sum(~isnan(OIndexAllStimBase(cond,:,stim))));  
        STEMOIndexAllStimBaseExc(cond, stim) = nanstd(OIndexAllStimBase(cond,classUnitsAll == 1,stim))/sqrt(sum(~isnan(OIndexAllStimBase(cond,classUnitsAll == 1,stim))));  
        STEMOIndexAllStimBaseInh(cond, stim) = nanstd(OIndexAllStimBase(cond,classUnitsAll == 2,stim))/sqrt(sum(~isnan(OIndexAllStimBase(cond,classUnitsAll == 2,stim))));  
    end
end

% Calculate mean and STEM of the ratio of normalized amplitude

meanRatioNormAllStimBase = nanmean(ratioNormAllStimBase,2);
meanRatioNormAllStimBaseExc = nanmean(ratioNormAllStimBase(:,classUnitsAll == 1,:),2);
meanRatioNormAllStimBaseInh = nanmean(ratioNormAllStimBase(:,classUnitsAll == 2,:),2);

STEMratioNormAllStimBase = nan(totalConds/2, numel(baseStim));
STEMratioNormAllStimBaseExc = nan(totalConds/2, numel(baseStim));
STEMratioNormAllStimBaseInh = nan(totalConds/2, numel(baseStim));
for cond = 1:2:totalConds
    for stim = 2:numel(baseStim)
        STEMratioNormAllStimBase((cond+1)/2,stim) = nanstd(ratioNormAllStimBase((cond+1)/2,:,stim))/sqrt(sum(~isnan(ratioNormAllStimBase((cond+1)/2,:,stim))));
        STEMratioNormAllStimBaseExc((cond+1)/2,stim) = nanstd(ratioNormAllStimBase((cond+1)/2,classUnitsAll == 1,stim))/sqrt(sum(~isnan(ratioNormAllStimBase((cond+1)/2,classUnitsAll == 1,stim))));
        STEMratioNormAllStimBaseInh((cond+1)/2,stim) = nanstd(ratioNormAllStimBase((cond+1)/2,classUnitsAll == 2,stim))/sqrt(sum(~isnan(ratioNormAllStimBase((cond+1)/2,classUnitsAll == 2,stim))));   
    end
end

pSuaBaseAll = clusterTimeSeriesAll.statsSua.pSuaBase;

for cond = 1:2:totalConds % fig 7dx
    for stim = 2:numel(baseStim)
        if mixed
            %         OIndexAllStimBase((cond+1)/2,classUnitsAll == 1, stim)), OIndexAllStimBase((cond+1)/2,classUnitsAll == 2, stim))
            [hOIndexAllStimBaseExc((cond+1)/2, stim), pOIndexAllStimBaseExc((cond+1)/2, stim)] =ttest(OIndexAllStimBase((cond+1)/2,classUnitsAll == 1, stim)); % opt vs vis
            [pOIndexAllStimBaseExcW((cond+1)/2, stim), hOIndexAllStimBaseExcW((cond+1)/2, stim)] =signrank(OIndexAllStimBase((cond+1)/2,classUnitsAll == 1, stim)); %  opt vs vis
            [hOIndexAllStimBaseInh((cond+1)/2, stim), pOIndexAllStimBaseInh((cond+1)/2, stim)] =ttest(OIndexAllStimBase((cond+1)/2,classUnitsAll == 2, stim)); % opt vs vis
            [pOIndexAllStimBaseInhW((cond+1)/2, stim), hOIndexAllStimBaseInhW((cond+1)/2, stim)] =signrank(OIndexAllStimBase((cond+1)/2,classUnitsAll == 2, stim)); %  opt vs vis
            [hOIndexAllStimBaseExcInh2((cond+1)/2, stim), pOIndexAllStimBaseExcInh2((cond+1)/2, stim)] =ttest2(OIndexAllStimBase((cond+1)/2,classUnitsAll == 1, stim), OIndexAllStimBase((cond+1)/2,classUnitsAll == 2, stim)); % opt vs vis
            %         [pOIndexAllStimBaseExcInh2W((cond+1)/2, stim), hOIndexAllStimBaseExcInh2W((cond+1)/2, stim)] =signrank(OIndexAllStimBase((cond+1)/2,classUnitsAll == 1, stim), OIndexAllStimBase((cond+1)/2,classUnitsAll == 2, stim)); %  opt vs vis
        end
        
    end
end

if sessionInfoAll.trialDuration == 18
    OIposUnits = iUnitsFilt & OIndexAllStimBase(totalConds/2,:, 4)>0; % run the next section before uncommenting this line
    OInegUnits = iUnitsFilt & OIndexAllStimBase(totalConds/2,:, 4)<0; % run the next section before uncommenting this line

    OIposUnitsSame = iUnitsFilt & baseSelect & OIndexAllStimBaseSame(totalConds,:, 4)>0; % run the next section before uncommenting this line
    OInegUnitsSame = iUnitsFilt & baseSelect & OIndexAllStimBaseSame(totalConds,:, 4)<0; % run the next section before uncommenting this line
elseif sessionInfoAll.trialDuration == 6 || sessionInfoAll.trialDuration == 9 
    OIposUnits = iUnitsFilt & OIndexAllStimBase(totalConds/2,:, 3)>0; % run the next section before uncommenting this line
    OInegUnits = iUnitsFilt & OIndexAllStimBase(totalConds/2,:, 3)<0; % run the next section before uncommenting this line

    OIposUnitsSame = iUnitsFilt & baseSelect & OIndexAllStimBaseSame(totalConds,:, 3)>0; % run the next section before uncommenting this line
    OInegUnitsSame = iUnitsFilt & baseSelect & OIndexAllStimBaseSame(totalConds,:, 3)<0; % run the next section before uncommenting this line
end

if longBase 
    path1 =pwd;
    filenameOIposnegUnits = fullfile(path1,'OIposnegUnits.mat');
    disp('Saving OIposneg.mat')
    save(filenameOIposnegUnits, 'OIposUnits', 'OInegUnits')
end


%% Analysis Fig. 9, 10 - Opto-index and ratio of amplitudes in photostim vs non-photostim. conditions

ratioAllStimAmpl = nan(totalConds/2, totalUnits, totalStim);
OIndexAllStimAmpl = nan(totalConds/2, totalUnits, totalStim);
for cond = 1:2:totalConds
    for unit = 1:totalUnits
        for stim = 1:totalStim
            ratioAllStimAmpl((cond+1)/2, unit, stim) = allStimAmpl(cond+1, unit, stim)/allStimAmpl(cond, unit, stim); 
            OIndexAllStimAmpl((cond+1)/2, unit, stim) = (allStimAmpl(cond+1, unit, stim)-allStimAmpl(cond, unit, stim))/(allStimAmpl(cond+1, unit, stim)+allStimAmpl(cond, unit, stim)); 
        end
    end
end


if totalStim == 1 % only for single-stim protocol
    ratioNormAllStimAmpl = ratioAllStimAmpl;
else % for multi-stm protocols, divide by 1st stim ampl
    ratioNormAllStimAmpl = ratioAllStimAmpl ./ ratioAllStimAmpl(:,:,1);
end    


% sort ratioNormAllStimAmpl
sortRatioNormAllStimAmpl = nan(totalConds/2, totalUnits, totalStim);
sortOIndexAllStimAmpl = nan(totalConds/2, totalUnits, totalStim);
indexRatioNormAllStimAmpl = nan(totalConds/2, totalUnits, totalStim);
indexOIndexAllStimAmpl = nan(totalConds/2, totalUnits, totalStim);

meanOIndexAllStimAmpl = nanmean(OIndexAllStimAmpl,2);
meanOIndexAllStimAmplExc = squeeze(nanmean(OIndexAllStimAmpl(:,classUnitsAll == 1,:),2));
meanOIndexAllStimAmplInh = squeeze(nanmean(OIndexAllStimAmpl(:,classUnitsAll == 2,:),2));

sigmaOIndexAllStimAmpl = nan(totalConds/2,numel(totalStim));
sigmaOIndexAllStimAmplExc = nan(totalConds/2,numel(totalStim));
sigmaOIndexAllStimAmplInh = nan(totalConds/2,numel(totalStim));

distOIndexAllStimAmpl = nan(totalConds/2,numel(totalStim), numel(OIvalues));
distOIndexAllStimAmplExc = nan(totalConds/2,numel(totalStim), numel(OIvalues));
distOIndexAllStimAmplInh = nan(totalConds/2,numel(totalStim), numel(OIvalues));

for cond = 1:2:totalConds
    for stim = 1:totalStim
        [sortRatioNormAllStimAmpl((cond+1)/2,:,stim), indexRatioNormAllStimAmpl((cond+1)/2,:,stim)] = sort(ratioNormAllStimAmpl((cond+1)/2,:,stim));
        [sortOIndexAllStimAmpl((cond+1)/2,:,stim), indexOIndexAllStimAmpl((cond+1)/2,:,stim)] = sort(OIndexAllStimAmpl((cond+1)/2,:,stim));
        if mixed
            sigmaOIndexAllStimAmpl((cond+1)/2, stim) = nanstd(OIndexAllStimAmpl((cond+1)/2,:, stim));
            sigmaOIndexAllStimAmplExc((cond+1)/2, stim) = nanstd(OIndexAllStimAmpl((cond+1)/2,classUnitsAll == 1,stim));
            sigmaOIndexAllStimAmplInh((cond+1)/2, stim) = nanstd(OIndexAllStimAmpl((cond+1)/2,classUnitsAll == 2, stim));
            
            pdOIndexAllStimAmpl((cond+1)/2, stim) = makedist('Normal','mu',meanOIndexAllStimAmpl((cond+1)/2, stim),'sigma',sigmaOIndexAllStimAmpl((cond+1)/2, stim));
            pdOIndexAllStimAmplExc((cond+1)/2, stim) = makedist('Normal','mu',meanOIndexAllStimAmplExc((cond+1)/2, stim),'sigma',sigmaOIndexAllStimAmplExc((cond+1)/2, stim));
            pdOIndexAllStimAmplInh((cond+1)/2, stim) = makedist('Normal','mu',meanOIndexAllStimAmplInh((cond+1)/2, stim),'sigma',sigmaOIndexAllStimAmplInh((cond+1)/2, stim));
            
            distOIndexAllStimAmpl((cond+1)/2, stim,:) = pdf(pdOIndexAllStimAmpl((cond+1)/2, stim),OIvalues);
            distOIndexAllStimAmplExc((cond+1)/2, stim,:) = pdf(pdOIndexAllStimAmplExc((cond+1)/2, stim),OIvalues);
            distOIndexAllStimAmplInh((cond+1)/2, stim,:) = pdf(pdOIndexAllStimAmplInh((cond+1)/2, stim),OIvalues);
            [hOIndexAllStimAmplExcInh((cond+1)/2, stim), pOIndexAllStimAmplExcInh((cond+1)/2, stim)] = kstest2(squeeze(OIndexAllStimAmpl((cond+1)/2,classUnitsAll == 1, stim)),squeeze(OIndexAllStimAmpl((cond+1)/2,classUnitsAll == 2, stim)));
        end
    end
end


for cond = 1:totalConds/2  
    for stim = 1:totalStim
        STEMOIndexAllStimAmpl(cond,stim) = nanstd(OIndexAllStimAmpl(cond,:,stim))/sqrt(sum(~isnan(OIndexAllStimAmpl(cond,:,stim))));  
    end
end

% Calculate mean and STEM of the ratio of normalized amplitude

meanRatioNormAllStimAmpl = squeeze(nanmean(ratioNormAllStimAmpl,2));

for cond = 1:2:totalConds
    for stim = 1:totalStim
        STEMratioNormAllStimAmpl((cond+1)/2,stim) = nanstd(ratioNormAllStimAmpl((cond+1)/2,:,stim))/sqrt(sum(~isnan(ratioNormAllStimAmpl((cond+1)/2,:,stim))));
    end
end

pSuaAll =  clusterTimeSeriesAll.statsSua.pSua;

%% Analysis Fig. 11, 12 - Opto-index and ratio of baselines in photostim vs non-photostim. conditions, combined conditions and relative to the same trial and cond
% !!! check out baseSelect in this section - it is different than in other
% sections. Check for inconsistencies

% totalUnits = size(allStimBase, 2);
% totalStim = size(allStimBase, 3);

allStimBaseComb = nan(2, totalUnits, numel(baseStim));

allStimBaseComb(1,1:totalUnits,1:numel(baseStim)) = nanmean(allStimBase(1:2:totalConds,:,:),1); % no photostim
allStimBaseComb(2,1:totalUnits,1:numel(baseStim)) = nanmean(allStimBase(2:2:totalConds,:,:),1); % with photostim

% thresholdFreq = 0.1; % selection threshold in Hz
baseSelectComb = allStimBaseComb >= thresholdFreq ; % select units with baseline higher than the selection threshold; 2 conds, unit, 3 stim
units = (1:totalUnits); 
baseSelectUnits = units(baseSelectComb(2,:,1)); % 
totalBaseSelectUnits = numel(baseSelectUnits);

ratioAllStimBaseComb = nan(2, totalUnits, numel(baseStim));% totalUnits, stim no.
OIndexAllStimBaseComb = nan(2, totalUnits, numel(baseStim)) ;% totalUnits, stim no.

% division to the first baseline within the same trial and cond
for cond = 1:2
    for unit = (1:totalBaseSelectUnits)
        for stim = 1:numel(baseStim)
            if allStimBaseComb(cond, baseSelectUnits(unit), 1) ~= 0
                ratioAllStimBaseComb(cond,baseSelectUnits(unit), stim) = allStimBaseComb(2, baseSelectUnits(unit), stim)/allStimBaseComb(2, baseSelectUnits(unit), 1);
            end
            if (allStimBaseComb(cond, baseSelectUnits(unit), 1)+allStimBaseComb(cond, baseSelectUnits(unit), stim)) ~= 0
                OIndexAllStimBaseComb(cond, baseSelectUnits(unit), stim) = (allStimBaseComb(cond, baseSelectUnits(unit), stim)-allStimBaseComb(cond, baseSelectUnits(unit), 1))/(allStimBaseComb(cond, baseSelectUnits(unit), stim)+allStimBaseComb(cond, baseSelectUnits(unit), 1));
            end
        end
    end
end

% only for multi-stim protocol
if numel(baseStim)>1
    ratioNormAllStimBaseComb = ratioAllStimBaseComb(:, :,:)./ratioAllStimBaseComb(:, :,1);
elseif numel(baseStim) == 1    
    ratioNormAllStimBaseComb = ratioAllStimBaseComb;
end    

% sort ratioNormAllStimBaseComb

sortRatioNormAllStimBaseComb=nan(2, totalUnits, numel(baseStim));
sortOIndexAllStimBaseComb=nan(2, totalUnits, numel(baseStim));
indexRatioNormAllStimBaseComb = nan(2, totalUnits, numel(baseStim));
indexOIndexAllStimBaseComb = nan(2, totalUnits, numel(baseStim));

meanOIndexAllStimBaseComb = squeeze(nanmean(OIndexAllStimBaseComb,2)); % with photostim
meanOIndexAllStimBaseCombExc = squeeze(nanmean(OIndexAllStimBaseComb(:,classUnitsAll(baseSelectUnits) == 1,:),2));
meanOIndexAllStimBaseCombInh = squeeze(nanmean(OIndexAllStimBaseComb(:,classUnitsAll(baseSelectUnits) == 2,:),2)); 

sigmaOIndexAllStimBaseComb = nan(2,numel(baseStim));
sigmaOIndexAllStimBaseCombExc = nan(2,numel(baseStim));
sigmaOIndexAllStimBaseCombInh = nan(2,numel(baseStim));

distOIndexAllStimBaseComb = nan(2,numel(baseStim), numel(OIvalues));
distOIndexAllStimBaseCombExc = nan(2,numel(baseStim), numel(OIvalues));
distOIndexAllStimBaseCombInh = nan(2,numel(baseStim), numel(OIvalues));

for cond = 1:2
    for stim = 2:numel(baseStim)
        [sortRatioNormAllStimBaseComb(cond,:, stim), indexRatioNormAllStimBaseComb(cond,:, stim)] = sort(ratioNormAllStimBaseComb(cond,:, stim));
        [sortOIndexAllStimBaseComb(cond,:, stim), indexOIndexAllStimBaseComb(cond,:, stim)] = sort(OIndexAllStimBaseComb(cond,:, stim));
        if mixed
            sigmaOIndexAllStimBaseComb(cond, stim) = nanstd(OIndexAllStimBaseComb(cond,:, stim));
            sigmaOIndexAllStimBaseCombExc(cond, stim) = nanstd(OIndexAllStimBaseComb(cond,classUnitsAll == 1,stim));
            sigmaOIndexAllStimBaseCombInh(cond, stim) = nanstd(OIndexAllStimBaseComb(cond,classUnitsAll == 2, stim));
            
            pdOIndexAllStimBaseComb(cond, stim) = makedist('Normal','mu',meanOIndexAllStimBaseComb(cond, stim),'sigma',sigmaOIndexAllStimBaseComb(cond, stim));
            pdOIndexAllStimBaseCombExc(cond, stim) = makedist('Normal','mu',meanOIndexAllStimBaseCombExc(cond, stim),'sigma',sigmaOIndexAllStimBaseCombExc(cond, stim));
            pdOIndexAllStimBaseCombInh(cond, stim) = makedist('Normal','mu',meanOIndexAllStimBaseCombInh(cond, stim),'sigma',sigmaOIndexAllStimBaseCombInh(cond, stim));
            
            distOIndexAllStimBaseComb(cond, stim,:) = pdf(pdOIndexAllStimBaseComb(cond, stim),OIvalues);
            distOIndexAllStimBaseCombExc(cond, stim,:) = pdf(pdOIndexAllStimBaseCombExc(cond, stim),OIvalues);
            distOIndexAllStimBaseCombInh(cond, stim,:) = pdf(pdOIndexAllStimBaseCombInh(cond, stim),OIvalues);
            [hOIndexAllStimBaseCombExcInh(cond, stim), pOIndexAllStimBaseCombExcInh(cond, stim)] = kstest2(squeeze(OIndexAllStimBaseComb(cond,classUnitsAll == 1, stim)),squeeze(OIndexAllStimBaseComb(cond,classUnitsAll == 2, stim)));
        end       
    end
end


STEMOIndexAllStimBaseComb = nan(2, totalStim);
STEMOIndexAllStimBaseCombExc = nan(2, totalStim);
STEMOIndexAllStimBaseCombInh = nan(2, totalStim);

% % not sure if usage of baseSelectUnits is correct
for cond =1:2
    for stim = 2:numel(baseStim)
        STEMOIndexAllStimBaseComb(cond, stim) = nanstd(OIndexAllStimBaseComb(cond,:,stim))/sqrt(sum(~isnan(OIndexAllStimBaseComb(cond,:,stim))));
        STEMOIndexAllStimBaseCombExc(cond, stim) = nanstd(OIndexAllStimBaseComb(cond,classUnitsAll == 1,stim))/sqrt(sum(~isnan(OIndexAllStimBaseComb(cond,classUnitsAll(baseSelectUnits) == 1,stim))));
        STEMOIndexAllStimBaseCombInh(cond, stim) = nanstd(OIndexAllStimBaseComb(cond,classUnitsAll == 2,stim))/sqrt(sum(~isnan(OIndexAllStimBaseComb(cond,classUnitsAll(baseSelectUnits) == 2,stim))));
    end
end    

% Calculate mean and STEM of the ratio of normalized amplitude

meanRatioNormAllStimBaseComb = nanmean(ratioNormAllStimBaseComb,2);
meanRatioNormAllStimBaseCombExc = nanmean(ratioNormAllStimBaseComb(:,classUnitsAll == 1,:),2);
meanRatioNormAllStimBaseCombInh = nanmean(ratioNormAllStimBaseComb(:,classUnitsAll == 2,:),2);

STEMratioNormAllStimBaseComb = nan(2, numel(baseStim));
STEMratioNormAllStimBaseCombExc = nan(2, numel(baseStim));
STEMratioNormAllStimBaseCombInh = nan(2, numel(baseStim));

for cond = 1:2
    for stim = 2:numel(baseStim)
        STEMratioNormAllStimBaseComb(cond,stim) = nanstd(ratioNormAllStimBaseComb(cond,:,stim))/sqrt(sum(~isnan(ratioNormAllStimBaseComb(cond,:,stim))));
        STEMratioNormAllStimBaseCombExc(cond,stim) = nanstd(ratioNormAllStimBaseComb(cond,classUnitsAll == 1,stim))/sqrt(sum(~isnan(ratioNormAllStimBaseComb(cond,classUnitsAll == 1,stim))));
        STEMratioNormAllStimBaseCombInh(cond,stim) = nanstd(ratioNormAllStimBaseComb(cond,classUnitsAll == 2,stim))/sqrt(sum(~isnan(ratioNormAllStimBaseComb(cond,classUnitsAll == 2,stim))));
    end
end

pSuaBaseCombAll = clusterTimeSeriesAll.statsSua.pSuaBaseComb;


%% Analysis Fig 13a - average amplitude - baseline (Hz)
if totalStim == 6
    amplMinusBase = allStimAmpl - allStimBase;
    
    meanAmplMinusBase = nanmean(amplMinusBase,2);
    
    for cond = 1:totalConds
        for stim = 1:totalStim
            STEMamplMinusBase(cond,stim) = nanstd(amplMinusBase(cond,:,stim))/sqrt(sum(~isnan(amplMinusBase(cond,:,stim))));
        end
    end
    
    for cond = (1:2:totalConds)
        for stim = 1:totalStim
            [hAmplMinusBase((cond+1)/2,stim), pAmplMinusBase((cond+1)/2,stim)] =ttest(amplMinusBase(cond,:,stim),amplMinusBase(cond+1,:,stim)); % opt vs vis
            [pAmplMinusBaseW((cond+1)/2,stim), hAmplMinusBaseW((cond+1)/2,stim)] =signrank(amplMinusBase(cond,:,stim),amplMinusBase(cond+1,:,stim)); %  opt vs vis
        end
    end
    
    ratioAmplMinusBase = nan(totalConds/2, totalUnits, totalStim);
    OIndexAmplMinusBase = nan(totalConds/2, totalUnits, totalStim);
    for cond = 1:2:totalConds
        for unit = 1:totalUnits
            for stim = 1:totalStim
                ratioAmplMinusBase((cond+1)/2, unit,stim) = amplMinusBase(cond+1, unit,stim)/amplMinusBase(cond, unit,stim);
                OIndexAmplMinusBase((cond+1)/2, unit,stim) = (amplMinusBase(cond+1, unit,stim)-amplMinusBase(cond, unit,stim))/(amplMinusBase(cond+1, unit,stim)+amplMinusBase(cond, unit,stim));
            end
        end
    end
    
    
    if totalStim == 1 % only for single-stim protocol
        ratioNormAmplMinusBase = ratioAmplMinusBase;
    else % for multi-stim protocol, divide by first stim
        ratioNormAmplMinusBase = ratioAmplMinusBase ./ ratioAmplMinusBase(:,:,1);
    end
    
    
    meanOIndexAmplMinusBase = nanmean(OIndexAmplMinusBase,2);
    STEMOIndexAmplMinusBase = nan(totalConds/2, totalStim);
    for cond = 1:totalConds/2
        for stim = 1:totalStim
            STEMOIndexAmplMinusBase(cond, stim) = nanstd(OIndexAmplMinusBase(cond,:,stim))/sqrt(sum(~isnan(OIndexAmplMinusBase(cond,:,stim))));
        end
    end
    
    % Calculate mean and STEM of the ratio of normalized amplitude
    
    meanRatioNormAmplMinusBase = squeeze(nanmean(ratioNormAmplMinusBase,2));
    STEMratioNormAmplMinusBase = nan(totalConds/2, totalStim);
    for cond = 1:2:totalConds
        for stim = 1:totalStim
            STEMratioNormAmplMinusBase((cond+1)/2,stim) = nanstd(ratioNormAmplMinusBase((cond+1)/2,:,stim))/sqrt(sum(~isnan(ratioNormAmplMinusBase((cond+1)/2,:,stim))));
        end
    end
elseif totalStim == 1
    amplMinusBase = allStimAmpl - squeeze(allStimBase(:,:,3));
    
    meanAmplMinusBase = nanmean(amplMinusBase,2);
    
    for cond = 1:totalConds
        STEMamplMinusBase(cond) = nanstd(amplMinusBase(cond,:))/sqrt(sum(~isnan(amplMinusBase(cond,:))));
    end
    
    for cond = (1:2:totalConds)
        [hAmplMinusBase((cond+1)/2), pAmplMinusBase((cond+1)/2)] =ttest(amplMinusBase(cond,:),amplMinusBase(cond+1,:)); % opt vs vis
        [pAmplMinusBaseW((cond+1)/2), hAmplMinusBaseW((cond+1)/2)] =signrank(amplMinusBase(cond,:),amplMinusBase(cond+1,:)); %  opt vs vis
    end
    
    for cond = 1:2:totalConds
        for unit = 1:totalUnits
            ratioAmplMinusBase((cond+1)/2, unit) = amplMinusBase(cond+1, unit)/amplMinusBase(cond, unit);
            OIndexAmplMinusBase((cond+1)/2, unit) = (amplMinusBase(cond+1, unit)-amplMinusBase(cond, unit))/(amplMinusBase(cond+1, unit)+amplMinusBase(cond, unit));
        end
    end
    % only for single-stim protocol
    ratioNormAmplMinusBase = ratioAmplMinusBase;
    
    meanOIndexAmplMinusBase = mean(OIndexAmplMinusBase,2);
    
    for cond = 1:totalConds/2
        STEMOIndexAmplMinusBase(cond) = nanstd(OIndexAmplMinusBase(cond,:))/sqrt(sum(~isnan(OIndexAmplMinusBase(cond,:))));
    end
    
    % Calculate mean and STEM of the ration of normalized amplitude
    
    meanRatioNormAmplMinusBase(:) = nanmean(ratioNormAmplMinusBase,2);
    
    for cond = 1:2:totalConds
        STEMratioNormAmplMinusBase((cond+1)/2) = nanstd(ratioNormAmplMinusBase((cond+1)/2,:))/sqrt(sum(~isnan(ratioNormAmplMinusBase((cond+1)/2,:))));
    end
end
%% Analysis Fig. 13b (1x) [under construction]- normalized amplitude - baseline to the first stim amplitude in 100% no photostim cond 
% 
% % Normalized amplitude calculations  
% 
% for cond = 1:totalConds
%     for unit = 1:totalUnits
% %         for stim = 1:totalStim
%         normAllStimAmpl100(cond, unit) = allStimAmpl(cond, unit)/allStimAmpl(1, unit);
% %         end
%     end
% end
% 
% % Calculate mean and STEM of normalized amplitude
% 
% meanNormAllStimAmpl100 = nanmean(normAllStimAmpl100,2);
%     
% for cond = 1:totalConds  
%     STEMnormAllStimAmpl100(cond) = nanstd(normAllStimAmpl100(cond,:))/sqrt(sum(~isnan(normAllStimAmpl100(cond,:))));  
% end
% 
% for cond = (1:2:totalConds)
%     [hNormAllStimAmpl100((cond+1)/2), pNormAllStimAmpl100((cond+1)/2)] =ttest(normAllStimAmpl100(cond,:),normAllStimAmpl100(cond+1,:)); % opt vs vis
%     [pNormAllStimAmpl100W((cond+1)/2), hNormAllStimAmpl100W((cond+1)/2)] =signrank(normAllStimAmpl100(cond,:),normAllStimAmpl100(cond+1,:)); %  opt vs vis
% end
%% Analysis Fig 13c - average amplitude - baseline (Hz)
if totalStim == 6
    amplMinusBaseNormTrace = allStimAmplNormTrace - allStimBaseNormTrace;
    
    meanAmplMinusBaseNormTrace = nanmean(amplMinusBaseNormTrace,2);
    
    for cond = 1:totalConds
        for stim = 1:totalStim
            STEMamplMinusBaseNormTrace(cond,stim) = nanstd(amplMinusBaseNormTrace(cond,:,stim))/sqrt(sum(~isnan(amplMinusBaseNormTrace(cond,:,stim))));
        end
    end
    
    for cond = (1:2:totalConds)
        for stim = 1:totalStim
            [hAmplMinusBaseNormTrace((cond+1)/2,stim), pAmplMinusBaseNormTrace((cond+1)/2,stim)] =ttest(amplMinusBaseNormTrace(cond,:,stim),amplMinusBaseNormTrace(cond+1,:,stim)); % opt vs vis
            [pAmplMinusBaseNormTraceW((cond+1)/2,stim), hAmplMinusBaseNormTraceW((cond+1)/2,stim)] =signrank(amplMinusBaseNormTrace(cond,:,stim),amplMinusBaseNormTrace(cond+1,:,stim)); %  opt vs vis
        end
    end
    
    ratioAmplMinusBaseNormTrace = nan(totalConds/2, totalUnits, totalStim);
    OIndexAmplMinusBaseNormTrace = nan(totalConds/2, totalUnits, totalStim);
    for cond = 1:2:totalConds
        for unit = 1:totalUnits
            for stim = 1:totalStim
                ratioAmplMinusBaseNormTrace((cond+1)/2, unit,stim) = amplMinusBaseNormTrace(cond+1, unit,stim)/amplMinusBaseNormTrace(cond, unit,stim);
                OIndexAmplMinusBaseNormTrace((cond+1)/2, unit,stim) = (amplMinusBaseNormTrace(cond+1, unit,stim)-amplMinusBaseNormTrace(cond, unit,stim))/(amplMinusBaseNormTrace(cond+1, unit,stim)+amplMinusBaseNormTrace(cond, unit,stim));
            end
        end
    end
    
elseif totalStim == 1
    amplMinusBaseNormTrace = allStimAmplNormTrace - squeeze(allStimBaseNormTrace(:,:,3));
    
    meanAmplMinusBaseNormTrace = nanmean(amplMinusBaseNormTrace,2);
    
    for cond = 1:totalConds
        STEMamplMinusBaseNormTrace(cond) = nanstd(amplMinusBaseNormTrace(cond,:))/sqrt(sum(~isnan(amplMinusBaseNormTrace(cond,:))));
    end
    
    for cond = (1:2:totalConds)
        [hAmplMinusBaseNormTrace((cond+1)/2), pAmplMinusBaseNormTrace((cond+1)/2)] =ttest(amplMinusBaseNormTrace(cond,:),amplMinusBaseNormTrace(cond+1,:)); % opt vs vis
        [pAmplMinusBaseNormTraceW((cond+1)/2), hAmplMinusBaseNormTraceW((cond+1)/2)] =signrank(amplMinusBaseNormTrace(cond,:),amplMinusBaseNormTrace(cond+1,:)); %  opt vs vis
    end
    
    for cond = 1:2:totalConds
        for unit = 1:totalUnits
            ratioAmplMinusBaseNormTrace((cond+1)/2, unit) = amplMinusBaseNormTrace(cond+1, unit)/amplMinusBaseNormTrace(cond, unit);
            OIndexAmplMinusBaseNormTrace((cond+1)/2, unit) = (amplMinusBaseNormTrace(cond+1, unit)-amplMinusBaseNormTrace(cond, unit))/(amplMinusBaseNormTrace(cond+1, unit)+amplMinusBaseNormTrace(cond, unit));
            
        end
    end
    % only for single-stim protocol
    ratioNormAmplMinusBaseNormTrace = ratioAmplMinusBaseNormTrace;
    % for multi-stim protocol, divide by first stim
    
    meanOIndexAmplMinusBaseNormTrace = mean(OIndexAmplMinusBaseNormTrace,2);
    
    for cond = 1:totalConds/2
        STEMOIndexAmplMinusBaseNormTrace(cond) = nanstd(OIndexAmplMinusBaseNormTrace(cond,:))/sqrt(sum(~isnan(OIndexAmplMinusBaseNormTrace(cond,:))));
    end
    
    % Calculate mean and STEM of the ratio of normalized amplitude
    
    meanRatioNormAmplMinusBaseNormTrace = squeeze(nanmean(ratioNormAmplMinusBaseNormTrace,2));
    
    for cond = 1:2:totalConds
        STEMratioNormAmplMinusBaseNormTrace((cond+1)/2) = nanstd(ratioNormAmplMinusBaseNormTrace((cond+1)/2,:))/sqrt(sum(~isnan(ratioNormAmplMinusBaseNormTrace((cond+1)/2,:))));
    end
end


%% Analysis Fig. 14a (1x)  - normalized amplitude-baseline to the first stim amplitude-baseline in no photostim cond or SEE NEXT!

% Normalized amplitude calculations  
normAmplMinusBase = nan(totalConds-2, totalUnits, totalStim);
for cond = 1:totalConds-2
    condNorm = floor((cond+1)/2)*2-1; % normalized by the non-photostim condition
    for unit = find(iUnitsFilt)
        for stim = 1:totalStim
            normAmplMinusBase(cond, unit, stim) = amplMinusBase(cond, unit, stim)/amplMinusBase(condNorm, unit, 1);
        end
    end
end

% Calculate mean and STEM of normalized amplitude

meanNormAmplMinusBase = squeeze(nanmean(normAmplMinusBase,2));
STEMnormAmplMinusBase = nan(totalConds-2, totalStim);    
for cond = 1:totalConds-2  
    for stim = 1:totalStim
        STEMnormAmplMinusBase(cond, stim) = nanstd(normAmplMinusBase(cond,:, stim))/sqrt(sum(~isnan(normAmplMinusBase(cond,:, stim))));  
    end
end

hNormAmplMinusBase = nan((totalConds-2)/2, totalStim);
pNormAmplMinusBase = nan((totalConds-2)/2, totalStim);
pNormAmplMinusBaseW = nan((totalConds-2)/2, totalStim);
hNormAmplMinusBaseW = nan((totalConds-2)/2, totalStim);
for cond = (1:2:totalConds-2)
    for stim = 1:totalStim
        [hNormAmplMinusBase((cond+1)/2, stim), pNormAmplMinusBase((cond+1)/2, stim)] =ttest(normAmplMinusBase(cond,:, stim),normAmplMinusBase(cond+1,:, stim)); % opt vs vis
        [pNormAmplMinusBaseW((cond+1)/2, stim), hNormAmplMinusBaseW((cond+1)/2, stim)] =signrank(normAmplMinusBase(cond,:, stim),normAmplMinusBase(cond+1,:, stim)); %  opt vs vis
    end
end

%% Analysis Fig. 14b (1x)  - normalized amplitude-base to the first stim amplitude-base in 100% no photostim cond 
% 
% % Normalized amplitude calculations : select first line or the next ones 
% normAmplMinusBase100 = allStimAmplNormTrace100 - squeeze(allStimBaseNormTrace100(:,:,3));
% 
% %  for cond = 1:totalConds
% %     for unit = 1:totalUnits
% %         normAmplMinusBase100(cond, unit) = amplMinusBase(cond, unit)/amplMinusBase(1, unit);
% %     end
% % end
% 
% % Calculate mean and STEM of normalized amplitude
% 
% meanNormAmplMinusBase100 = nanmean(normAmplMinusBase100,2);
%     
% for cond = 1:totalConds  
%     STEMnormAmplMinusBase100(cond) = nanstd(normAmplMinusBase100(cond,:))/sqrt(sum(~isnan(normAmplMinusBase100(cond,:))));  
% end
% 
% for cond = (1:2:totalConds)
%     [hNormAmplMinusBase100((cond+1)/2), pNormAmplMinusBase100((cond+1)/2)] =ttest(normAmplMinusBase100(cond,:),normAmplMinusBase100(cond+1,:)); % opt vs vis
%     [pNormAmplMinusBase100W((cond+1)/2), hNormAmplMinusBase100W((cond+1)/2)] =signrank(normAmplMinusBase100(cond,:),normAmplMinusBase100(cond+1,:)); %  opt vs vis
% end


%% Analysis Fig16. base1 vs base2, combined - applicable for spont in protocol 7 and protocol 2 
% 

% baseSelect = allStimBase(totalConds-1,:,1) >= thresholdFreq ; %%% under
% construction
allStimBaseComb(1,:,:) = nanmean(allStimBase(1:2:end, :, :), 1);
allStimBaseComb(2,:,:) = nanmean(allStimBase(2:2:end, :, :), 1);


%% Analysis Fig. 17: Combined baseline quantification

% Calculate mean and STEM of baseline and stat tests
if totalStim == 1
    meanAllStimBaseComb = squeeze(nanmean(allStimBaseComb,2));
    
    for cond = 1:2
        for stim = 1:numel(baseStim)
            STEMallStimBaseComb(cond, stim) = nanstd(allStimBaseComb(cond,:,stim))/sqrt(sum(~isnan(allStimBaseComb(cond, :,stim))));
        end
    end
    
    
    for stim = 1:numel(baseStim)
        [hAllStimBaseComb(stim,1), pAllStimBaseComb(stim,1)] = ttest(squeeze(allStimBaseComb(2,:,1)),squeeze(allStimBaseComb(2,:,stim))); % param: all stims vs first stim in photostim conditions
        [hAllStimBaseComb(stim,2), pAllStimBaseComb(stim,2)] = ttest(squeeze(allStimBaseComb(1,:,stim)),squeeze(allStimBaseComb(2,:,stim))); % param: stim in photostim cond vs stim in non-photostim cond
        [pAllStimBaseCombW(stim,1), hAllStimBaseCombW(stim,1)] = signrank(squeeze(allStimBaseComb(2,:,1)),squeeze(allStimBaseComb(2,:,stim))); % nonparam: all stims vs first stim in photostim conditions
        [pAllStimBaseCombW(stim,2), hAllStimBaseCombW(stim,2)] = signrank(squeeze(allStimBaseComb(1,:,stim)),squeeze(allStimBaseComb(2,:,stim))); % nonparam: stim in photostim cond vs stim in non-photostim cond
    end
end    

%% Analysis Fig. 18 - Normalized combined baseline to the first stim value

% normalize baseline to first stim (before photostim) in each condition 

if totalStim == 1
    normAllStimBaseComb = nan(2, totalUnits, numel(baseStim));
    for cond = 1:2
        for unit = find(iUnitsFilt)
            for stim = 1:numel(baseStim)
                if allStimBaseComb(cond, unit, 1) ~=0 && ~isnan(allStimBaseComb(cond, unit, 1))
                    normAllStimBaseComb(cond, unit, stim) = allStimBaseComb(cond, unit, stim)./allStimBaseComb(cond, unit, 1);
                else
                    normAllStimBaseComb(cond, unit, stim) = NaN;
                end
            end
        end
    end
    
    % Calculate mean and STEM of normalized baseline
    meanNormAllStimBaseComb = squeeze(nanmean(normAllStimBaseComb,2));
    
    for cond = 1:2
        for stim = 1:numel(baseStim)
            STEMnormAllStimBaseComb(cond,stim) = nanstd(normAllStimBaseComb(cond,:,stim))/sqrt(sum(~isnan(normAllStimBaseComb(cond,:,stim))));
        end
    end
    
    
    for stim = 1:numel(baseStim)
        [hNormAllStimBaseComb(stim,1), pNormAllStimBaseComb(stim,1)] = ttest(squeeze(normAllStimBaseComb(2,:,1)),squeeze(normAllStimBaseComb(2,:,stim))); % param: all stims vs first stim in photostim conditions
        [hNormAllStimBaseComb(stim,2), pNormAllStimBaseComb(stim,2)] = ttest(squeeze(normAllStimBaseComb(1,:,stim)),squeeze(normAllStimBaseComb(2,:,stim))); % param: stim in photostim cond vs stim in non-photostim cond
        [pNormAllStimBaseCombW(stim,1), hNormAllStimBaseCombW(stim,1)] = signrank(squeeze(normAllStimBaseComb(2,:,1)),squeeze(normAllStimBaseComb(2,:,stim))); % nonparam: all stims vs first stim in photostim conditions
        [pNormAllStimBaseCombW(stim,2), hNormAllStimBaseCombW(stim,2)] = signrank(squeeze(normAllStimBaseComb(1,:,stim)),squeeze(normAllStimBaseComb(2,:,stim))); % nonparam: stim in photostim cond vs stim in non-photostim cond
    end
end

%% Analysis Fig. 20 (1x) - Combine traces with or without photostim (prev fig 19, short)
if totalStim == 1
    traceFreqAllComb = nan(2, totalUnits, totalDatapoints);
    for unit = find(iUnitsFilt)
        traceFreqAllComb(1,unit,:) = nanmean(clusterTimeSeriesAll.traceFreqGood(1:2:end, unit, :), 1);
        traceFreqAllComb(2,unit,:) = nanmean(clusterTimeSeriesAll.traceFreqGood(2:2:end, unit, :), 1);
    end
    % Calculate mean of smoothed trace frequency TCs
    meanTraceFreqAllComb = squeeze(nanmean(traceFreqAllComb(:, iUnitsFilt,:),2));
    
    % Calculate STEM of frequency TCs over cells
    for cond = 1 : 2
        for datapoint = 1:totalDatapoints
            STEMtraceFreqAllComb(cond, datapoint) = nanstd(traceFreqAllComb(cond, iUnitsFilt, datapoint))/sqrt(sum(~isnan(traceFreqAllComb(cond, iUnitsFilt, datapoint))));
        end
    end
end

%% Analysis for Fig. 21 (1x): average of normalized time courses (prev fig 20, short)
% Baseline calculations  % dim: cond, unit, stim 
if totalStim == 1
    % normalize to baseline (without photostim) and then smooth
    for cond = 1:2
        for unit = find(iUnitsFilt)
            normTraceFreqAllComb(cond, unit, :) = smooth(traceFreqAllComb(cond, unit, :)/allStimBaseComb(1, unit,1),smooth_param, smooth_method);
        end
    end
    
    % Calculate mean of smoothed and norm TCs
    for cond = 1:2
        meanNormTraceFreqAllComb = squeeze(nanmean(normTraceFreqAllComb,2));
    end
    
    % Calculate STEM of TCs over cells
    for cond = 1:2
        for datapoint = 1:totalDatapoints
            STEMnormTraceFreqAllComb(cond, datapoint) = nanstd(normTraceFreqAllComb(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAllComb(cond, :,datapoint))));
        end
    end
end



%% Analysis for Fig. 22: traces of visual evoked - sponateneous activity

allStimMagn = allStimAmpl-allStimBase;
if totalStim == 1
    allStimMagn = allStimMagn(:,:,end);
end

meanAllStimMagn = squeeze(nanmean(allStimMagn(:,baseSelect,:),2)); % added baseSelect on 28.02.2023

STEMallStimMagn = nan(totalConds, totalStim);
for cond = 1:totalConds
    for stim = 1:totalStim
        STEMallStimMagn(cond, stim) = nanstd(allStimMagn(cond,baseSelect,stim))/sqrt(sum(~isnan(allStimMagn(cond, baseSelect,stim))));        
    end
end

for cond = (1:2:totalConds)
    for stim = 1:totalStim
        [hAllStimMagn((cond+1)/2, stim), pAllStimMagn((cond+1)/2, stim)] =ttest(allStimMagn(cond,baseSelect, stim),allStimMagn(cond+1,baseSelect, stim)); % opt vs vis
        [pAllStimMagnW((cond+1)/2, stim), hAllStimMagnW((cond+1)/2, stim)] =signrank(allStimMagn(cond,baseSelect, stim),allStimMagn(cond+1,baseSelect, stim)); %  opt vs vis
    end   
end

% calculation for LineaRegressionAnalysis
if totalStim == 1
    allStimMagnNorm = nan(totalConds/2, totalUnits);
    for unit = find(baseSelect)
        if (max(allStimMagn(:,unit)) ~= 0)
            allStimMagnNorm(:,unit) = allStimMagn(1:2:totalConds,unit) / max(allStimMagn(1:2:totalConds,unit));
        end
    end
    % continue here with a proper calculation of the above
%     figure
    allStimMagnNorm = nan(totalConds/2, totalUnits);
    for cond = (1:2:totalConds-2)
        for unit = find(baseSelect)
            if (max(allStimMagn(cond,unit)) ~= 0)% && unit ~= 120) % only for PvCre, exc, 9s
                allStimMagnNorm((cond+1)/2,unit) = (allStimMagn(cond+1,unit) -allStimMagn(cond,unit))./ allStimMagn(cond,unit);
            end
        end  
%         subplot(1,5,(cond+1)/2)
        %boxplot(allStimMagnNorm((cond+1)/2,:))
        %ylim([-2 2]);
%         histogram(allStimMagnNorm((cond+1)/2,:))
    end
    nanmedian(allStimMagnNorm,2)
    %%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % similar amplitude calculation        
%     figure
    allStimAmplNorm = nan(totalConds/2, totalUnits);
    for cond = (1:2:totalConds)
        for unit = find(baseSelect)
            if (max(allStimAmpl(cond,unit)) ~= 0 && unit ~= 120) % only for PvCre, exc, 9s
                allStimAmplNorm((cond+1)/2,unit) = allStimAmpl(cond+1,unit) ./ allStimAmpl(cond,unit);
            end
        end  
%         subplot(1,5,(cond+1)/2)
%         boxplot(allStimAmplNorm((cond+1)/2,:))
%         ylim([-0.2 3]);
        %histogram(allStimAmplNorm((cond+1)/2,:))
    end
    nanmean(allStimAmplNorm,2)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    allStimMagnDiff = nan(totalConds/2, totalUnits);
%     figure
    for cond = (1:2:totalConds)
        allStimMagnDiff((cond+1)/2,:) = allStimMagn(cond+1,:) - allStimMagn(cond,:);
%         subplot(1,5,(cond+1)/2)
%         boxplot(allStimMagnDiff((cond+1)/2,:))
        %scatter(1, nanmean(allStimMagnDiff((cond+1)/2,:)))
%         ylim([-4 3])
        %histogram(allStimMagnDiff((cond+1)/2,:))
        
    end
    
    allStimMagnDiffNorm = nan(totalConds/2, totalUnits);
%     for unit = find(baseSelect)
%         if (max(allStimMagnDiff(:,unit)) ~= 0)
%             allStimMagnDiffNorm(:,unit) = allStimMagnDiff(:,unit) / max(allStimMagnDiff(:,unit));
%         end
%     end
    
    % OR
    for unit = find(baseSelect)
        if (allStimMagn(1,unit) ~= 0)
            allStimMagnDiffNorm(:,unit) = allStimMagnDiff(:,unit) / allStimMagn(1,unit);
        end
    end
    
    
    %%% trying with the amplitude
    allStimAmplDiff = nan(totalConds/2, totalUnits);
    for cond = (1:2:totalConds)
        allStimAmplDiff((cond+1)/2,:) = allStimAmpl(cond,:) - allStimAmpl(cond+1,:);
    end
    

%     allStimMagnDiffNorm = nan(totalConds/2, totalUnits);
%     for unit = find(baseSelect)
%         if (allStimMagnDiff(1,unit) ~= 0)
%             allStimMagnDiffNorm(:,unit) = allStimMagnDiff(:,unit) / allStimMagnDiff(1,unit);
%         end
%     end
%       
%     meanAllStimMagnDiffNorm = nanmean(allStimMagnDiffNorm,2);
%     STEMallStimMagnDiffNorm = nan(totalConds/2);
%     for cond = 1:totalConds/2
%         STEMallStimMagnDiffNorm(cond) = nanstd(allStimMagnDiffNorm(cond,:))/sqrt(sum(~isnan(allStimMagnDiffNorm(cond, :))));
%     end

    
end



% the next calculation seems very weird
% calculate magnitude as V-Vph

% baseSelect = allStimBase(totalConds-1,:,1) >= thresholdFreq ; 
magnCondDiff = nan(totalConds-2, totalUnits, totalDatapoints);
for cond = 1:totalConds-2
    for unit = find(iUnitsFilt & baseSelect)
        % subtract S from V or Sph from Vph
        magnCondDiff(cond, unit, :) = smoothTraceFreqAll(cond, unit,:)-smoothTraceFreqAll(totalConds-mod(cond,2), unit,:);
    end
end


meanMagnCondDiff = nanmean(magnCondDiff,2);


% Calculate STEM of TCs over cells

STEMmagnCondDiff = nan(totalConds-2, totalDatapoints);
for cond = 1:totalConds-2
    for datapoint = 1:totalDatapoints
        STEMmagnCondDiff(cond, datapoint) = nanstd(magnCondDiff(cond,:,datapoint))/sqrt(sum(~isnan(magnCondDiff(cond, :,datapoint))));        
    end    
end


%% Analysis for fig 23: normalized Ev - Sp to the 1st vis resp

% calculate max in each timecourse of each cell, for conds with evoked activity
if sessionInfoAll.trialDuration == 18
    searchMax = [17:19]; % in data points
elseif sessionInfoAll.trialDuration == 6
    searchMax = [31:33];
elseif sessionInfoAll.trialDuration == 9
    searchMax = [46:48];
end

maxMagnCondDiff = nan(totalConds-2, totalUnits);
maxIndMagnCondDiff = nan(totalConds-2, totalUnits);
smoothMaxMagnCondDiff = nan(totalConds-2, totalUnits);

for cond = 1: totalConds-2
    for unit = find(iUnitsFilt & baseSelect)
        [maxMagnCondDiff(cond, unit), maxIndMagnCondDiff(cond, unit)] = max(magnCondDiff(cond, unit, searchMax));
        maxIndMagnCondDiff(cond, unit) = maxIndMagnCondDiff(cond, unit) + searchMax(1)-1;
        smoothMaxMagnCondDiff(cond, unit) = mean(magnCondDiff(cond, unit, maxIndMagnCondDiff(cond, unit))); % just max
    end
end


% normalize >0% vis. stim. to max (without photostim) (or smoothMax) and then smooth
smooth_param = 1;
normMagnCondDiff = nan(totalConds-2, totalUnits, totalDatapoints);
normMagnCondDiff100 = nan(totalConds-2, totalUnits, totalDatapoints);
for cond = 1:totalConds-2
    condNorm = floor((cond+1)/2)*2-1; % normalize by the non-photostim condition
    for unit = find(iUnitsFilt & baseSelect)       
        % normalize by the non-photostim condition
        normMagnCondDiff(cond, unit, :) = smooth(magnCondDiff(cond, unit, :)/smoothMaxMagnCondDiff(condNorm, unit),smooth_param, smooth_method);
        % normalize by the 100% non-photostim condition
        normMagnCondDiff100(cond, unit, :) = smooth(magnCondDiff(cond, unit, :)/smoothMaxMagnCondDiff(1, unit),smooth_param, smooth_method);
    end
end


meanNormMagnCondDiff = squeeze(nanmean(normMagnCondDiff,2));
meanNormMagnCondDiff100 = squeeze(nanmean(normMagnCondDiff100,2));
 

% Calculate STEM of TCs over cells
STEMnormMagnCondDiff = nan(totalConds, totalDatapoints);
STEMnormMagnCondDiff100 = nan(totalConds, totalDatapoints);
for cond = 1:totalConds-2
    for datapoint = 1:totalDatapoints
        STEMnormMagnCondDiff(cond, datapoint) = nanstd(normMagnCondDiff(cond,:,datapoint))/sqrt(sum(~isnan(normMagnCondDiff(cond, :,datapoint))));
        STEMnormMagnCondDiff100(cond, datapoint) = nanstd(normMagnCondDiff100(cond,:,datapoint))/sqrt(sum(~isnan(normMagnCondDiff100(cond, :,datapoint))));
    end    
end

%% Analysis Fig. 24 : Magnitude (evoked - spont trace) quantification (under construction!!! - no figure for this script yet)

disp('For fig 24 and onwards, baseStim and baseDuration modified as for longBase = 0')
   

% Baseline calculations  % dim: cond, unit, stim 
baseStim = clusterTimeSeriesAll.baseTime; % [12 27 42 57 72 87] or [6, 12, 26];
baseDuration = 1/bin-1; % additional data points for baseline quantification (1 sec)
       
allStimBaseMagnCondDiff = nan(totalConds-2, totalUnits, numel(baseStim));
for cond = 1:totalConds-2
    for unit = find(iUnitsFilt)
        for stim = 1:numel(baseStim)
            allStimBaseMagnCondDiff(cond, unit, stim) = nanmean(magnCondDiff(cond, unit, baseStim(stim):baseStim(stim)+baseDuration),3);
        end
    end
end

% calculare max in each timecourse of each cell, for conds with evoked activity
if sessionInfoAll.trialDuration == 18
    amplInt = [17:19]; % in data points 
elseif sessionInfoAll.trialDuration == 6
    amplInt = [31:33];
elseif sessionInfoAll.trialDuration == 9
    amplInt = [46:48];
end

allStimAmplMagnCondDiff = nan(totalConds-2, totalUnits, totalStim);

for cond = 1:totalConds-2
    for unit = find(iUnitsFilt & baseSelect)
        for stim = 1:totalStim % 2 calculations: hz values and normalized values
            allStimAmplMagnCondDiff(cond, unit, stim) = nanmean(magnCondDiff(cond, unit, (stim-1)*(3/bin)+amplInt),3);
        end
    end
end

% Calculate mean and STEM of baselines and amplitudes
meanAllStimBaseMagnCondDiff = nan(totalConds-2, totalStim);
meanAllStimAmplMagnCondDiff = nan(totalConds-2, totalStim);

for cond = 1:totalConds-2
    for stim = 1:numel(baseStim)
        meanAllStimBaseMagnCondDiff (cond, stim) = squeeze(nanmean(allStimBaseMagnCondDiff(cond, :, stim),2));
    end
end

for cond = 1:totalConds-2
    for stim = 1:totalStim
        meanAllStimAmplMagnCondDiff (cond, stim) = squeeze(nanmean(allStimAmplMagnCondDiff(cond, :, stim),2));
    end
end

STEMallStimBaseMagnCondDiff  = nan(totalConds-2, numel(baseStim));
for cond = 1:totalConds-2
    for stim = 1:numel(baseStim)
        STEMallStimBaseMagnCondDiff (cond, stim) = nanstd(allStimBaseMagnCondDiff (cond,:, stim))/sqrt(sum(~isnan(allStimBaseMagnCondDiff (cond,:, stim))));  
    end
end

STEMallStimAmplMagnCondDiff  = nan(totalConds-2, totalStim);
for cond = 1:totalConds-2
    for stim = 1:totalStim
        STEMallStimAmplMagnCondDiff (cond, stim) = nanstd(allStimAmplMagnCondDiff (cond,:, stim))/sqrt(sum(~isnan(allStimAmplMagnCondDiff (cond,:, stim))));  
    end
end

for cond = (1:2:totalConds-2)
    for stim = 1:numel(baseStim)
        [hAllStimBaseMagnCondDiff((cond+1)/2, stim), pAllStimBaseMagnCondDiff((cond+1)/2, stim)] =ttest(allStimBaseMagnCondDiff(cond,:, stim),allStimBaseMagnCondDiff(cond+1,:, stim)); % opt vs vis
        [pAllStimBaseMagnCondDiffW((cond+1)/2, stim), hAllStimBaseMagnCondDiffW((cond+1)/2, stim)] =signrank(allStimBaseMagnCondDiff(cond,:, stim),allStimBaseMagnCondDiff(cond+1,:, stim)); %  opt vs vis
    end   
end

for cond = (1:2:totalConds-2)
    for stim = 1:totalStim
        [hAllStimAmplMagnCondDiff((cond+1)/2, stim), pAllStimAmplMagnCondDiff((cond+1)/2, stim)] =ttest(allStimAmplMagnCondDiff(cond,:, stim),allStimAmplMagnCondDiff(cond+1,:, stim)); % opt vs vis
        [pAllStimAmplMagnCondDiffW((cond+1)/2, stim), hAllStimAmplMagnCondDiffW((cond+1)/2, stim)] =signrank(allStimAmplMagnCondDiff(cond,:, stim),allStimAmplMagnCondDiff(cond+1,:, stim)); %  opt vs vis
    end   
end


%% analysis for Fig 25a - reproduction of fig 5a from eLife 2020 (average of baseline-subtracted and norm traces )
% analysis for Fig 26a - reproduction of fig 8a from eLife 2020 (average of baseline-subtracted and norm traces )
% analysis for Fig 26b - reproduction of fig 8c from eLife 2020 (average of baseline-subtracted and norm traces )

% approach: subtr Sph from Vph, subtr baseline, normalize to max in first cond
% this approach is the same as subtr baseline, normalize to max in first cond, subtr Sph from Vph
% all fine with figs 25a, 26a, but is 26b the same no mather the approach?
% Most likely yes

allStimMagnMagnCondDiff = allStimAmplMagnCondDiff-allStimBaseMagnCondDiff;

traces = [smoothTraceFreqAll;magnCondDiff];

baseStim = clusterTimeSeriesAll.baseTime; % [12 27 42 57 72 87] or [6, 12, 26];
baseDuration = 1/bin-1; % additional data points for baseline quantification (1 sec)
       
allStimBaseTraces = nan(2*totalConds-2, totalUnits, numel(baseStim));
for cond = 1:2*totalConds-2
    for unit = find(iUnitsFilt & baseSelect)
        for stim = 1:numel(baseStim)
            allStimBaseTraces(cond, unit, stim) = nanmean(traces(cond, unit, baseStim(stim):baseStim(stim)+baseDuration),3);
        end
    end
end

tracesBaseSubtr = nan(size(traces));
for cond = 1:2*totalConds-2
    for unit = find(iUnitsFilt & baseSelect)
        tracesBaseSubtr(cond, unit, :) = traces(cond, unit, :) - allStimBaseTraces(cond,unit,1);
    end
end    

% baseSelect = allStimBase(totalConds-1,:,1) >= thresholdFreq ; 
% meanTraces = nanmean(traces(:,iUnitsFilt & baseSelect,:),2);

% calculate max in each timecourse of each cell, for conds with evoked activity
if sessionInfoAll.trialDuration == 18
    searchMax = [17:19]; % in data points
elseif sessionInfoAll.trialDuration == 6
    searchMax = [31:33]; %[31:33]
elseif sessionInfoAll.trialDuration == 9
    searchMax = [46:48]; %[31:33]
end

maxTracesBaseSubtr = nan(2*totalConds-2, totalUnits);
maxIndTracesBaseSubtr = nan(2*totalConds-2, totalUnits);
smoothMaxTracesBaseSubtr = nan(2*totalConds-2, totalUnits);

for cond = 1: 2*totalConds-2
    for unit = find(iUnitsFilt)% & baseSelect)
        [maxTracesBaseSubtr(cond, unit), maxIndTracesBaseSubtr(cond, unit)] = max(tracesBaseSubtr(cond, unit, searchMax));
        maxIndTracesBaseSubtr(cond, unit) = maxIndTracesBaseSubtr(cond, unit) + searchMax(1)-1;
%         smoothMaxTracesBaseSubtr(cond, unit) = mean(tracesBaseSubtr(cond, unit, maxIndTracesBaseSubtr(1, unit))); % just max, 1st condition
         smoothMaxTracesBaseSubtr(cond, unit) = mean(tracesBaseSubtr(cond, unit, searchMax),3); % mean across interval

    end
end

normTracesBaseSubtr = nan(2*totalConds-2, totalUnits, totalDatapoints); % normalized traces to 100 % max in the same group
normTracesBaseSubtr100 = nan(2*totalConds-2, totalUnits, totalDatapoints); % normalized traces to 100 % max in the control group (V)

condNorms = [repmat([1,2], 1, totalConds/2), repmat([totalConds+1,totalConds+2], 1, totalConds/2-1)];
for cond = 1:2*totalConds-2
    condNorm = condNorms(cond);
    for unit = find(iUnitsFilt & baseSelect)       
        % normalize by the non-photostim condition - needs checking for V-S
        % and Vph - Sph
        normTracesBaseSubtr(cond, unit, :) = smooth(tracesBaseSubtr(cond, unit, :)/smoothMaxTracesBaseSubtr(condNorm, unit),smooth_param, smooth_method);
        % normalize by the 100% non-photostim condition
        normTracesBaseSubtr100(cond, unit, :) = smooth(tracesBaseSubtr(cond, unit, :)/smoothMaxTracesBaseSubtr(1, unit),smooth_param, smooth_method);
    end
end

% Calculate mean of smoothed trace frequency TCs
meanNormTracesBaseSubtr = squeeze(nanmean(normTracesBaseSubtr,2));
meanNormTracesBaseSubtr100 = squeeze(nanmean(normTracesBaseSubtr100,2));

%%%%%%% this passage needs further consideration %%%%%%%%
% adjust by a certain factor in order to have a peak at 1 and not the avg of several data points
% comment out if needed

normTracesBaseSubtrAdj = nan(2*totalConds-2, totalUnits, totalDatapoints); % normalized traces to 100 % max in the same group
for cond = 1:2*totalConds-2
    condNorm = condNorms(cond);
    for unit = find(iUnitsFilt & baseSelect)  
        normTracesBaseSubtrAdj(cond, unit, :) =  normTracesBaseSubtr(cond, unit, :) / max(meanNormTracesBaseSubtr(condNorm,searchMax));
    end
end
normTracesBaseSubtr100Adj =  normTracesBaseSubtr100 / max(meanNormTracesBaseSubtr100(1,searchMax));

% Recalculate the means
meanNormTracesBaseSubtrAdj = squeeze(nanmean(normTracesBaseSubtrAdj,2));
meanNormTracesBaseSubtr100Adj = squeeze(nanmean(normTracesBaseSubtr100Adj,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Calculate STEM of frequency TCs over cells
STEMnormTracesBaseSubtr100 = nan(2*totalConds-2, totalDatapoints);
STEMnormTracesBaseSubtr = nan(2*totalConds-2, totalDatapoints);
STEMnormTracesBaseSubtr100Adj = nan(2*totalConds-2, totalDatapoints);
STEMnormTracesBaseSubtrAdj = nan(2*totalConds-2, totalDatapoints);
for cond = 1 : 2*totalConds-2
    for datapoint = 1:totalDatapoints
        STEMnormTracesBaseSubtr100(cond, datapoint) = nanstd(normTracesBaseSubtr100(cond, :, datapoint))/sqrt(sum(~isnan(normTracesBaseSubtr100(cond, :, datapoint))));
        STEMnormTracesBaseSubtr(cond, datapoint) = nanstd(normTracesBaseSubtr(cond, :, datapoint))/sqrt(sum(~isnan(normTracesBaseSubtr(cond, :, datapoint))));
        STEMnormTracesBaseSubtr100Adj(cond, datapoint) = nanstd(normTracesBaseSubtr100Adj(cond, :, datapoint))/sqrt(sum(~isnan(normTracesBaseSubtr100Adj(cond, :, datapoint))));
        STEMnormTracesBaseSubtrAdj(cond, datapoint) = nanstd(normTracesBaseSubtrAdj(cond, :, datapoint))/sqrt(sum(~isnan(normTracesBaseSubtrAdj(cond, :, datapoint))));
    end 
end


%% Analysis for Fig 25b - reproduction of fig 5bi from eLife 2020 (average amplitude of normalized and baseline subtr traces)
% analysis for Fig 26c - reproduction of fig 8di(1) from eLife 2020 (average amplitude of normalized and baseline subtr traces)
% analysis for Fig 26d - reproduction of fig 8di(2) from eLife 2020 (average amplitude of normalized and baseline subtr traces)

if sessionInfoAll.trialDuration == 18
    amplInt = [17:19]; % in data points [17 18] % as long as these are the same with searchMax, the amplitude in the conditions for normalization will be 1
elseif sessionInfoAll.trialDuration == 6
    amplInt = [31:33];% [31 32]
elseif sessionInfoAll.trialDuration == 9
    amplInt = [46:48];% [46 48]
end

allStimAmplNormTracesBaseSubtr = nan(2*totalConds-2, totalUnits, totalStim);
allStimAmplNormTracesBaseSubtr100 = nan(2*totalConds-2, totalUnits, totalStim);

for cond = 1:2*totalConds-2
    for unit = find(iUnitsFilt & baseSelect)  
        for stim = 1:totalStim 
            allStimAmplNormTracesBaseSubtr(cond, unit, stim) = nanmean(normTracesBaseSubtr(cond, unit, (stim-1)*(3/bin)+amplInt),3);
            allStimAmplNormTracesBaseSubtr100(cond, unit, stim) = nanmean(normTracesBaseSubtr100(cond, unit, (stim-1)*(3/bin)+amplInt),3);
        end
    end
end

% Calculate mean and STEM of amplitudes
meanAllStimAmplNormTracesBaseSubtr= squeeze(nanmean(allStimAmplNormTracesBaseSubtr,2));
meanAllStimAmplNormTracesBaseSubtr100= squeeze(nanmean(allStimAmplNormTracesBaseSubtr100,2));

STEMallStimAmplNormTracesBaseSubtr = nan(2*totalConds-2, totalStim);
STEMallStimAmplNormTracesBaseSubtr100 = nan(2*totalConds-2, totalStim);

for cond = 1:2*totalConds-2
    for stim = 1:totalStim
        STEMallStimAmplNormTracesBaseSubtr(cond, stim) = nanstd(allStimAmplNormTracesBaseSubtr(cond,:, stim))/sqrt(sum(~isnan(allStimAmplNormTracesBaseSubtr(cond,:, stim))));  
        STEMallStimAmplNormTracesBaseSubtr100(cond, stim) = nanstd(allStimAmplNormTracesBaseSubtr100(cond,:, stim))/sqrt(sum(~isnan(allStimAmplNormTracesBaseSubtr100(cond,:, stim))));  

    end
end

for cond = (1:2:totalConds)
    for stim = 1:totalStim
        [hAllStimAmplNormTracesBaseSubtr((cond+1)/2, stim), pAllStimAmplNormTracesBaseSubtr((cond+1)/2, stim)] =ttest(allStimAmplNormTracesBaseSubtr(cond,:, stim),allStimAmplNormTracesBaseSubtr(cond+1,:, stim)); % opt vs vis
        [pAllStimAmplNormTracesBaseSubtrW((cond+1)/2, stim), hAllStimAmplNormTracesBaseSubtrW((cond+1)/2, stim)] =signrank(allStimAmplNormTracesBaseSubtr(cond,:, stim),allStimAmplNormTracesBaseSubtr(cond+1,:, stim)); %  opt vs vis
 
        [hAllStimAmplNormTracesBaseSubtr100((cond+1)/2, stim), pAllStimAmplNormTracesBaseSubtr100((cond+1)/2, stim)] =ttest(allStimAmplNormTracesBaseSubtr100(cond,:, stim),allStimAmplNormTracesBaseSubtr100(cond+1,:, stim)); % opt vs vis
        [pAllStimAmplNormTracesBaseSubtr100W((cond+1)/2, stim), hAllStimAmplNormTracesBaseSubtr100W((cond+1)/2, stim)] =signrank(allStimAmplNormTracesBaseSubtr100(cond,:, stim),allStimAmplNormTracesBaseSubtr100(cond+1,:, stim)); %  opt vs vis
    end   
end

for cond = (totalConds+1:2:2*totalConds-2)
    for stim = 1:totalStim
        [hAllStimAmplNormTracesBaseSubtr((cond+1)/2, stim), pAllStimAmplNormTracesBaseSubtr((cond+1)/2, stim)] =ttest(allStimAmplNormTracesBaseSubtr(cond- totalConds,:, stim),allStimAmplNormTracesBaseSubtr(cond+1,:, stim)); % V vs Vph- Sph
        [pAllStimAmplNormTracesBaseSubtrW((cond+1)/2, stim), hAllStimAmplNormTracesBaseSubtrW((cond+1)/2, stim)] =signrank(allStimAmplNormTracesBaseSubtr(cond-totalConds,:, stim),allStimAmplNormTracesBaseSubtr(cond+1,:, stim)); % V vs Vph- Sph
       
        [hAllStimAmplNormTracesBaseSubtr100((cond+1)/2, stim), pAllStimAmplNormTracesBaseSubtr100((cond+1)/2, stim)] =ttest(allStimAmplNormTracesBaseSubtr100(cond- totalConds,:, stim),allStimAmplNormTracesBaseSubtr100(cond+1,:, stim)); % V vs Vph- Sph
        [pAllStimAmplNormTracesBaseSubtr100W((cond+1)/2, stim), hAllStimAmplNormTracesBaseSubtr100W((cond+1)/2, stim)] =signrank(allStimAmplNormTracesBaseSubtr100(cond-totalConds,:, stim),allStimAmplNormTracesBaseSubtr100(cond+1,:, stim)); % V vs Vph- Sph

    end   
end


%% Analysis for Fig 25c - reproduction of fig 5bii from eLife 2020 ( average baseline of normalized and baseline subtr traces)

baseStim = clusterTimeSeriesAll.baseTime; % [12 27 42 57 72 87] or [6, 12, 26];
baseDuration = 1/bin-1; % additional data points for baseline quantification (1 sec)
       
allStimBaseNormTracesBaseSubtr100 = nan(2*totalConds-2, totalUnits, numel(baseStim));
for cond = 1:2*totalConds-2
    for unit = find(iUnitsFilt & baseSelect)  
        for stim = 1:numel(baseStim)
            allStimBaseNormTracesBaseSubtr100(cond, unit, stim) = nanmean(normTracesBaseSubtr100(cond, unit, baseStim(stim):baseStim(stim)+baseDuration),3);
        end
    end
end

% Calculate mean and STEM of baselines
meanAllStimBaseNormTracesBaseSubtr100= squeeze(nanmean(allStimBaseNormTracesBaseSubtr100,2));

STEMallStimBaseNormTracesBaseSubtr100 = nan(2*totalConds-2, totalStim);

for cond = 1:2*totalConds-2
    for stim = 1:totalStim
        STEMallStimBaseNormTracesBaseSubtr100(cond, stim) = nanstd(allStimBaseNormTracesBaseSubtr100(cond,:, stim))/sqrt(sum(~isnan(allStimBaseNormTracesBaseSubtr100(cond,:, stim))));  
    end
end

for cond = (1:2:2*totalConds-2)
    for stim = 1:totalStim
        [hAllStimBaseNormTracesBaseSubtr100((cond+1)/2, stim), pAllStimBaseNormTracesBaseSubtr100((cond+1)/2, stim)] =ttest(allStimBaseNormTracesBaseSubtr100(1,:, stim),allStimBaseNormTracesBaseSubtr100(cond+1,:, stim)); % opt vs vis 100%
        [pAllStimBaseNormTracesBaseSubtr100W((cond+1)/2, stim), hAllStimBaseNormTracesBaseSubtr100W((cond+1)/2, stim)] =signrank(allStimBaseNormTracesBaseSubtr100(1,:, stim),allStimBaseNormTracesBaseSubtr100(cond+1,:, stim)); %  opt vs vis 100%
    end   
end


%% Anaylsis for Fig. 25d - reproduction of fig 5biii from eLife 2020 (average magnitude of normalized and baseline subtr traces)
% Analysis for Fig. 26e (1x) : reproduction of fig 8bi from eLife 2020 (average magnitude of normalized and baseline subtr traces)


if totalStim == 6
    allStimMagnNormTracesBaseSubtr100 = allStimAmplNormTracesBaseSubtr100 - allStimBaseNormTracesBaseSubtr100;% 2*totalConds-2, totalUnits, numel(baseStim)
elseif totalStim == 1 % to be modified
    allStimMagnNormTracesBaseSubtr100 = allStimAmplNormTracesBaseSubtr100 - allStimBaseNormTracesBaseSubtr100(:,:,3);% 2*totalConds-2, totalUnits, numel(baseStim)
end
    
% Calculate mean and STEM of baselines
meanAllStimMagnNormTracesBaseSubtr100= squeeze(nanmean(allStimMagnNormTracesBaseSubtr100,2));

STEMallStimMagnNormTracesBaseSubtr100 = nan(2*totalConds-2, totalStim);

for cond = 1:2*totalConds-2
    for stim = 1:totalStim
        STEMallStimMagnNormTracesBaseSubtr100(cond, stim) = nanstd(allStimMagnNormTracesBaseSubtr100(cond,:, stim))/sqrt(sum(~isnan(allStimMagnNormTracesBaseSubtr100(cond,:, stim))));
    end
end

for cond = (1:2:totalConds)
    for stim = 1:totalStim
        [hAllStimMagnNormTracesBaseSubtr100((cond+1)/2, stim), pAllStimMagnNormTracesBaseSubtr100((cond+1)/2, stim)] =ttest(allStimMagnNormTracesBaseSubtr100(cond,:, stim),allStimMagnNormTracesBaseSubtr100(cond+1,:, stim)); % opt vs vis 100%
        [pAllStimMagnNormTracesBaseSubtr100W((cond+1)/2, stim), hAllStimMagnNormTracesBaseSubtr100W((cond+1)/2, stim)] =signrank(allStimMagnNormTracesBaseSubtr100(cond,:, stim),allStimMagnNormTracesBaseSubtr100(cond+1,:, stim)); %  opt vs vis 100%
    end 
    
    % uncomment to run permutation correction for multiple comparisons
%     notNaN = ~isnan(mean(allStimMagnNormTracesBaseSubtr100(cond,:, :),3));
%     allStimMagnNormTracesBaseSubtr100Diff((cond+1)/2,:,:) = allStimMagnNormTracesBaseSubtr100(cond,:, :)-allStimMagnNormTracesBaseSubtr100(cond+1,:,:);  
%     [pvalAllStimMagnNormTracesBaseSubtr100DiffMC((cond+1)/2,:), t_origAllStimMagnNormTracesBaseSubtr100DiffMC((cond+1)/2,:), crit_tAllStimMagnNormTracesBaseSubtr100DiffMC((cond+1)/2,:),...
%         est_alphaAllStimMagnNormTracesBaseSubtr100DiffMC((cond+1)/2,:), seed_stateAllStimMagnNormTracesBaseSubtr100DiffMC(:,(cond+1)/2)]=mult_comp_perm_t1(squeeze(allStimMagnNormTracesBaseSubtr100Diff((cond+1)/2,notNaN,:)),50000);
end
for cond = (totalConds+1:2:2*totalConds-2)
    for stim = 1:totalStim
        [hAllStimMagnNormTracesBaseSubtr100((cond+1)/2, stim), pAllStimMagnNormTracesBaseSubtr100((cond+1)/2, stim)] =ttest(allStimMagnNormTracesBaseSubtr100(cond- totalConds,:, stim),allStimMagnNormTracesBaseSubtr100(cond+1,:, stim)); % V vs Vph- Sph
        [pAllStimMagnNormTracesBaseSubtr100W((cond+1)/2, stim), hAllStimMagnNormTracesBaseSubtr100W((cond+1)/2, stim)] =signrank(allStimMagnNormTracesBaseSubtr100(cond-totalConds,:, stim),allStimMagnNormTracesBaseSubtr100(cond+1,:, stim)); % V vs Vph- Sph
    end
end
 
%% Analysis for figure 28 - linear regression like figure 16f-h, but for single units

% maxNoTrials = 25;
% longBase = 1;
% disp('longBase = 1, overwritten for fig 28')
% if longBase
%     if isequal(baseStim, [12 27 42 57 72 87]) %
%         baseStim = [12 27 42 57 72 87] -7;
%         baseDuration = 3/bin-1; % additional data points for baseline quantification (3 sec)
%     elseif isequal(baseStim, [6, 12, 26])
%         baseStim = [1, 12, 21];% modify baseStim to allow longer baseline quantification time
%         baseDuration = 2/bin-1; % additional data points for baseline quantification (2 sec)
%     elseif isequal(baseStim, [6, 12, 41])
%         baseStim = [1, 12, 36];% modify baseStim to allow longer baseline quantification time
%         baseDuration = 2/bin-1; % additional data points for baseline quantification (2 sec)
%     end
% end
% 
% allStimBaseByTrial = nan(totalConds, totalUnits, maxNoTrials, numel(baseStim));
% for cond = 1:totalConds
%     for unit = find(iUnitsFilt)
%         for trial = 1:maxNoTrials
%             for stim = 1:numel(baseStim)
%                 allStimBaseByTrial(cond, unit, trial, stim) = nanmean(clusterTimeSeriesAll.traceByTrial(cond, unit, trial, baseStim(stim):baseStim(stim)+baseDuration),4);
%             end
%         end
%         
%     end
% end
% 
% allStimAmplByTrial = nan(totalConds, totalUnits, maxNoTrials, totalStim);
% for cond = 1:totalConds
%     for unit = find(iUnitsFilt)
%         for trial = 1:maxNoTrials
%             for stim = 1:totalStim 
%                 allStimAmplByTrial(cond, unit, trial, stim) = nanmean(clusterTimeSeriesAll.traceByTrial(cond, unit, trial, (stim-1)*(3/bin)+amplInt(1):(stim-1)*(3/bin)+amplInt(end)+2),4);
%             end
%         end
%     end
% end
% 
% longBase = 0;    
% baseDuration = 1/bin-1;

%% Analysis for fig. 29a -  average normalized baseline to same stim in the control condition

allStimBaseNormToStim = nan(totalConds, totalUnits, numel(baseStim));

for cond = 1:2:totalConds
    for unit = find(baseSelect)
        for stim = 1:numel(baseStim)  
            if allStimBase(cond, unit, stim) ~= 0
                allStimBaseNormToStim(cond, unit, stim) = allStimBase(cond, unit, stim)/ allStimBase(cond, unit, stim); 
                allStimBaseNormToStim(cond+1, unit, stim) = allStimBase(cond+1, unit, stim)/ allStimBase(cond, unit, stim);
            else
                allStimBaseNormToStim(cond:cond+1, unit, stim) = NaN;
            end
        end    
    end
end   

meanAllStimBaseNormToStim = squeeze(nanmean(allStimBaseNormToStim,2));
STEMallStimBaseNormToStim = nan(totalConds, numel(baseStim));

for cond = 1:totalConds
    for stim = 1:numel(baseStim)
        STEMallStimBaseNormToStim(cond,stim) = nanstd(allStimBaseNormToStim(cond,:,stim))/sqrt(sum(~isnan(allStimBaseNormToStim(cond,:,stim))));
    end
end

for cond = 1:2:totalConds
    for stim = 1:numel(baseStim)
        [hAllStimBaseNormToStim((cond+1)/2,stim), pAllStimBaseNormToStim((cond+1)/2,stim)] = ttest(squeeze(allStimBaseNormToStim(cond,:,stim)),squeeze(allStimBaseNormToStim(cond+1,:,stim))); 
        [pAllStimBaseNormToStimW((cond+1)/2,stim), hAllStimBaseNormToStimW((cond+1)/2,stim)] = signrank(squeeze(allStimBaseNormToStim(cond,:,stim)),squeeze(allStimBaseNormToStim(cond+1,:,stim))); 
    end    
end

%% Analysis for fig. 29b - average normalized magnitude to same stim in the control condition

allStimMagnNormToStim = nan(totalConds, totalUnits, totalStim);

for cond = 1:2:totalConds
    for unit = find(baseSelect)
        for stim = 1:totalStim
            if allStimMagn(cond, unit, stim) ~= 0
                allStimMagnNormToStim(cond, unit, stim) = allStimMagn(cond, unit, stim)/ allStimMagn(cond, unit, stim);
                allStimMagnNormToStim(cond+1, unit, stim) = allStimMagn(cond+1, unit, stim)/ allStimMagn(cond, unit, stim);
            else
                allStimMagnNormToStim(cond:cond+1, unit, stim) = NaN;
            end
        end
    end
end 

meanAllStimMagnNormToStim = squeeze(nanmean(allStimMagnNormToStim,2));
STEMallStimMagnNormToStim = nan(totalConds, totalStim);

for cond = 1:totalConds
    for stim = 1:totalStim
        STEMallStimMagnNormToStim(cond,stim) = nanstd(allStimMagnNormToStim(cond,:,stim))/sqrt(sum(~isnan(allStimMagnNormToStim(cond,:,stim))));
    end
end

for cond = 1:2:totalConds
    for stim = 1:totalStim
        [hAllStimMagnNormToStim((cond+1)/2,stim), pAllStimMagnNormToStim((cond+1)/2,stim)] = ttest(squeeze(allStimMagnNormToStim(cond,:,stim)),squeeze(allStimMagnNormToStim(cond+1,:,stim))); 
        [pAllStimMagnNormToStimW((cond+1)/2,stim), hAllStimMagnNormToStimW((cond+1)/2,stim)] = signrank(squeeze(allStimMagnNormToStim(cond,:,stim)),squeeze(allStimMagnNormToStim(cond+1,:,stim))); 
    end    
end

%% Analysis for fig. 29c - effect on baseline (difference between the stimulated and control condition), or normalized to the control condition
% same p values as in fig 29a,as the only difference is the extra normalization

allStimBaseSubtr = nan(totalConds, totalUnits, numel(baseStim));
allStimBaseSubtrNorm = nan(totalConds, totalUnits, numel(baseStim));

for cond = 1:2:totalConds
    for unit = find(baseSelect)
        for stim = 1:numel(baseStim)  
            allStimBaseSubtr(cond, unit, stim) = allStimBase(cond, unit, stim)- allStimBase(cond, unit, stim); 
            allStimBaseSubtr(cond+1, unit, stim) = allStimBase(cond+1, unit, stim)- allStimBase(cond, unit, stim); 
            if allStimBase(cond, unit, stim) ~= 0
                allStimBaseSubtrNorm(cond, unit, stim) = (allStimBase(cond, unit, stim)-allStimBase(cond, unit, stim))/ allStimBase(cond, unit, stim);
                allStimBaseSubtrNorm(cond+1, unit, stim) = (allStimBase(cond+1, unit, stim)-allStimBase(cond, unit, stim))/ allStimBase(cond, unit, stim);
            else
                allStimBaseSubtrNorm(cond:cond+1, unit, stim) = NaN;
            end
        end    
    end
end   

meanAllStimBaseSubtr = squeeze(nanmean(allStimBaseSubtr,2));
meanAllStimBaseSubtrNorm = squeeze(nanmean(allStimBaseSubtrNorm,2));
STEMallStimBaseSubtr = nan(totalConds, numel(baseStim));
STEMallStimBaseSubtrNorm = nan(totalConds, numel(baseStim));

for cond = 1:totalConds
    for stim = 1:numel(baseStim)
        STEMallStimBaseSubtr(cond,stim) = nanstd(allStimBaseSubtr(cond,:,stim))/sqrt(sum(~isnan(allStimBaseSubtr(cond,:,stim))));
        STEMallStimBaseSubtrNorm(cond,stim) = nanstd(allStimBaseSubtrNorm(cond,:,stim))/sqrt(sum(~isnan(allStimBaseSubtrNorm(cond,:,stim))));    
    end
end

for cond = 1:2:totalConds
    for stim = 1:numel(baseStim)
        [hAllStimBaseSubtr((cond+1)/2,stim), pAllStimBaseSubtr((cond+1)/2,stim)] = ttest(squeeze(allStimBaseSubtr(cond,:,stim)),squeeze(allStimBaseSubtr(cond+1,:,stim))); 
        [pAllStimBaseSubtrW((cond+1)/2,stim), hAllStimBaseSubtrW((cond+1)/2,stim)] = signrank(squeeze(allStimBaseSubtr(cond,:,stim)), squeeze(allStimBaseSubtr(cond+1,:,stim))); 
        [hAllStimBaseSubtrNorm((cond+1)/2,stim), pAllStimBaseSubtrNorm((cond+1)/2,stim)] = ttest(squeeze(allStimBaseSubtrNorm(cond,:,stim)),squeeze(allStimBaseSubtrNorm(cond+1,:,stim))); 
        [pAllStimBaseSubtrNormW((cond+1)/2,stim), hAllStimBaseSubtrNormW((cond+1)/2,stim)] = signrank(squeeze(allStimBaseSubtrNorm(cond,:,stim)), squeeze(allStimBaseSubtrNorm(cond+1,:,stim))); 
    end    
end

%% Fig 30a -  baseline of the trace that represents the difference of the normalized traces

allStimBaseNormTraceFreqAllAdjSubtr = nan(totalConds/2, totalUnits, numel(baseStim));

baseDuration = 1/bin-1; % additional data points for baseline quantification (1 sec) 

for cond = 1:2:totalConds
    for unit = find(baseSelect)
        for stim = 1:numel(baseStim)
            allStimBaseNormTraceFreqAllAdjSubtr((cond+1)/2, unit, stim) = nanmean(normTraceFreqAllAdjSubtr((cond+1)/2, unit,baseStim(stim):baseStim(stim)+baseDuration),3);
        end
    end
end

meanAllStimBaseNormTraceFreqAllAdjSubtr = squeeze(nanmean(allStimBaseNormTraceFreqAllAdjSubtr,2));
STEMallStimBaseNormTraceFreqAllAdjSubtr = nan(totalConds/2, numel(baseStim));


for cond = 1:totalConds/2
    for stim = 1:numel(baseStim)
        STEMallStimBaseNormTraceFreqAllAdjSubtr(cond,stim) = nanstd(allStimBaseNormTraceFreqAllAdjSubtr(cond,:,stim))/sqrt(sum(~isnan(allStimBaseNormTraceFreqAllAdjSubtr(cond,:,stim))));
    end
end

for cond = 1:totalConds/2
    for stim = 1:numel(baseStim)
        [hAllStimBaseNormTraceFreqAllAdjSubtr(cond,stim), pAllStimBaseNormTraceFreqAllAdjSubtr(cond,stim)] = ttest(squeeze(allStimBaseNormTraceFreqAllAdjSubtr(cond,:,stim))); 
        [pAllStimBaseNormTraceFreqAllAdjSubtrW(cond,stim), hAllStimBaseNormTraceFreqAllAdjSubtrW(cond,stim)] = signrank(squeeze(allStimBaseNormTraceFreqAllAdjSubtr(cond,:,stim))); 
    end    
end

%% Fig. 30b -  magnitude of the trace that represents the difference of the normalized traces

allStimAmplNormTraceFreqAllAdjSubtr = nan(totalConds/2, totalUnits, totalStim);
% allStimMagnNormTraceFreqAllAdjSubtr = nan(totalConds/2, totalUnits, totalStim);
% calculare max in each timecourse of each cell, for conds with evoked activity
if sessionInfoAll.trialDuration == 18
    amplInt = [18:18]; % in data points
elseif sessionInfoAll.trialDuration == 6
    amplInt = [31:33];
elseif sessionInfoAll.trialDuration == 9
    amplInt = [46:48];
end

for cond = 1:2:totalConds
    for unit = find(baseSelect)
        for stim = 1:totalStim
            allStimAmplNormTraceFreqAllAdjSubtr((cond+1)/2, unit, stim) = nanmean(normTraceFreqAllAdjSubtr((cond+1)/2, unit, (stim-1)*(3/bin)+amplInt),3);            
        end
    end
end

allStimMagnNormTraceFreqAllAdjSubtr = allStimAmplNormTraceFreqAllAdjSubtr-allStimBaseNormTraceFreqAllAdjSubtr;
meanAllStimMagnNormTraceFreqAllAdjSubtr = squeeze(nanmean(allStimMagnNormTraceFreqAllAdjSubtr,2));

STEMallStimMagnNormTraceFreqAllAdjSubtr = nan(totalConds/2, totalStim);

for cond = 1:totalConds/2
    for stim = 1:totalStim
        STEMallStimMagnNormTraceFreqAllAdjSubtr(cond,stim) = nanstd(allStimMagnNormTraceFreqAllAdjSubtr(cond,:,stim))/sqrt(sum(~isnan(allStimMagnNormTraceFreqAllAdjSubtr(cond,:,stim))));
    end
end

for cond = 1:totalConds/2
    for stim = 1:totalStim
        [hAllStimMagnNormTraceFreqAllAdjSubtr(cond,stim), pAllStimMagnNormTraceFreqAllAdjSubtr(cond,stim)] = ttest(squeeze(allStimMagnNormTraceFreqAllAdjSubtr(cond,:,stim))); 
        [pAllStimMagnNormTraceFreqAllAdjSubtrW(cond,stim), hAllStimMagnNormTraceFreqAllAdjSubtrW(cond,stim)] = signrank(squeeze(allStimMagnNormTraceFreqAllAdjSubtr(cond,:,stim))); 
    end    
end

%% Fig. 30bx -  compare difference of magnitude in the non-adj norm traces to 0 (magn of 1st stim = 1 and not peak =1)

% calculate the difference in magnitudes in Vph vs V and Sph vs S 
normTraceFreqAllAdjSubtr = nan(totalConds/2, totalUnits, totalDatapoints);
for cond =1:2:totalConds
    allStimMagnNormTracesBaseSubtr100Subtr((cond+1)/2,:,:) = squeeze(allStimMagnNormTracesBaseSubtr100(cond+1, :, :) - allStimMagnNormTracesBaseSubtr100(cond, :, :)); 
end
meanAllStimMagnNormTracesBaseSubtr100Subtr = squeeze(nanmean(allStimMagnNormTracesBaseSubtr100Subtr,2));

STEMallStimMagnNormTracesBaseSubtr100Subtr = nan(totalConds/2, totalStim);

for cond = 1:totalConds/2
    for stim = 1:totalStim
        STEMallStimMagnNormTracesBaseSubtr100Subtr(cond,stim) = nanstd(allStimMagnNormTracesBaseSubtr100Subtr(cond,:,stim))/sqrt(sum(~isnan(allStimMagnNormTracesBaseSubtr100Subtr(cond,:,stim))));
    end
end

for cond = 1:totalConds/2
    for stim = 1:totalStim
        [hAllStimMagnNormTracesBaseSubtr100Subtr(cond,stim), pAllStimMagnNormTracesBaseSubtr100Subtr(cond,stim)] = ttest(squeeze(allStimMagnNormTracesBaseSubtr100Subtr(cond,:,stim))); 
        [pAllStimMagnNormTracesBaseSubtr100SubtrW(cond,stim), hAllStimMagnNormTracesBaseSubtr100SubtrW(cond,stim)] = signrank(squeeze(allStimMagnNormTracesBaseSubtr100Subtr(cond,:,stim))); 
    end    
end

% calculate average magnitude difference over stims 2-4: 

stim24MagnNormTracesBaseSubtr100Subtr = mean(allStimMagnNormTracesBaseSubtr100Subtr(:,:,2:4),3);
meanStim24MagnNormTracesBaseSubtr100Subtr = nanmean(stim24MagnNormTracesBaseSubtr100Subtr,2);

STEMstim24MagnNormTracesBaseSubtr100Subtr = nan(totalConds/2);

for cond = 1:totalConds/2  
    STEMstim24MagnNormTracesBaseSubtr100Subtr(cond) = nanstd(stim24MagnNormTracesBaseSubtr100Subtr(cond,:))/sqrt(sum(~isnan(stim24MagnNormTracesBaseSubtr100Subtr(cond,:))));   
end

for cond = 1:totalConds/2    
    [hStim24MagnNormTracesBaseSubtr100Subtr(cond), pStim24MagnNormTracesBaseSubtr100Subtr(cond)] = ttest(squeeze(stim24MagnNormTracesBaseSubtr100Subtr(cond,:)));
    [pStim24MagnNormTracesBaseSubtr100SubtrW(cond), hStim24MagnNormTracesBaseSubtr100SubtrW(cond)] = signrank(squeeze(stim24MagnNormTracesBaseSubtr100Subtr(cond,:)));   
end

%% ttest on magnitude effect (compares to 0) is like paired t-test for comparing baseline effect and amplitude effect
% 
% for cond = 1:totalConds/2
%     for stim = 1:totalStim
%         [hxx(cond,stim), pxx(cond,stim)] = ttest(squeeze(allStimBaseNormTraceFreqAllAdjSubtr(cond,:,stim)),squeeze(allStimAmplNormTraceFreqAllAdjSubtr(cond,:,stim))); 
%     end    
% end
%% generate graphs above with colors specific for the respective mouse-cell combination
% can be applied to graphs 29 and 30
cCreCellTypeAll = [213 94 0; 153,199,225; 239,191,170; 0,114,178]/255;

if sum(classUnitsAll(iUnitsFilt) == 1) && strcmp(expSetFilt(1).animalStrain, 'NexCre')
    cCreCellType = [0 176 80]/255;% NexCre exc
    cCreCellType = [213 94 0]/255; % new
elseif sum(classUnitsAll(iUnitsFilt) == 2) && strcmp(expSetFilt(1).animalStrain, 'NexCre')
    cCreCellType = [230 153 153]/255;% NexCre inh
    cCreCellType = [153,199,225]/255; % new
elseif sum(classUnitsAll(iUnitsFilt) == 1) && strcmp(expSetFilt(1).animalStrain, 'PvCre') && strcmp(expSetFilt(1).animalVirus, 'AAV9-flx-mOp2A+AAV9-CaMKII-mOp2A')
    cCreCellType = [0 176 80]/255;% exc
    cCreCellType = [213 94 0]/255; % new
elseif sum(classUnitsAll(iUnitsFilt) == 2) && strcmp(expSetFilt(1).animalStrain, 'PvCre') && strcmp(expSetFilt(1).animalVirus, 'AAV9-flx-mOp2A+AAV9-CaMKII-mOp2A')
    cCreCellType = [192 0 0]/255;% inh
    cCreCellType = [0,114,178]/255; % new
elseif sum(classUnitsAll(iUnitsFilt) == 1) && strcmp(expSetFilt(1).animalStrain, 'PvCre')
    cCreCellType = [153 224 185]/255;% PvCre exc
    cCreCellType = [239,191,170]/255; % new
elseif sum(classUnitsAll(iUnitsFilt) == 2) && strcmp(expSetFilt(1).animalStrain, 'PvCre')
    cCreCellType = [192 0 0]/255;% PvCre inh
    cCreCellType = [0,114,178]/255; % new
end

%% Fig. 30c -  magnitude of the trace that represents the difference of the normalized traces
% check if the one sample t-test on magnitude in subtracted traces (fig 30b) returns
% the same p values as the 2-sample ttest on magnitude in the
% non-subtracted traces ---> it is the same thing
% no figure with this name, just compares p values

allStimBaseNormTraceFreqAllAdj=nan(totalConds, totalUnits, totalStim);
baseDuration = 1/bin-1; % additional data points for baseline quantification (1 sec)

allStimAmplNormTraceFreqAllAdj = nan(totalConds, totalUnits, totalStim);
% calculare max in each timecourse of each cell, for conds with evoked activity
if sessionInfoAll.trialDuration == 18
    amplInt = [18:18]; % in data points
elseif sessionInfoAll.trialDuration == 6
    amplInt = [31:33];
elseif sessionInfoAll.trialDuration == 9
    amplInt = [46:48];
end

for cond = 1:totalConds
    for unit = find(baseSelect)
        for stim = 1:numel(baseStim)
            allStimBaseNormTraceFreqAllAdj(cond, unit, stim) = nanmean(normTraceFreqAllAdj(cond, unit,baseStim(stim):baseStim(stim)+baseDuration),3);
        end
        for stim = 1:totalStim
            allStimAmplNormTraceFreqAllAdj(cond, unit, stim) = nanmean(normTraceFreqAllAdj(cond, unit, (stim-1)*(3/bin)+amplInt),3);
        end
        
    end
end

allStimMagnNormTraceFreqAllAdj = allStimAmplNormTraceFreqAllAdj-allStimBaseNormTraceFreqAllAdj;
meanAllStimMagnNormTraceFreqAllAdj = squeeze(nanmean(allStimMagnNormTraceFreqAllAdj,2));

STEMallStimMagnNormTraceFreqAllAdj = nan(totalConds, totalStim);

for cond = 1:totalConds
    for stim = 1:totalStim
        STEMallStimMagnNormTraceFreqAllAdj(cond,stim) = nanstd(allStimMagnNormTraceFreqAllAdj(cond,:,stim))/sqrt(sum(~isnan(allStimMagnNormTraceFreqAllAdj(cond,:,stim))));
    end
end

for cond = 1:2:totalConds
    for stim = 1:totalStim
        [hAllStimMagnNormTraceFreqAllAdj((cond+1)/2,stim), pAllStimMagnNormTraceFreqAllAdj((cond+1)/2,stim)] = ttest(squeeze(allStimMagnNormTraceFreqAllAdj(cond,:,stim)),squeeze(allStimMagnNormTraceFreqAllAdj(cond+1,:,stim))); 
        [pAllStimMagnNormTraceFreqAllAdjW((cond+1)/2,stim), hAllStimMagnNormTraceFreqAllAdjW((cond+1)/2,stim)] = signrank(squeeze(allStimMagnNormTraceFreqAllAdj(cond,:,stim)), squeeze(allStimMagnNormTraceFreqAllAdj(cond+1,:,stim))); 
    end    
end
        
%% Fig 30 d relative change in magnitude of the normalized traces - 
% magnitude normalized to each peak in the control condition

relChAllStimMagnNormTraceFreqAllAdj = nan(totalConds, totalUnits, totalStim);
for cond = 1:2:totalConds
    for unit = find(baseSelect)
        for stim = 1:totalStim
            if abs(allStimMagnNormTraceFreqAllAdj(1, unit, stim))>=0.001 %&& isfinite(allStimMagnNormTraceFreqAllAdj(1, unit, stim))
%                 relChAllStimMagnNormTraceFreqAllAdj(cond, unit, stim) = allStimMagnNormTraceFreqAllAdj(cond, unit, stim)-allStimMagnNormTraceFreqAllAdj(1, unit, stim);
                relChAllStimMagnNormTraceFreqAllAdj(cond, unit, stim) = allStimMagnNormTraceFreqAllAdj(cond, unit, stim)/allStimMagnNormTraceFreqAllAdj(cond, unit, stim)-1;
                relChAllStimMagnNormTraceFreqAllAdj(cond+1, unit, stim) = allStimMagnNormTraceFreqAllAdj(cond+1, unit, stim)/allStimMagnNormTraceFreqAllAdj(cond, unit, stim)-1;

            else
                relChAllStimMagnNormTraceFreqAllAdj(cond, unit, stim) = NaN;
            end
        end    
    end
end    

meanRelChAllStimMagnNormTraceFreqAllAdj = squeeze(nanmean(relChAllStimMagnNormTraceFreqAllAdj,2));

STEMrelChAllStimMagnNormTraceFreqAllAdj = nan(totalConds, totalStim);

for cond = 1:totalConds
    for stim = 1:totalStim
        STEMrelChAllStimMagnNormTraceFreqAllAdj(cond,stim) = nanstd(relChAllStimMagnNormTraceFreqAllAdj(cond,:,stim))/sqrt(sum(~isnan(relChAllStimMagnNormTraceFreqAllAdj(cond,:,stim))));
    end
end

for cond = 1:2:totalConds
    for stim = 1:totalStim
        [hRelChAllStimMagnNormTraceFreqAllAdj((cond+1)/2,stim), pRelChAllStimMagnNormTraceFreqAllAdj((cond+1)/2,stim)] = ttest(squeeze(relChAllStimMagnNormTraceFreqAllAdj(cond+1,:,stim))); 
        [pRelChAllStimMagnNormTraceFreqAllAdjW((cond+1)/2,stim), hRelChAllStimMagnNormTraceFreqAllAdjW((cond+1)/2,stim)] = signrank(squeeze(relChAllStimMagnNormTraceFreqAllAdj(cond+1,:,stim))); 
    end    
end       

%%

% comparison on baseline effects between Vph and Sph
% based on fig 25c

for cond = (1:2:totalConds-2)
    for stim = 1:totalStim
        [hAllStimBaseNormTracesBaseSubtr100PhComp((cond+1)/2, stim), pAllStimBaseNormTracesBaseSubtr100PhComp((cond+1)/2, stim)] =ttest(allStimBaseNormTracesBaseSubtr100(totalConds,:, stim),allStimBaseNormTracesBaseSubtr100(cond+1,:, stim)); % opt vs vis 100%
        [pAllStimBaseNormTracesBaseSubtr100PhCompW((cond+1)/2, stim), hAllStimBaseNormTracesBaseSubtr100PhCompW((cond+1)/2, stim)] =signrank(allStimBaseNormTracesBaseSubtr100(totalConds,:, stim),allStimBaseNormTracesBaseSubtr100(cond+1,:, stim)); %  opt vs vis 100%
    end   
end



%% Figure 31 a - similar to fig 2, but for selected OI
% reminder: there is no adjustment over the last 2 condition

% if longBase % OIposUnits and OInegUnits already calculated above
%     OIposUnits = iUnitsFilt & OIndexAllStimBase(totalConds/2,:, 4)>0; % run the next section before uncommenting this line
%     OInegUnits = iUnitsFilt & OIndexAllStimBase(totalConds/2,:, 4)<0; % run the next section before uncommenting this line
if longBase == 0
    path1 =pwd;
    filenameOIposnegUnits = fullfile(path1,'OIposnegUnits.mat');
    if exist(filenameOIposnegUnits,'file')
        load(filenameOIposnegUnits)
        disp('Loading OIposnegUnits.mat')
    else
        disp('The OIposnegUnits.mat does not exist')
    end    
end    
% these 2 lines can be commented out
% OIposUnits = OIposUnits & baseSelect;
% OInegUnits = OInegUnits & baseSelect;

normTraceFreqAllAdjOIpos = normTraceFreqAllAdj(:,OIposUnits,:); % copying to already contain the spont conds, which will not be adjusted
meanNormTraceFreqAllAdjOIpos = squeeze(nanmean(normTraceFreqAllAdjOIpos,2));

normTraceFreqAllAdjOIneg = normTraceFreqAllAdj(:,OInegUnits,:); % copying to already contain the spont conds, which will not be adjusted
meanNormTraceFreqAllAdjOIneg = squeeze(nanmean(normTraceFreqAllAdjOIneg,2));

% normalization to the same condition   
normTraceFreqAllSameOIpos = normTraceFreqAllsame(:,OIposUnitsSame,:); % copying to already contain the spont conds, which will not be adjusted
meanNormTraceFreqAllSameOIpos = squeeze(nanmean(normTraceFreqAllSameOIpos,2));

normTraceFreqAllSameOIneg = normTraceFreqAllsame(:,OInegUnitsSame,:); % copying to already contain the spont conds, which will not be adjusted
meanNormTraceFreqAllSameOIneg = squeeze(nanmean(normTraceFreqAllSameOIneg,2));
 
% Calculate STEM of TCs over cells
STEMnormTraceFreqAllAdjOIpos = nan(totalConds, totalDatapoints);
STEMnormTraceFreqAllAdjOIneg = nan(totalConds, totalDatapoints);
STEMnormTraceFreqAllSameOIpos = nan(totalConds, totalDatapoints);
STEMnormTraceFreqAllSameOIneg = nan(totalConds, totalDatapoints);
for cond = 1:totalConds
    for datapoint = 1:totalDatapoints
        STEMnormTraceFreqAllAdjOIpos(cond, datapoint) = nanstd(normTraceFreqAllAdjOIpos(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAllAdjOIpos(cond, :,datapoint))));
        STEMnormTraceFreqAllAdjOIneg(cond, datapoint) = nanstd(normTraceFreqAllAdjOIneg(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAllAdjOIneg(cond, :,datapoint))));
        STEMnormTraceFreqAllSameOIpos(cond, datapoint) = nanstd(normTraceFreqAllSameOIpos(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAllSameOIpos(cond, :,datapoint))));
        STEMnormTraceFreqAllSameOIneg(cond, datapoint) = nanstd(normTraceFreqAllSameOIneg(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAllSameOIneg(cond, :,datapoint))));
    end    
end

% if longBase 
%     path1 =pwd;
%     filenameOIposnegUnits = fullfile(path1,'OIposnegUnits.mat');
%     disp('Saving OIposneg.mat')
%     save('OIposnegUnits', 'OIposUnits', 'OInegUnits.mat')
% end

%% Figure 31 b - similar to fig4b, but for selected OI

normAllStimBaseOIpos = normAllStimBase(:,OIposUnits,:);
normAllStimBaseOIneg = normAllStimBase(:,OInegUnits,:);

meanNormAllStimBaseOIpos = squeeze(nanmean(normAllStimBaseOIpos,2));
meanNormAllStimBaseOIneg = squeeze(nanmean(normAllStimBaseOIneg,2));

STEMnormAllStimBaseOIpos = nan(totalConds, numel(baseStim));
STEMnormAllStimBaseOIneg = nan(totalConds, numel(baseStim));

for cond = 1:totalConds
    for stim = 1:numel(baseStim)
        STEMnormAllStimBaseOIpos(cond,stim) = nanstd(normAllStimBaseOIpos(cond,:,stim))/sqrt(sum(~isnan(normAllStimBaseOIpos(cond,:,stim))));
        STEMnormAllStimBaseOIneg(cond,stim) = nanstd(normAllStimBaseOIneg(cond,:,stim))/sqrt(sum(~isnan(normAllStimBaseOIneg(cond,:,stim))));
    end
end

for cond = 1:2:totalConds
    for stim = 1:numel(baseStim)
        [hNormAllStimBaseOIpos((cond+1)/2,stim,1), pNormAllStimBaseOIpos((cond+1)/2,stim,1)] = ttest(squeeze(normAllStimBaseOIpos(cond+1,:,1)),squeeze(normAllStimBaseOIpos(cond+1,:,stim))); % param: all stims vs first stim in photostim conditions
        [hNormAllStimBaseOIpos((cond+1)/2,stim,2), pNormAllStimBaseOIpos((cond+1)/2,stim,2)] = ttest(squeeze(normAllStimBaseOIpos(cond,:,stim)),squeeze(normAllStimBaseOIpos(cond+1,:,stim))); % param: stim in photostim cond vs stim in non-photostim cond
        [pNormAllStimBaseOIposW((cond+1)/2,stim,1), hNormAllStimBaseOIposW((cond+1)/2,stim,1)] = signrank(squeeze(normAllStimBaseOIpos(cond+1,:,1)),squeeze(normAllStimBaseOIpos(cond+1,:,stim))); % nonparam: all stims vs first stim in photostim conditions
        [pNormAllStimBaseOIposW((cond+1)/2,stim,2), hNormAllStimBaseOIposW((cond+1)/2,stim,2)] = signrank(squeeze(normAllStimBaseOIpos(cond,:,stim)),squeeze(normAllStimBaseOIpos(cond+1,:,stim))); % nonparam: stim in photostim cond vs stim in non-photostim cond
        [hNormAllStimBaseOIneg((cond+1)/2,stim,1), pNormAllStimBaseOIneg((cond+1)/2,stim,1)] = ttest(squeeze(normAllStimBaseOIneg(cond+1,:,1)),squeeze(normAllStimBaseOIneg(cond+1,:,stim))); % param: all stims vs first stim in photostim conditions
        [hNormAllStimBaseOIneg((cond+1)/2,stim,2), pNormAllStimBaseOIneg((cond+1)/2,stim,2)] = ttest(squeeze(normAllStimBaseOIneg(cond,:,stim)),squeeze(normAllStimBaseOIneg(cond+1,:,stim))); % param: stim in photostim cond vs stim in non-photostim cond
        [pNormAllStimBaseOInegW((cond+1)/2,stim,1), hNormAllStimBaseOInegW((cond+1)/2,stim,1)] = signrank(squeeze(normAllStimBaseOIneg(cond+1,:,1)),squeeze(normAllStimBaseOIneg(cond+1,:,stim))); % nonparam: all stims vs first stim in photostim conditions
        [pNormAllStimBaseOInegW((cond+1)/2,stim,2), hNormAllStimBaseOInegW((cond+1)/2,stim,2)] = signrank(squeeze(normAllStimBaseOIneg(cond,:,stim)),squeeze(normAllStimBaseOIneg(cond+1,:,stim))); % nonparam: stim in photostim cond vs stim in non-photostim cond
    end    
end

%% Fig. 32bx (bxx, bxxx) -  compare difference of magnitude in the non-adj norm traces to 0 (magn of 1st stim = 1 and not peak =1) for OIpos and OIneg
% these 2 lines can be commented out
OIposUnits = OIposUnits & baseSelect;
OInegUnits = OInegUnits & baseSelect;

allStimMagnNormTracesBaseSubtr100SubtrOIpos =allStimMagnNormTracesBaseSubtr100Subtr(:,OIposUnits,:);
allStimMagnNormTracesBaseSubtr100SubtrOIneg =allStimMagnNormTracesBaseSubtr100Subtr(:,OInegUnits,:);

meanAllStimMagnNormTracesBaseSubtr100SubtrOIpos = squeeze(nanmean(allStimMagnNormTracesBaseSubtr100SubtrOIpos,2));
meanAllStimMagnNormTracesBaseSubtr100SubtrOIneg = squeeze(nanmean(allStimMagnNormTracesBaseSubtr100SubtrOIneg,2));

STEMallStimMagnNormTracesBaseSubtr100SubtrOIpos = nan(totalConds/2, totalStim);
STEMallStimMagnNormTracesBaseSubtr100SubtrOIneg = nan(totalConds/2, totalStim);

for cond = 1:totalConds/2
    for stim = 1:totalStim
        STEMallStimMagnNormTracesBaseSubtr100SubtrOIpos(cond,stim) = nanstd(allStimMagnNormTracesBaseSubtr100SubtrOIpos(cond,:,stim))/sqrt(sum(~isnan(allStimMagnNormTracesBaseSubtr100SubtrOIpos(cond,:,stim))));
        STEMallStimMagnNormTracesBaseSubtr100SubtrOIneg(cond,stim) = nanstd(allStimMagnNormTracesBaseSubtr100SubtrOIneg(cond,:,stim))/sqrt(sum(~isnan(allStimMagnNormTracesBaseSubtr100SubtrOIneg(cond,:,stim))));

    end
end

for cond = 1:totalConds/2
    for stim = 1:totalStim
        [hAllStimMagnNormTracesBaseSubtr100SubtrOIpos(cond,stim), pAllStimMagnNormTracesBaseSubtr100SubtrOIpos(cond,stim)] = ttest(squeeze(allStimMagnNormTracesBaseSubtr100SubtrOIpos(cond,:,stim))); 
        [pAllStimMagnNormTracesBaseSubtr100SubtrOIposW(cond,stim), hAllStimMagnNormTracesBaseSubtr100SubtrOIposW(cond,stim)] = signrank(squeeze(allStimMagnNormTracesBaseSubtr100SubtrOIpos(cond,:,stim))); 
        [hAllStimMagnNormTracesBaseSubtr100SubtrOIneg(cond,stim), pAllStimMagnNormTracesBaseSubtr100SubtrOIneg(cond,stim)] = ttest(squeeze(allStimMagnNormTracesBaseSubtr100SubtrOIneg(cond,:,stim))); 
        [pAllStimMagnNormTracesBaseSubtr100SubtrOInegW(cond,stim), hAllStimMagnNormTracesBaseSubtr100SubtrOInegW(cond,stim)] = signrank(squeeze(allStimMagnNormTracesBaseSubtr100SubtrOIneg(cond,:,stim))); 

    end    
end

%% Fig. 33
% allStimMagnNormTracesBaseSubtr100 % 2*totalConds-2, totalUnits, numel(baseStim)
% variable containing the magn values before condition subtractions by
% figure30bxxx.m


OIndexAllStimMagnNormTracesBaseSubtr100 = nan(totalConds -1 , totalUnits, numel(baseStim));

for cond = 1:2:2*totalConds-2
    for unit = find(baseSelect)%find(iUnitsFilt)%
        for stim = 1:totalStim
            if (allStimMagnNormTracesBaseSubtr100(cond+1, unit, stim)+allStimMagnNormTracesBaseSubtr100(cond, unit, stim)) ~= 0
                OIndexAllStimMagnNormTracesBaseSubtr100((cond+1)/2, unit, stim) = (allStimMagnNormTracesBaseSubtr100(cond+1, unit, stim)-allStimMagnNormTracesBaseSubtr100(cond, unit, stim))/(allStimMagnNormTracesBaseSubtr100(cond+1, unit, stim)+allStimMagnNormTracesBaseSubtr100(cond, unit, stim)); 
            end    
        end        
    end
end

for cond = 1:2:2*totalConds-2
    for stim = 1:totalStim
       if mixed
           [hOIndexAllStimMagnNormTracesBaseSubtr100ExcInh((cond+1)/2, stim), pOIndexAllStimMagnNormTracesBaseSubtr100ExcInh((cond+1)/2, stim)] = kstest2(squeeze(OIndexAllStimMagnNormTracesBaseSubtr100((cond+1)/2,classUnitsAll == 1, stim)),squeeze(OIndexAllStimMagnNormTracesBaseSubtr100((cond+1)/2,classUnitsAll == 2, stim)));
        end
    end
end
%% Fig. 34

OIndexAllStimMagn = nan((totalConds -2)/2 , totalUnits, numel(baseStim));

cond = 1;
baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;

for cond = 1:2:totalConds-2
    for unit = find(baseSelect)%find(iUnitsFilt)%
        for stim = 1:totalStim
            if (allStimMagn(cond+1, unit, stim)+allStimMagn(cond, unit, stim)) ~= 0
                OIndexAllStimMagn((cond+1)/2, unit, stim) = (allStimMagn(cond+1, unit, stim)-allStimMagn(cond, unit, stim))/(allStimMagn(cond+1, unit, stim)+allStimMagn(cond, unit, stim)); 
            end    
        end        
    end
end

meanOIndexAllStimMagn = squeeze(nanmean(OIndexAllStimMagn,2));
meanOIndexAllStimMagnExc = squeeze(nanmean(OIndexAllStimMagn(:,classUnitsAll == 1,:),2));
meanOIndexAllStimMagnInh = squeeze(nanmean(OIndexAllStimMagn(:,classUnitsAll == 2,:),2));

STEMOIndexAllStimMagn = nan(totalConds/2, numel(baseStim));
STEMOIndexAllStimMagnExc = nan(totalConds/2, numel(baseStim));
STEMOIndexAllStimMagnInh = nan(totalConds/2, numel(baseStim));

for cond = 1:totalConds/2-1  
    for stim = 2:numel(baseStim)
        STEMOIndexAllStimMagn(cond, stim) = nanstd(OIndexAllStimMagn(cond,:,stim))/sqrt(sum(~isnan(OIndexAllStimMagn(cond,:,stim))));  
        STEMOIndexAllStimMagnExc(cond, stim) = nanstd(OIndexAllStimMagn(cond,classUnitsAll == 1,stim))/sqrt(sum(~isnan(OIndexAllStimMagn(cond,classUnitsAll == 1,stim))));  
        STEMOIndexAllStimMagnInh(cond, stim) = nanstd(OIndexAllStimMagn(cond,classUnitsAll == 2,stim))/sqrt(sum(~isnan(OIndexAllStimMagn(cond,classUnitsAll == 2,stim))));  
    end
end


for cond = 1:2:totalConds-2
    for stim = 1:totalStim
       if mixed
           [hOIndexAllStimMagnExcInh((cond+1)/2, stim), pOIndexAllStimMagnExcInh((cond+1)/2, stim)] = kstest2(squeeze(OIndexAllStimMagn((cond+1)/2,classUnitsAll == 1, stim)),squeeze(OIndexAllStimMagn((cond+1)/2,classUnitsAll == 2, stim)));
        end
    end
end

%reset baseSelect
baseSelect = allStimBase(totalConds-1,:,1) >= thresholdFreq ; % select units with baseline higher than the selection threshold for 0%;

%% Fig. 35

stimPost = (2:4);
allStimAvgMagn = nanmean(allStimMagn(:,:,stimPost),3);

OIndexAllStimAvgMagn = nan((totalConds -2)/2 , totalUnits);
cond = 1;
baseSelect = allStimBase(cond,:,1) >= thresholdFreq ;

for cond = 1:2:totalConds-2
    for unit = find(baseSelect)%find(iUnitsFilt)%
        for stim = 1:numel(baseStim)
            if (allStimAvgMagn(cond+1, unit)+allStimAvgMagn(cond, unit)) ~= 0
                OIndexAllStimAvgMagn((cond+1)/2, unit) = (allStimAvgMagn(cond+1, unit)-allStimAvgMagn(cond, unit))/(allStimAvgMagn(cond+1, unit)+allStimAvgMagn(cond, unit)); 
            end    
        end        
    end
end

%reset baseSelect
baseSelect = allStimBase(totalConds-1,:,1) >= thresholdFreq ; % select units with baseline higher than the selection threshold for 0%;


%%