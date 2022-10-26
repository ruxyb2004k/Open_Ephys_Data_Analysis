%%% Data visualization of cells from multiple experiments %%%
%%% additionally contains lfp anaylsis in comparison to the previous version
clear all

load('allExp.mat')
expSet = allExp; % select experiment set

numFilt = 10; % max number filters
filt = true(numFilt,size(expSet,2)); 

%%%%%%% add filter here %%%%%%%

filt(1,:) = [expSet.trialDuration] == 18; % Protocol type
% filt(2,:) = strcmp({expSet.animalStrain}, 'NexCre'); % mouse line
filt(2,:) = strcmp({expSet.animalStrain}, 'PvCre') |strcmp({expSet.animalStrain}, 'PvCre') ; % mouse line
% filt(3,:) = strcmp({expSet.experimentName}, '2020-08-11_15-44-59');
% filt(4,:) = ~(contains({expSet.experimentName}, '2020-11-12_14-20-47') | contains({expSet.experimentName}, '2020-12-01_13-58-50') | contains({expSet.experimentName},'2020-12-03_14-41-44'));
% filt(5,:) = contains({expSet.animalName}, '20200730') | contains({expSet.animalName}, '20200805');
% filt(6,:) = datetime({expSet.experimentName}, 'InputFormat','yyyy-MM-dd_HH-mm-ss')>datetime(2021,09,09); % exclude experiments before a certain date (yyyy, MM, dd)
filt(7,:) = [expSet.expSel1] == 1; % first experiment selection
filt(8,:) = [expSet.expSel2] == 1; % 2nd experiment selection
filt(9,:) = [expSet.expSel3] == 1; % 3rd experiment selection


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

combinedFilter = sum(filt,1) == numFilt;
expSetFilt = expSet(combinedFilter); % apply filters to the experiment set
disp(['Experiments to be analyzed: ', num2str(size(expSetFilt,2))]);

allExpNo
%% Data loading
% add real animal names
for i =1:(size(expSetFilt,2))
    expSetFilt(i).animalID = expSetFilt(i).animalName(1:end-4);
end    
% expSetFilt = orderfields(expSetFilt,[1:3,9,4:8]); % reorder fields in structure
expSetFilt = orderfields(expSetFilt,[1:3,10,4:9]); % reorder fields in structure

% create structures with experiment info for each unit
fields = fieldnames(expSetFilt);
c = cell(length(fields),1);
expSetFiltSua = cell2struct(c,fields); % no. rows = no. units
expSetFiltMua = cell2struct(c,fields); % no. rows = no. units

% import experiments from the experiment set list
path = strsplit(pwd,filesep);

realDepthAll = [];
realDepthChannelAll = [];
if std([expSetFilt.trialDuration])% if all elements (protocols) ar different
    allProt=1;
else % if all elements (protocols) are the same
    allProt=0;
end    

% putativeConnections.excitatory = [];
putativeConnectionsTemp = struct('excitatory',{[]},'inhibitory',{[]});
putativeConnections = struct('excitatory',{[]},'inhibitory',{[]});
% Read each experiment
for i =1:(size(expSetFilt,2))
    clearvars sessionInfo timeSeries spikeClusterData clusterTimeSeries cellMetrics orientationMetrics lfp
    
    disp('');
    disp(['Loading experiment ', num2str(i)]);
    experimentName = expSetFilt(i).experimentName
    sessionName = expSetFilt(i).sessionName;
    
    basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
    basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);
    
    filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session
    filenameTimeSeries = fullfile(basePathMatlab,[sessionName,'.timeSeries.mat']); % time series info
    filenameSpikeClusterData = fullfile(basePathMatlab,[sessionName,'.spikeClusterData.mat']); % spike cluster data
    filenameClusterTimeSeries = fullfile(basePathMatlab,[sessionName,'.clusterTimeSeries.mat']); % cluster time series 
    filenameCellMetrics = fullfile(basePathMatlab,[sessionName,'.cellMetrics.mat']); % cell emtrics
    filenameOrientationMetrics = fullfile(basePathMatlab,[sessionName,'.orientationMetrics.mat']); % orientation metrics
    %filenameLFP = fullfile(basePathMatlab,[sessionName,'.lfp1.mat']); % !!! LOAD lfp for NexCre, LFP1 for PvCre

    % try to load structures 
    [sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
    [timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries);
    [spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);
    [clusterTimeSeries, CTSexist] = tryLoad('clusterTimeSeries', filenameClusterTimeSeries);
    [cellMetrics, CMexist] = tryLoad('cellMetrics', filenameCellMetrics);
    [orientationMetrics, OMexist] = tryLoad('orientationMetrics', filenameOrientationMetrics);
%    [lfp, LFPexist] = tryLoad('lfp', filenameLFP);
    
    clusterTimeSeries = adjustStruct(clusterTimeSeries); % add 2 extra fields: iSelectedCodesInd and iSelectedCodesIndSpont   

%     % expand Sua and Mua structures containing experiment information
    currUnitsSua = size(expSetFiltSua,2);
    expSua = size(clusterTimeSeries.traceFreqGood,2);
    expSetFiltSua(currUnitsSua+1:currUnitsSua+expSua) = expSetFilt(i);
    
    % real depth single units
    realDepthAll = [realDepthAll; spikeClusterData.uniqueCodesRealDepth(ismember(spikeClusterData.uniqueCodes(:,1), spikeClusterData.goodCodes))];
    
    % real depth calculation for each channel

    shankDepth = nan(sessionInfo.nChannels, 1);
    spikeClusterData.channelShank = [spikeClusterData.channelShank; zeros(numel(shankDepth)-numel(spikeClusterData.channelShank),1)]; % extend array with 0s for missing channels
    for ch = 1:numel(shankDepth)%spikeClusterData.channelShank)%
        if (spikeClusterData.channelShank(ch))
            shankDepth(ch) = sessionInfo.recordingDepth(spikeClusterData.channelShank(ch));
        else
            spikeClusterData.channelPosition(ch,:) = NaN; % replace position values for missing channels
        end
    end    
    realDepthChannelAll = [realDepthChannelAll; shankDepth(:) + spikeClusterData.channelPosition(:,2)];
    %%% momentary commented out
%     putativeConnections(currUnitsSua+1:currUnitsSua+expSua) = putativeConnectionsTemp;
%     if ~isempty(cellMetrics.putativeConnections.excitatory)
%         for ind = 1:size(cellMetrics.putativeConnections.excitatory,1)
%             unitNo = cellMetrics.putativeConnections.excitatory(ind,1);
%             putativeConnections(currUnitsSua+unitNo).excitatory = [putativeConnections(currUnitsSua+unitNo).excitatory, cellMetrics.putativeConnections.excitatory(ind,2)+currUnitsSua-1];
%         end
%     end   
%     if ~isempty(cellMetrics.putativeConnections.inhibitory)
%         for ind = 1:size(cellMetrics.putativeConnections.inhibitory,1)
%             unitNo = cellMetrics.putativeConnections.inhibitory(ind,1);
%             putativeConnections(currUnitsSua+unitNo).inhibitory = [putativeConnections(currUnitsSua+unitNo).inhibitory, cellMetrics.putativeConnections.inhibitory(ind,2)+currUnitsSua-1];
%         end
%     end  
    %%%%%%%
    currUnitsMua = size(expSetFiltMua,2);
    expMua = size(clusterTimeSeries.traceFreqMuaSel,2);
    expSetFiltMua(currUnitsMua+1:currUnitsMua+expMua) = expSetFilt(i);
    
    % expand the meta-data structures after reading each experiment
    if i == 1
        sessionInfoAll = sessionInfo;
        timeSeriesAll = timeSeries;
        spikeClusterDataAll = spikeClusterData;
        cellMetricsAll = cellMetrics;        
        clusterTimeSeriesAll = clusterTimeSeries; 
        orientationMetricsAll = orientationMetrics;
%        lfpAll = lfp;
%        lfpAll = rmfield(lfpAll, 'data'); % doesn't seem to free memory
%        lfpAll = rmfield(lfpAll, 'timestamps'); % doesn't seem to free memory
    else
        sessionInfoAll = addToStruct(sessionInfo, sessionInfoAll, allProt);
        timeSeriesAll = addToStruct(timeSeries, timeSeriesAll, allProt);
        spikeClusterDataAll = addToStruct(spikeClusterData, spikeClusterDataAll, allProt);
        cellMetricsAll = addToStruct(cellMetrics, cellMetricsAll, allProt);       
        clusterTimeSeriesAll = addToStruct(clusterTimeSeries, clusterTimeSeriesAll, allProt); 
        orientationMetricsAll = [orientationMetricsAll orientationMetrics];
%        lfpAll = addToStruct(lfp, lfpAll, allProt); 
    end    
    
end
sessionInfoAll_backup = sessionInfoAll;

expSetFiltSua(1) = []; % delete empty first row
expSetFiltMua(1) = []; % delete empty first row
putativeConnections(1) = []; % delete empty last row

% extract name and number of experiments
[expNames,~,iEN] = unique({expSetFiltSua.experimentName},'stable');
suaEachExp = accumarray(iEN(:),1,[numel(expNames),1]); % previously called hemisphere
noExps = numel(expNames)

% extract name and number of hemispheres
[hemNames,~,iHN] = unique({expSetFiltSua.animalName},'stable');
suaEachHem = accumarray(iHN(:),1,[numel(hemNames),1]); % previously called hemisphere
noHems = numel(hemNames)

% name and number of animals - equal or different than hemispheres
% animalNames = hemNames;
% noAnimals = numel(animalNames);

% unique animal names
[animalID,~,iAN] = unique({expSetFiltSua.animalID},'stable');
suaEachAnimal = accumarray(iAN(:),1,[numel(animalID),1]); % previously called animals
noAnimals = numel(animalID)

% C = [[0 0 0]; [0 0 1];  [0.7 0.7 0.7]; [0 0.4470 0.7410]; [0 0 0]; [0.5 0.5 0.5]]; % black, navy-blue, grey, light blue, black, dark grey - traces
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
% for i = 1:noAnimals
%     C_units = [C_units; repmat(C_animal(i,:),suaEachAnimal(i),1)];
% end
for i = 1:noHems
    C_units = [C_units; repmat(C_animal(i,:),suaEachHem(i),1)];
end

fs = 24; %font size
fsStars = 24;
smooth_method = 'moving';
EIColor = 'gr';
fC=0.5; % 0.8 for waveforms
EI_Color = [fC,1,fC; 1,fC,fC];

% Analysis for Figs xx - yy -

totalConds = numel(fieldnames(sessionInfoAll.conditionNames)); % number of conditions
totalDatapoints = size(clusterTimeSeriesAll.traceFreqGood,3); % number of data time points
totalStim = numel(clusterTimeSeriesAll.stimTime);

bin = clusterTimeSeriesAll.bin;
corrTimeline = 1;
if corrTimeline == 0
    plotBeg = -sessionInfoAll.preTrialTime + bin;
    plotEnd = sessionInfoAll.trialDuration + sessionInfoAll.afterTrialTime;
else    
    plotBeg = 0 + bin;
    plotEnd = sessionInfoAll.trialDuration + sessionInfoAll.afterTrialTime + sessionInfoAll.preTrialTime;
    sessionInfoAll.visStim = sessionInfoAll_backup.visStim + sessionInfoAll.preTrialTime;
    sessionInfoAll.optStimInterval = sessionInfoAll_backup.optStimInterval+ sessionInfoAll.preTrialTime;
%     sessionInfoAll.preTrialTime = 0;
%     sessionInfoAll.trialDuration = sessionInfoAll.trialDuration + sessionInfoAll.preTrialTime;

end    

waveformDiff % calculates the differential of the waveform and the slope at 0.5 ms after trough
clusterTimeSeriesAll_backup = clusterTimeSeriesAll;
%% 
clusterTimeSeriesAll = clusterTimeSeriesAll_backup;
%%% !!!!! Comment out 2 of the next 3 lines !!!!! %%%
classUnitsAll = ([cellMetricsAll.troughPeakTime]< 0.5) + 1; % subject to change - different criteria; 1 = pyr, 2 = inh
% fClassifyUnits % cluster the data
% fClassifyUnitsCellExplorer
layerAll = (realDepthAll < 0) + (realDepthAll < -100) + (realDepthAll < -320)*2+(realDepthAll < -400); 

%%%%%%%%%%% apply filters to the unit data set here %%%%%%%%%%%%%%%%

iUnitsFilt = repelem(true(1), size(cellMetricsAll.waveformCodes,1)); % all units
iUnitsFilt = iUnitsFilt &  clusterTimeSeriesAll.iSelectedCodesInd == 1; % only selected = 1
iUnitsFilt = iUnitsFilt & clusterTimeSeriesAll.iSelectedCodesIndSpont == 0; % only evoked = 0 or spont = 1
% iUnitsFilt = iUnitsFilt &  classUnitsAll == 2; % only specifiy cell type: 1 = exc, 2 = inh
% iUnitsFilt = iUnitsFilt &  layerAll' == 5; % choose layer between 1, 2, 4 and 5
% iUnitsFilt = iUnitsFilt & OIndexAllStimBase(totalConds/2,:, 4)>0; % run the next section before uncommenting this line
% iUnitsFilt = iUnitsFilt & pSuaBaseAll(totalConds/2,:, 4)<0.05; % run the next section before uncommenting this line

saveFigs = false;
savePath = [strjoin({path{1:end}, 'figs','2022-07',  'NexCre', 'long','evoked', 'inh'}, filesep), filesep];%,  'NexCre', 'long', 'evoked', 'exc'
savePath = [strjoin({path{1:end}, 'figs','2022-02',  'all'}, filesep), filesep];%,  'NexCre', 'long', 'evoked', 'exc'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% , 'Gad2Cre','short', 'evoked'
totalUnits = size(iUnitsFilt,2);
totalUnitsFilt = sum(iUnitsFilt);

disp(['Total units: ', num2str(totalUnitsFilt)]);
disp(['Total excitatory units: ', num2str(sum(classUnitsAll(iUnitsFilt) == 1)), ' = ', num2str(sum(classUnitsAll(iUnitsFilt) == 1)/totalUnitsFilt*100), '%']);
disp(['Total inhibitory units: ', num2str(sum(classUnitsAll(iUnitsFilt) == 2)), ' = ', num2str(sum(classUnitsAll(iUnitsFilt) == 2)/totalUnitsFilt*100), '%']);
disp(['Total wide inhibitory units: ', num2str(sum(classUnitsAll(iUnitsFilt) == 3)), ' = ', num2str(sum(classUnitsAll(iUnitsFilt) == 3)/totalUnitsFilt*100), '%']);

%% Analysis

analyzeBy = 'unit'; %, 'unit', 'exp', 'hem', 'animal'
thresholdFreq = 0.5 % selection threshold in Hz - Figs 2, 4, 11-12, ....
longBase = 1 % choose between 1= long baseline(2 or 3 s) and 0 = short baseline (1 s)
groupData;
applyBonfCorr = 1;
analysis_allExpDataVisualization_A2 % !!!choose between 6a and 6b and possibly other analysis - under construction; fix fig 14 b bug

%% Plot figures

figure1 % ! average of time courses evoked activity 100% contrast and spontaneous activity
figure1b % ! average of time courses evoked activity 100% contrast and spontaneous activity for paper
figure1c % subtr + average of time courses evoked activity 100% contrast and spontaneous activity for paper
figure2 % ! Norm average of time courses evoked activity 100% contrast and spontaneous activity
figure2b % Subtr + Norm average of time courses evoked activity 100% contrast and spontaneous activity
figure2c % ! subplot: Subtr + Norm average of time courses evoked activity 100% contrast and spontaneous activity
figure3 % average baseline frequency 
figure3b % ! Average baseline for stim 4
figure4 % ! Average normalized baseline 
figure4b % ! Average normalized baseline for stim 4
figure5a % average amplitude 
figure5b % average amplitude: if totalStim == 1
figure6a % average normalized amplitude: if totalStim == 1
figure6b % ! average normalized amplitude - all data in one graph in comparison to 6a
figure7a % ! opto-index bar plot with p value for baselines (10x)
figure7b % Opto-index indivdual data points with average and errorbars - comparison baselines between before and during photostim. 
figure7d % Opto-index indivdual data points with average and errorbars - comparison baselines between before and during photostim. as 7b, but markers for each cell type
figure7dx % !Opto-index indivdual data points with average and errorbars - comparison baselines between before and during photostim. as 7b, but markers for each cell type
figure7e % opto-index histocounts for baselines - cell types (10x)
figure7f % OIbase vs depth
figure7g % histograms of opto-index for each cell type and PDFs
figure7gxx % ! thin histograms of opto-index for each cell type and PDFs
figure9a % ! opto-index bar plot with p value for amplitudes
figure9b % Opto-index indivdual data points with average and errorbars - comparison evoked responses between before and during photostim. 
figure9f % OIampl vs depth
figure7g % histograms of Ampl opto-index for each cell type and PDFs
figure11a % ! opto-index bar plot with p value for combined baselines (5x)
figure11b % Opto-index indivdual data points with average and errorbars - comparison combined baselines between before and during photostim.: if totalStim == 1
figure11e % ! histograms of opto-index of combined baselines for each cell type
figure11f % OIbaseComb vs depth
figure11g % histograms of opto-index comb base for each cell type and PDFs
figure13a % average amplitude - baseline
figure13c % average amplitude - baseline on normalized traces
figure14a % average normalized amplitude -baseline
figure14b % average normalized amplitude- baseline 
figure15 % waveforms and their features
figure16a % base1 vs base2 combined: if totalStim == 1
figure16b % base2 vs base3 combined: if totalStim == 1
figure16c % base1 vs base3 combined: if totalStim == 1
figure16d % base1 vs base4: if totalStim == 6
figure16e % base1 vs base4: if totalStim == 6
figure16f % linear model 4 params, base1 vs base 3 
figure16fx % linear model 4 params, base1 vs base 3 - coefficients
figure16g % linear model 4 params, ampl1 vs ampl4 3 
figure16h % linear model 7 params 
figure17 % average combined baseline frequency: if totalStim == 1
figure18 % !Average normalized combined baseline if totalStim == 1
figure19a % ampl1 vs ampl4: if totalStim == 6
figure20 % average of time courses - combined contrasts (prev fig 19, short): if totalStim == 1
figure21 % Norm combined traces to the combined baseline (prev fig 20, short): if totalStim == 1
% figure22 % traces of visual evoked - sponateneous activity
% figure23 % normalized traces of visual evoked - sponateneous activity
figure25ax % ! totalStim = 6; reproduction of fig 5a from eLife 2020 (average of baseline-subtracted and norm traces)
figure25b % ! totalStim = 6; reproduction of fig 5bi from eLife 2020 (average amplitude of normalized and baseline subtr traces)
figure25c % ! totalStim = 6; reproduction of fig 5bii from eLife 2020 (average baseline of normalized and baseline subtr traces)
figure25d % ! totalStim = 6; reproduction of fig 5biii from eLife 2020 (average magnitude of normalized and baseline subtr traces)
figure25dx % ! totalStim = 6; average magnitude of normalized and baseline subtr traces, stims 1 and 4
figure25dxx % ! totalStim = 6; average magnitude of normalized and baseline subtr traces, stim 4
figure25dxxx % ! bar plot of magnitude, related to fig 5biii from eLife 2020, all stims (average magnitude of normalized and baseline subtr traces)
figure25e % ! totalStim = 6; average magnitude of non-normalized traces
figure25ex % ! totalStim = 6; average magnitude of non-normalized traces, stims 1 and 4
figure26ax % ! totalStim = 1; reproduction of fig 8a from eLife 2020 (average of baseline-subtracted and norm traces )
figure26bx % ! totalStim = 1; reproduction of fig 8c from eLife 2020 (average of baseline-subtracted and norm traces to max in their own group )
figure26c % ! totalStim = 1; reproduction of fig 8di(1) from eLife 2020 (average amplitude of normalized and baseline subtr traces)
figure26d % ! totalStim = 1; reproduction of fig 8di(2) from eLife 2020 (average amplitude of normalized and baseline subtr traces)
figure26e % ! totalStim = 1; reproduction of fig 8bi from eLife 2020 (average magnitude of normalized and baseline subtr traces)
figure27a % totalStim = 1; similar to fig 26c, but for each individual unit
figure27b % totalStim = 1; similar to fig 26d, but for each individual unit
figure29a % ! Bar plot, average normalized baseline to same stim in the control condition
figure29b % ! Bar plot, average normalized magnitue to same stim in the control condition
figure30a % ! Bar plot, baseline of the trace that represents the difference of the normalized traces
figure30b % ! Bar plot, magnitude of the trace that represents the difference of the normalized traces
figure30bx % ! Bar plot, difference of magnitude between the normalized traces  (magn =1 and not peak =1)
figure30bxx % ! Thin Bar plot, difference of magnitude between the normalized traces  (magn =1 and not peak =1)
figure30bxxx % ! Line plot, difference of magnitude between the normalized traces  (magn =1 and not peak =1)
figure31a % ! similar to fig 2, but for selected OI
figure31b % ! similar to fig 4b, but for selected OI
figure32bxxx % Plot line, difference of magnitude between the normalized traces, OI sel  (magn =1 and not peak =1)
figure33 % plots the effect of photostim vs the visually evoked response (reproduction of Mohammad's figure
figure50a % % waveforms for the ccg graph 
figure50b % histogram instead of traces of firing rates