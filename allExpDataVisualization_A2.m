%%% Data visualization of cells from multiple experiments %%%
clear all

load('allExp.mat')
expSet = allExp; % select experiment set

numFilt = 10; % max number filters
filt = true(numFilt,size(expSet,2)); 

%%%%%%% add filter here %%%%%%%

filt(1,:) = [expSet.trialDuration] == 6;
filt(2,:) = strcmp({expSet.animalStrain}, 'PvCre');
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
iUnitsFilt = iUnitsFilt & clusterTimeSeriesAll.iSelectedCodesIndSpont == 0 ; % only evoked = 0 or spont = 1
% iUnitsFilt = iUnitsFilt &  classUnitsAll == 2; % only specifiy cell type: 1 = pyr, 2 = inh

saveFigs = false;
savePath = [strjoin({path{1:end}, 'figs','2020-12', 'NexCre', 'long', 'spont'}, filesep), filesep];%, 'spont'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
totalUnits = size(iUnitsFilt,2);
totalUnitsFilt = sum(iUnitsFilt);

disp(['Total excitatory units: ', num2str(sum(classUnitsAll(iUnitsFilt) == 1))]);
disp(['Total inhibitory units: ', num2str(sum(classUnitsAll(iUnitsFilt) == 2))]);

%% Analysis

analysis_allExpDataVisualization % choose between 6a and 6b and possibly other analysis - under construction
%% Plot figures

figure1 % average of time courses evoked activity 100% contrast and spontaneous activity
figure2 % Norm average of time courses evoked activity 100% contrast and spontaneous activity
figure3 % average baseline frequency 
figure4 % Average normalized baseline 
figure5a % average amplitude 
figure5b % average amplitude: if totalStim == 1
figure6a % average normalized amplitude: if totalStim == 1
figure6b %  average normalized amplitude - all data in one graph in comparison to 6a
figure7a % opto-index bar plot with p value for baselines (10x)
figure7b % Opto-index indivdual data points with average and errorbars - comparison baselines between before and during photostim. 
figure7d % Opto-index indivdual data points with average and errorbars - comparison baselines between before and during photostim. as 7b, but markers for each cell type
figure9a % opto-index bar plot with p value for amplitudes
figure9b % Opto-index indivdual data points with average and errorbars - comparison evoked responses between before and during photostim. 
figure11a % opto-index bar plot with p value for combined baselines (5x)
figure11b % Opto-index indivdual data points with average and errorbars - comparison combined baselines between before and during photostim.: if totalStim == 1
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
figure17 % average combined baseline frequency: if totalStim == 1
figure18 % Average normalized combined baseline if totalStim == 1
figure19a % ampl1 vs ampl4: if totalStim == 6
figure20 % average of time courses - combined contrasts (prev fig 19, short): if totalStim == 1
figure21 % Norm combined traces to the combined baseline (prev fig 20, short): if totalStim == 1




