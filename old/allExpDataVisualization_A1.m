%%% Data visualization of cells from multiple experiments %%%
clear all

load('allExp.mat')
expSet = allExp; % select experiment set

numFilt = 10; % max number filters
filt = true(numFilt,size(expSet,2)); 

%%%%%%% add filter here %%%%%%%

filt(1,:) = [expSet.trialDuration] == 18;
filt(2,:) = strcmp({expSet.animalStrain}, 'NexCre');
% filt(3,:) = strcmp({expSet.experimentName}, '2020-08-11_15-44-59');
% filt(4,:) = ~(contains({expSet.experimentName}, '2020-11-12_14-20-47') | contains({expSet.experimentName}, '2020-12-01_13-58-50') | contains({expSet.experimentName},'2020-12-03_14-41-44'));
% filt(5,:) = contains({expSet.animalName}, '20200730') | contains({expSet.animalName}, '20200805');
filt(6,:) = [repelem(0,71),repelem(1,37)];
filt(7,:) = [expSet.expSel] == 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

combinedFilter = sum(filt,1) == numFilt;
expSetFilt = expSet(combinedFilter); % apply filters to the experiment set

%% Read each experiment

% create structures with experiment info for each unit
fields = fieldnames(expSetFilt);
c = cell(length(fields),1);
expSetFiltSua = cell2struct(c,fields); % no. rows = no. units
expSetFiltMua = cell2struct(c,fields); % no. rows = no. units

% import experiments from the experiment set list
for i =1:(size(expSetFilt,2))
    clearvars sessionInfo timeSeries spikeClusterData clusterTimeSeries cellMetrics
    
    experimentName = expSetFilt(i).experimentName
    sessionName = expSetFilt(i).sessionName;
    
    path = strsplit(pwd,filesep);
    basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
    basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);
    
    filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session
%     filenameTimeSeries = fullfile(basePathMatlab,[sessionName,'.timeSeries.mat']); % time series info
    filenameSpikeClusterData = fullfile(basePathMatlab,[sessionName,'.spikeClusterData.mat']); % general info about the session
    filenameClusterTimeSeries = fullfile(basePathMatlab,[sessionName,'.clusterTimeSeries.mat']); % cluster time series 
    filenameCellMetrics = fullfile(basePathMatlab,[sessionName,'.cellMetrics.mat']); % spike cluster data
    
    % try to load structures 
    [sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
%     [timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries);
    [spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);
    [clusterTimeSeries, CTSexist] = tryLoad('clusterTimeSeries', filenameClusterTimeSeries);
    [cellMetrics, CMexist] = tryLoad('cellMetrics', filenameCellMetrics);
    
    clusterTimeSeries = adjustStruct(clusterTimeSeries); % add 2 extra fields: iSelectedCodesInd and iSelectedCodesIndSpont   
    
%     % expand Sua and Mua structures containing experiment information
    currUnitsSua = size(expSetFiltSua,2);
    expSua = size(clusterTimeSeries.traceFreqGood,2);
    expSetFiltSua(currUnitsSua+1:currUnitsSua+expSua) = expSetFilt(i);
    
    currUnitsMua = size(expSetFiltMua,2);
    expMua = size(clusterTimeSeries.traceFreqMuaSel,2);
    expSetFiltMua(currUnitsMua+1:currUnitsMua+expMua) = expSetFilt(i);
    
    % expand the meta-data structures after reading each experiment
    if i == 1
        sessionInfoAll = sessionInfo;
        spikeClusterDataAll = spikeClusterData;
        cellMetricsAll = cellMetrics;
        clusterTimeSeriesAll = clusterTimeSeries; 
    else
%         sessionInfoAll = addToStruct(sessionInfo, sessionInfoAll);
        spikeClusterDataAll = addToStruct(spikeClusterData, spikeClusterDataAll);
        cellMetricsAll = addToStruct(cellMetrics, cellMetricsAll);       
        clusterTimeSeriesAll = addToStruct(clusterTimeSeries, clusterTimeSeriesAll); 
    end    
    
end
expSetFiltSua(1) = []; % delete empty first row
expSetFiltMua(1) = []; % delete empty first row

% extract name and number of hemispheres
hemNames = unique({expSetFilt.animalName});
noHems = numel(hemNames);

% name and number of animals - equal or different than hemispheres
animalNames = hemNames;
noAnimals = noHems;

% unique animal names
[animNames,~,i] = unique({expSetFiltSua.animalName},'stable');
suaEachAnimal = accumarray(i(:),1,[numel(animNames),1]); % previously called animals


C = [[0 0 0]; [0 0 1]; [0 0.4470 0.7410]; [0.5 0.5 0.5]]; % black, navy-blue, blue, gray - traces
% asign each animal a color
C_animal = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330]; [1 0 1]; [1 0 0]; [0 1 0]; [1 1 0]; [0 0 1]; [0.5 0.5 0.5];...
    [0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330]; [1 0 1]; [1 0 0]; [0 1 0]; [1 1 0]; [0 0 1]; [0.5 0.5 0.5];...
    [0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330]; [1 0 1]; [1 0 0]; [0 1 0]; [1 1 0]; [0 0 1]; [0.5 0.5 0.5];...
    [0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330]; [1 0 1]; [1 0 0]; [0 1 0]; [1 1 0]; [0 0 1]; [0.5 0.5 0.5]]; % blue, orange, yellow, purple, green, cyan, magenta, red, green, diff yellow, diff blue, grey
C_units = [];
for animal = 1:noAnimals
    C_units = [C_units; repmat(C_animal(animal,:),suaEachAnimal(animal),1)];
end

fs = 24; %font size
smooth_method = 'moving';
classUnitsAll = ([cellMetricsAll.troughPeakTime]< 0.5) + 1; % subject to change - different criteria; 1 = pyr, 2 = inh
EIColor = 'gr';

% Analysis for Figs xx - yy -

totalConds = numel(fieldnames(sessionInfoAll.conditionNames)); % number of conditions
totalDatapoints = size(clusterTimeSeriesAll.traceFreqGood,3); % number of data time points
totalStim = numel(clusterTimeSeriesAll.stimTime);

bin = clusterTimeSeriesAll.bin;
plotBeg = -sessionInfoAll.preTrialTime + bin;
plotEnd = sessionInfoAll.trialDuration + sessionInfoAll.afterTrialTime;

%% 
%%%%%%%%%%% apply filters to the unit data set here %%%%%%%%%%%%%%%%

iUnitsFilt = repelem(1, size(cellMetricsAll.waveformCodes,1)); % all units
iUnitsFilt = iUnitsFilt &  clusterTimeSeriesAll.iSelectedCodesInd == 1; % only selected = 1
iUnitsFilt = iUnitsFilt & clusterTimeSeriesAll.iSelectedCodesIndSpont == 1 ; % only evoked = 0 or spont = 1
% iUnitsFilt = iUnitsFilt &  classUnitsAll == 2; % only specifiy cell type: 1 = pyr, 2 = inh

saveFigs = true;
savePath = [strjoin({path{1:end}, 'figs','2020-12', 'NexCre', 'long', 'spont'}, filesep), filesep];%, 'spont'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
totalUnits = size(iUnitsFilt,2);
totalUnitsFilt = sum(iUnitsFilt);

disp(['Total excitatory units: ', num2str(sum(classUnitsAll(iUnitsFilt) == 1))]);
disp(['Total inhibitory units: ', num2str(sum(classUnitsAll(iUnitsFilt) == 2))]);

%% Fig 15 - waveform figures

titleFig15 = {'All waveforms', 'Normalized waveforms', 'Ratio vs time','Time vs peak asymmetry', '3D plot'};
saveFig15 = {'allWaveforms.fig', 'normAllWaveforms.fig', 'ratioVsTime.fig', 'timeVsPeakAsym.fig', '3Dplot.fig'};

% Fig. 15a: plot all waveforms
% figure; 
% for unit = find(iUnitsFilt)
%     plot(cellMetricsAll.waveformFiltAvg(unit,:), 'Color', C_units(unit,:)); hold on
% end   
% title(titleFig15{1},'FontSize',18);
% if saveFigs == true
%     savefig(strcat(savePath, saveFig15{1}));
% end

% Fig. 15b: normalized waveforms to trough = -1
figure; 
for unit = find(iUnitsFilt)
%     plot(cellMetricsAll.waveformFiltAvgNorm(unit,:), 'Color', C_units(unit,:)); hold on
    plot(((0:size(cellMetricsAll.waveformFiltAvgNorm,2)-1)/20), cellMetricsAll.waveformFiltAvgNorm(unit,:), 'Color', EIColor(classUnitsAll(unit))); hold on
end
xlabel('Time (ms)')
% ylim([-1,1.52])
ylim([-1,1.5])
title(titleFig15{2},'FontSize',18);
box off
if saveFigs == true
    savefig(strcat(savePath, saveFig15{2}));
    saveas(gcf, strcat(savePath, saveFig15{2}(1:end-3), 'png'));
end


% 
% % Fig. 15c: plot ratio vs time
% figure;
% for unit = find(iUnitsFilt)
%     if classUnitsAll(unit) == 1
%         plot(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.troughPeakTime(unit), 'Marker','^','MarkerSize',10,'Color', C_units(unit,:)); hold on
%     elseif classUnitsAll(unit) == 2
%         plot(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.troughPeakTime(unit), 'Marker','o','MarkerSize',10,'Color', C_units(unit,:)); hold on
%     end
%     text(cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.troughPeakTime(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',8, 'HorizontalAlignment','center'); hold on
% end
% xlabel('peak : trough ratio'); 
% ylabel('trough to peak (ms)');
% title(titleFig15{3},'FontSize',18);
% if saveFigs == true
%     savefig(strcat(savePath, saveFig15{3}));
% end
% 

% Fig. 15d: plot time vs peak asymmetry
figure; 
for unit = find(iUnitsFilt)
    if classUnitsAll(unit) == 1 % excitatory
%         plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','^','MarkerSize',10,'Color', C_units(unit,:)); hold on
        plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','^','MarkerSize',10,'Color', 'g'); hold on
    elseif classUnitsAll(unit) == 2 % inhibitory
%         plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','o','MarkerSize',10,'Color', C_units(unit,:)); hold on
        plot(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), 'Marker','o','MarkerSize',10,'Color', 'r'); hold on
    end    
%     text(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakAsymmetry(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',8, 'HorizontalAlignment','center'); hold on   
end
xlabel('trough to peak (ms)'); 
ylabel('peak asymmetry (P2-P1)/(P2+P1)');
title(titleFig15{4},'FontSize',18);
if saveFigs == true
    savefig(strcat(savePath, saveFig15{4}));
    saveas(gcf, strcat(savePath, saveFig15{4}(1:end-3), 'png'));% works, but file is not saved as vector
%     print('-painters', '-depsc')% save file as vector image
end

% Fig. 15e: 3D plot time vs ratio vs peak asymmetry
figure; 
scatter3(cellMetricsAll.troughPeakTime(classUnitsAll ==1),  cellMetricsAll.peakTroughRatio(classUnitsAll ==1), cellMetricsAll.peakAsymmetry(classUnitsAll ==1), '^'); hold on
scatter3(cellMetricsAll.troughPeakTime(classUnitsAll ==2),  cellMetricsAll.peakTroughRatio(classUnitsAll ==2), cellMetricsAll.peakAsymmetry(classUnitsAll ==2), 'o'); hold on
% for unit = 1:totalUnits
%     text(cellMetricsAll.troughPeakTime(unit), cellMetricsAll.peakTroughRatio(unit), cellMetricsAll.peakAsymmetry(unit), num2str(unit), 'Color', C_units(unit,:), 'FontSize',10, 'HorizontalAlignment','center'); hold on   
% end
xlabel('trough to peak (ms)'); 
ylabel('peak : trough ratio');
zlabel('peak asymmetry (P2-P1)/(P2+P1)');
title(titleFig15{5},'FontSize',18);
grid off
if saveFigs == true
    savefig(strcat(savePath, saveFig15{5}));
end



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

%% Fig 1 (2x): average of time courses evoked activity 100% contrast and spontaneous activity
if totalStim == 6
    titleFig1 = {'100% visual stim. vs 100% visual + photostim. all cells',...
    '0% visual stim. vs 0% visual + photostim. all cells'};
    saveFig1 = {'meanTC100All.fig', 'meanTC0All.fig'};
elseif totalStim == 1
    titleFig1 = {'100% visual stim. vs 100% visual + photostim. all cells',...
    '50% visual stim. vs 50% visual + photostim. all cells', ...
    '25% visual stim. vs 25% visual + photostim. all cells', ...
    '12% visual stim. vs 12% visual + photostim. all cells', ...
    '0% visual stim. vs 0% visual + photostim. all cells'};

    saveFig1 = {'meanTC100All.fig', 'meanTC50All.fig','meanTC25All.fig','meanTC12All.fig','meanTC0All.fig'};
end
max_hist1 = 1.5 * max(max(meanTraceFreqAll(1:2,:)));

for cond = (1:2:totalConds)
    figure
    ax = gca;
    hold on
    plot((plotBeg:bin:plotEnd), meanTraceFreqAll(cond,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((plotBeg:bin:plotEnd), meanTraceFreqAll(cond+1,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    
%     max_hist1 = 1.5 * max(max(meanTraceFreqAll(cond:cond+1,:)));
    min_hist = 0;
    
    xlabel('Time [sec]');
    ylabel('Average spike freq. (Hz)');
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    % set(ax,'xtick',[ceil(-plotBeg):2:floor(plotEnd)]) % set major ticks
    set(ax, 'TickDir', 'out');
    % set(ax,'xtick',[]);
    % set(gca, 'XColor', 'w');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs);
    title(titleFig1{(cond+1)/2}); 
    % background = get(gcf, 'color');
    %set(gcf,'color','white');
    h1 = line(sessionInfoAll.optStimInterval,[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    fact = 0.95;
    x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
    for i = (1:totalStim)  
        if cond < totalConds-1
            h2 = line('XData',x(i,:),'YData',fact*[max_hist1 max_hist1]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
            set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
        end
    end
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    shadedErrorBar1((plotBeg:bin:plotEnd),meanTraceFreqAll(cond,:),STEMtraceFreqAll(cond,:), {'Color', C(1,:)}); hold on
    shadedErrorBar1((plotBeg:bin:plotEnd),meanTraceFreqAll(cond+1,:),STEMtraceFreqAll(cond+1,:), {'Color', C(2,:)}); hold on
    if saveFigs == true
        savefig(strcat(savePath, saveFig1{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig1{(cond+1)/2}(1:end-3), 'png'));
    end
end

%% Analysis for Fig. 2 (2x): average of normalized time courses
% Baseline calculations  % dim: cond, unit, stim 
baseStim = clusterTimeSeriesAll.baseTime; % [12 27 42 57 72 87] or [6, 12, 26];
baseDuration = 1/bin-1; % additional data points for baseline quantification

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

thresholdFreq = 0.1; % selection threshold in Hz
baseSelect = allStimBase(totalConds-1,:,1) >= thresholdFreq ; % select units with baseline higher than the selection threshold for 0%;
totalBaseSelectUnits = numel(find(baseSelect));
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

%% Fig 2 (2x): Norm average of time courses evoked activity 100% contrast and spontaneous activity
if totalStim == 6
    titleFig2 = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
    '0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig2 = {'meanNormTC100All.fig','meanNormTC0All.fig'};
elseif totalStim == 1
    titleFig2 = {'100% visual stim. vs 100% visual + photostim. all cells norm',...
    '50% visual stim. vs 50% visual + photostim. all cells norm', ...
    '25% visual stim. vs 25% visual + photostim. all cells norm', ...
    '12% visual stim. vs 12% visual + photostim. all cells norm', ...
    '0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig2 = {'meanNormTC100All.fig', 'meanNormTC50All.fig','meanNormTC25All.fig','meanNormTC12All.fig','meanNormTC0All.fig'};
end
for cond = (1:2:totalConds)
    figure
    ax = gca;
    hold on
    plot((plotBeg:bin:plotEnd), meanNormTraceFreqAll(cond,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((plotBeg:bin:plotEnd), meanNormTraceFreqAll(cond+1,:),'LineWidth', 3, 'Color', C(2,:)); hold on

    max_hist1 = 1.5 * max(max(meanNormTraceFreqAll(cond:cond+1,:)));
    min_hist = -0.5;
    xlabel('Time [sec]');
    ylabel('Norm. average spike freq.');
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig2{(cond+1)/2});
    h1 = line(sessionInfoAll.optStimInterval,[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    fact = 0.95;
    x = [sessionInfoAll.visStim; sessionInfoAll.visStim + 0.2]';
    for i = (1:totalStim)  
        if cond < totalConds-1
            h2 = line('XData',x(i,:),'YData',fact*[max_hist1 max_hist1]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
            set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
        end
    end
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAll(cond,:),STEMnormTraceFreqAll(cond,:), {'Color', C(1,:)}); hold on
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAll(cond+1,:),STEMnormTraceFreqAll(cond+1,:), {'Color', C(2,:)}); hold on
    if saveFigs == true
        savefig(strcat(savePath, saveFig2{(cond+1)/2}));
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

%% Fig. 3 (2x) : average baseline frequency 
if totalStim ==6
    titleFig3 = {'Baseline frequency 100% visual stim. vs 100% visual + photostim. all cells',...
    'Baseline frequency 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig3 = {'meanBaseline100.fig','meanBaseline0.fig'};
elseif totalStim == 1
    titleFig3 = {'Baseline frequency 100% visual stim. vs 100% visual + photostim. all cells',...
    'Baseline frequency 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Baseline frequency 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Baseline frequency 12% visual stim. vs 12% visual + photostim. all cells norm', ...
    'Baseline frequency 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig3 = {'meanBaseline100.fig', 'meanBaseline50.fig','meanBaseline25.fig','meanBaseline12.fig','meanBaseline0.fig'};
end

for cond = (1:2:totalConds)
    figure
    ax = gca;
    hold on
    plot((1:numel(baseStim)),meanAllStimBase(cond,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:numel(baseStim)),meanAllStimBase(cond+1,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    min_hist = 0;
    max_hist1 = 1.2 *max(max(meanAllStimBase(cond:cond+1,:)))*1.3;
    xlabel('Stim#');
    ylabel('Baseline spike freq. (Hz)');
    set(ax,'XLim',[0.8 numel(baseStim)+0.2],'FontSize',fs);
%     set(gca,'FontSize',fs, 'XTickLabel',{'1','2', '3','4','5','6'},'XTick',[1 2 3 4 5 6]);
    set(ax,'xtick',[1:1:numel(baseStim)]) % set major ticks
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig3{(cond+1)/2});
    background = get(gcf, 'color');
    h1 = line([1.7 4.3],[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    errorbar((1:numel(baseStim)),meanAllStimBase(cond,:),STEMallStimBase(cond,:), 'Color', C(1,:)); hold on
    errorbar((1:numel(baseStim)),meanAllStimBase(cond+1,:),STEMallStimBase(cond+1,:), 'Color', C(2,:)); hold on
    
    for stim = 1:totalStim
        p_temp =  pAllStimBase((cond+1)/2,stim,2);
        y = max(meanAllStimBase(cond:cond+1,stim)+STEMallStimBase(cond:cond+1,stim));
%         text(stim, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
        if p_temp <= 0.001
            text(stim, y+0.1*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(stim, y+0.1*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(stim, y+0.1*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        end
    end    
    if saveFigs == true
        savefig(strcat(savePath, saveFig3{(cond+1)/2}));
    end
end

%% Analysis Fig. 4 (2x) - Normalized baseline to the first stim value

% normalize baseline to first stim (before photostim) in each condition 
normAllStimBase = nan(totalConds, totalUnits, totalStim);
allStimBaseNormTrace = nan(totalConds, totalUnits, numel(baseStim));

for cond = 1:totalConds
    for unit = find(iUnitsFilt)
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

%% Fig. 4 (2x) : Average normalized baseline 
if totalStim == 6
    titleFig4 = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
        'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};
    
    saveFig4 = {'meanNormBaseline100.fig','meanNormBaseline0.fig'};
elseif totalStim ==1
    titleFig4 = {'Normalized baseline 100% visual stim. vs 100% visual + photostim. all cells',...
    'Normalized baseline 50% visual stim. vs 50% visual + photostim. all cells norm', ...
    'Normalized baseline 25% visual stim. vs 25% visual + photostim. all cells norm', ...
    'Normalized baseline 12% visual stim. vs 12% visual + photostim. all cells norm', ...
    'Normalized baseline 0% visual stim. vs 0% visual + photostim. all cells norm'};

    saveFig4 = {'meanNormBaseline100.fig', 'meanNormBaseline50l.fig','meanNormBaseline25.fig','meanNormBaseline12.fig','meanNormBaseline0.fig'};
end
for cond = (1:2:totalConds)
    figure
    ax = gca;
    hold on
    plot((1:numel(baseStim)),meanNormAllStimBase(cond,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:numel(baseStim)),meanNormAllStimBase(cond+1,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    
%     min_hist = -1;
    max_hist1 = 1.5;
    xlabel('Stim#');
    ylabel('Normalized baseline ');
    set(ax,'XLim',[0.8 numel(baseStim)+0.2],'FontSize',fs);
    set(ax,'xtick',[1:1:numel(baseStim)]) % set major ticks
    set(ax, 'TickDir', 'out');
%     set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
%     set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig4{(cond+1)/2});
    background = get(gcf, 'color');

    errorbar((1:numel(baseStim)),meanNormAllStimBase(cond,:),STEMnormAllStimBase(cond,:), 'Color', C(1,:)); hold on
    errorbar((1:numel(baseStim)),meanNormAllStimBase(cond+1,:),STEMnormAllStimBase(cond+1,:), 'Color', C(2,:)); hold on
    for stim = 1:totalStim
        p_temp =  pNormAllStimBase((cond+1)/2,stim,2);
        y = max(meanNormAllStimBase(cond:cond+1,stim)+STEMnormAllStimBase(cond:cond+1,stim));
%         text(stim, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
        if p_temp <= 0.001
            text(stim, y+0.1*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(stim, y+0.1*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(stim, y+0.1*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        end
    end 
    yl=ylim;
    h1 = line([1.7 4.3],[yl(2)*0.99 yl(2)*0.99]);    
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    if saveFigs == true
        savefig(strcat(savePath, saveFig4{(cond+1)/2}));
        title('');
        saveas(gcf, strcat(savePath, saveFig4{(cond+1)/2}(1:end-3), 'png'));
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
%% Fig. 5a (1x) : average amplitude 
if totalStim == 6
    titleFig5a = {'Amplitude 100% visual stim. +/- photostim.',...
        'Amplitude 0% visual stim. +/- photostim.'};
    
    saveFig5a = {'meanAmpl100.fig','meanAmpl0.fig'};
elseif totalStim == 1
    titleFig5a = {'Amplitude 100% visual stim. +/- photostim.',...
    'Amplitude 50% visual stim. +/- photostim.', ...
    'Amplitude 25% visual stim. +/- photostim.', ...
    'Amplitude 12% visual stim. +/- photostim.', ...
    'Amplitude 0% visual stim. +/- photostim.'};

    saveFig5a = {'meanAmpl100.fig', 'meanAmpl50.fig','meanAmpl25.fig','meanAmpl12.fig','meanAmpl0.fig'};
end

for cond = (1:2:totalConds-2)
    figure
    ax = gca;
    hold on
    plot((1:totalStim),meanAllStimAmpl(cond,:),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:totalStim),meanAllStimAmpl(cond+1,:),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
    max_hist1 = 1.2 *max(max(meanAllStimAmpl(cond:cond+1,:)))*1.3;
    xlabel('Stim#');
    ylabel('Amplitude spike freq. (Hz)');
    set(ax,'XLim',[0.8 totalStim+0.2],'FontSize',fs);
    set(ax,'xtick',[1:1:numel(baseStim)]) % set major ticks
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[0 max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig5a{(cond+1)/2},'FontSize',18);
    background = get(gcf, 'color');
    line ([1 10], [0 0], 'Color', [0 0 0]);
    errorbar((1:totalStim),meanAllStimAmpl(cond,:),STEMallStimAmpl(cond,:), 'Color', C(1,:)); hold on
    errorbar((1:totalStim),meanAllStimAmpl(cond+1,:),STEMallStimAmpl(cond+1,:), 'Color', C(2,:)); hold on
    if saveFigs == true
        savefig(strcat(savePath, saveFig5a{(cond+1)/2}));
    end
end
%% Fig. 5b (1x) : average amplitude
if totalStim == 1
    
    titleFig5b = {'Amplitude visual stim. +/- photostim.'};
    
    saveFig5b = {'meanAmpl.fig'};
    
    figure
    ax = gca;
    hold on
    plot((1:totalConds/2),meanAllStimAmpl(1:2:totalConds),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:totalConds/2),meanAllStimAmpl(2:2:totalConds),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
    
    max_hist1 = 1.2 *max(meanAllStimAmpl)*1.3;
    min_hist = 0;
    xlabel('Contrast');
    ylabel('Amplitude spike freq. (Hz)');
    set(ax,'XLim',[0.8 totalConds/2+0.2],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    xticklabels({'100%', '50%', '25%', '12%', '0%'});
    set(ax,'FontSize',fs)
    title(titleFig5b,'FontSize',18);
    background = get(gcf, 'color');
    errorbar((1:totalConds/2),meanAllStimAmpl(1:2:totalConds),STEMallStimAmpl(1:2:totalConds), 'Color', C(1,:)); hold on
    errorbar((1:totalConds/2),meanAllStimAmpl(2:2:totalConds),STEMallStimAmpl(2:2:totalConds), 'Color', C(2,:)); hold on
    for cond = 1:2:totalConds
        p_temp = pAllStimAmpl((cond+1)/2);
        y = max(meanAllStimAmpl(cond:cond+1)+STEMallStimAmpl(cond:cond+1));
        %     text((cond+1)/2, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
        if p_temp <= 0.001
            text((cond+1)/2, y+0.1*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text((cond+1)/2, y+0.1*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text((cond+1)/2, y+0.1*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        end
    end
    if saveFigs == true
        savefig(strcat(savePath, saveFig5b{1}));
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
if totalStim == 1 % Correction for normalization: maybe it can also be applied to P7 ? 
    meanNormAllStimAmpl100 = meanNormAllStimAmpl100 /meanNormAllStimAmpl100 (1);
    normAllStimAmpl100 = normAllStimAmpl100 /meanNormAllStimAmpl100 (1);
end
    
    
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


%% Fig. 6a (5x) : average normalized amplitude

if totalStim == 1
    titleFig6a = {'Normalized amplitude 100% visual stim. +/- photostim.',...
        'Normalized amplitude 50% visual stim. +/- photostim.', ...
        'Normalized amplitude 25% visual stim. +/- photostim.', ...
        'Normalized amplitude 12% visual stim. +/- photostim.', ...
        'Normalized amplitude 0% visual stim. +/- photostim.'};
    
    saveFig6a = {'meanNormAmpl100.fig', 'meanNormAmpl50.fig','meanNormAmpl25.fig','meanNormAmpl12.fig','meanNormAmpl0.fig'};
    
    for cond = (1:2:totalConds)
        figure
        ax = gca;
        hold on
        plot(1,meanNormAllStimAmpl(cond),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
        plot(1,meanNormAllStimAmpl(cond+1),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
        max_hist1 = 1.2 *max(meanNormAllStimAmpl(cond:cond+1))*1.3;
        xlabel('Contrast');
        ylabel('Normalized amplitude');
        set(ax,'XLim',[0.8 1.2],'FontSize',fs);
        set(ax, 'TickDir', 'out');
%         set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
        set(ax,'FontSize',fs)
        title(titleFig6a{(cond+1)/2},'FontSize',18);
        background = get(gcf, 'color');
        errorbar((1),meanNormAllStimAmpl(cond),STEMnormAllStimAmpl(cond), 'Color', C(1,:)); hold on
        errorbar((1),meanNormAllStimAmpl(cond+1),STEMnormAllStimAmpl(cond+1), 'Color', C(2,:)); hold on
        if saveFigs == true
            savefig(strcat(savePath, saveFig6a{(cond+1)/2}));
        end
    end
end

%% Fig. 6b (1x) : average normalized amplitude
if totalStim == 6
    titleFig6b = {'Normalized amplitude to 100% visual stim. without photostim.'};

    saveFig6b = {'meanNormAmplTo100.fig'};
elseif totalStim == 1
    titleFig6b = {'Normalized amplitude to 100% visual stim. without photostim.'};

    saveFig6b = {'meanNormAmplTo100.fig'};
end

cond = 1;
figure

ax = gca;
hold on
if totalStim == 6
    plot((1:totalStim),meanNormAllStimAmpl100(1, :),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:totalStim),meanNormAllStimAmpl100(2, :),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on    
    xlabel('Stim #')
    set(ax,'XLim',[0.8 totalStim+0.2],'FontSize',fs);
    errorbar((1:totalStim),meanNormAllStimAmpl100(1,:),STEMnormAllStimAmpl100(1,:), 'Color', C(1,:)); hold on
    errorbar((1:totalStim),meanNormAllStimAmpl100(2,:),STEMnormAllStimAmpl100(2,:), 'Color', C(2,:)); hold on
    for stim = 1:totalStim
        p_temp =  pNormAllStimAmpl100((cond+1)/2, stim);
        y = max(meanNormAllStimAmpl100(cond:cond+1, stim)+STEMnormAllStimAmpl100(cond:cond+1, stim));
        if p_temp <= 0.001
            text(stim, y+0.05*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(stim, y+0.05*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(stim, y+0.05*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        end
    end  
elseif totalStim == 1
    plot((1:totalConds/2),meanNormAllStimAmpl100(1:2:end, :),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:totalConds/2),meanNormAllStimAmpl100(2:2:end, :),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
    xlabel('Contrast');
    xticks(1:totalConds/2);
    xticklabels({'100%', '50%', '25%', '12%', '0'});
    set(ax,'XLim',[0.8 totalConds/2+0.2],'FontSize',fs);
    errorbar((1:totalConds/2),meanNormAllStimAmpl100(1:2:end, :),STEMnormAllStimAmpl100(1:2:end,:), 'Color', C(1,:)); hold on
    errorbar((1:totalConds/2),meanNormAllStimAmpl100(2:2:end, :),STEMnormAllStimAmpl100(2:2:end,:), 'Color', C(2,:)); hold on
    for cond = 1:2:totalConds
        p_temp =  pNormAllStimAmpl100((cond+1)/2);
        y = max(meanNormAllStimAmpl100(cond:cond+1)+STEMnormAllStimAmpl100(cond:cond+1));
        if p_temp <= 0.001
            text((cond+1)/2, y+0.05*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text((cond+1)/2, y+0.05*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text((cond+1)/2, y+0.05*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        end
    end  
    
end
    max_hist1 = max(max(meanNormAllStimAmpl100))*1.2;
    
    ylabel('Normalized amplitude');
    
    set(ax, 'TickDir', 'out');
%     set(ax,'YLim',[-0.2 max_hist1]);
    set(ax,'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig6b,'FontSize',18);
    background = get(gcf, 'color');

     
if saveFigs == true
    savefig(strcat(savePath, saveFig6b{1}));
    title('');
    saveas(gcf, strcat(savePath, saveFig6b{1}(1:end-3), 'png'));
    
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
%% Fig. 7a - opto-index bar plot with p value for baselines (10x)
if totalStim == 6
    titleFig7a = {'Opto-index 100% visual stim. +/- photostim. Base2',...
        'Opto-index 100% visual stim. +/- photostim. Base3',...
        'Opto-index 100% visual stim. +/- photostim. Base4',...
        'Opto-index 100% visual stim. +/- photostim. Base5',...
        'Opto-index 100% visual stim. +/- photostim. Base6',...
        'Opto-index 0% visual stim. +/- photostim. Base2',...
        'Opto-index 0% visual stim. +/- photostim. Base3',...
        'Opto-index 0% visual stim. +/- photostim. Base4',...
        'Opto-index 0% visual stim. +/- photostim. Base5',...
        'Opto-index 0% visual stim. +/- photostim. Base6'};
    
    saveFig7a = {'OptoindexBarplot100Base2.fig', 'OptoindexBarplot100Base3.fig',...
        'OptoindexBarplot100Base4.fig', 'OptoindexBarplot100Base5.fig',...
        'OptoindexBarplot100Base6.fig',...
        'OptoindexBarplot0Base2.fig', 'OptoindexBarplot0Base3.fig',...
        'OptoindexBarplot0Base4.fig', 'OptoindexBarplot0Base5.fig',...
        'OptoindexBarplot0Base6.fig'};
elseif totalStim == 1
    titleFig7a = {'Opto-index 100% visual stim. +/- photostim. Base2',...
        'Opto-index 100% visual stim. +/- photostim. Base3',...
        'Opto-index 50% visual stim. +/- photostim. Base2',...
        'Opto-index 50% visual stim. +/- photostim. Base3',...
        'Opto-index 25% visual stim. +/- photostim. Base2',...
        'Opto-index 25% visual stim. +/- photostim. Base3',...
        'Opto-index 12% visual stim. +/- photostim. Base2',...
        'Opto-index 12% visual stim. +/- photostim. Base3',...
        'Opto-index 0% visual stim. +/- photostim. Base2',...
        'Opto-index 0% visual stim. +/- photostim. Base3'};
    
    saveFig7a = {'OptoindexBarplot100Base2.fig', 'OptoindexBarplot100Base3.fig',...
        'OptoindexBarplot50Base2.fig', 'OptoindexBarplot50Base3.fig',...
        'OptoindexBarplot25Base2.fig', 'OptoindexBarplot25Base3.fig',...
        'OptoindexBarplot12Base2.fig', 'OptoindexBarplot20Base3.fig',...
        'OptoindexBarplot0Base2.fig', 'OptoindexBarplot0Base3.fig'};
end

for cond = (1:2:totalConds)
    for stim = 2:numel(baseStim)
        figure
        ax = gca;
        hold on
        b = bar((1:totalUnits),sortOIndexAllStimBase((cond+1)/2,:, stim));
%         b = bar((1:totalUnitsFilt),sortOIndexAllStimBase((cond+1)/2,(1:totalUnitsFilt), stim));
        b.FaceColor = 'flat';
        for unit = (1:totalUnitsFilt)%find(iUnitsFilt)
%             b.CData(unit,:) = C_units(indexOIndexAllStimBase((cond+1)/2,unit, stim),:);
            if classUnitsAll(indexOIndexAllStimBase((cond+1)/2,unit, stim)) == 1
                b.CData(unit,:) = [0 1 0];
            elseif classUnitsAll(indexOIndexAllStimBase((cond+1)/2,unit, stim)) == 2
                b.CData(unit,:) = [1 0 0];
            end    
            y = sortOIndexAllStimBase((cond+1)/2,unit, stim);%
            p_temp = pSuaBaseAll((cond+1)/2,indexOIndexAllStimBase((cond+1)/2,unit, stim), stim);
%             text(unit, y+0.1*sign(y), num2str(pSuaBaseAll((cond+1)/2,indexOIndexAllStimBase((cond+1)/2,unit, stim), stim)),'FontSize',5, 'HorizontalAlignment','center');
%             text(unit, y-0.1*sign(y), [num2str(indexOIndexAllStimBase((cond+1)/2,unit, stim)) ',' num2str(spikeClusterDataAll.goodCodes(indexOIndexAllStimBase((cond+1)/2,unit, stim)))] ,'FontSize',5, 'HorizontalAlignment','center');
            if p_temp <= 0.001
                text(unit, y-0.05*sign(y),'***','FontSize',10, 'HorizontalAlignment','center');
            elseif p_temp <= 0.01
                text(unit, y-0.05*sign(y),'**','FontSize',10, 'HorizontalAlignment','center');
            elseif p_temp <= 0.05
                text(unit, y-0.05*sign(y),'*','FontSize',10, 'HorizontalAlignment','center');
            end
        end
        xlabel('Unit no.');
        ylabel('Opto-index');% (B+ph - B-ph)/(B+ph + B-ph)');
        set(ax,'XLim',[0.5 totalUnitsFilt+0.5],'YLim', [-1 1],'FontSize',fs);
        set(ax, 'TickDir', 'out');
        %     % set(ax,'xtick',[]);
        %     % set(gca, 'XColor', 'w');
        set(ax,'FontSize',fs)
        background = get(gcf, 'color');
        title(titleFig7a{(cond+1)/2*(numel(baseStim)-1)+(stim-numel(baseStim))},'FontSize',18);
        if saveFigs == true
            savefig(strcat(savePath, saveFig7a{(cond+1)/2*(numel(baseStim)-1)+(stim-numel(baseStim))}));
        end

    end
end


%% Fig 7b (10x): Opto-index indivdual data points with average and errorbars - comparison baselines between before and during photostim. 
if totalStim ==6
    
    titleFig7b = {'Opto-index 100% visual stim. +/- photostim. Base2',...
        'Opto-index 100% visual stim. +/- photostim. Base3',...
        'Opto-index 100% visual stim. +/- photostim. Base4',...
        'Opto-index 100% visual stim. +/- photostim. Base5',...
        'Opto-index 100% visual stim. +/- photostim. Base6',...
        'Opto-index 0% visual stim. +/- photostim. Base2',...
        'Opto-index 0% visual stim. +/- photostim. Base3',...
        'Opto-index 0% visual stim. +/- photostim. Base4',...
        'Opto-index 0% visual stim. +/- photostim. Base5',...
        'Opto-index 0% visual stim. +/- photostim. Base6'};
    
    saveFig7b = {'OptoindexScatterplot100Base2.fig', 'OptoindexScatterplot100Base3.fig',...
        'OptoindexScatterplot100Base4.fig', 'OptoindexScatterplot100Base5.fig',...
        'OptoindexScatterplot100Base6.fig',...
        'OptoindexScatterplot0Base2.fig', 'OptoindexScatterplot0Base3.fig',...
        'OptoindexScatterplot0Base4.fig', 'OptoindexScatterplot0Base5.fig',...
        'OptoindexScatterplot0Base6.fig'};
elseif totalStim == 1
    titleFig7b = {'Opto-index 100% visual stim. +/- photostim. Base2',...
    'Opto-index 100% visual stim. +/- photostim. Base3',...
    'Opto-index 50% visual stim. +/- photostim. Base2',...
    'Opto-index 50% visual stim. +/- photostim. Base3',...
    'Opto-index 25% visual stim. +/- photostim. Base2',...
    'Opto-index 25% visual stim. +/- photostim. Base3',...
    'Opto-index 12% visual stim. +/- photostim. Base2',...
    'Opto-index 12% visual stim. +/- photostim. Base3',...
    'Opto-index 0% visual stim. +/- photostim. Base2',...
    'Opto-index 0% visual stim. +/- photostim. Base3'};

saveFig7b = {'OptoindexScatterplot100Base2.fig', 'OptoindexScatterplot100Base3.fig',...
    'OptoindexScatterplot50Base2.fig', 'OptoindexScatterplot50Base3.fig',...
    'OptoindexScatterplot25Base2.fig', 'OptoindexScatterplot25Base3.fig',...
    'OptoindexScatterplot12Base2.fig', 'OptoindexScatterplot20Base3.fig',...
    'OptoindexScatterplot0Base2.fig', 'OptoindexScatterplot0Base3.fig'};
end

for cond = (1:2:totalConds)
    for stim =2:numel(baseStim)
        figure
        ax = gca;
        hold on            
        for unit = 1:totalUnits
            plot(1, OIndexAllStimBase((cond+1)/2,unit, stim), 'Marker','o','MarkerSize',20,'Color', C_units(unit,:));
        end
        scatter((1.1), meanOIndexAllStimBase((cond+1)/2, stim), 200, '+', 'k', 'LineWidth', 2); hold on
        
        ylabel('Opto-index','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'XLim',[0.8 1.2],'YLim', [-1 1],'FontSize',24);
        title(titleFig7b{(cond+1)/2*(numel(baseStim)-1)+(stim-numel(baseStim))},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
        errorbar((1.1),meanOIndexAllStimBase((cond+1)/2, stim),STEMOIndexAllStimBase((cond+1)/2, stim),'.k','LineWidth',2);
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig7b{(cond+1)/2*(numel(baseStim)-1)+(stim-numel(baseStim))}));
        end
    end
end
%% Fig 7d (10x): Opto-index indivdual data points with average and errorbars - comparison baselines between before and during photostim. 
% as 7b, but markers for each cell type

titleFig7d = {'Opto-index 100% visual stim. +/- photostim. Base2',...
    'Opto-index 100% visual stim. +/- photostim. Base3',...
    'Opto-index 100% visual stim. +/- photostim. Base4',...
    'Opto-index 100% visual stim. +/- photostim. Base5',...
    'Opto-index 100% visual stim. +/- photostim. Base6',...
    'Opto-index 0% visual stim. +/- photostim. Base2',...
    'Opto-index 0% visual stim. +/- photostim. Base3',...
    'Opto-index 0% visual stim. +/- photostim. Base4',...
    'Opto-index 0% visual stim. +/- photostim. Base5',...
    'Opto-index 0% visual stim. +/- photostim. Base6'};

saveFig7d = {'OptoindexScatterplot100Base2Class.fig', 'OptoindexScatterplot100Base3Class.fig',...
    'OptoindexScatterplot100Base4Class.fig', 'OptoindexScatterplot100Base5Class.fig',...
    'OptoindexScatterplot100Base6Class.fig',...
    'OptoindexScatterplot0Base2Class.fig', 'OptoindexScatterplot0Base3Class.fig',...
    'OptoindexScatterplot0Base4Class.fig', 'OptoindexScatterplot0Base5Class.fig',...
    'OptoindexScatterplot0Base6Class.fig'};

for cond = (1:2:totalConds)
    for stim =2:totalStim
        figure
        ax = gca;
        hold on
        % beeswarm graph
        plotSpread(squeeze(OIndexAllStimBase((cond+1)/2,:, stim))','categoryIdx',classUnitsAll,...
            'categoryMarkers',{'^','o'},'categoryColors',{'g','r'},'spreadWidth', 0.2)
        % regular graph
%         for unit = 1:totalUnits
%             if classUnitsAll(unit) == 1
%                 plot(1, OIndexAllStimBase((cond+1)/2,unit, stim), 'Marker','^','MarkerSize',20,'Color', C_units(unit,:));
%             elseif classUnitsAll(unit) == 2
%                 plot(1, OIndexAllStimBase((cond+1)/2,unit, stim), 'Marker','o','MarkerSize',20,'Color', C_units(unit,:));
%             end
%             text(0.95, OIndexAllStimBase((cond+1)/2,unit, stim), num2str(unit), 'Color', C_units(unit,:), 'FontSize',8, 'HorizontalAlignment','center'); hold on
%         end
        scatter((1.1), meanOIndexAllStimBase((cond+1)/2, stim), 200, '+', 'k', 'LineWidth', 2); hold on
        scatter((1.15), meanOIndexAllStimBaseExc((cond+1)/2, stim), 200, '+', 'g', 'LineWidth', 2); hold on
        scatter((1.15), meanOIndexAllStimBaseInh((cond+1)/2, stim), 200, '+', 'r', 'LineWidth', 2); hold on     
        
        ylabel('Opto-index','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'XLim',[0.8 1.2],'YLim', [-1 1],'FontSize',24);
        title(titleFig7d{(cond+1)/2*5+(stim-6)},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
        errorbar((1.1),meanOIndexAllStimBase((cond+1)/2, stim),STEMOIndexAllStimBase((cond+1)/2, stim),'.k','LineWidth',2);
        errorbar((1.15),meanOIndexAllStimBaseExc((cond+1)/2, stim),STEMOIndexAllStimBaseExc((cond+1)/2, stim),'.g','LineWidth',2);
        errorbar((1.15),meanOIndexAllStimBaseInh((cond+1)/2, stim),STEMOIndexAllStimBaseInh((cond+1)/2, stim),'.r','LineWidth',2);
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig7d{(cond+1)/2*5+(stim-6)}));
        end
    end
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

%% Fig. 9a - opto-index bar plot with p value for amplitudes
if totalStim ==6
    titleFig9a = {'Opto-index 100% visual stim. +/- photostim. Ampl1',...
        'Opto-index 100% visual stim. +/- photostim. Ampl2',...
        'Opto-index 100% visual stim. +/- photostim. Ampl3',...
        'Opto-index 100% visual stim. +/- photostim. Ampl4',...
        'Opto-index 100% visual stim. +/- photostim. Ampl5',...
        'Opto-index 100% visual stim. +/- photostim. Ampl6'};
    
    saveFig9a = {'OptoindexBarplot100Ampl1.fig','OptoindexBarplot100Ampl2.fig','OptoindexBarplot100Ampl3.fig','OptoindexBarplot100Ampl4.fig','OptoindexBarplot100Ampl5.fig','OptoindexBarplot100Ampl6.fig'};

    cond = 1;
    for stim = (1:totalStim)
        figure
        ax = gca;
        hold on
        b = bar((1:totalUnits),sortOIndexAllStimAmpl((cond+1)/2,:,stim), 'EdgeColor', [0 0 0]);
        b.FaceColor = 'flat';
        for unit = 1:totalUnitsFilt
            %         b.CData(unit,:) = C_units(indexOIndexAllStimAmpl((cond+1)/2,unit,stim),:);
            if classUnitsAll(indexOIndexAllStimAmpl((cond+1)/2,unit,stim)) == 1
                b.CData(unit,:) = [0 1 0];
            elseif classUnitsAll(indexOIndexAllStimAmpl((cond+1)/2,unit,stim)) == 2
                b.CData(unit,:) = [1 0 0];
            end
            y = sortOIndexAllStimAmpl((cond+1)/2,unit,stim);
            p_temp = pSuaAll((cond+1)/2,indexOIndexAllStimAmpl((cond+1)/2,unit,stim), stim);
            %         text(unit, y+0.1*sign(y), num2str(p_temp),'FontSize',5, 'HorizontalAlignment','center');
%             text(unit, y-0.1*sign(y), [num2str(indexOIndexAllStimAmpl((cond+1)/2,unit,stim)) ',' num2str(spikeClusterDataAll.goodCodes(indexOIndexAllStimAmpl((cond+1)/2,unit,stim)))] ,'FontSize',5, 'HorizontalAlignment','center');
            if p_temp <= 0.001
                text(unit, y-0.05*sign(y),'***','FontSize',10, 'HorizontalAlignment','center');
            elseif p_temp <= 0.01
                text(unit, y-0.05*sign(y),'**','FontSize',10, 'HorizontalAlignment','center');
            elseif p_temp <= 0.05
                text(unit, y-0.05*sign(y),'*','FontSize',10, 'HorizontalAlignment','center');
            end
        end
        xlabel('Unit no.');
        ylabel('Opto-index');% (Ampl+ph - Ampl-ph)/(Ampl+ph + Ampl-ph)');
        set(ax,'XLim',[0.5 totalUnitsFilt+0.5],'YLim', [-1 1],'FontSize',fs);
        set(ax, 'TickDir', 'out');
        %     % set(ax,'xtick',[]);
        %     % set(gca, 'XColor', 'w');
        set(ax,'FontSize',fs)
        title(titleFig9a{stim},'FontSize',18);
        background = get(gcf, 'color');
        if saveFigs == true
            savefig(strcat(savePath, saveFig9a{stim}));
        end
        
    end
elseif totalStim ==1
    titleFig9a = {'Opto-index 100% visual stim. +/- photostim.',...
    'Opto-index 50% visual stim. +/- photostim.', ...
    'Opto-index 25% visual stim. +/- photostim.', ...
    'Opto-index 12% visual stim. +/- photostim.', ...
    'Opto-index 0% visual stim. +/- photostim.'};

    saveFig9a = {'OptoindexBarplot100Ampl.fig', 'OptoindexBarplot50Ampl.fig','OptoindexBarplot25Ampl.fig','OptoindexBarplot12Ampl.fig','OptoindexBarplot0Ampl.fig'};
    for cond = (1:2:totalConds-2)
        figure
        ax = gca;
        hold on
        b = bar((1:totalUnits),sortOIndexAllStimAmpl((cond+1)/2,:));
        b.FaceColor = 'flat';
        for unit = 1:totalUnits
            %         b.CData(unit,:) = C_units(indexOIndexAllStimAmpl((cond+1)/2,unit,stim),:);
            if classUnitsAll(indexOIndexAllStimAmpl((cond+1)/2,unit)) == 1
                b.CData(unit,:) = [0 1 0];
            elseif classUnitsAll(indexOIndexAllStimAmpl((cond+1)/2,unit)) == 2
                b.CData(unit,:) = [1 0 0];
            end
            y = sortOIndexAllStimAmpl((cond+1)/2,unit);
            p_temp = pSuaAll((cond+1)/2,indexOIndexAllStimAmpl((cond+1)/2,unit));
            %         text(unit, y+0.1*sign(y), num2str(p_temp),'FontSize',5, 'HorizontalAlignment','center');
%                     text(unit, y-0.1*sign(y), [num2str(indexOIndexAllStimAmpl((cond+1)/2,unit)) ',' num2str(spikeClusterDataAll.goodCodes(indexOIndexAllStimAmpl((cond+1)/2,unit)))] ,'FontSize',5, 'HorizontalAlignment','center');
            if p_temp <= 0.001
                text(unit, y-0.05*sign(y),'***','FontSize',10, 'HorizontalAlignment','center');
            elseif p_temp <= 0.01
                text(unit, y-0.05*sign(y),'**','FontSize',10, 'HorizontalAlignment','center');
            elseif p_temp <= 0.05
                text(unit, y-0.05*sign(y),'*','FontSize',10, 'HorizontalAlignment','center');
            end
        end
        xlabel('Unit no.');
        ylabel('Opto-index');
        set(ax,'XLim',[0.5 totalUnitsFilt+0.5+0.5],'YLim', [-1 1],'FontSize',fs);
        set(ax, 'TickDir', 'out');
        %     % set(ax,'xtick',[]);
        %     % set(gca, 'XColor', 'w');
        set(ax,'FontSize',fs)
            title(titleFig9a{(cond+1)/2},'FontSize',18);
        background = get(gcf, 'color');
        if saveFigs == true
            savefig(strcat(savePath, saveFig9a{(cond+1)/2}));
        end
    end
end
    
%% Fig 9b (5x): Opto-index indivdual data points with average and errorbars - comparison evoked responses between before and during photostim. 

if totalStim ==6
    titleFig9b = {'Opto-index 100% visual stim. +/- photostim. Ampl1',...
        'Opto-index 100% visual stim. +/- photostim. Ampl2',...
        'Opto-index 100% visual stim. +/- photostim. Ampl3',...
        'Opto-index 100% visual stim. +/- photostim. Ampl4',...
        'Opto-index 100% visual stim. +/- photostim. Ampl5',...
        'Opto-index 100% visual stim. +/- photostim. Ampl6'};
    
    saveFig9b = {'OptoindexIndivData100Ampl1.fig', 'OptoindexIndivData100Ampl2.fig','OptoindexIndivData100Ampl3.fig', 'OptoindexIndivData100Ampl4.fig','OptoindexIndivData100Ampl5.fig', 'OptoindexIndivData100Ampl6.fig',};
    
    cond = 1;
    for stim = 1:totalStim
        figure
        ax = gca;
        hold on
        for unit = 1:totalUnits
            plot(1, OIndexAllStimAmpl((cond+1)/2,unit,stim), 'Marker','o','MarkerSize',20,'Color', C_units(unit,:));
        end
        scatter((1.1), meanOIndexAllStimAmpl((cond+1)/2,stim), 200, '+', 'k', 'LineWidth', 2); hold on
        
        ylabel('Opto-index','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'XLim',[0.8 1.2],'YLim', [-1 1],'FontSize',24);
        title(titleFig9b{stim},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
        errorbar((1.1),meanOIndexAllStimAmpl((cond+1)/2,stim),STEMOIndexAllStimAmpl((cond+1)/2,stim),'.k','LineWidth',2);
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig9b{stim}));
        end
    end
elseif totalStim == 1
    titleFig9b = {'Opto-index 100% visual stim. +/- photostim.',...
        'Opto-index 50% visual stim. +/- photostim.', ...
        'Opto-index 25% visual stim. +/- photostim.', ...
        'Opto-index 12% visual stim. +/- photostim.', ...
        'Opto-index 0% visual stim. +/- photostim.'};
    
    saveFig9b = {'OptoindexIndivData100.fig', 'OptoindexIndivData50.fig','OptoindexIndivData25.fig','OptoindexIndivData12.fig','OptoindexIndivData0.fig'};
    
    for cond = (1:2:totalConds)
        figure
        ax = gca;
        hold on
        for unit = 1:totalUnits
            plot(1, OIndexAllStimAmpl((cond+1)/2,unit), 'Marker','o','MarkerSize',20,'Color', C_units(unit,:));
        end
        scatter((1.1), meanOIndexAllStimAmpl((cond+1)/2), 200, '+', 'k', 'LineWidth', 2); hold on
        
        ylabel('Opto-index','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'XLim',[0.8 1.2],'YLim', [-1 1],'FontSize',24);
        title(titleFig9b{(cond+1)/2},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
        errorbar((1.1),meanOIndexAllStimAmpl((cond+1)/2),STEMOIndexAllStimAmpl((cond+1)/2),'.k','LineWidth',2);
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig9b{(cond+1)/2}));
        end
    end
end

%% Analysis Fig. 11, 12 - Opto-index and ratio of baselines in photostim vs non-photostim. conditions, combined conditions and relative to the same trial and cond
% 
% totalUnits = size(allStimBase, 2);
% totalStim = size(allStimBase, 3);

allStimBaseComb = nan(2, totalUnits, numel(baseStim));

allStimBaseComb(1,1:totalUnits,1:numel(baseStim)) = nanmean(allStimBase(1:2:totalConds,:,:),1); % no photostim
allStimBaseComb(2,1:totalUnits,1:numel(baseStim)) = nanmean(allStimBase(2:2:totalConds,:,:),1); % with photostim

thresholdFreq = 0.5; % selection threshold in Hz
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

%% Fig. 11a - opto-index bar plot with p value for combined baselines (5x)
if totalStim ==6
    titleFig11a = {'Opto-index +/- photostim. comb. Base2 vs Base1',...
    'Opto-index +/- photostim. comb. Base3 vs Base1',...
    'Opto-index +/- photostim. comb. Base4 vs Base1',...
    'Opto-index +/- photostim. comb. Base5 vs Base1',...
    'Opto-index +/- photostim. comb. Base6 vs Base1'};

    saveFig11a = {'OptoindexBarplotCombBase2.fig', 'OptoindexBarplotCombBase3.fig',...
    'OptoindexBarplotCombBase4.fig', 'OptoindexBarplotCombBase5.fig',...
    'OptoindexBarplotCombBase6.fig'};
elseif totalStim == 1
    titleFig11a = {'Opto-index +/- photostim. comb. Base2 vs Base1',...
        'Opto-index +/- photostim. comb. Base3 vs Base1'};
    
    saveFig11a = {'OptoindexBarplotCombBase2.fig', 'OptoindexBarplotCombBase3.fig'};
end

cond = 2;
for stim = 2:numel(baseStim)
    figure
    ax = gca;
    hold on
    b = bar((1:totalUnits),sortOIndexAllStimBaseComb(cond,:, stim));
    b.FaceColor = 'flat';
    for unit = 1:totalBaseSelectUnits
        if classUnitsAll(indexOIndexAllStimBaseComb(cond,unit, stim)) == 1
            b.CData(unit,:) = [0 1 0];
        elseif classUnitsAll(indexOIndexAllStimBaseComb(cond,unit, stim)) == 2
            b.CData(unit,:) = [1 0 0];
        end
        y = sortOIndexAllStimBaseComb(cond,unit, stim);%
        p_temp = pSuaBaseCombAll(indexOIndexAllStimBaseComb(cond,unit, stim), stim);
%         text(unit, y+0.1*sign(y), num2str(p_temp),'FontSize',5, 'HorizontalAlignment','center');
%         text(unit, y-0.1*sign(y), [num2str(indexOIndexAllStimBaseComb(cond, unit, stim)) ',' num2str(spikeClusterDataAll.goodCodes(indexOIndexAllStimBaseComb(cond,unit, stim)))] ,'FontSize',5, 'HorizontalAlignment','center');
        if p_temp <= 0.001
            text(unit, y-0.05*sign(y),'***','FontSize',10, 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(unit, y-0.05*sign(y),'**','FontSize',10, 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(unit, y-0.05*sign(y),'*','FontSize',10, 'HorizontalAlignment','center');
        end
    end
    xlabel('Unit no.');
    ylabel('Opto-index');% (B+ph - B-ph)/(B+ph + B-ph)');
    set(ax,'XLim',[0.5 totalBaseSelectUnits+0.5],'YLim', [-1 1],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    %     % set(ax,'xtick',[]);
    %     % set(gca, 'XColor', 'w');
    set(ax,'FontSize',fs)
    title(titleFig11a{stim-1},'FontSize',18);
    background = get(gcf, 'color');
    if saveFigs == true
        savefig(strcat(savePath, saveFig11a{stim-1}));
    end
end
%% Fig 11b (2x): Opto-index indivdual data points with average and errorbars - comparison combined baselines between before and during photostim. 

if totalStim == 1
    titleFig11b = {'Opto-index combined +/- photostim. Base2',...
        'Opto-index combined +/- photostim. Base3'};
    
    saveFig11b = {'OptoindexScatterplotCombBase2.fig', 'OptoindexScatterplotCombBase3.fig'};
    cond = 2;
    for stim =2:3
        figure
        ax = gca;
        hold on
        for unitInd = 1:totalBaseSelectUnits
            unit = baseSelectUnits(unitInd);
            plot(1, OIndexAllStimBaseComb(cond,unit, stim), 'Marker','o','MarkerSize',20,'Color', C_units(baseSelectUnits(unitInd),:));
        end
        scatter((1.1), meanOIndexAllStimBaseComb(cond,stim), 200, '+', 'k', 'LineWidth', 2); hold on
        
        ylabel('Opto-index','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'XLim',[0.8 1.2],'YLim', [-1 1],'FontSize',24);
        title(titleFig11b{stim-1},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        set(gca,'FontSize',24, 'XTickLabel',{'Without photostim.','With photostim.'},'XTick',[1 2]);
        errorbar((1.1),meanOIndexAllStimBaseComb(cond,stim),STEMOIndexAllStimBaseComb(cond, stim),'.k','LineWidth',2);
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig11b{stim-1}));
        end
    end
end
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
    
    % Calculate mean and STEM of the ration of normalized amplitude
    
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
%% Fig. 13a (1x) : average amplitude - baseline
titleFig13a = {'Amplitude - baseline +/- photostim.'};

saveFig13a = {'meanAmplMinusBase.fig'};
if totalStim ==6 
    figure
    ax = gca;
    hold on
    for cond = 1:totalConds-2
        plot((1:totalStim),meanAmplMinusBase(cond,1:totalStim),'Marker','.','LineWidth', 3, 'Color', C(cond,:)); hold on
    end
    max_hist1 = 1.2 *max(max(meanAmplMinusBase))*1.3;
    xlabel('Stim#');
    ylabel('Ampl-base spike freq. (Hz)');
    set(ax,'XLim',[0.8 totalStim+0.2],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    xticks([1:totalStim]);
    set(ax,'YLim',[-0.5 max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig13a,'FontSize',18);
    background = get(gcf, 'color');
    for cond = 1:totalConds-2
        errorbar((1:totalStim),meanAmplMinusBase(cond,1:totalStim),STEMamplMinusBase(cond,1:totalStim), 'Color', C(cond,:)); hold on
    end

elseif totalStim ==1
    figure
    ax = gca;
    hold on
    plot((1:totalConds/2-1),meanAmplMinusBase(1:2:totalConds-2),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:totalConds/2-1),meanAmplMinusBase(2:2:totalConds-2),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
    
    max_hist1 = 1.2 *max(meanAmplMinusBase)*1.3;
    xlabel('Contrast');
    ylabel('Ampl-base spike freq. (Hz)');
    set(ax,'XLim',[0.8 totalConds/2-1+0.2],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    xticklabels({'100%', '50%', '25%', '12%'});
    set(ax,'YLim',[-0.5 max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig13a,'FontSize',18);
    background = get(gcf, 'color');
    errorbar((1:totalConds/2-1),meanAmplMinusBase(1:2:totalConds-2),STEMamplMinusBase(1:2:totalConds-2), 'Color', C(1,:)); hold on
    errorbar((1:totalConds/2-1),meanAmplMinusBase(2:2:totalConds-2),STEMamplMinusBase(2:2:totalConds-2), 'Color', C(2,:)); hold on

end
if saveFigs == true
    savefig(strcat(savePath, saveFig13a{1}));
end

%% Fig. 13c (1x) : average amplitude - baseline on normalized traces
titleFig13c = {'Amplitude - baseline +/- photostim. from norm trace'};

saveFig13c = {'meanAmplMinusBaseNormTrace.fig'};

if totalStim == 6
    figure
    ax = gca;
    hold on
    for cond = 1:totalConds-2
        plot((1:totalStim),meanAmplMinusBaseNormTrace(cond,1:totalStim),'Marker','.','LineWidth', 3, 'Color', C(cond,:)); hold on
    end
    max_hist1 = 1.2 *max(max(meanAmplMinusBaseNormTrace))*1.3;
    xlabel('Stim#');
    ylabel('Amplitude-baseline spike freq. (Hz)');
    set(ax,'XLim',[0.8 totalStim+0.2],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[-2.5 max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig13a,'FontSize',18);
    background = get(gcf, 'color');
    for cond= 1:totalConds-2
        errorbar((1:totalStim),meanAmplMinusBaseNormTrace(cond,1:totalStim),STEMamplMinusBaseNormTrace(cond,1:totalStim), 'Color', C(cond,:)); hold on
    end

elseif totalStim ==1
    
    figure
    ax = gca;
    hold on
    plot((1:totalConds/2-1),meanAmplMinusBaseNormTrace(1:2:totalConds-2),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:totalConds/2-1),meanAmplMinusBaseNormTrace(2:2:totalConds-2),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
    
    max_hist1 = 1.2 *max(meanAmplMinusBaseNormTrace)*1.3;
    xlabel('Condition (contrast)');
    ylabel('Normalized amplitude-baseline');
    set(ax,'XLim',[0.8 totalConds/2-1+0.2],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[-0.5 max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig13c,'FontSize',18);
    background = get(gcf, 'color');
    errorbar((1:totalConds/2-1),meanAmplMinusBaseNormTrace(1:2:totalConds-2),STEMamplMinusBaseNormTrace(1:2:totalConds-2), 'Color', C(1,:)); hold on
    errorbar((1:totalConds/2-1),meanAmplMinusBaseNormTrace(2:2:totalConds-2),STEMamplMinusBaseNormTrace(2:2:totalConds-2), 'Color', C(2,:)); hold on
end
if saveFigs == true
    savefig(strcat(savePath, saveFig13c{1}));
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

% Normalized amplitude calculations : select first line or the next ones 
normAmplMinusBase100 = allStimAmplNormTrace100 - squeeze(allStimBaseNormTrace100(:,:,3));

%  for cond = 1:totalConds
%     for unit = 1:totalUnits
%         normAmplMinusBase100(cond, unit) = amplMinusBase(cond, unit)/amplMinusBase(1, unit);
%     end
% end

% Calculate mean and STEM of normalized amplitude

meanNormAmplMinusBase100 = nanmean(normAmplMinusBase100,2);
    
for cond = 1:totalConds  
    STEMnormAmplMinusBase100(cond) = nanstd(normAmplMinusBase100(cond,:))/sqrt(sum(~isnan(normAmplMinusBase100(cond,:))));  
end

for cond = (1:2:totalConds)
    [hNormAmplMinusBase100((cond+1)/2), pNormAmplMinusBase100((cond+1)/2)] =ttest(normAmplMinusBase100(cond,:),normAmplMinusBase100(cond+1,:)); % opt vs vis
    [pNormAmplMinusBase100W((cond+1)/2), hNormAmplMinusBase100W((cond+1)/2)] =signrank(normAmplMinusBase100(cond,:),normAmplMinusBase100(cond+1,:)); %  opt vs vis
end
%% Fig. 14a (1x) : average normalized amplitude -baseline
if totalStim == 6
    titleFig14a = {'Normalized amplitude 100% visual stim. +/- photostim.'};
    
    saveFig14a = {'meanNormAmpl100.fig'};
      
    figure
    ax = gca;
    hold on
    for cond = 1:totalConds-2
        plot(1:totalStim,meanNormAmplMinusBase(cond, 1:totalStim),'Marker','.','LineWidth', 3, 'Color', C(cond,:)); hold on
    end
    max_hist1 = 1.2 *max(max(meanNormAmplMinusBase))*1.3;
    xlabel('Contrast');
    ylabel('Normalized amplitude-baseline');
    set(ax,'XLim',[0.8 6.2],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[-1 max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig14a{1},'FontSize',18);
    background = get(gcf, 'color');
    for cond = 1:totalConds-2
        errorbar((1:totalStim),meanNormAmplMinusBase(cond,1:totalStim),STEMnormAmplMinusBase(cond,1:totalStim), 'Color', C(cond,:)); hold on
    end
    if saveFigs == true
        savefig(strcat(savePath, saveFig14a{1}));
    end

elseif totalStim == 1
    titleFig14a = {'Normalized amplitude 100% visual stim. +/- photostim.',...
    'Normalized amplitude 50% visual stim. +/- photostim.', ...
    'Normalized amplitude 25% visual stim. +/- photostim.', ...
    'Normalized amplitude 12% visual stim. +/- photostim.', ...
    'Normalized amplitude 0% visual stim. +/- photostim.'};

    saveFig14a = {'meanNormAmpl100.fig', 'meanNormAmpl50.fig','meanNormAmpl25.fig','meanNormAmpl12.fig','meanNormAmpl0.fig'};

    for cond = (1:2:totalConds-2)
        figure
        ax = gca;
        hold on
        plot(1,meanNormAmplMinusBase(cond),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
        plot(1,meanNormAmplMinusBase(cond+1),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
        max_hist1 = 1.2 *max(meanNormAmplMinusBase(cond:cond+1))*1.3;
        xlabel('Contrast');
        ylabel('Normalized amplitude-baseline');
        set(ax,'XLim',[0.8 1.2],'FontSize',fs);
        set(ax, 'TickDir', 'out');
        set(ax,'YLim',[-1 max_hist1],'FontSize',fs)
        set(ax,'FontSize',fs)
        title(titleFig14a{(cond+1)/2},'FontSize',18);
        background = get(gcf, 'color');
        errorbar((1),meanNormAmplMinusBase(cond),STEMnormAmplMinusBase(cond), 'Color', C(1,:)); hold on
        errorbar((1),meanNormAmplMinusBase(cond+1),STEMnormAmplMinusBase(cond+1), 'Color', C(2,:)); hold on
        if saveFigs == true
            savefig(strcat(savePath, saveFig14a{(cond+1)/2}));
        end
    end
end

%% Fig. 14b (1x) : average normalized amplitude- baseline 
titleFig14b = {'Normalized amplitude to 100% visual stim. without photostim.'};

saveFig14b = {'meanNormAmplTo100.fig'};

figure
ax = gca;
hold on
plot((1:totalConds/2),meanNormAmplMinusBase100(1:2:totalConds),'Marker','.','LineWidth', 3, 'Color', C(1,:)); hold on
plot((1:totalConds/2),meanNormAmplMinusBase100(2:2:totalConds),'Marker','.','LineWidth', 3, 'Color', C(2,:)); hold on
max_hist1 = 1.2 *max(meanNormAmplMinusBase100)*1.3;
min_hist = -0.1;
xlabel('Contrast');
ylabel('Normalized amplitude-baseline');
set(ax,'XLim',[0.8 totalConds/2+0.2],'FontSize',fs);
set(ax, 'TickDir', 'out');
set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
set(ax,'FontSize',fs)
title(titleFig14b,'FontSize',18);
background = get(gcf, 'color');
errorbar((1:totalConds/2),meanNormAmplMinusBase100(1:2:totalConds),STEMnormAmplMinusBase100(1:2:totalConds), 'Color', C(1,:)); hold on
errorbar((1:totalConds/2),meanNormAmplMinusBase100(2:2:totalConds),STEMnormAmplMinusBase100(2:2:totalConds), 'Color', C(2,:)); hold on
if saveFigs == true
    savefig(strcat(savePath, saveFig14b{1}));
end




%% Analysis Fig16. base1 vs base2, combined - applicable for spont in protocol 7 and protocol 2 
% 

allStimBaseComb(1,:,:) = nanmean(allStimBase(1:2:end, :, :), 1);
allStimBaseComb(2,:,:) = nanmean(allStimBase(2:2:end, :, :), 1);


%% Figure 16a base1 vs base2 combined
if totalStim == 1
    titleFig16a = {'Base1 vs base2 no photostim', 'Base1 vs base2 with photostim'};
    
    saveFig16a = {'Base1base2NoPh.fig', 'Base1base2Ph.fig'};
    
    for cond=1:2 % 1= non-photostimulated combined baselines; 2= non-photostimulated combined baselines
        figure;
        ax=axes;
        for unit = 1:size(allStimBaseComb,2)
            plot(allStimBaseComb(cond, unit,1), allStimBaseComb(cond, unit,2), 'Marker','o','MarkerSize',20,'Color', C_units(unit,:)); hold on
            text(allStimBaseComb(cond, unit,1), allStimBaseComb(cond, unit,2), num2str(unit), 'Color', C_units(unit,:), 'FontSize',10, 'HorizontalAlignment','center');  hold on
        end
        idx = isnan(allStimBaseComb(cond, :,1)) | isnan(allStimBaseComb(cond, :,2));
        fitline1 = fit(squeeze(allStimBaseComb(cond, ~idx,1))', squeeze(allStimBaseComb(cond, ~idx,2))', 'poly1');
        plot(fitline1);
        coeffs1(cond,:) = coeffvalues(fitline1);
        legend off
        xlabel('Base 1 spike freq. [Hz]','FontSize',24);
        ylabel('Base 2 spike freq [Hz]','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'FontSize',24);
        title(titleFig16a{cond},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        lim = max(max(max(allStimBaseComb(cond, :,1:2))));
        text(lim*0.5, lim*0.95, [num2str(round(coeffs1(cond,1),2)),'*x + ',num2str(round(coeffs1(cond,2),2)) ] ,'FontSize',10, 'HorizontalAlignment','center');
        h1 = line([0 lim],[0 lim]); % diagonal line
        set(h1, 'Color','k','LineWidth',1, 'LineStyle', '--')% Set properties of lines
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig16a{cond}));
        end
    end
end    
%% Figure 16b base2 vs base3 combined
if totalStim == 1
    titleFig16b = {'Base2 vs base3 no photostim', 'Base2 vs base3 with photostim'};
    
    saveFig16b = {'Base2base3NoPh.fig', 'Base2base3Ph.fig'};
    
    for cond=1:2% 1= non-photostimulated combined baselines; 2= non-photostimulated combined baselines
        figure;
        ax=axes;
        for unit = 1:size(allStimBaseComb,2)
            plot(allStimBaseComb(cond, unit,2), allStimBaseComb(cond, unit,3), 'LineStyle', 'none', 'Marker','o','MarkerSize',20,'Color', C_units(unit,:)); hold on
            text(allStimBaseComb(cond, unit,2), allStimBaseComb(cond, unit,3), num2str(unit),'Color', C_units(unit,:), 'FontSize',10, 'HorizontalAlignment','center');
        end
        idx = isnan(allStimBaseComb(cond, :,2)) | isnan(allStimBaseComb(cond, :,3));
        fitline2 = fit(squeeze(allStimBaseComb(cond, ~idx,2))', squeeze(allStimBaseComb(cond, ~idx,3))', 'poly1');
        plot(fitline2);
        coeffs2(cond,:) = coeffvalues(fitline2);
        legend off
        xlabel('Base 2 spike freq. [Hz]','FontSize',24);
        ylabel('Base 3 spike freq [Hz]','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'FontSize',24);
        title(titleFig16b{cond},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        lim = max(max(max(allStimBaseComb(cond, :,2:3))));
        text(lim*0.5, lim*0.95, [num2str(round(coeffs2(cond,1),2)),'*x + ',num2str(round(coeffs2(cond,2),2)) ] ,'FontSize',10, 'HorizontalAlignment','center');
        h1 = line([0 lim],[0 lim]); % diagonal line
        set(h1, 'Color','k','LineWidth',1, 'LineStyle', '--')% Set properties of lines
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig16b{cond}));
        end
    end
end
%% Figure 16c base1 vs base3 combined
if totalStim == 1
    titleFig16c = {'Base1 vs base3 no photostim', 'Base1 vs base3 with photostim'};
    
    saveFig16c = {'Base1base3NoPh.fig', 'Base1base3Ph.fig'};
    
    for cond =1:2 % 1= non-photostimulated combined baselines; 2= non-photostimulated combined baselines
        figure;
        ax=axes;
        for unit = 1:size(allStimBaseComb,2)
            plot(allStimBaseComb(cond, unit,1), allStimBaseComb(cond, unit,3), 'LineStyle', 'none', 'Marker','o','MarkerSize',20,'Color', C_units(unit,:)); hold on
            text(allStimBaseComb(cond, unit,1), allStimBaseComb(cond, unit,3), num2str(unit) ,'FontSize',10, 'Color', C_units(unit,:), 'HorizontalAlignment','center');
        end
        idx = isnan(allStimBaseComb(cond, :,1)) | isnan(allStimBaseComb(cond, :,3));
        fitline3 = fit(squeeze(allStimBaseComb(cond, ~idx,1))', squeeze(allStimBaseComb(cond, ~idx,3))', 'poly1');
        plot(fitline3);
        coeffs3(cond,:) = coeffvalues(fitline3);
        legend off
        xlabel('Base 1 spike freq. [Hz]','FontSize',24);
        ylabel('Base 3 spike freq [Hz]','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'FontSize',24);
        title(titleFig16c{cond},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        lim = max(max(max(allStimBaseComb(cond, :,:))));
        text(lim*0.5, lim*0.95, [num2str(round(coeffs3(cond,1),2)),'*x + ',num2str(round(coeffs3(cond,2),2)) ] ,'FontSize',10, 'HorizontalAlignment','center');
        h1 = line([0 lim],[0 lim]); % diagonal line
        set(h1, 'Color','k','LineWidth',1, 'LineStyle', '--')% Set properties of lines
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig16c{cond}));
        end
    end
end    
%% Figure 16d base1 vs base4 
if totalStim == 6
    titleFig16d = {'Base1 vs base4 100% no photostim', 'Base1 vs base4 100% with photostim',...
        'Base1 vs base4 0% no photostim','Base1 vs base4 0% with photostim'};
    
    saveFig16d = {'Base1base4NoPh100.fig', 'Base1base4Ph100.fig',...
        'Base1base4NoPh0.fig', 'Base1base4Ph0.fig'};
    
    for cond =1:totalConds % 1= non-photostimulated combined baselines; 2= non-photostimulated combined baselines
        figure;
        ax=axes;
        for unit = 1:size(allStimBase,2)
            plot(allStimBase(cond, unit,1), allStimBase(cond, unit,4), 'LineStyle', 'none', 'Marker','o','MarkerSize',20,'Color', C_units(unit,:)); hold on
            text(allStimBase(cond, unit,1), allStimBase(cond, unit,4), num2str(unit) ,'FontSize',10, 'Color', C_units(unit,:), 'HorizontalAlignment','center');
        end
        idx = isnan(allStimBase(cond, :,1)) | isnan(allStimBase(cond, :,4));
        fitline4 = fit(squeeze(allStimBase(cond, ~idx,1))', squeeze(allStimBase(cond, ~idx,4))', 'poly1');
        plot(fitline4);
        coeffs4(cond,:) = coeffvalues(fitline4);
        legend off
        xlabel('Base 1 spike freq. [Hz]','FontSize',24);
        ylabel('Base 4 spike freq [Hz]','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'FontSize',24);
        title(titleFig16d{cond},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        lim = max(max(max(allStimBase(cond, :,:))));
        text(lim*0.5, lim*0.95, [num2str(round(coeffs4(cond,1),2)),'*x + ',num2str(round(coeffs4(cond,2),2)) ] ,'FontSize',10, 'HorizontalAlignment','center');
        h1 = line([0 lim],[0 lim]); % diagonal line
        set(h1, 'Color','k','LineWidth',1, 'LineStyle', '--')% Set properties of lines
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig16d{cond}));
        end
    end
end    
%% Figure 16e base1 vs base4 
if totalStim == 6
    titleFig16e = {'Base1 vs base4 100% no photostim', 'Base1 vs base4 100% with photostim',...
        'Base1 vs base4 0% no photostim','Base1 vs base4 0% with photostim'};
    
    saveFig16e = {'Base1base4NoPh100_1.fig', 'Base1base4Ph100_1.fig',...
        'Base1base4NoPh0_1.fig', 'Base1base4Ph0_1.fig'};
    
    for cond =1:totalConds
        figure;
        ax=axes;
        for unit = 1:size(allStimBase,2)
            if classUnitsAll(unit) == 1
                plot((1:2),[allStimBase(cond, unit,1), allStimBase(cond, unit,4)], 'LineStyle', '-', 'Marker','^','MarkerSize',20,'Color','g'); hold on
            elseif classUnitsAll(unit) == 2
                plot((1:2),[allStimBase(cond, unit,1), allStimBase(cond, unit,4)], 'LineStyle', '-', 'Marker','o','MarkerSize',20,'Color','r'); hold on
            end
            text(2.2, allStimBase(cond, unit,4), num2str(unit) ,'FontSize',10, 'Color', C_units(unit,:), 'HorizontalAlignment','center');
        end
        
        legend off
        set(gca, 'XTick', 1:2, 'XTickLabels', {'Base1', 'Base4'});
        %     set(gca, 'YScale', 'log');
        xlim([0 3]);
        ylabel('Spike freq [Hz]','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'FontSize',24);
        title(titleFig16e{cond},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig16e{cond}));
        end
    end
end

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
%% Fig. 17 : average combined baseline frequency
if totalStim == 1
    titleFig17 = {'Combined Baseline frequency no photostim. vs photostim. all cells'};
    
    saveFig17 = {'meanBaselineComb.fig'};
    
    figure
    ax = gca;
    hold on
    plot((1:numel(baseStim)),meanAllStimBaseComb(1,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:numel(baseStim)),meanAllStimBaseComb(2,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    min_hist = 0;
    max_hist1 = 1.2 *max(max(meanAllStimBaseComb))*1.3;
    % xlabel('Stim#');
    ylabel('Baseline spike freq. (Hz)');
    set(ax,'XLim',[0.8 3.2],'FontSize',fs);
    set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'xtick',[1:1:numel(baseStim)]) % set major ticks
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig17);
    background = get(gcf, 'color');
    h1 = line([1.7 3.3],[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    errorbar((1:numel(baseStim)),meanAllStimBaseComb(1,:),STEMallStimBaseComb(1,:), 'Color', C(1,:)); hold on
    errorbar((1:numel(baseStim)),meanAllStimBaseComb(2,:),STEMallStimBaseComb(2,:), 'Color', C(2,:)); hold on
    
    for stim = 1:totalStim
        p_temp =  pAllStimBaseComb(stim,2);
        y = max(meanAllStimBaseComb(:,stim)+STEMallStimBaseComb(:,stim));
        %     text((cond+1)/2, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
        if p_temp <= 0.001
            text(stim, y+0.1*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(stim, y+0.1*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(stim, y+0.1*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        end
    end
    if saveFigs == true
        savefig(strcat(savePath, saveFig17{1}));
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
%% Fig. 18 : Average normalized combined baseline 
if totalStim == 1
    titleFig18 = {'Normalized combined baselineno photostim. vs with photostim.'};
    
    saveFig18 = {'meanNormBaselineComb.fig'};
    
    figure
    ax = gca;
    hold on
    plot((1:numel(baseStim)),meanNormAllStimBaseComb(1,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((1:numel(baseStim)),meanNormAllStimBaseComb(2,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    
    min_hist = 0;
    max_hist1 = 1.2 *max(max(meanNormAllStimBaseComb))*1.3;
    xlabel('Stim#');
    ylabel('Normalized baseline ');
    set(ax,'XLim',[0.8 3.2],'FontSize',fs);
    set(ax,'xtick',[1:1:numel(baseStim)]) % set major ticks
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(gca,'FontSize',fs, 'XTickLabel',{'Base. 1','Base. 2', 'Base. 3'},'XTick',[1 2 3]);
    set(ax,'FontSize',fs)
    title(titleFig18);
    background = get(gcf, 'color');
    h1 = line([1.7 3.3],[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    errorbar((1:numel(baseStim)),meanNormAllStimBaseComb(1,:),STEMnormAllStimBaseComb(1,:), 'Color', C(1,:)); hold on
    errorbar((1:numel(baseStim)),meanNormAllStimBaseComb(2,:),STEMnormAllStimBaseComb(2,:), 'Color', C(2,:)); hold on
    for stim = 1:numel(baseStim)
        p_temp =  pNormAllStimBaseComb(stim,2);
        y = max(meanNormAllStimBaseComb(:,stim)+STEMnormAllStimBaseComb(:,stim));
        %     text((cond+1)/2, y+0.5*sign(y), num2str(p_temp),'FontSize',8, 'HorizontalAlignment','center');
        if p_temp <= 0.001
            text(stim, y+0.1*sign(y),'***','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.01
            text(stim, y+0.1*sign(y),'**','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        elseif p_temp <= 0.05
            text(stim, y+0.1*sign(y),'*','FontSize',10, 'Color', 'b', 'HorizontalAlignment','center');
        end
    end
    if saveFigs == true
        savefig(strcat(savePath, saveFig18{1}));
    end
end    


%% Figure 19a ampl1 vs ampl4 

if totalStim == 6
    titleFig19a = {'Ampl1 vs ampl4 100% no photostim', 'Ampl1 vs ampl4 100% with photostim'};
    
    saveFig19a = {'Ampl1ampl4NoPh100_1.fig', 'Ampl1ampl4Ph100_1.fig'};
    
    for cond =1:totalConds-2
        figure;
        ax=axes;
        for unit = 1:totalUnits
            if classUnitsAll(unit) == 1
                plot((1:2),[allStimAmpl(cond, unit,1), allStimAmpl(cond, unit,4)], 'LineStyle', '-', 'Marker','^','MarkerSize',20,'Color','g'); hold on
            elseif classUnitsAll(unit) == 2
                plot((1:2),[allStimAmpl(cond, unit,1), allStimAmpl(cond, unit,4)], 'LineStyle', '-', 'Marker','o','MarkerSize',20,'Color','r'); hold on
            end
            text(2.2, allStimAmpl(cond, unit,4), num2str(unit) ,'FontSize',10, 'Color', C_units(unit,:), 'HorizontalAlignment','center');
        end
        
        legend off
        set(gca, 'XTick', 1:2, 'XTickLabels', {'Ampl1', 'Ampl4'});
        set(gca, 'YScale', 'log');
        xlim([0 3]);
        ylabel('Spike freq [Hz]','FontSize',24);
        % set(b,'facecolor',[1 1 1]);
        set(ax,'FontSize',24);
        title(titleFig19a{cond},'FontSize',18);
        background = get(gcf, 'color');
        set(gcf,'color','white'); hold on
        
        box off
        if saveFigs == true
            savefig(strcat(savePath, saveFig19a{cond}));
        end
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
%% Fig 20 (1x): average of time courses - combined contrasts (prev fig 19, short)
if totalStim == 1
    titleFig20 = {'Combined contrasts- with or without photostim. all cells'};
    
    saveFig20 = {'meanTCComb.fig'};
    cond = 1;
    
    figure
    ax = gca;
    hold on
    plot((plotBeg:bin:plotEnd), meanTraceFreqAllComb(cond,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((plotBeg:bin:plotEnd), meanTraceFreqAllComb(cond+1,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    
    max_hist1 = 1.2 * max(max(meanTraceFreqAllComb(cond:cond+1,:)));
    min_hist = 0;
    
    xlabel('Time [sec]');
    ylabel('Average spike freq. (Hz)');
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs);
    title(titleFig20{1});
    h1 = line([0.2 5.2],[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    fact = 0.95;
    x = [4 4.2];
    if cond < totalConds-1
        h2 = line('XData',x,'YData',fact*[max_hist1 max_hist1]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
        set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
    end
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    shadedErrorBar1((plotBeg:bin:plotEnd),meanTraceFreqAllComb(cond,:),STEMtraceFreqAllComb(cond,:), {'Color', C(1,:)}); hold on
    shadedErrorBar1((plotBeg:bin:plotEnd),meanTraceFreqAllComb(cond+1,:),STEMtraceFreqAllComb(cond+1,:), {'Color', C(2,:)}); hold on
    if saveFigs == true
        savefig(strcat(savePath, saveFig20{1}));
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

%% Fig 21 (1x): Norm combined traces to the combined baseline (prev fig 20, short)
if totalStim == 1
    titleFig21 = {'Normalized Combined contrasts to- with or without photostim. all cells'};
    
    saveFig21 = {'meanNormTCComb.fig'};
    
    cond = 1;
    figure
    ax = gca;
    hold on
    plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllComb(cond,:),'LineWidth', 3, 'Color', C(1,:)); hold on
    plot((plotBeg:bin:plotEnd), meanNormTraceFreqAllComb(cond+1,:),'LineWidth', 3, 'Color', C(2,:)); hold on
    
    % max_hist1 = 1.2 * max(max(meanNormTraceFreqAllComb(cond:cond+1,:)));
    max_hist1 = 3;
    min_hist = -0;
    xlabel('Time [sec]');
    ylabel('Norm. average spike freq.');
    set(ax,'XLim',[plotBeg plotEnd],'FontSize',fs);
    set(ax, 'TickDir', 'out');
    set(ax,'YLim',[min_hist max_hist1],'FontSize',fs)
    set(ax,'FontSize',fs)
    title(titleFig21{1});
    h1 = line([0.2 5.2],[max_hist1 max_hist1]);
    set(h1,'Color',[0.25 0.61 1] ,'LineWidth',4);% Set properties of lines
    fact = 0.95;
    x = [4 4.2];
    if cond < totalConds-1
        h2 = line('XData',x,'YData',fact*[max_hist1 max_hist1]); %line([-2.4 -2.2],[fact*max_hist2 fact*max_hist2]);
        set(h2,'Color',[0.25 0.25 0.25] ,'LineWidth',4);% Set properties of lines
    end
    set(gca,'children',flipud(get(gca,'children')))% The order of the "children" of the plot determines which one appears on top. Need to flip it here.
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAllComb(cond,:),STEMnormTraceFreqAllComb(cond,:), {'Color', C(1,:)}); hold on
    shadedErrorBar1((plotBeg:bin:plotEnd),meanNormTraceFreqAllComb(cond+1,:),STEMnormTraceFreqAllComb(cond+1,:), {'Color', C(2,:)}); hold on
    if saveFigs == true
        savefig(strcat(savePath, saveFig21{1}));
    end
end