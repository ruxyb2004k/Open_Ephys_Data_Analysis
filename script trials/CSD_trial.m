%% use only the selected trials
cond = 33;
indCond = find(condData.codes == cond);
indCondSel = indCond(ismember(indCond, timeSeries.subTrialsForAnalysis));%%
events = recStartDataPoint(indCondSel)/samplingRate; % events are time 0 of trials of a specific cond
eventsVisStim = events+0.2; % start of trial +0.2 s to get the first vis stim
eventsVisStim6 = repmat(events,1,numel(sessionInfo.visStim));
eventsVisStim6 = eventsVisStim6 + repmat(sessionInfo.visStim, size(events,1),1);
eventsVisStim6 = eventsVisStim6';
eventsVisStim6 = eventsVisStim6(:);
%% events are time 0 of a visual stimulus - not adjusted to missing data points!!! - don't use
% dataEv5 = find(dataEv == 5);
% visStimOn = dataEv5(1:2:end);
% visStimOnTimestamps = timestampsEv(visStimOn);
%% sort channels
if strcmp(sessionInfo.probe, '2x16_P1')
    load('/data/oidata/Ruxandra/Open Ephys/chanMap_2x16_P1_real.mat')
elseif strcmp(sessionInfo.probe, '2x16_E1')
    load('/data/oidata/Ruxandra/Open Ephys/chanMap_2x16_E1.mat') 
elseif strcmp(sessionInfo.probe, '1x16_E1')
    load('/data/oidata/Ruxandra/Open Ephys/chanMap_1x16_E1.mat') 
elseif strcmp(sessionInfo.probe, '1x16_P1')
    load('/data/oidata/Ruxandra/Open Ephys/chanMap_1x16_P1.mat')
elseif strcmp(sessionInfo.probe, '2x32_H6')
    load('/data/oidata/Ruxandra/Open Ephys/chanMap_2x32_H6.mat')  
else
    disp('Channel map not it the list.')
end
[sorted1, IndSorted1] = sort(ycoords(1:16), 'descend');

if strcmp(sessionInfo.probe(1), '2')
    [sorted2, IndSorted2] = sort(ycoords(17:32), 'descend');
    IndSorted2 = IndSorted2+16;
end    
%% calculate CSD % it needs all channels to be analyzed
% [csd, lfpAvg] = bz_eventCSD(lfpdown, events)%, 'channels', [8]);
saveFigs = false;

[csd2, lfpAvg2] = bz_eventCSD(lfp.data, eventsVisStim6, 'channels', IndSorted2);
if saveFigs == true
    savefig(strcat(savePathFigs, ['/sh1_cond',  num2str(cond)]));
    saveas(gcf, strcat(savePathFigs, ['/sh1_cond',  num2str(cond)], '.png'));
end

[csd1, lfpAvg1] = bz_eventCSD(lfp, eventsVisStim6, 'channels', IndSorted1);
if saveFigs == true
    savefig(strcat(savePathFigs, ['/sh2_cond',  num2str(cond)]));
    saveas(gcf, strcat(savePathFigs, ['/sh2_cond',  num2str(cond)], '.png'));
end