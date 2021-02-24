%%%%%% Code created by RB on 08.01.2021 %%%

% k = 0; % for the first experiment, then comment out
clearvars -except k
k=k+1
load('allExp.mat');

expSet = allExp; % select experiment set
numFilt = 10; % max number filters
filt = true(numFilt,size(expSet,2)); 

%%%%%%% add filter here %%%%%%%k=87

% filt(1,:) = [expSet.trialDuration] == 6;
% filt(2,:) = strcmp({expSet.animalStrain}, 'PvCre');
% filt(3,:) = strcmp({expSet.experimentName}, '2020-08-11_15-44-59');
% filt(4,:) = ~(contains({expSet.experimentName}, '2020-11-12_14-20-47') | contains({expSet.experimentName}, '2020-12-01_13-58-50') | contains({expSet.experimentName},'2020-12-03_14-41-44'));
% filt(5,:) = contains({expSet.animalName}, '20200730') | contains({expSet.animalName}, '20200805');
% filt(6,1:71) = 0; % exclude experiments before 29.09.2020
% filt(7,:) = [expSet.expSel1] == 1; % first experiment selection
% filt(8,:) = [expSet.expSel2] == 1; % 2nd experiment selection


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

combinedFilter = sum(filt,1) == numFilt;
expSetFilt = expSet(combinedFilter); % apply filters to the experiment set

experimentName = expSetFilt(k).experimentName
sessionName = expSetFilt(k).sessionName;


%% go through each selected exp and open gui_MonoSyn if there are any selected synaptic connections

clearvars cellMetrics spikeClusterData
k = k+1;

experimentName = expSetFilt(k).experimentName
sessionName = expSetFilt(k).sessionName

path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

filenameCellMetrics = fullfile(basePathMatlab,[sessionName,'.cellMetrics.mat']); % spike cluster data


[cellMetrics, CMexist] = tryLoad('cellMetrics', filenameCellMetrics);

if  ~isempty(cellMetrics.putativeConnections.inhibitory) || ~isempty(cellMetrics.putativeConnections.excitatory)
    filenameSpikeClusterData = fullfile(basePathMatlab,[sessionName,'.spikeClusterData.mat']); % spike cluster data
    [spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);
    if ~isempty(cellMetrics.putativeConnections.excitatory)
        exc_con = spikeClusterData.goodCodes(cellMetrics.putativeConnections.excitatory)
        cellMetrics.troughPeakTime(cellMetrics.putativeConnections.excitatory(:,1))
    end    
    if ~isempty(cellMetrics.putativeConnections.inhibitory)
        inh_con = spikeClusterData.goodCodes(cellMetrics.putativeConnections.inhibitory)
        cellMetrics.troughPeakTime(cellMetrics.putativeConnections.inhibitory(:,1))
    end
    gui_MonoSyn(cellMetrics.mono_res);
    
end

