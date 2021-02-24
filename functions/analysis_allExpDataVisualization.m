%%% created by RB on 23.12.2020
%%% analysis for allExpDataVisualization_A2.m
disp('Running  analysis...')
%% Analysis for Fig. 1 (2x): average of timecourses 

% Smooth trace frequency timecourses (TCs)
smooth_param = 1;
smoothTraceFreqAll = nan(totalConds, totalUnits, totalDatapoints);
for cond = 1 : totalConds
    for unit = find(iUnitsFilt)
        smoothTraceFreqAll(cond,unit,:) = smooth(squeeze(clusterTimeSeriesAll.traceFreqGood(cond, unit, :)),smooth_param, smooth_method);
    end
end

% Calculate mean of smoothed trace frequency TCs
meanTraceFreqAll = squeeze(nanmean(smoothTraceFreqAll,2));

% Calculate STEM of frequency TCs over cells
STEMtraceFreqAll = nan(totalConds, totalDatapoints);
for cond = 1 : totalConds
    for datapoint = 1:totalDatapoints
        STEMtraceFreqAll(cond, datapoint) = nanstd(smoothTraceFreqAll(cond, :, datapoint))/sqrt(sum(~isnan(smoothTraceFreqAll(cond, :, datapoint))));
    end 
end


%% Analysis for Fig. 2 (2x): average of normalized time courses
% Baseline calculations  % dim: cond, unit, stim 
baseStim = clusterTimeSeriesAll.baseTime; % [12 27 42 57 72 87] or [6, 12, 26];
baseDuration = 1/bin-1; % additional data points for baseline quantification (1 sec)
if longBase
    if isequal(baseStim, [12 27 42 57 72 87]) %
        baseDuration = 3/bin-1; % additional data points for baseline quantification (3 sec)
    elseif isequal(baseStim, [6, 12, 26])
        baseStim = [1, 12, 21];% modify baseStim to allow longer baseline quantification time
        baseDuration = 2/bin-1; % additional data points for baseline quantification (2 sec)
    end
end    
       
allStimBase = nan(totalConds, totalUnits, numel(baseStim));
for cond = 1:totalConds
    for unit = find(iUnitsFilt)
        for stim = 1:numel(baseStim)
            allStimBase(cond, unit, stim) = nanmean(clusterTimeSeriesAll.traceFreqGood(cond, unit, baseStim(stim):baseStim(stim)+baseDuration),3);
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
end


maxTraceFreqAll = nan(totalConds, totalUnits);
maxIndTraceFreqAll = nan(totalConds, totalUnits);
smoothMaxTraceFreqAll = nan(totalConds, totalUnits);

for cond = 1: totalConds-2
    for unit = find(iUnitsFilt)
        [maxTraceFreqAll(cond, unit), maxIndTraceFreqAll(cond, unit)] = max(traceFreqAllMinusBase(cond, unit, searchMax));
        maxIndTraceFreqAll(cond, unit) = maxIndTraceFreqAll(cond, unit) + searchMax(1)-1;
        %             smoothMaxTraceFreqAll(cond, unit) = mean(mean(traceFreqAllMinusBase(cond, unit, maxIndTraceFreqAll(cond, unit)-1:maxIndTraceFreqAll(cond,unit)+1))); % smooth over 3 points
        smoothMaxTraceFreqAll(cond, unit) = mean(traceFreqAllMinusBase(cond, unit, maxIndTraceFreqAll(cond, unit))); % just max
    end
end


% normalize >0% vis. stim. to max (without photostim) (or smoothMax) and then smooth
smooth_param = 1;
normTraceFreqAll = nan(totalConds,totalUnits, totalDatapoints);
for cond = 1:totalConds-2
    condNorm = floor((cond+1)/2)*2-1; % normalized by the non-photostim condition
    for unit = find(iUnitsFilt)
%         normTraceFreqAll(cond, unit, :) = smooth(traceFreqAllMinusBase(cond, unit, :)/maxTraceFreqAll(condNorm, unit),smooth_param, smooth_method);
        normTraceFreqAll(cond, unit, :) = smooth(traceFreqAllMinusBase(cond, unit, :)/smoothMaxTraceFreqAll(condNorm, unit),smooth_param, smooth_method);
        normTraceFreqAll100(cond, unit, :) = smooth(traceFreqAllMinusBase(cond, unit, :)/smoothMaxTraceFreqAll(1, unit),smooth_param, smooth_method);
    end
end

% normalize 0% vis stim to baseline (without photostim) and then smooth

% thresholdFreq = 0.1 % selection threshold in Hz
baseSelect = allStimBase(totalConds-1,:,1) >= thresholdFreq ; % select units with baseline higher than the selection threshold for 0%;
totalBaseSelectUnits = numel(find(baseSelect))
for cond = totalConds-1:totalConds
    for unit = find(baseSelect)
        normTraceFreqAll(cond, unit, :) = smooth(clusterTimeSeriesAll.traceFreqGood(cond, unit, :)/allStimBase(totalConds-1, unit,1),smooth_param, smooth_method);
        normTraceFreqAll100(cond, unit, :) = smooth(traceFreqAllMinusBase(cond, unit, :)/smoothMaxTraceFreqAll(1, unit),smooth_param, smooth_method);
    end
end

% Calculate mean of smoothed and norm TCs
for cond = 1:totalConds
    meanNormTraceFreqAll = squeeze(nanmean(normTraceFreqAll,2));
    meanNormTraceFreqAll100 = squeeze(nanmean(normTraceFreqAll100,2));
end    

% Calculate STEM of TCs over cells
STEMnormTraceFreqAll = nan(totalConds, totalDatapoints);
for cond = 1:totalConds
    for datapoint = 1:totalDatapoints
        STEMnormTraceFreqAll(cond, datapoint) = nanstd(normTraceFreqAll(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAll(cond, :,datapoint))));
        STEMnormTraceFreqAll100(cond, datapoint) = nanstd(normTraceFreqAll100(cond,:,datapoint))/sqrt(sum(~isnan(normTraceFreqAll100(cond, :,datapoint))));
    end    
end


%% Analysis Fig. 3 (2x): Baseline quantification

% Calculate mean and STEM of baseline and stat tests

meanAllStimBase = squeeze(nanmean(allStimBase,2));

for cond = 1:totalConds
    for stim = 1:numel(baseStim)
        STEMallStimBase(cond, stim) = nanstd(allStimBase(cond,:,stim))/sqrt(sum(~isnan(allStimBase(cond, :,stim))));
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
baseSelect = allStimBase(totalConds-1,:,1) >= thresholdFreq ; % select units with baseline higher than the selection threshold for 0%;
totalBaseSelectUnits = numel(find(baseSelect));
for cond = 1:totalConds
    for unit = find(baseSelect)
        for stim = 1:numel(baseStim)            
            if allStimBase(cond, unit, 1) ~=0
                normAllStimBase(cond, unit, stim) = allStimBase(cond, unit, stim)/allStimBase(cond, unit, 1)-1;  
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
    amplInt = [18 18]; % in data points
elseif sessionInfoAll.trialDuration == 6
    amplInt = [31 33];
end

allStimAmpl = nan(totalConds, totalUnits, totalStim);
allStimAmplNormTrace = nan(totalConds, totalUnits, totalStim);
allStimAmplNormTrace100 = nan(totalConds, totalUnits);
for cond = 1:totalConds
    for unit = find(iUnitsFilt)
        for stim = 1:totalStim % 2 calculations: hz values and normalized values
            allStimAmpl(cond, unit, stim) = nanmean(clusterTimeSeriesAll.traceFreqGood(cond, unit, (stim-1)*(3/bin)+amplInt(1):(stim-1)*(3/bin)+amplInt(2)),3);
            allStimAmplNormTrace(cond, unit, stim) = nanmean(normTraceFreqAll(cond, unit, (stim-1)*(3/bin)+amplInt(1):(stim-1)*(3/bin)+amplInt(2)),3);
            allStimAmplNormTrace100(cond, unit) = nanmean(normTraceFreqAll100(cond, unit, (stim-1)*(3/bin)+amplInt(1):(stim-1)*(3/bin)+amplInt(2)),3);
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
    normAllStimAmpl100 = allStimAmplNormTrace; % normalize to first stim in the same non-photostim cond
elseif totalStim == 1
    normAllStimAmpl100 = allStimAmplNormTrace100;
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


%% Analysis Fig. 7, 8 - Opto-index and ratio of baselines in photostim vs non-photostim. conditions

ratioAllStimBase = nan(totalConds/2, totalUnits, numel(baseStim));
OIndexAllStimBase = nan(totalConds/2, totalUnits, numel(baseStim));

for cond = 1:2:totalConds
    for unit = find(iUnitsFilt)
        for stim = 1:numel(baseStim)
            if allStimBase(cond, unit, stim) ~= 0
                ratioAllStimBase((cond+1)/2, unit, stim) = allStimBase(cond+1, unit, stim)/allStimBase(cond, unit, stim); 
            end
            if (allStimBase(cond+1, unit, stim)+allStimBase(cond, unit, stim)) ~= 0
                OIndexAllStimBase((cond+1)/2, unit, stim) = (allStimBase(cond+1, unit, stim)-allStimBase(cond, unit, stim))/(allStimBase(cond+1, unit, stim)+allStimBase(cond, unit, stim));   
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

for cond = 1:2:totalConds
    for stim = 2:numel(baseStim)
        [sortRatioNormAllStimBase((cond+1)/2,:, stim), indexRatioNormAllStimBase((cond+1)/2,:, stim)] = sort(ratioNormAllStimBase((cond+1)/2,:, stim));
        [sortOIndexAllStimBase((cond+1)/2,:, stim), indexOIndexAllStimBase((cond+1)/2,:, stim)] = sort(OIndexAllStimBase((cond+1)/2,:, stim));
    end
end

meanOIndexAllStimBase = squeeze(nanmean(OIndexAllStimBase,2));
meanOIndexAllStimBaseExc = squeeze(nanmean(OIndexAllStimBase(:,classUnitsAll == 1,:),2));
meanOIndexAllStimBaseInh = squeeze(nanmean(OIndexAllStimBase(:,classUnitsAll == 2,:),2));

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
for cond = 1:2:totalConds
    for stim = 1:totalStim
        [sortRatioNormAllStimAmpl((cond+1)/2,:,stim), indexRatioNormAllStimAmpl((cond+1)/2,:,stim)] = sort(ratioNormAllStimAmpl((cond+1)/2,:,stim));
        [sortOIndexAllStimAmpl((cond+1)/2,:,stim), indexOIndexAllStimAmpl((cond+1)/2,:,stim)] = sort(OIndexAllStimAmpl((cond+1)/2,:,stim));
    end
end

meanOIndexAllStimAmpl = nanmean(OIndexAllStimAmpl,2);

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
% 
% totalUnits = size(allStimBase, 2);
% totalStim = size(allStimBase, 3);

allStimBaseComb = nan(2, totalUnits, numel(baseStim));

allStimBaseComb(1,1:totalUnits,1:numel(baseStim)) = nanmean(allStimBase(1:2:totalConds,:,:),1); % no photostim
allStimBaseComb(2,1:totalUnits,1:numel(baseStim)) = nanmean(allStimBase(2:2:totalConds,:,:),1); % with photostim

% thresholdFreq = 0.1; % selection threshold in Hz
baseSelect = allStimBaseComb >= thresholdFreq ; % select units with baseline higher than the selection threshold; 2 conds, unit, 3 stim
units = (1:totalUnits); 
baseSelectUnits = units(baseSelect(2,:,1)); % 
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

for cond = 1:2
    for stim = 2:numel(baseStim)
        [sortRatioNormAllStimBaseComb(cond,:, stim), indexRatioNormAllStimBaseComb(cond,:, stim)] = sort(ratioNormAllStimBaseComb(cond,:, stim));
        [sortOIndexAllStimBaseComb(cond,:, stim), indexOIndexAllStimBaseComb(cond,:, stim)] = sort(OIndexAllStimBaseComb(cond,:, stim));
    end
end

meanOIndexAllStimBaseComb = squeeze(nanmean(OIndexAllStimBaseComb,2)); % with photostim
meanOIndexAllStimBaseCombExc = squeeze(nanmean(OIndexAllStimBaseComb(:,classUnitsAll(baseSelectUnits) == 1,:),2));
meanOIndexAllStimBaseCombInh = squeeze(nanmean(OIndexAllStimBaseComb(:,classUnitsAll(baseSelectUnits) == 2,:),2)); 

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
    
    % only for single-stim protocol
    if totalStim == 1
        ratioNormAmplMinusBaseNormTrace = ratioAmplMinusBaseNormTrace;
    else % for multi-stim protocol, divide by first stim
        ratioNormAmplMinusBaseNormTrace = ratioAmplMinusBaseNormTrace ./ ratioAmplMinusBaseNormTrace(:,:,1);
    end
    
    meanOIndexAmplMinusBaseNormTrace = nanmean(OIndexAmplMinusBaseNormTrace,2);
    STEMOIndexAmplMinusBaseNormTrace = nan(totalConds/2,totalStim);
    for cond = 1:totalConds/2
        for stim = 1:totalStim
            STEMOIndexAmplMinusBaseNormTrace(cond, stim) = nanstd(OIndexAmplMinusBaseNormTrace(cond,:,stim))/sqrt(sum(~isnan(OIndexAmplMinusBaseNormTrace(cond,:,stim))));
        end
    end
    
    % Calculate mean and STEM of the ration of normalized amplitude
    
    meanRatioNormAmplMinusBaseNormTrace = squeeze(nanmean(ratioNormAmplMinusBaseNormTrace,2));
    STEMratioNormAmplMinusBaseNormTrace = nan(totalConds/2, totalStim);
    for cond = 1:2:totalConds
        for stim = 1:totalStim
            STEMratioNormAmplMinusBaseNormTrace((cond+1)/2,stim) = nanstd(ratioNormAmplMinusBaseNormTrace((cond+1)/2,:,stim))/sqrt(sum(~isnan(ratioNormAmplMinusBaseNormTrace((cond+1)/2,:,stim))));
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



%% Analysis for Fig. 22


