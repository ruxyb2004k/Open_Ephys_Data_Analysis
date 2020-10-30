%%% Code created by RB on 13.10.2020 %%%

% Example 1 - modify during load_command_A1

% experimentName = '2020-07-21_14-57-33'
% sessionName = 'V1_20200721_1'


animal.name = '20200716_LV1';
animal.sex = 'm';
animal.strain = 'PvCre';
animal.virus = 'AAV9-mOp2A';
recRegion = 'LV1';


sessionInfo.animal = animal;
sessionInfo.recRegion = recRegion;

sessionInfo = rmfield(sessionInfo,'spontActInterval');
sessionInfo = rmfield(sessionInfo,'evokedActInterval');

%% Example 2: Add extra fields to structures
clear all

load('allExp.mat')
expSet = allExp; % select experiment set

numFilt = 10; % max number filters
filt = true(numFilt,size(expSet,2)); 
%%
%%%%%%% add filter here %%%%%%%

% filt(1,:) = [expSet.trialDuration] == 18;
% filt(2,:) = strcmp({expSet.animalStrain}, 'PvCre');
% filt(3,:) = strcmp({expSet.experimentName}, '2020-08-11_15-44-59');
% filt(4,:) = contains({expSet.experimentName}, '2020-08-06') | contains({expSet.experimentName}, '2020-08-07');
% filt(5,:) = contains({expSet.animalName}, '20200730') | contains({expSet.animalName}, '20200805');
filt(6,:) = [repelem(1,71), repelem(0,2)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
combinedFilter = sum(filt,1) == numFilt;
expSetFilt = expSet(combinedFilter); 
%%
for i =1:(size(expSetFilt,2))
    clearvars sessionInfo timeSeries spikeClusterData clusterTimeSeries cellMetrics...
        filenameSessionInfo filenameTimeSeries filenameSpikeClusterData filenameClusterTimeSeries filenameCellMetrics
    
    experimentName = expSetFilt(i).experimentName
    sessionName = expSetFilt(i).sessionName;
    
    path = strsplit(pwd,filesep);
    basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
    basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);
    
%     filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session
%     filenameTimeSeries = fullfile(basePathMatlab,[sessionName,'.timeSeries.mat']); % time series info
    filenameSpikeClusterData = fullfile(basePathMatlab,[sessionName,'.spikeClusterData.mat']); % general info about the session
    filenameClusterTimeSeries = fullfile(basePathMatlab,[sessionName,'.clusterTimeSeries.mat']); % cluster time series 
%     filenameCellMetrics = fullfile(basePathMatlab,[sessionName,'.cellMetrics.mat']); % spike cluster data
    
    % try to load structures 
%     [sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
%     [timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries);
    [spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);
    [clusterTimeSeries, CTSexist] = tryLoad('clusterTimeSeries', filenameClusterTimeSeries);
%     [cellMetrics, CMexist] = tryLoad('cellMetrics', filenameCellMetrics);
   
   
    % insert here what to modify   
    % example 2a
%     bin = clusterTimeSeries.bin;
%     if sessionInfo.trialDuration == 18 % protocol 7
%         stimTime = round((sessionInfo.visStim+sessionInfo.preTrialTime)/bin+1)%[17 32 47 62 77 92];
%         baseTime = round((sessionInfo.visStim+sessionInfo.preTrialTime-1)/bin+1)%[12, 27, 42, 57, 72, 87];
%     elseif sessionInfo.trialDuration == 6 % protocol 2
%         stimTime = round((sessionInfo.visStim+sessionInfo.preTrialTime)/bin+1)%[31];
%         baseTime = round(([-1,0.2,sessionInfo.visStim(1)-1]+sessionInfo.preTrialTime)/bin+1)%[6, 12, 26];
%     end
% 
%     clusterTimeSeries.stimTime = stimTime;
%     clusterTimeSeries.baseTime = baseTime;
%     % save file
%     save(filenameClusterTimeSeries, 'clusterTimeSeries')
    
    % example 2b    
%     sessionInfo.chOffset = 0;
%     sessionInfo.nShanks = 1;
%     save(filenameSessionInfo, 'sessionInfo')
    
    % example 2c

    clusterTimeSeries.selectedCodesDepth = spikeClusterData.uniqueCodesRealDepth(ismember(spikeClusterData.uniqueCodes(:,1), clusterTimeSeries.selectedCodes));
    clusterTimeSeries.selectedCodesDepthMua = spikeClusterData.uniqueCodesRealDepth(ismember(spikeClusterData.uniqueCodes(:,1), clusterTimeSeries.selectedCodesMua));

    save(filenameClusterTimeSeries, 'clusterTimeSeries')
    
end    