%%% Load matlab data from open ephys kwik files. 
%%% modified 13.07.2020 by Ruxandra %%%

% experimentName = '2020-09-23_14-18-30'
% sessionName = 'V1_20200923_1'

clearvars -except experimentName sessionName

path = strsplit(pwd,filesep);
basePath = strjoin({path{1:end-1}, 'Open Ephys Data', experimentName}, filesep);
basePathData = strjoin({basePath, 'data'}, filesep);
basePathKilosort = strjoin({basePath, 'kilosort analysis'}, filesep);
basePathMatlab = strjoin({basePath, 'matlab analysis'}, filesep);

filenameSessionInfo = fullfile(basePathMatlab,[sessionName,'.sessionInfo.mat']); % general info about the session
filenameTimeSeries = fullfile(basePathMatlab,[sessionName,'.timeSeries.mat']); % time series info
filenameSpikeClusterData = fullfile(basePathMatlab,[sessionName,'.spikeClusterData.mat']); % general info about the session

% try to load structures if they don't already exist in the workspace
[sessionInfo, SIexist] = tryLoad('sessionInfo', filenameSessionInfo);
[timeSeries, TSexist] = tryLoad('timeSeries', filenameTimeSeries);
[spikeClusterData, SCDexist] = tryLoad('spikeClusterData', filenameSpikeClusterData);

if ~SCDexist
    
    spikeClusterData.clusterSoftware = 'kilosort';
    spikeClusterData.trialsForAnalysisSelected = timeSeries.trialsForAnalysis;
    
    filename_kilosort1 = fullfile(basePathKilosort,'rez.mat'); % general info about the session    
    load(filename_kilosort1);

    spikeClusterData.times = [];
    spikeClusterData.adjGraph = [];
    spikeClusterData.codes = [];

    spikeClusterData.times = double(readNPY(fullfile(basePathKilosort,'spike_times.npy')))/sessionInfo.rates.wideband; % all spike times in sec
%     spikeClusterData.adjGraph = double(h5readatt(filename_kilosort,'/channel_groups/0','adjacency_graph')); still needed? 
    spikeClusterData.codes = double(readNPY(fullfile(basePathKilosort,'spike_clusters.npy'))); % all spike codes
    spikeClusterData.uniqueCodes(:,1) = unique(spikeClusterData.codes); % ordered list of all codes
    
    spikeClusterData.channelPosition = double(readNPY(fullfile(basePathKilosort,'channel_positions.npy'))); % column 2 is the depth, where 0 is the tip of the electrode and all other channels have positive depths
     
    [~, cl] = readClusterGroupsCSV(fullfile(basePathKilosort,'cluster_KSLabel.tsv')); % spikeClusterData.uniqueCodesLabel is 0(noise), 1(mua) or 2(good)
    spikeClusterData.uniqueCodesLabel = cl';
%     spikeClusterData.uniqueCodes(:,2) = 0;
    spikeClusterData.uniqueCodes(:,2) = rez.iNeighPC(1,:)'-1;
end
warning('Please double-check the channel numbers');
%% verify first in kilosort if the channels fit the cluster codes and insert manually the channel number...

if ~SCDexist
    % ...for each cluster code in 2nd column of spikeClusterData.uniqueCodes, then run the next command
    spikeClusterData.uniqueCodesChannel(:,1) = spikeClusterData.uniqueCodes(:,2);

    % calculate the depth of each cluster based on the channel position
    spikeClusterData.uniqueCodesDepth(:,1) = spikeClusterData.channelPosition(spikeClusterData.uniqueCodesChannel(:,1)+1,2);

    % calculate the depth of each channel based on the recording depth
    spikeClusterData.uniqueCodesRealDepth(:,1) = sessionInfo.recordingDepth + spikeClusterData.uniqueCodesDepth(:,1); 
    
    unclCodes = []; % unclassified codes
    goodCodes = [];
    muaCodes = [];
    noiseCodes = [];

    for i =(1:numel(spikeClusterData.uniqueCodes(:,1)))
        if spikeClusterData.uniqueCodesLabel(i,1) == 3 % 0 = noise, 1= mua, 2= good, 3 = unclassified
            unclCodes(end+1,1) = spikeClusterData.uniqueCodes(i,1);
        elseif spikeClusterData.uniqueCodesLabel(i,1) == 2 % 0 = noise, 1= mua, 2= good, 3 = unclassified
            goodCodes(end+1,1) = spikeClusterData.uniqueCodes(i,1);
        elseif spikeClusterData.uniqueCodesLabel(i,1) == 1 % 0 = noise, 1= mua, 2= good, 3 = unclassified
            muaCodes(end+1,1) = spikeClusterData.uniqueCodes(i,1);
        elseif spikeClusterData.uniqueCodesLabel(i,1) == 0 % 0 = noise, 1= mua, 2= good, 3 = unclassified
            noiseCodes(end+1,1) = spikeClusterData.uniqueCodes(i,1);
        end
    end    
    
    timestampsRange = timeSeries.timestampsRange;
    
    kilosortTime = (0:1:numel(timestampsRange)-1)./sessionInfo.rates.wideband;
    spikeClusterData.rangeTimes = zeros([numel(spikeClusterData.times),1]);
    spikeClusterData.kilosortTime = kilosortTime;
    spikeClusterData.unclCodes = unclCodes;
    spikeClusterData.goodCodes = goodCodes;
    spikeClusterData.muaCodes = muaCodes;
    spikeClusterData.noiseCodes = noiseCodes;
    
    %adjust the spike times from kilosort to the real recording times
    j=1;
    for i=(1:numel(spikeClusterData.times))
        while spikeClusterData.times(i) > kilosortTime(j) % search for each spike time in the the kilosortTime, then take the time index and match it to timestamp index.
            j = j+1;
        end
        spikeClusterData.rangeTimes(i) = timeSeries.timestampsRange(j); % The matched timestamp will be the adjusted spike time
    end
 
end
%%
% modify when selecting different trials than already selected in load_command
% spikeClusterData.trialsForAnalysisSelected = timeSeries.trialsForAnalysis([1:13,15]);

conditionFieldnames = fieldnames(sessionInfo.conditionNames); % extract conditionNames (c0visStim c100visStim etc)
totalConds = numel(conditionFieldnames);

spikeTimes = [];
spikeTypeCount = [];
alltempMean =[];
totalTrials = numel(spikeClusterData.trialsForAnalysisSelected);

tempSpikes = spikeClusterData.rangeTimes; % times at which spikes occur
tempCodes = spikeClusterData.codes(:,1); % array with all codes for waveforms
totalCodes = numel(unique(tempCodes)); % total codes number
   
for condInt = 1:totalConds % for all conditions
    currentConName = conditionFieldnames{condInt}; % extract current condition name
    currentConDataID = sessionInfo.conditionNames.(currentConName); % extract ID number for this specific condition
    temp = sessionInfo.condData.codes; % array containing all condition codes - only first column out of 4 produced by Spike2 (numel = trials*conditions)
    temp = (temp == currentConDataID); % keep only the entries for the current condition, everything else is 0 
    
    temptimes = sessionInfo.condData.times;% load condition starting times
    temptimes = temptimes(temp);% keep only the starting times of the current condition
    temptimes = temptimes(spikeClusterData.trialsForAnalysisSelected);
    
    tempTotalTrials = numel(temptimes);
    
    for trialInt=1:tempTotalTrials % for every trial
        refTime = temptimes(trialInt); % real start of the condition in this trial
        startTime= refTime-sessionInfo.preTrialTime; % startTime could be seconds before the real condition start
        endTime = refTime+ sessionInfo.trialDuration + sessionInfo.preTrialTime; % end is the end of the recorded trial 
        iTrialTimeFrame = tempSpikes >= startTime & tempSpikes <= endTime; % array with numel = total spike number, 1 for each spike in this trial and cond, 0 for all others
        trialTime = tempSpikes(iTrialTimeFrame); % time at which the spikes occur in this trial and cond
        trialTime =  trialTime - refTime; % time at which the spikes occur in this trial and cond relative to the start of the condition
        trialCodes = tempCodes(iTrialTimeFrame); % extract codes that occur only in this condition an trial
        iConfinedTimeFrame = trialTime>(-sessionInfo.preTrialTime) & trialTime<(sessionInfo.trialDuration+sessionInfo.preTrialTime); % logical for all spikes occuring in the evokedActInterval or spontActInterval in this condition and trial
        realtime = trialTime(iConfinedTimeFrame);
        codes = trialCodes(iConfinedTimeFrame);
        spikeTimes.(currentConName){trialInt} = [realtime,codes]; % matrix containing evoked spike times for each condition and entire trial
                
    end
end
spikeClusterData.spikeTimes = spikeTimes

RefPerAndFalsePos_A1

%%
if exist(filenameSpikeClusterData,'file')
    warning('.spikeClusterData.mat file already exists.')
else
    spikeClusterData
    cfSCD = checkFields(spikeClusterData);
    if ~cfSCD            
         disp(['Saving ', experimentName, ' / ' , sessionName, ' .spikeClusterData.mat file'])
         save(filenameSpikeClusterData, 'spikeClusterData')
    end     
end   

